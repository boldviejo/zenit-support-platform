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

// Needed to receive Page post comments for comment moderation
export const FACEBOOK_COMMENT_SCOPES = ['pages_read_user_content'];

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
