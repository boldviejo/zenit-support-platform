class Api::V1::Accounts::MetaAppsController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  before_action :set_meta_app

  def show; end

  def update
    @meta_app.update!(meta_app_params)
    render :show
  end

  private

  def set_meta_app
    @meta_app = Current.account.meta_app || Current.account.build_meta_app
  end

  # Secrets are write-only: the dashboard sends them only when the admin types a new one
  def meta_app_params
    params.require(:meta_app)
          .permit(:facebook_app_id, :facebook_app_secret, :instagram_app_id, :instagram_app_secret)
          .reject { |key, value| key.end_with?('_secret') && value.blank? }
  end

  def check_authorization
    authorize(AccountMetaApp)
  end
end
