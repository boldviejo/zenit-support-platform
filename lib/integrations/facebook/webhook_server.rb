# Messenger webhook endpoint. The gem's server only dispatches `messaging` events, so Page
# feed changes (comments on posts) are handed to an extension point here.
class Integrations::Facebook::WebhookServer < Facebook::Messenger::Server
  private

  def trigger(events)
    super

    feed_entries = events['entry'].select { |entry| entry['changes'].present? }
    process_feed_entries(feed_entries) if feed_entries.any?
  end

  # Enterprise ingests Page comments from these entries
  def process_feed_entries(_entries); end
end

Integrations::Facebook::WebhookServer.prepend_mod_with('Integrations::Facebook::WebhookServer')
