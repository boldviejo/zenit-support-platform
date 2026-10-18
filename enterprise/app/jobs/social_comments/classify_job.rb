class SocialComments::ClassifyJob < ApplicationJob
  queue_as :low
  retry_on StandardError, wait: :polynomially_longer, attempts: 3 do |job, error|
    comment = job.arguments.first
    comment.update!(status: :failed)
    ChatwootExceptionTracker.new(error, account: comment.account).capture_exception
  end

  def perform(comment)
    Captain::Llm::SocialCommentClassifierService.new(comment: comment).perform
  end
end
