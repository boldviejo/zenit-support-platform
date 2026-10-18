class SocialComments::WebhookJob < ApplicationJob
  queue_as :default

  def perform(platform, entries)
    entries.each do |entry|
      SocialComments::IngestService.new(platform: platform, entry: entry.with_indifferent_access).perform
    end
  end
end
