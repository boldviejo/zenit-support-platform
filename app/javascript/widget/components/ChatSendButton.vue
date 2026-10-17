<script setup>
import { computed } from 'vue';
import { getContrastingTextColor } from '@chatwoot/utils';
import Spinner from 'shared/components/Spinner.vue';

const props = defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  color: {
    type: String,
    default: '#1c2024',
  },
});

const iconColor = computed(() => getContrastingTextColor(props.color));
</script>

<template>
  <button
    type="submit"
    :disabled="disabled"
    :aria-label="$t('COMPOSER.SEND')"
    class="flex items-center justify-center transition-opacity rounded-full shrink-0 size-9 disabled:opacity-30"
    :style="{ backgroundColor: color, color: iconColor }"
  >
    <span v-if="!loading" class="text-lg i-lucide-arrow-up" />
    <Spinner v-else size="small" />
  </button>
</template>
