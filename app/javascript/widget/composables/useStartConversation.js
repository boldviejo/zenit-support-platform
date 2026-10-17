import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useStore, useMapGetter } from 'dashboard/composables/store';
import { IFrameHelper } from 'widget/helpers/utils';
import { CHATWOOT_ON_START_CONVERSATION } from 'widget/constants/sdkEvents';

/**
 * Starts (or continues) the visitor's conversation from the home screen, either
 * with a typed message, a suggested question or an attachment. When the inbox
 * asks for a pre-chat form before the first message, the visitor is sent there
 * with the message prefilled instead.
 */
export function useStartConversation() {
  const store = useStore();
  const router = useRouter();
  const conversationSize = useMapGetter('conversation/getConversationSize');

  const hasConversation = computed(() => !!conversationSize.value);

  const needsPreChatForm = computed(() => {
    const { preChatFormEnabled, preChatFormOptions = {} } =
      window.chatwootWebChannel;
    const fields = preChatFormOptions.pre_chat_fields || [];
    return (
      !hasConversation.value &&
      preChatFormEnabled &&
      fields.some(field => field.enabled)
    );
  });

  const notifyStart = () => {
    IFrameHelper.sendMessage({
      event: 'onEvent',
      eventIdentifier: CHATWOOT_ON_START_CONVERSATION,
      data: { hasConversation: hasConversation.value },
    });
  };

  const send = async (action, payload) => {
    const isFirstMessage = !hasConversation.value;
    if (isFirstMessage) notifyStart();
    router.replace({ name: 'messages' });
    await store.dispatch(action, payload);
    if (isFirstMessage) store.dispatch('conversationAttributes/getAttributes');
  };

  const startWithMessage = content => {
    if (needsPreChatForm.value) {
      notifyStart();
      return router.replace({
        name: 'prechat-form',
        query: { message: content },
      });
    }
    return send('conversation/sendMessage', { content });
  };

  const startWithAttachment = attachment =>
    send('conversation/sendAttachment', { attachment });

  return {
    hasConversation,
    needsPreChatForm,
    startWithMessage,
    startWithAttachment,
  };
}
