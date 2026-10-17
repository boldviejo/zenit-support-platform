# == Schema Information
#
# Table name: account_meta_apps
#
#  id                   :bigint           not null, primary key
#  facebook_app_secret  :string
#  instagram_app_secret :string
#  verify_token         :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  account_id           :bigint           not null
#  facebook_app_id      :string
#  instagram_app_id     :string
#
# Indexes
#
#  index_account_meta_apps_on_account_id    (account_id) UNIQUE
#  index_account_meta_apps_on_verify_token  (verify_token) UNIQUE
#
# Meta (Facebook / Instagram) app credentials owned by an account, so each tenant can
# connect its Pages and Instagram accounts through its own Meta app instead of the
# installation-wide one configured in Super Admin.
class AccountMetaApp < ApplicationRecord
  belongs_to :account

  if Chatwoot.encryption_configured?
    encrypts :facebook_app_secret
    encrypts :instagram_app_secret
  end

  has_secure_token :verify_token

  validates :account_id, uniqueness: true
  validates :facebook_app_secret, presence: true, if: -> { facebook_app_id.present? }
  validates :instagram_app_secret, presence: true, if: -> { instagram_app_id.present? }
end
