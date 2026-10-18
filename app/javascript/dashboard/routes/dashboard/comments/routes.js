import { FEATURE_FLAGS } from 'dashboard/featureFlags';
import { frontendURL } from '../../../helper/URLHelper';
import CommentsReview from './pages/CommentsReview.vue';
import CommentsInsights from './pages/CommentsInsights.vue';
import CommentsSettings from './pages/CommentsSettings.vue';

const meta = {
  permissions: ['administrator', 'agent'],
  featureFlag: FEATURE_FLAGS.COMMENT_MODERATION,
};

export const routes = [
  {
    path: frontendURL('accounts/:accountId/comments'),
    name: 'comments_review_index',
    component: CommentsReview,
    meta,
  },
  {
    path: frontendURL('accounts/:accountId/comments/insights'),
    name: 'comments_insights_index',
    component: CommentsInsights,
    meta,
  },
  {
    path: frontendURL('accounts/:accountId/comments/settings'),
    name: 'comments_settings_index',
    component: CommentsSettings,
    meta: { ...meta, permissions: ['administrator'] },
  },
];
