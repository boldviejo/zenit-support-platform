# Deletes a comment on Facebook or Instagram and records who deleted it; a nil user
# means it was deleted automatically.
class SocialComments::DeleteService
  pattr_initialize [:comment!, { user: nil }]

  def perform
    channel = comment.inbox.channel
    response = HTTParty.delete("#{SocialComments::MetaGraph.base_url(channel)}/#{comment.external_id}",
                               query: { access_token: SocialComments::MetaGraph.access_token(channel) })
    raise CustomExceptions::SocialComment::DeleteFailed.new(error: meta_error(response)) unless response.success?

    comment.update!(deleted_at: Time.current, deleted_by: user, delete_error: nil)
  end

  private

  def meta_error(response)
    response.parsed_response.is_a?(Hash) ? response.parsed_response.dig('error', 'message') : response.body
  end
end
