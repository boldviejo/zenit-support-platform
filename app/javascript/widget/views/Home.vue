<script setup>
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useMapGetter } from 'dashboard/composables/store';
import { useMessageFormatter } from 'shared/composables/useMessageFormatter';
import { useStartConversation } from 'widget/composables/useStartConversation';
import ChatInputWrap from 'widget/components/ChatInputWrap.vue';
import ArticleContainer from '../components/pageComponents/Home/Article/ArticleContainer.vue';

const router = useRouter();
const { formatMessage } = useMessageFormatter();
const appConfig = useMapGetter('appConfig/getAppConfig');
const conversationAttributes = useMapGetter(
  'conversationAttributes/getConversationParams'
);
const unreadMessageCount = useMapGetter('conversation/getUnreadMessageCount');
const {
  hasConversation,
  needsPreChatForm,
  startWithMessage,
  startWithAttachment,
} = useStartConversation();

const channelConfig = window.chatwootWebChannel;
const greeting = computed(
  () => appConfig.value.welcomeTitle || channelConfig.welcomeTitle
);
const tagline = computed(
  () => appConfig.value.welcomeDescription || channelConfig.welcomeTagline
);
const starterPrompts = computed(() =>
  hasConversation.value ? [] : channelConfig.starterPrompts || []
);
const isReplyBoxHidden = computed(
  () =>
    !channelConfig.allowMessagesAfterResolved &&
    conversationAttributes.value.status === 'resolved'
);

const continueConversation = () => router.replace({ name: 'messages' });
</script>

<template>
  <div class="z-50 flex flex-col flex-1 w-full min-h-0">
    <div
      class="flex flex-col justify-end flex-1 gap-5 px-5 pb-3 overflow-y-auto"
    >
      <div>
        <h2
          v-if="greeting"
          v-dompurify-html="greeting"
          class="text-2xl font-semibold tracking-tight text-n-slate-12"
        />
        <h2
          v-else
          class="text-2xl font-semibold tracking-tight text-n-slate-12"
        >
          {{ $t('HOME.GREETING') }}
        </h2>
        <p
          v-if="tagline"
          v-dompurify-html="formatMessage(tagline)"
          class="mt-1.5 text-base leading-normal text-n-slate-11 [&_a]:underline"
        />
      </div>

      <ul
        v-if="hasConversation || starterPrompts.length"
        class="flex flex-col -mx-2"
      >
        <li v-if="hasConversation">
          <button
            class="flex items-center w-full gap-3 px-2 py-2 text-base transition-colors rounded-xl text-start text-n-slate-12 hover:bg-n-slate-3"
            @click="continueConversation"
          >
            <span
              class="text-lg i-lucide-messages-square shrink-0 text-n-slate-11"
            />
            <span class="flex-1">{{ $t('CONTINUE_CONVERSATION') }}</span>
            <span
              v-if="unreadMessageCount"
              class="px-1.5 text-xs font-medium rounded-full min-w-5 bg-n-slate-12 text-n-slate-1"
            >
              {{ unreadMessageCount }}
            </span>
          </button>
        </li>
        <li v-for="prompt in starterPrompts" :key="prompt">
          <button
            class="flex items-center w-full gap-3 px-2 py-2 text-base transition-colors rounded-xl text-start text-n-slate-12 hover:bg-n-slate-3"
            @click="startWithMessage(prompt)"
          >
            <span
              class="text-lg i-lucide-message-circle shrink-0 text-n-slate-11"
            />
            <span>{{ prompt }}</span>
          </button>
        </li>
      </ul>

      <ArticleContainer />
    </div>

    <ChatInputWrap
      v-if="!isReplyBoxHidden"
      class="mx-3 mb-1"
      :allow-attachments="!needsPreChatForm"
      :on-send-message="startWithMessage"
      :on-send-attachment="startWithAttachment"
    />
  </div>
</template>
