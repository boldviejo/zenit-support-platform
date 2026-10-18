json.meta do
  json.count @comments_count
  json.current_page @comments.current_page
end
json.payload do
  json.array! @comments, partial: 'api/v1/accounts/social_comments/social_comment', as: :social_comment
end
