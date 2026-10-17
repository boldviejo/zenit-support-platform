<script>
import { useMessageFormatter } from 'shared/composables/useMessageFormatter';

export default {
  name: 'UserMessageBubble',
  props: {
    message: {
      type: String,
      default: '',
    },
  },
  setup() {
    const { formatMessage } = useMessageFormatter();
    return {
      formatMessage,
    };
  },
};
</script>

<template>
  <div
    v-dompurify-html="formatMessage(message, false)"
    class="chat-bubble user"
  />
</template>

<style lang="scss" scoped>
.chat-bubble.user {
  :deep(blockquote) {
    @apply bg-transparent border-n-slate-7 ltr:border-l-2 rtl:border-r-2 border-solid;

    p {
      @apply text-n-slate-11;
    }
  }
}
</style>
