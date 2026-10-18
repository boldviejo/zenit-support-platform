class CreateSocialComments < ActiveRecord::Migration[7.1]
  def change
    create_table :social_comments do |t|
      t.references :account, null: false, index: false
      t.references :inbox, null: false
      t.integer :platform, null: false
      t.string :external_id, null: false
      t.string :parent_external_id, :post_external_id, :post_permalink, :author_external_id, :author_name
      t.text :post_caption, :message, :decision_reason
      t.datetime :commented_at, null: false
      t.integer :status, null: false, default: 0
      t.string :decision, :sentiment, :language, :llm_model, :reviewed_decision
      t.float :confidence, :sentiment_score
      t.jsonb :topics, null: false, default: []
      t.boolean :mentions_someone, null: false, default: false
      t.datetime :classified_at, :reviewed_at
      t.bigint :reviewed_by_id, index: true
      t.timestamps
    end
    add_index :social_comments, [:account_id, :platform, :external_id], unique: true, name: 'index_social_comments_on_account_platform_external_id'
    add_index :social_comments, [:account_id, :commented_at]
  end
end
