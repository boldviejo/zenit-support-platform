module Enterprise::Webhooks::InstagramController
  private

  def process_comment_entries(entries)
    SocialComments::WebhookJob.perform_later('instagram', entries)
  end
end
