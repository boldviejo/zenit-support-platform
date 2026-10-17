<script setup>
defineProps({
  config: {
    type: Object,
    default: () => ({}),
  },
});
</script>

<template>
  <div
    class="flex items-center flex-shrink-0 gap-2 px-4 py-3"
    :class="{ 'border-b border-n-weak': !config.isDefaultScreen }"
  >
    <img v-if="config.logo" :src="config.logo" class="rounded-full size-7" />
    <div v-if="!config.isDefaultScreen">
      <div class="flex items-center gap-1">
        <span class="text-sm font-medium text-n-slate-12">
          {{ config.websiteName }}
        </span>
        <div v-if="config.isOnline" class="rounded-full size-2 bg-n-teal-10" />
      </div>
      <span class="text-xs text-n-slate-11">{{ config.replyTime }}</span>
    </div>
  </div>
</template>
