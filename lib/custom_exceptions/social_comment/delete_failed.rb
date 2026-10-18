# frozen_string_literal: true

class CustomExceptions::SocialComment::DeleteFailed < CustomExceptions::Base
  def message
    I18n.t('errors.social_comments.delete_failed', error: @data[:error])
  end

  def http_status
    422
  end
end
