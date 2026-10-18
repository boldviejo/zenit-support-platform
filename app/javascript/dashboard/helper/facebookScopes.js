export const FACEBOOK_PAGE_SCOPES = [
  'pages_manage_metadata',
  'business_management',
  'pages_messaging',
  'pages_show_list',
  'pages_read_engagement',
];

export const INSTAGRAM_SCOPES = [
  'instagram_basic',
  'instagram_manage_messages',
];

// Deleting Page comments needs the "Manage everything on your Page" use case on the Meta app
export const FACEBOOK_COMMENT_SCOPES = ['pages_manage_engagement'];

export const buildFacebookLoginScopes = ({
  includeInstagramScopes = false,
  includeCommentScopes = false,
} = {}) => {
  const scopes = [...FACEBOOK_PAGE_SCOPES];
  if (includeInstagramScopes) {
    scopes.push(...INSTAGRAM_SCOPES);
  }
  if (includeCommentScopes) {
    scopes.push(...FACEBOOK_COMMENT_SCOPES);
  }
  return scopes.join(',');
};
