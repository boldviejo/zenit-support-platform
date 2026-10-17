// An account can run Facebook / Instagram through its own Meta app (Settings →
// Account). When it has none, the installation app from Super Admin is used.
export const getFacebookAppId = account =>
  account?.meta_app?.facebook_app_id || window.chatwootConfig?.fbAppId;

export const getInstagramAppId = account =>
  account?.meta_app?.instagram_app_id || window.chatwootConfig?.instagramAppId;
