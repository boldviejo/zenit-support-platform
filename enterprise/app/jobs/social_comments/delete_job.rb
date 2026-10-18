class SocialComments::DeleteJob < ApplicationJob
  queue_as :default

  def perform(comment)
    SocialComments::DeleteService.new(comment: comment).perform
  rescue CustomExceptions::SocialComment::DeleteFailed => e
    comment.update!(delete_error: e.message)
  end
end
