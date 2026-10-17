<script>
export default {
  name: 'AgentTypingBubble',
};
</script>

<template>
  <div class="agent-message-wrap sticky bottom-1">
    <div class="agent-message">
      <div class="message-wrap mt-2">
        <div class="chat-bubble agent is-plain typing-bubble">
          <img
            src="assets/images/typing.gif"
            alt="Agent is typing a message"
            class="!w-full"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.typing-bubble {
  @apply max-w-[2.4rem];
}
</style>
