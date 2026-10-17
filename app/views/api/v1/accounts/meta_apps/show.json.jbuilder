frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')

json.facebook_app_id @meta_app.facebook_app_id
json.facebook_app_secret_configured @meta_app.facebook_app_secret.present?
json.instagram_app_id @meta_app.instagram_app_id
json.instagram_app_secret_configured @meta_app.instagram_app_secret.present?
json.verify_token @meta_app.verify_token
json.messenger_webhook_url "#{frontend_url}/bot"
json.instagram_webhook_url "#{frontend_url}/webhooks/instagram"
json.instagram_redirect_uri "#{frontend_url}/instagram/callback"
