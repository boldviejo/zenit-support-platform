<script>
import { defineAsyncComponent } from 'vue';
import { mapGetters } from 'vuex';

import ChatAttachmentButton from 'widget/components/ChatAttachment.vue';
import ChatSendButton from 'widget/components/ChatSendButton.vue';
import { useAttachments } from '../composables/useAttachments';
import FluentIcon from 'shared/components/FluentIcon/Index.vue';
import ResizableTextArea from 'shared/components/ResizableTextArea.vue';

const EmojiPicker = defineAsyncComponent(
  () => import('shared/components/emoji/EmojiPicker.vue')
);

export default {
  name: 'ChatInputWrap',
  components: {
    ChatAttachmentButton,
    ChatSendButton,
    EmojiPicker,
    FluentIcon,
    ResizableTextArea,
  },
  props: {
    onSendMessage: {
      type: Function,
      default: () => {},
    },
    onSendAttachment: {
      type: Function,
      default: () => {},
    },
    allowAttachments: {
      type: Boolean,
      default: true,
    },
  },
  setup() {
    const {
      canHandleAttachments,
      shouldShowEmojiPicker,
      hasEmojiPickerEnabled,
    } = useAttachments();
    return {
      canHandleAttachments,
      shouldShowEmojiPicker,
      hasEmojiPickerEnabled,
    };
  },
  data() {
    return {
      userInput: '',
      showEmojiPicker: false,
      isFocused: false,
    };
  },

  computed: {
    ...mapGetters({
      widgetColor: 'appConfig/getWidgetColor',
      isWidgetOpen: 'appConfig/getIsWidgetOpen',
      shouldShowEmojiPicker: 'appConfig/getShouldShowEmojiPicker',
    }),
    showAttachment() {
      return this.allowAttachments && this.canHandleAttachments;
    },
    hasInput() {
      return this.userInput.trim().length > 0;
    },
  },
  watch: {
    isWidgetOpen(isWidgetOpen) {
      if (isWidgetOpen) {
        this.focusInput();
      }
    },
  },
  unmounted() {
    document.removeEventListener('keypress', this.handleEnterKeyPress);
  },
  mounted() {
    document.addEventListener('keypress', this.handleEnterKeyPress);
    if (this.isWidgetOpen) {
      this.focusInput();
    }
  },

  methods: {
    onBlur() {
      this.isFocused = false;
    },
    onFocus() {
      this.isFocused = true;
    },
    handleButtonClick() {
      if (this.userInput && this.userInput.trim()) {
        this.onSendMessage(this.userInput);
      }
      this.userInput = '';
      this.focusInput();
    },
    handleEnterKeyPress(e) {
      if (e.keyCode === 13 && !e.shiftKey) {
        e.preventDefault();
        this.handleButtonClick();
      }
    },
    toggleEmojiPicker() {
      this.showEmojiPicker = !this.showEmojiPicker;
    },
    hideEmojiPicker(e) {
      if (this.showEmojiPicker) {
        e.stopPropagation();
        this.toggleEmojiPicker();
      }
    },
    emojiOnClick(emoji) {
      this.userInput = `${this.userInput}${emoji} `;
    },
    onSelectEmoji({ value }) {
      this.emojiOnClick(value);
    },
    onTypingOff() {
      this.toggleTyping('off');
    },
    onTypingOn() {
      this.toggleTyping('on');
    },
    toggleTyping(typingStatus) {
      this.$store.dispatch('conversation/toggleUserTyping', { typingStatus });
    },
    focusInput() {
      this.$refs.chatInput.focus();
    },
  },
};
</script>

<template>
  <div
    class="relative flex items-end gap-1 p-1.5 transition-colors duration-200 shadow-sm rounded-3xl bg-n-solid-1 outline outline-1 -outline-offset-1"
    :class="[
      isFocused ? 'outline-n-strong' : 'outline-n-weak',
      { 'ltr:pl-3 rtl:pr-3': !showAttachment },
    ]"
    @keydown.esc="hideEmojiPicker"
  >
    <ChatAttachmentButton
      v-if="showAttachment"
      class="shrink-0"
      :on-attach="onSendAttachment"
    />
    <ResizableTextArea
      id="chat-input"
      ref="chatInput"
      v-model="userInput"
      :rows="1"
      :min-height="2.25"
      :aria-label="$t('CHAT_PLACEHOLDER')"
      :placeholder="$t('CHAT_PLACEHOLDER')"
      class="user-message-input reset-base"
      @typing-off="onTypingOff"
      @typing-on="onTypingOn"
      @focus="onFocus"
      @blur="onBlur"
    />
    <button
      v-if="shouldShowEmojiPicker && hasEmojiPickerEnabled"
      class="flex items-center justify-center rounded-full shrink-0 size-9 hover:bg-n-slate-3"
      :aria-label="$t('EMOJI.ARIA_LABEL')"
      @click="toggleEmojiPicker"
    >
      <FluentIcon
        icon="emoji"
        class="transition-all duration-150"
        :class="{
          'text-n-slate-11': !showEmojiPicker,
          'text-n-slate-12': showEmojiPicker,
        }"
      />
    </button>
    <EmojiPicker
      v-if="shouldShowEmojiPicker && showEmojiPicker"
      v-on-clickaway="hideEmojiPicker"
      class="!bottom-full end-0 mb-2 max-w-[calc(100vw-3rem)]"
      @select="onSelectEmoji"
      @keydown.esc="hideEmojiPicker"
    />
    <ChatSendButton
      :color="widgetColor"
      :disabled="!hasInput"
      @click="handleButtonClick"
    />
  </div>
</template>

<style scoped lang="scss">
.user-message-input {
  @apply flex-1 border-none outline-none w-full placeholder:text-n-slate-10 resize-none min-h-9 max-h-60 py-1.5 px-1 m-0 bg-transparent text-n-slate-12 text-[0.9375rem] leading-6;
}
</style>
