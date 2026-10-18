# Stores the comments of one Meta webhook entry (a Page `feed` change or an Instagram
# `comments` change) for every connected inbox whose account moderates comments, and
# queues their classification.
# Payloads: https://developers.facebook.com/docs/graph-api/webhooks/reference/page/#feed
#           https://developers.facebook.com/docs/instagram-platform/webhooks#comments
class SocialComments::IngestService
  FACEBOOK_COMMENT_VERBS = %w[add edited].freeze

  pattr_initialize [:platform!, :entry!]

  def perform
    channels.each do |channel|
      next unless channel.account.feature_enabled?('comment_moderation')

      comment_values.each { |value| store(channel, value) }
    end
  end

  private

  def facebook?
    platform == 'facebook'
  end

  def channels
    return Channel::FacebookPage.where(page_id: entry[:id]) if facebook?

    Channel::Instagram.where(instagram_id: entry[:id]) + Channel::FacebookPage.where(instagram_id: entry[:id])
  end

  # Comments written by the page / account itself are not moderated
  def comment_values
    Array(entry[:changes]).filter_map do |change|
      value = change[:value]
      next unless comment_change?(change[:field], value)
      next if value.dig(:from, :id).to_s == entry[:id].to_s

      value
    end
  end

  def comment_change?(field, value)
    return field == 'comments' unless facebook?

    field == 'feed' && value[:item] == 'comment' && FACEBOOK_COMMENT_VERBS.include?(value[:verb])
  end

  def store(channel, value)
    attributes = facebook? ? facebook_attributes(value) : instagram_attributes(value)
    comment = channel.account.social_comments.find_or_initialize_by(platform: platform, external_id: attributes.delete(:external_id))
    comment.assign_attributes(attributes.merge(inbox: channel.inbox))
    return unless comment.new_record? || comment.message_changed?

    comment.assign_attributes(post_attributes(channel, comment.post_external_id)) if comment.new_record?
    comment.status = :pending
    comment.save!
    SocialComments::ClassifyJob.perform_later(comment)
  end

  def facebook_attributes(value)
    {
      external_id: value[:comment_id],
      # Top-level comments have the post as parent
      parent_external_id: (value[:parent_id] if value[:parent_id] != value[:post_id]),
      post_external_id: value[:post_id],
      post_permalink: value.dig(:post, :permalink_url),
      author_external_id: value.dig(:from, :id),
      author_name: value.dig(:from, :name),
      message: value[:message],
      commented_at: Time.zone.at(value[:created_time] || entry[:time])
    }
  end

  def instagram_attributes(value)
    {
      external_id: value[:id],
      parent_external_id: value[:parent_id],
      post_external_id: value.dig(:media, :id),
      author_external_id: value.dig(:from, :id),
      author_name: value.dig(:from, :username),
      message: value[:text],
      commented_at: Time.zone.at(entry[:time])
    }
  end

  # Caption and permalink give the classifier context and reviewers a link to the post
  def post_attributes(channel, post_id)
    context = SocialComments::PostContextService.new(channel: channel, platform: platform, post_id: post_id).perform
    { post_caption: context[:caption], post_permalink: context[:permalink] }.compact
  end
end
