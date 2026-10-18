<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { dynamicTime } from 'shared/helpers/timeHelper';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import Label from 'dashboard/components-next/label/Label.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import Select from 'dashboard/components-next/select/Select.vue';
import { useCommentLabels } from './useCommentLabels';
import {
  DECISIONS,
  DECISION_COLORS,
  SENTIMENT_COLORS,
  PLATFORM_ICONS,
  DELETE_CONFIRM_TIMEOUT,
} from './constants';

const props = defineProps({
  comment: {
    type: Object,
    required: true,
  },
  canDelete: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['review', 'delete']);

const { t } = useI18n();
const { decisionLabel, sentimentLabel, platformLabel, topicLabel } =
  useCommentLabels();

const isClassified = computed(() => props.comment.status === 'classified');
const isReviewed = computed(() => !!props.comment.reviewed_decision);
const agreesWithReview = computed(
  () => props.comment.reviewed_decision === props.comment.decision
);
const confidence = computed(() =>
  Math.round((props.comment.confidence || 0) * 100)
);

const decisionOptions = computed(() =>
  DECISIONS.map(decision => ({
    value: decision,
    label: decisionLabel(decision),
  }))
);

const isDeleted = computed(() => !!props.comment.deleted_at);
const deletedLabel = computed(() =>
  props.comment.deleted_by_name
    ? t('SOCIAL_COMMENTS.REVIEW.DELETED_BY', {
        name: props.comment.deleted_by_name,
      })
    : t('SOCIAL_COMMENTS.REVIEW.DELETED_AUTOMATICALLY')
);

// Deleting is irreversible, so the first click only arms the button
const isConfirmingDelete = ref(false);
const onDeleteClick = () => {
  if (isConfirmingDelete.value) {
    isConfirmingDelete.value = false;
    emit('delete');
    return;
  }
  isConfirmingDelete.value = true;
  setTimeout(() => {
    isConfirmingDelete.value = false;
  }, DELETE_CONFIRM_TIMEOUT);
};

const reviewedDecision = computed({
  get: () => props.comment.reviewed_decision || '',
  set: decision => emit('review', decision),
});
</script>

<template>
  <article class="flex gap-3 py-4 border-b border-n-weak">
    <Icon
      :icon="PLATFORM_ICONS[comment.platform]"
      :aria-label="platformLabel(comment.platform)"
      class="size-5 mt-0.5 shrink-0 text-n-slate-11"
    />
    <div class="flex flex-col flex-1 min-w-0 gap-2">
      <header class="flex flex-wrap items-center gap-x-2 text-sm">
        <span class="font-medium text-n-slate-12">
          {{ comment.author_name }}
        </span>
        <span class="text-n-slate-11">{{ comment.inbox_name }}</span>
        <span class="rounded-full size-1 bg-n-slate-8" />
        <span class="text-n-slate-11">
          {{ dynamicTime(comment.commented_at) }}
        </span>
        <template v-if="comment.is_reply">
          <span class="rounded-full size-1 bg-n-slate-8" />
          <span class="text-n-slate-11">
            {{ t('SOCIAL_COMMENTS.REVIEW.REPLY') }}
          </span>
        </template>
        <a
          v-if="comment.post_permalink"
          :href="comment.post_permalink"
          target="_blank"
          rel="noopener noreferrer"
          class="text-n-blue-11 hover:underline"
        >
          {{ t('SOCIAL_COMMENTS.REVIEW.VIEW_POST') }}
        </a>
      </header>
      <p class="text-sm break-words whitespace-pre-line text-n-slate-12">
        {{ comment.message }}
      </p>
      <div v-if="isClassified" class="flex flex-wrap items-center gap-2">
        <Label
          :label="decisionLabel(comment.decision)"
          :color="DECISION_COLORS[comment.decision]"
          compact
        />
        <Label
          v-if="comment.sentiment"
          :label="sentimentLabel(comment.sentiment)"
          :color="SENTIMENT_COLORS[comment.sentiment]"
          compact
        />
        <Label
          v-for="topic in comment.topics"
          :key="topic"
          :label="topicLabel(topic)"
          compact
        />
        <span class="text-xs text-n-slate-11">
          {{ t('SOCIAL_COMMENTS.REVIEW.CONFIDENCE', { confidence }) }}
        </span>
      </div>
      <p v-else class="text-xs text-n-slate-11">
        {{
          comment.status === 'failed'
            ? t('SOCIAL_COMMENTS.REVIEW.FAILED')
            : t('SOCIAL_COMMENTS.REVIEW.CLASSIFYING')
        }}
      </p>
      <p v-if="comment.decision_reason" class="text-xs text-n-slate-11">
        {{ comment.decision_reason }}
      </p>
      <p
        v-if="comment.delete_error && !isDeleted"
        class="text-xs text-n-ruby-11"
      >
        {{ comment.delete_error }}
      </p>
    </div>
    <div v-if="isClassified" class="flex flex-col items-end gap-2 shrink-0">
      <Label v-if="isDeleted" :label="deletedLabel" color="ruby" compact />
      <Button
        v-else-if="canDelete"
        :label="
          isConfirmingDelete
            ? t('SOCIAL_COMMENTS.REVIEW.CONFIRM_DELETE')
            : t('SOCIAL_COMMENTS.REVIEW.DELETE')
        "
        icon="i-lucide-trash-2"
        size="xs"
        color="ruby"
        :variant="isConfirmingDelete ? 'solid' : 'faded'"
        @click="onDeleteClick"
      />
      <Label
        v-if="isReviewed"
        :label="
          t('SOCIAL_COMMENTS.REVIEW.REVIEWED_AS', {
            decision: decisionLabel(comment.reviewed_decision),
          })
        "
        :color="agreesWithReview ? 'teal' : 'amber'"
        compact
      />
      <Button
        v-else
        :label="t('SOCIAL_COMMENTS.REVIEW.MARK_CORRECT')"
        icon="i-lucide-check"
        size="xs"
        color="teal"
        variant="faded"
        @click="emit('review', comment.decision)"
      />
      <Select
        v-model="reviewedDecision"
        :options="decisionOptions"
        :placeholder="t('SOCIAL_COMMENTS.REVIEW.CHANGE_DECISION')"
        :aria-label="t('SOCIAL_COMMENTS.REVIEW.CHANGE_DECISION')"
        class="w-40"
      />
    </div>
  </article>
</template>
