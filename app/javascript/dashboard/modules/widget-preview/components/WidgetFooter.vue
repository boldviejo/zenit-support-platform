<script setup>
import { computed } from 'vue';
import { getContrastingTextColor } from '@chatwoot/utils';
import { useMessageFormatter } from 'shared/composables/useMessageFormatter';

const props = defineProps({
  config: {
    type: Object,
    default: () => ({}),
  },
});

const { formatMessage } = useMessageFormatter();

const sendIconColor = computed(() =>
  getContrastingTextColor(props.config.color)
);
</script>

<template>
  <div class="flex flex-col w-full gap-4 px-3">
    <div v-if="config.isDefaultScreen" class="flex flex-col gap-3 px-1">
      <div>
        <h2 class="text-xl font-semibold break-words text-n-slate-12">
          {{
            config.welcomeHeading ||
            $t('INBOX_MGMT.WIDGET_BUILDER.BODY.DEFAULT_GREETING')
          }}
        </h2>
        <p
          v-if="config.welcomeTagline"
          v-dompurify-html="formatMessage(config.welcomeTagline)"
          class="mt-1 text-sm break-words text-n-slate-11 [&_a]:underline"
        />
      </div>
      <ul v-if="config.starterPrompts.length" class="flex flex-col gap-2">
        <li
          v-for="prompt in config.starterPrompts"
          :key="prompt"
          class="flex items-center gap-2.5 text-sm text-n-slate-12"
        >
          <span class="i-lucide-message-circle shrink-0 text-n-slate-11" />
          {{ prompt }}
        </li>
      </ul>
    </div>
    <div
      class="flex items-center gap-1 p-1 shadow-sm rounded-3xl bg-n-solid-1 outline outline-1 -outline-offset-1 outline-n-weak"
    >
      <span class="flex items-center justify-center size-8 text-n-slate-12">
        <span class="text-lg i-lucide-plus" />
      </span>
      <span class="flex-1 px-1 text-sm text-n-slate-10">
        {{ $t('INBOX_MGMT.WIDGET_BUILDER.FOOTER.CHAT_INPUT_PLACEHOLDER') }}
      </span>
      <span
        class="flex items-center justify-center rounded-full size-8"
        :style="{ backgroundColor: config.color, color: sendIconColor }"
      >
        <span class="i-lucide-arrow-up" />
      </span>
    </div>
  </div>
</template>
