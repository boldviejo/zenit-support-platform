# Fetches the caption and permalink of the post a comment belongs to, cached per post.
# Missing context only makes the classification less informed, so API errors are logged
# and an empty context is returned.
class SocialComments::PostContextService
  CACHE_TTL = 1.hour

  pattr_initialize [:channel!, :platform!, :post_id!]

  def perform
    return {} if post_id.blank?

    Rails.cache.fetch("social_comments:post_context:#{platform}:#{post_id}", expires_in: CACHE_TTL, skip_nil: true) { fetch } || {}
  end

  private

  def fetch
    return facebook_post if platform == 'facebook'

    instagram_media
  rescue StandardError => e
    Rails.logger.warn("[SocialComments] Could not fetch #{platform} post #{post_id}: #{e.message}")
    nil
  end

  def facebook_post
    post = Koala::Facebook::API.new(channel.page_access_token).get_object(post_id, fields: 'message,permalink_url')
    { caption: post['message'], permalink: post['permalink_url'] }
  end

  def instagram_media
    response = HTTParty.get("#{SocialComments::MetaGraph.base_url(channel)}/#{post_id}",
                            query: { fields: 'caption,permalink', access_token: SocialComments::MetaGraph.access_token(channel) })
    raise response.body unless response.success?

    { caption: response['caption'], permalink: response['permalink'] }
  end
end
