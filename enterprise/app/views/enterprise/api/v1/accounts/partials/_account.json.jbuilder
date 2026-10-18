json.billing_provider account.billing_provider
json.subscribed_features account.subscribed_features
json.comment_topic_options SocialComment.topics_for(account) if account.feature_enabled?('comment_moderation')
