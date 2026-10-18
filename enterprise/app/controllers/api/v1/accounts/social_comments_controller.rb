class Api::V1::Accounts::SocialCommentsController < Api::V1::Accounts::BaseController
  RESULTS_PER_PAGE = 25
  DEFAULT_INSIGHTS_RANGE = 30.days
  EQUALITY_FILTERS = %i[decision sentiment platform].freeze

  before_action :ensure_comment_moderation_enabled
  before_action :check_authorization
  before_action :fetch_comment, only: [:update, :destroy]

  def index
    comments = filtered_comments
    @comments_count = comments.count
    @comments = comments.includes(:inbox).order(commented_at: :desc).page(params[:page]).per(RESULTS_PER_PAGE)
  end

  # Shadow mode: a reviewer confirms or corrects the proposed decision
  def update
    @comment.update!(reviewed_decision: params.require(:reviewed_decision), reviewed_by: Current.user, reviewed_at: Time.current)
  end

  def destroy
    SocialComments::DeleteService.new(comment: @comment, user: Current.user).perform
    render :update
  rescue CustomExceptions::SocialComment::DeleteFailed => e
    render_error_response(e)
  end

  def insights
    render json: SocialComments::InsightsService.new(account: Current.account, range: insights_range, time_zone: insights_time_zone).perform
  end

  private

  def ensure_comment_moderation_enabled
    head :forbidden unless Current.account.feature_enabled?('comment_moderation')
  end

  def check_authorization
    authorize(SocialComment)
  end

  def fetch_comment
    @comment = Current.account.social_comments.find(params[:id])
  end

  def filtered_comments
    comments = Current.account.social_comments.where(params.permit(*EQUALITY_FILTERS).to_h.compact_blank)
    comments = comments.where('topics @> ?', [params[:topic]].to_json) if params[:topic].present?
    comments = comments.classified.where(reviewed_decision: nil) if params[:review] == 'pending'
    comments
  end

  def insights_range
    since = params[:since].present? ? Time.zone.at(params[:since].to_i) : DEFAULT_INSIGHTS_RANGE.ago
    until_time = params[:until].present? ? Time.zone.at(params[:until].to_i) : Time.current
    since..until_time
  end

  def insights_time_zone
    ActiveSupport::TimeZone[params[:timezone_offset].to_f] || Time.zone
  end
end
