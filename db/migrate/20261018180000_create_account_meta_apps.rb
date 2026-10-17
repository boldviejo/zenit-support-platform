class CreateAccountMetaApps < ActiveRecord::Migration[7.1]
  def change
    create_table :account_meta_apps do |t|
      t.references :account, null: false, index: { unique: true }
      t.string :facebook_app_id
      t.string :facebook_app_secret
      t.string :instagram_app_id
      t.string :instagram_app_secret
      t.string :verify_token, null: false
      t.timestamps
    end
    add_index :account_meta_apps, :verify_token, unique: true
  end
end
