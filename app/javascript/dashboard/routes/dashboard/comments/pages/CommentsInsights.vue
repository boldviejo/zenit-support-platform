<script setup>
import { computed, ref, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { format, parseISO, getUnixTime, subDays } from 'date-fns';
import { useAlert } from 'dashboard/composables';
import SocialCommentsAPI from 'dashboard/api/socialComments';
import { useCommentLabels } from 'dashboard/components-next/SocialComments/useCommentLabels';
import {
  DECISIONS,
  SENTIMENTS,
  SENTIMENT_CHART_COLORS,
  DECISION_CHART_COLORS,
  INSIGHTS_RANGES,
} from 'dashboard/components-next/SocialComments/constants';
import Select from 'dashboard/components-next/select/Select.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import BarChart from 'shared/components/charts/BarChart.vue';
import PercentageChart from 'shared/components/charts/PercentageChart.vue';

const TIMELINE_HEIGHT = 260;
const TOPIC_BAR_HEIGHT = 10;

const { t } = useI18n();
const { decisionLabel, sentimentLabel, topicLabel } = useCommentLabels();

const rangeDays = ref(String(INSIGHTS_RANGES[1]));
const insights = ref(null);
const isFetching = ref(true);

const rangeOptions = computed(() =>
  INSIGHTS_RANGES.map(days => ({
    value: String(days),
    label: t('SOCIAL_COMMENTS.INSIGHTS.RANGE', { days }),
  }))
);

const classifiedCount = computed(() =>
  SENTIMENTS.reduce(
    (sum, sentiment) => sum + insights.value.sentiments[sentiment],
    0
  )
);

const percentOf = (value, total) =>
  total ? Math.round((value / total) * 100) : 0;

const kpis = computed(() => {
  const { total, sentiments, decisions, review } = insights.value;
  return [
    { key: 'total', label: t('SOCIAL_COMMENTS.INSIGHTS.TOTAL'), value: total },
    {
      key: 'negative',
      label: t('SOCIAL_COMMENTS.INSIGHTS.NEGATIVE'),
      value: `${percentOf(sentiments.negative, classifiedCount.value)}%`,
    },
    {
      key: 'answer',
      label: t('SOCIAL_COMMENTS.INSIGHTS.TO_ANSWER'),
      value: decisions.answer,
    },
    {
      key: 'remove',
      label: t('SOCIAL_COMMENTS.INSIGHTS.TO_REMOVE'),
      value: decisions.remove,
    },
    {
      key: 'agreement',
      label: t('SOCIAL_COMMENTS.INSIGHTS.AGREEMENT'),
      value: review.reviewed
        ? `${percentOf(review.agreed, review.reviewed)}%`
        : '—',
      hint: review.reviewed
        ? t('SOCIAL_COMMENTS.INSIGHTS.AGREEMENT_HINT', review)
        : t('SOCIAL_COMMENTS.INSIGHTS.NOT_REVIEWED'),
    },
  ];
});

const sentimentSegments = counts =>
  SENTIMENTS.map(sentiment => ({
    id: sentiment,
    label: sentimentLabel(sentiment),
    value: counts[sentiment],
    color: SENTIMENT_CHART_COLORS[sentiment],
  }));

const sentimentBalance = computed(() => ({
  segments: sentimentSegments(insights.value.sentiments),
}));

const decisionBreakdown = computed(() => ({
  segments: DECISIONS.map(decision => ({
    id: decision,
    label: decisionLabel(decision),
    value: insights.value.decisions[decision],
    color: DECISION_CHART_COLORS[decision],
  })),
}));

const timelineChart = computed(() => ({
  categories: insights.value.timeline.map(day =>
    format(parseISO(day.date), 'dd MMM')
  ),
  series: SENTIMENTS.map(sentiment => ({
    id: sentiment,
    label: sentimentLabel(sentiment),
    color: SENTIMENT_CHART_COLORS[sentiment],
    data: insights.value.timeline.map(day => day[sentiment]),
  })),
}));

const fetchInsights = async () => {
  isFetching.value = true;
  try {
    const { data } = await SocialCommentsAPI.insights({
      since: getUnixTime(subDays(new Date(), Number(rangeDays.value))),
      timezone_offset: -new Date().getTimezoneOffset() / 60,
    });
    insights.value = data;
  } catch {
    useAlert(t('SOCIAL_COMMENTS.INSIGHTS.FETCH_ERROR'));
  } finally {
    isFetching.value = false;
  }
};

watch(rangeDays, fetchInsights);
onMounted(fetchInsights);
</script>

<template>
  <section class="flex flex-col w-full h-full overflow-y-auto bg-n-surface-1">
    <header
      class="flex flex-wrap items-start justify-between gap-4 px-6 pt-6 pb-4"
    >
      <div>
        <h1 class="text-xl font-medium text-n-slate-12">
          {{ t('SOCIAL_COMMENTS.INSIGHTS.HEADER') }}
        </h1>
        <p class="mt-1 text-sm text-n-slate-11">
          {{ t('SOCIAL_COMMENTS.INSIGHTS.DESCRIPTION') }}
        </p>
      </div>
      <Select
        v-model="rangeDays"
        :options="rangeOptions"
        :aria-label="t('SOCIAL_COMMENTS.INSIGHTS.HEADER')"
        class="w-44"
      />
    </header>

    <div v-if="isFetching" class="flex items-center justify-center py-16">
      <Spinner :size="24" />
    </div>
    <p
      v-else-if="!insights || !classifiedCount"
      class="py-16 text-base text-center text-n-slate-11"
    >
      {{ t('SOCIAL_COMMENTS.INSIGHTS.EMPTY_STATE') }}
    </p>
    <main v-else class="flex flex-col gap-6 px-6 pb-8">
      <p v-if="insights.pending" class="text-sm text-n-slate-11">
        {{
          t('SOCIAL_COMMENTS.INSIGHTS.STILL_CLASSIFYING', {
            count: insights.pending,
          })
        }}
      </p>

      <div class="grid grid-cols-2 gap-4 lg:grid-cols-5">
        <div
          v-for="kpi in kpis"
          :key="kpi.key"
          class="p-4 border rounded-xl border-n-weak bg-n-solid-1"
        >
          <p class="text-sm text-n-slate-11">{{ kpi.label }}</p>
          <p class="mt-1 text-2xl font-medium text-n-slate-12">
            {{ kpi.value }}
          </p>
          <p v-if="kpi.hint" class="mt-1 text-xs text-n-slate-11">
            {{ kpi.hint }}
          </p>
        </div>
      </div>

      <div class="grid gap-4 lg:grid-cols-2">
        <div class="p-4 border rounded-xl border-n-weak bg-n-solid-1">
          <h2 class="mb-4 text-base font-medium text-n-slate-12">
            {{ t('SOCIAL_COMMENTS.INSIGHTS.SENTIMENT_BALANCE') }}
          </h2>
          <PercentageChart
            :data="sentimentBalance"
            :aria-label="t('SOCIAL_COMMENTS.INSIGHTS.SENTIMENT_BALANCE')"
          />
        </div>
        <div class="p-4 border rounded-xl border-n-weak bg-n-solid-1">
          <h2 class="mb-4 text-base font-medium text-n-slate-12">
            {{ t('SOCIAL_COMMENTS.INSIGHTS.DECISIONS') }}
          </h2>
          <PercentageChart
            :data="decisionBreakdown"
            :aria-label="t('SOCIAL_COMMENTS.INSIGHTS.DECISIONS')"
          />
        </div>
      </div>

      <div class="p-4 border rounded-xl border-n-weak bg-n-solid-1">
        <h2 class="mb-4 text-base font-medium text-n-slate-12">
          {{ t('SOCIAL_COMMENTS.INSIGHTS.SENTIMENT_OVER_TIME') }}
        </h2>
        <BarChart
          :data="timelineChart"
          :aria-label="t('SOCIAL_COMMENTS.INSIGHTS.SENTIMENT_OVER_TIME')"
          :height="TIMELINE_HEIGHT"
          stacked
          timeseries
        />
      </div>

      <div class="p-4 border rounded-xl border-n-weak bg-n-solid-1">
        <h2 class="text-base font-medium text-n-slate-12">
          {{ t('SOCIAL_COMMENTS.INSIGHTS.TOPICS') }}
        </h2>
        <p class="mt-1 mb-4 text-sm text-n-slate-11">
          {{ t('SOCIAL_COMMENTS.INSIGHTS.TOPICS_NOTE') }}
        </p>
        <p v-if="!insights.topics.length" class="text-sm text-n-slate-11">
          {{ t('SOCIAL_COMMENTS.INSIGHTS.TOPICS_EMPTY') }}
        </p>
        <ul v-else class="flex flex-col gap-4">
          <li
            v-for="topic in insights.topics"
            :key="topic.topic"
            class="grid items-center grid-cols-[10rem_3rem_1fr] gap-3"
          >
            <span class="text-sm truncate text-n-slate-12">
              {{ topicLabel(topic.topic) }}
            </span>
            <span class="text-sm text-end text-n-slate-11">
              {{ topic.total }}
            </span>
            <PercentageChart
              :data="{ segments: sentimentSegments(topic) }"
              :aria-label="topicLabel(topic.topic)"
              :bar-height="TOPIC_BAR_HEIGHT"
              :show-legend="false"
            />
          </li>
        </ul>
      </div>
    </main>
  </section>
</template>
