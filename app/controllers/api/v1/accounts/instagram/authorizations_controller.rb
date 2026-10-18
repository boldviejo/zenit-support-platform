class Api::V1::Accounts::Instagram::AuthorizationsController < Api::V1::Accounts::OauthAuthorizationController
  include InstagramConcern
  include Instagram::IntegrationHelper

  def create
    # https://developers.facebook.com/docs/instagram-platform/instagram-api-with-instagram-login/business-login#step-1--get-authorization
    redirect_url = instagram_client.auth_code.authorize_url(
      {
        redirect_uri: "#{base_url}/instagram/callback",
        scope: instagram_scopes.join(','),
        enable_fb_login: '0',
        force_reauth: 'true',
        response_type: 'code',
        state: generate_instagram_token(Current.account.id, params[:return_to])
      }
    )
    if redirect_url
      render json: { success: true, url: redirect_url }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def instagram_account
    Current.account
  end

  def instagram_scopes
    return REQUIRED_SCOPES unless Current.account.feature_enabled?('comment_moderation')

    REQUIRED_SCOPES + COMMENT_SCOPES
  end
end
