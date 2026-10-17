module Enterprise::Concerns::Message
  extend ActiveSupport::Concern

  # Same separator the dashboard puts between an agent's reply and their signature.
  SIGNATURE_DELIMITER = '--'.freeze

  included do
    has_one :call, dependent: :nullify
    has_many :message_reports, class_name: 'Captain::MessageReport', dependent: :destroy_async

    before_validation :append_captain_email_signature, on: :create, if: :captain_email_reply?
  end

  private

  def captain_email_reply?
    sender.is_a?(Captain::Assistant) && outgoing? && !private? && inbox&.email? && sender.message_signature.present?
  end

  def append_captain_email_signature
    self.content = "#{content.to_s.rstrip}\n\n#{SIGNATURE_DELIMITER}\n\n#{sender.message_signature}"
  end
end
