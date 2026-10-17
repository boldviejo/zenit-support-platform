<script setup>
import { useI18n } from 'vue-i18n';
import { Letter } from 'vue-letter';
import { allowedCssProperties } from 'lettersanitizer';
import TextArea from 'dashboard/components-next/textarea/TextArea.vue';

defineProps({
  id: { type: String, default: '' },
});

const modelValue = defineModel({ type: String, default: '' });

// Rich signatures with inline styles and tables are a few KB; leave room for that.
const MAX_SIGNATURE_LENGTH = 10000;

const { t } = useI18n();
</script>

<template>
  <div class="flex flex-col gap-4">
    <TextArea
      :id="id"
      v-model="modelValue"
      :placeholder="t('EMAIL_SIGNATURE_HTML.PLACEHOLDER')"
      :max-length="MAX_SIGNATURE_LENGTH"
      show-character-count
      resize
      min-height="8rem"
      max-height="20rem"
      custom-text-area-class="font-mono !text-xs"
    />
    <div class="flex flex-col gap-2">
      <span class="text-body-main font-medium text-n-slate-12">
        {{ t('EMAIL_SIGNATURE_HTML.PREVIEW') }}
      </span>
      <div
        class="rounded-lg border border-n-weak bg-white p-4 text-n-slate-12 overflow-x-auto"
      >
        <Letter
          v-if="modelValue"
          class-name="!max-w-none"
          :html="modelValue"
          :allowed-css-properties="allowedCssProperties"
        />
        <span v-else class="text-body-main text-n-slate-10">
          {{ t('EMAIL_SIGNATURE_HTML.EMPTY_PREVIEW') }}
        </span>
      </div>
    </div>
  </div>
</template>
