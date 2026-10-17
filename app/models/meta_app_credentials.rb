# Resolves which Meta app an account talks to: the account's own app when it has one,
# otherwise the installation-wide app from Super Admin.
class MetaAppCredentials
  GLOBAL_VERIFY_TOKEN_KEYS = %w[FB_VERIFY_TOKEN IG_VERIFY_TOKEN INSTAGRAM_VERIFY_TOKEN].freeze

  def self.valid_verify_token?(token)
    return false if token.blank?

    AccountMetaApp.exists?(verify_token: token) ||
      GLOBAL_VERIFY_TOKEN_KEYS.any? { |key| ActiveSupport::SecurityUtils.secure_compare(token, GlobalConfigService.load(key, '').to_s) }
  end

  def initialize(account)
    @meta_app = account&.meta_app
  end

  def facebook_app_id
    own_facebook_app? ? @meta_app.facebook_app_id : GlobalConfigService.load('FB_APP_ID', '')
  end

  def facebook_app_secret
    own_facebook_app? ? @meta_app.facebook_app_secret : GlobalConfigService.load('FB_APP_SECRET', '')
  end

  def instagram_app_id
    own_instagram_app? ? @meta_app.instagram_app_id : GlobalConfigService.load('INSTAGRAM_APP_ID', nil)
  end

  def instagram_app_secret
    own_instagram_app? ? @meta_app.instagram_app_secret : GlobalConfigService.load('INSTAGRAM_APP_SECRET', nil)
  end

  private

  def own_facebook_app?
    @meta_app&.facebook_app_id.present?
  end

  def own_instagram_app?
    @meta_app&.instagram_app_id.present?
  end
end
