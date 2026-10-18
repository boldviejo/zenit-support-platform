module Instagram::IntegrationHelper
  REQUIRED_SCOPES = %w[instagram_business_basic instagram_business_manage_messages].freeze
  COMMENT_SCOPES = %w[instagram_business_manage_comments].freeze

  # Generates a signed JWT token for Instagram integration
  #
  # @param account_id [Integer] The account ID to encode in the token
  # @param return_to [String, nil] Optional onboarding return hint
  # @return [String, nil] The encoded JWT token or nil if client secret is missing
  def generate_instagram_token(account_id, return_to = nil)
    secret = instagram_app_secret_for(account_id)
    return if secret.blank?

    JWT.encode(token_payload(account_id, return_to), secret, 'HS256')
  rescue StandardError => e
    Rails.logger.error("Failed to generate Instagram token: #{e.message}")
    nil
  end

  def token_payload(account_id, return_to = nil)
    payload = { sub: account_id, iat: Time.current.to_i }
    payload[:return_to] = return_to if return_to.present?
    payload
  end

  # Verifies and decodes a Instagram JWT token
  #
  # @param token [String] The JWT token to verify
  # @return [Integer, nil] The account ID from the token or nil if invalid
  def verify_instagram_token(token)
    decode_verified_token(token)&.dig('sub')
  end

  # Reads the onboarding return hint from a Instagram JWT token, if present.
  def instagram_token_return_to(token)
    decode_verified_token(token)&.dig('return_to')
  end

  private

  # The token is signed with the Instagram secret of the account's Meta app, so the
  # unverified account id only picks the secret; the signature is then verified with it.
  def decode_verified_token(token)
    return if token.blank?

    account_id = JWT.decode(token, nil, false).first['sub']
    secret = instagram_app_secret_for(account_id)
    return if secret.blank?

    decode_token(token, secret)
  rescue JWT::DecodeError => e
    Rails.logger.error("Unexpected error verifying Instagram token: #{e.message}")
    nil
  end

  def instagram_app_secret_for(account_id)
    MetaAppCredentials.new(Account.find_by(id: account_id)).instagram_app_secret
  end

  def decode_token(token, secret)
    JWT.decode(token, secret, true, {
                 algorithm: 'HS256',
                 verify_expiration: true
               }).first
  rescue StandardError => e
    Rails.logger.error("Unexpected error verifying Instagram token: #{e.message}")
    nil
  end
end
