import { useI18n } from 'vue-i18n';

// Labels for the values the classifier returns. Custom topics added by the account
// have no translation and are shown as typed.
export function useCommentLabels() {
  const { t } = useI18n();

  const decisionLabels = () => ({
    remove: t('SOCIAL_COMMENTS.DECISIONS.REMOVE'),
    answer: t('SOCIAL_COMMENTS.DECISIONS.ANSWER'),
    escalate: t('SOCIAL_COMMENTS.DECISIONS.ESCALATE'),
    ignore: t('SOCIAL_COMMENTS.DECISIONS.IGNORE'),
  });

  const sentimentLabels = () => ({
    positive: t('SOCIAL_COMMENTS.SENTIMENTS.POSITIVE'),
    neutral: t('SOCIAL_COMMENTS.SENTIMENTS.NEUTRAL'),
    negative: t('SOCIAL_COMMENTS.SENTIMENTS.NEGATIVE'),
  });

  const platformLabels = () => ({
    facebook: t('SOCIAL_COMMENTS.PLATFORMS.FACEBOOK'),
    instagram: t('SOCIAL_COMMENTS.PLATFORMS.INSTAGRAM'),
  });

  const topicLabels = () => ({
    product: t('SOCIAL_COMMENTS.TOPICS.PRODUCT'),
    shipping: t('SOCIAL_COMMENTS.TOPICS.SHIPPING'),
    order_status: t('SOCIAL_COMMENTS.TOPICS.ORDER_STATUS'),
    sizing: t('SOCIAL_COMMENTS.TOPICS.SIZING'),
    pricing: t('SOCIAL_COMMENTS.TOPICS.PRICING'),
    quality: t('SOCIAL_COMMENTS.TOPICS.QUALITY'),
    customer_service: t('SOCIAL_COMMENTS.TOPICS.CUSTOMER_SERVICE'),
    availability: t('SOCIAL_COMMENTS.TOPICS.AVAILABILITY'),
    returns: t('SOCIAL_COMMENTS.TOPICS.RETURNS'),
    other: t('SOCIAL_COMMENTS.TOPICS.OTHER'),
  });

  const decisionLabel = decision => decisionLabels()[decision];
  const sentimentLabel = sentiment => sentimentLabels()[sentiment];
  const platformLabel = platform => platformLabels()[platform];
  const topicLabel = topic => topicLabels()[topic] || topic;

  return { decisionLabel, sentimentLabel, platformLabel, topicLabel };
}
