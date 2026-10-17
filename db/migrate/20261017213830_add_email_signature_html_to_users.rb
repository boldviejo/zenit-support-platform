class AddEmailSignatureHtmlToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :email_signature_html, :text
  end
end
