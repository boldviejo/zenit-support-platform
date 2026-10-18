# Graph API base URL and token for the channel a comment arrived on: Instagram login
# channels use the Instagram graph, Facebook Pages (and Instagram linked to them) the Facebook graph.
module SocialComments::MetaGraph
  def self.base_url(channel)
    return "https://graph.instagram.com/#{GlobalConfigService.load('INSTAGRAM_API_VERSION', 'v22.0')}" if channel.is_a?(Channel::Instagram)

    "https://graph.facebook.com/#{GlobalConfigService.load('FACEBOOK_API_VERSION', 'v18.0')}"
  end

  def self.access_token(channel)
    channel.is_a?(Channel::Instagram) ? channel.access_token : channel.page_access_token
  end
end
