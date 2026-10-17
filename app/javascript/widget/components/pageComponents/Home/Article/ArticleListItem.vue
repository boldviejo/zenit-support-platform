<script setup>
const props = defineProps({
  link: {
    type: String,
    default: '',
  },
  title: {
    type: String,
    default: '',
  },
});
const emit = defineEmits(['selectArticle']);
const onClick = () => {
  emit('selectArticle', props.link);
};
</script>

<template>
  <div
    class="flex items-center gap-3 px-2 py-2 transition-colors cursor-pointer rounded-xl text-n-slate-12 hover:bg-n-slate-3"
    role="button"
    @click="onClick"
  >
    <span class="text-lg i-lucide-file-text shrink-0 text-n-slate-11" />
    <button class="flex-1 text-base leading-6 ltr:text-left rtl:text-right">
      {{ title }}
    </button>
    <span
      class="text-base i-lucide-chevron-right shrink-0 text-n-slate-10 rtl:rotate-180"
    />
  </div>
</template>
