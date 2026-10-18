module Enterprise::Integrations::Facebook::WebhookServer
  private

  def process_feed_entries(entries)
    SocialComments::WebhookJob.perform_later('facebook', entries)
  end
end
