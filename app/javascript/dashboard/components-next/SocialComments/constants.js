export const DECISIONS = ['remove', 'answer', 'escalate', 'ignore'];
export const SENTIMENTS = ['positive', 'neutral', 'negative'];
export const PLATFORMS = ['facebook', 'instagram'];

export const DECISION_COLORS = {
  remove: 'ruby',
  answer: 'blue',
  escalate: 'amber',
  ignore: 'slate',
};

export const SENTIMENT_COLORS = {
  positive: 'teal',
  neutral: 'slate',
  negative: 'ruby',
};

// Chart colors use the same design tokens as the label colors above
export const SENTIMENT_CHART_COLORS = {
  positive: 'rgb(var(--teal-9))',
  neutral: 'rgb(var(--slate-8))',
  negative: 'rgb(var(--ruby-9))',
};

export const DECISION_CHART_COLORS = {
  remove: 'rgb(var(--ruby-9))',
  answer: 'rgb(var(--blue-9))',
  escalate: 'rgb(var(--amber-9))',
  ignore: 'rgb(var(--slate-8))',
};

export const PLATFORM_ICONS = {
  facebook: 'i-ri-facebook-circle-fill',
  instagram: 'i-ri-instagram-line',
};

export const INSIGHTS_RANGES = [7, 30, 90];
export const RESULTS_PER_PAGE = 25;
export const DELETE_CONFIRM_TIMEOUT = 4000;
export const AUTO_DELETE_THRESHOLDS = [0.8, 0.9, 0.95];
export const DEFAULT_AUTO_DELETE_THRESHOLD = 0.9;
