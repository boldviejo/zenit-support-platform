class AddDeletionToSocialComments < ActiveRecord::Migration[7.1]
  def change
    add_column :social_comments, :deleted_at, :datetime
    add_column :social_comments, :deleted_by_id, :bigint
    add_column :social_comments, :delete_error, :text
  end
end
