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

    # Instagram login channels use the Instagram graph; Instagram linked to a Page uses the Facebook graph
    if channel.is_a?(Channel::Instagram)
      instagram_media(instagram_login_url, channel.access_token)
    else
      instagram_media(facebook_graph_url, channel.page_access_token)
    end
  rescue StandardError => e
    Rails.logger.warn("[SocialComments] Could not fetch #{platform} post #{post_id}: #{e.message}")
    nil
  end

  def facebook_post
    post = Koala::Facebook::API.new(channel.page_access_token).get_object(post_id, fields: 'message,permalink_url')
    { caption: post['message'], permalink: post['permalink_url'] }
  end

  def instagram_media(base_url, access_token)
    response = HTTParty.get("#{base_url}/#{post_id}", query: { fields: 'caption,permalink', access_token: access_token })
    raise response.body unless response.success?

    { caption: response['caption'], permalink: response['permalink'] }
  end

  def instagram_login_url
    "https://graph.instagram.com/#{GlobalConfigService.load('INSTAGRAM_API_VERSION', 'v22.0')}"
  end

  def facebook_graph_url
    "https://graph.facebook.com/#{GlobalConfigService.load('FACEBOOK_API_VERSION', 'v18.0')}"
  end
end
