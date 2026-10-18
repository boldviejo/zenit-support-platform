<script setup>
import { computed, ref, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useAccount } from 'dashboard/composables/useAccount';
import { useAdmin } from 'dashboard/composables/useAdmin';
import SocialCommentsAPI from 'dashboard/api/socialComments';
import CommentListItem from 'dashboard/components-next/SocialComments/CommentListItem.vue';
import { useCommentLabels } from 'dashboard/components-next/SocialComments/useCommentLabels';
import {
  DECISIONS,
  SENTIMENTS,
  PLATFORMS,
  RESULTS_PER_PAGE,
  DEFAULT_AUTO_DELETE_THRESHOLD,
} from 'dashboard/components-next/SocialComments/constants';
import Select from 'dashboard/components-next/select/Select.vue';
import PaginationFooter from 'dashboard/components-next/pagination/PaginationFooter.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

const { t } = useI18n();
const { decisionLabel, sentimentLabel, platformLabel, topicLabel } =
  useCommentLabels();

const { currentAccount } = useAccount();
const { isAdmin } = useAdmin();

const modeDescription = computed(() => {
  const settings = currentAccount.value?.settings || {};
  if (!settings.comment_auto_delete) return t('SOCIAL_COMMENTS.SHADOW_MODE');

  const threshold =
    settings.comment_auto_delete_threshold || DEFAULT_AUTO_DELETE_THRESHOLD;
  return t('SOCIAL_COMMENTS.AUTO_DELETE_MODE', {
    confidence: Math.round(threshold * 100),
  });
});

const comments = ref([]);
const totalCount = ref(0);
const currentPage = ref(1);
const isFetching = ref(true);

const filters = ref({
  review: 'pending',
  decision: '',
  sentiment: '',
  platform: '',
  topic: '',
});

const topics = computed(
  () => currentAccount.value?.comment_topic_options || []
);

const withAllOption = (label, options) => [{ value: '', label }, ...options];

const filterSelects = computed(() => [
  {
    key: 'review',
    options: [
      {
        value: 'pending',
        label: t('SOCIAL_COMMENTS.REVIEW.FILTERS.PENDING_REVIEW'),
      },
      { value: '', label: t('SOCIAL_COMMENTS.REVIEW.FILTERS.ALL_REVIEWS') },
    ],
  },
  {
    key: 'decision',
    options: withAllOption(
      t('SOCIAL_COMMENTS.REVIEW.FILTERS.ALL_DECISIONS'),
      DECISIONS.map(value => ({ value, label: decisionLabel(value) }))
    ),
  },
  {
    key: 'sentiment',
    options: withAllOption(
      t('SOCIAL_COMMENTS.REVIEW.FILTERS.ALL_SENTIMENTS'),
      SENTIMENTS.map(value => ({ value, label: sentimentLabel(value) }))
    ),
  },
  {
    key: 'platform',
    options: withAllOption(
      t('SOCIAL_COMMENTS.REVIEW.FILTERS.ALL_PLATFORMS'),
      PLATFORMS.map(value => ({ value, label: platformLabel(value) }))
    ),
  },
  ...(topics.value.length
    ? [
        {
          key: 'topic',
          options: withAllOption(
            t('SOCIAL_COMMENTS.REVIEW.FILTERS.ALL_TOPICS'),
            topics.value.map(value => ({ value, label: topicLabel(value) }))
          ),
        },
      ]
    : []),
]);

const fetchComments = async () => {
  isFetching.value = true;
  try {
    const params = Object.fromEntries(
      Object.entries(filters.value).filter(([, value]) => value)
    );
    const { data } = await SocialCommentsAPI.get({
      ...params,
      page: currentPage.value,
    });
    comments.value = data.payload;
    totalCount.value = data.meta.count;
  } catch {
    useAlert(t('SOCIAL_COMMENTS.REVIEW.FETCH_ERROR'));
  } finally {
    isFetching.value = false;
  }
};

const replaceComment = updated => {
  comments.value = comments.value.map(item =>
    item.id === updated.id ? updated : item
  );
};

const onReview = async (comment, decision) => {
  try {
    const { data } = await SocialCommentsAPI.review(comment.id, decision);
    replaceComment(data);
  } catch {
    useAlert(t('SOCIAL_COMMENTS.REVIEW.REVIEW_ERROR'));
  }
};

const onDelete = async comment => {
  try {
    const { data } = await SocialCommentsAPI.delete(comment.id);
    replaceComment(data);
  } catch (error) {
    useAlert(
      error?.response?.data?.message || t('SOCIAL_COMMENTS.REVIEW.DELETE_ERROR')
    );
  }
};

const onPageChange = page => {
  currentPage.value = page;
  fetchComments();
};

watch(
  filters,
  () => {
    currentPage.value = 1;
    fetchComments();
  },
  { deep: true }
);

onMounted(fetchComments);
</script>

<template>
  <section class="flex flex-col w-full h-full overflow-hidden bg-n-surface-1">
    <header class="px-6 pt-6 pb-4 border-b shrink-0 border-n-weak">
      <h1 class="text-xl font-medium text-n-slate-12">
        {{ t('SOCIAL_COMMENTS.REVIEW.HEADER') }}
      </h1>
      <p class="mt-1 text-sm text-n-slate-11">
        {{ modeDescription }}
        {{ t('SOCIAL_COMMENTS.REVIEW.DESCRIPTION') }}
      </p>
      <div class="flex flex-wrap gap-2 mt-4">
        <Select
          v-for="filter in filterSelects"
          :key="filter.key"
          v-model="filters[filter.key]"
          :options="filter.options"
          :aria-label="filter.options[0].label"
          class="w-48"
        />
      </div>
    </header>
    <main class="flex-1 px-6 overflow-y-auto">
      <div v-if="isFetching" class="flex items-center justify-center py-16">
        <Spinner :size="24" />
      </div>
      <p
        v-else-if="!comments.length"
        class="py-16 text-base text-center text-n-slate-11"
      >
        {{ t('SOCIAL_COMMENTS.REVIEW.EMPTY_STATE') }}
      </p>
      <template v-else>
        <CommentListItem
          v-for="comment in comments"
          :key="comment.id"
          :comment="comment"
          :can-delete="isAdmin"
          @review="decision => onReview(comment, decision)"
          @delete="onDelete(comment)"
        />
      </template>
    </main>
    <footer v-if="comments.length" class="sticky bottom-0 shrink-0">
      <PaginationFooter
        :current-page="currentPage"
        :total-items="totalCount"
        :items-per-page="RESULTS_PER_PAGE"
        @update:current-page="onPageChange"
      />
    </footer>
  </section>
</template>
