# == Schema Information
#
# Table name: social_comments
#
#  id                 :bigint           not null, primary key
#  author_name        :string
#  classified_at      :datetime
#  commented_at       :datetime         not null
#  confidence         :float
#  decision           :string
#  decision_reason    :text
#  delete_error       :text
#  deleted_at         :datetime
#  language           :string
#  llm_model          :string
#  mentions_someone   :boolean          default(FALSE), not null
#  message            :text
#  platform           :integer          not null
#  post_caption       :text
#  post_permalink     :string
#  reviewed_at        :datetime
#  reviewed_decision  :string
#  sentiment          :string
#  sentiment_score    :float
#  status             :integer          default("pending"), not null
#  topics             :jsonb            not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  author_external_id :string
#  deleted_by_id      :bigint
#  external_id        :string           not null
#  inbox_id           :bigint           not null
#  parent_external_id :string
#  post_external_id   :string
#  reviewed_by_id     :bigint
#
# Indexes
#
#  index_social_comments_on_account_id_and_commented_at   (account_id,commented_at)
#  index_social_comments_on_account_platform_external_id  (account_id,platform,external_id) UNIQUE
#  index_social_comments_on_inbox_id                      (inbox_id)
#  index_social_comments_on_reviewed_by_id                (reviewed_by_id)
#
# A public comment left on a connected Facebook Page post or Instagram media, with the
# shadow-mode moderation decision the LLM proposes for it.
class SocialComment < ApplicationRecord
  DECISIONS = %w[remove answer escalate ignore].freeze
  SENTIMENTS = %w[positive neutral negative].freeze
  DEFAULT_TOPICS = %w[product shipping order_status sizing pricing quality customer_service availability returns].freeze
  OTHER_TOPIC = 'other'.freeze
  DEFAULT_AUTO_DELETE_THRESHOLD = 0.9

  belongs_to :account
  belongs_to :inbox
  belongs_to :reviewed_by, class_name: 'User', optional: true
  belongs_to :deleted_by, class_name: 'User', optional: true

  enum :platform, { facebook: 0, instagram: 1 }
  enum :status, { pending: 0, classified: 1, failed: 2 }

  validates :external_id, presence: true, uniqueness: { scope: [:account_id, :platform] }
  validates :commented_at, presence: true
  validates :decision, inclusion: { in: DECISIONS }, allow_nil: true
  validates :reviewed_decision, inclusion: { in: DECISIONS }, allow_nil: true
  validates :sentiment, inclusion: { in: SENTIMENTS }, allow_nil: true

  scope :in_range, ->(range) { where(commented_at: range) }

  # Comments the account lets the AI delete on its own: proposed removals above its confidence threshold
  def auto_delete?
    return false unless remove? && deleted_at.nil? && ActiveModel::Type::Boolean.new.cast(account.comment_auto_delete)

    confidence.to_f >= (account.comment_auto_delete_threshold || DEFAULT_AUTO_DELETE_THRESHOLD).to_f
  end

  def remove?
    decision == 'remove'
  end

  def self.topics_for(account)
    account.comment_topics.presence || DEFAULT_TOPICS
  end
end
