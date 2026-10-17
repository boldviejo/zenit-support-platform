<script setup>
import HeaderActions from './HeaderActions.vue';

defineProps({
  avatarUrl: {
    type: String,
    default: '',
  },
  showPopoutButton: {
    type: Boolean,
    default: false,
  },
});
</script>

<template>
  <header
    class="relative box-border flex items-center w-full px-5 pt-4 pb-2"
    :class="avatarUrl ? 'justify-between' : 'justify-end'"
  >
    <img
      v-if="avatarUrl"
      class="rounded-full size-8"
      :src="avatarUrl"
      alt="Avatar"
    />
    <HeaderActions
      :show-popout-button="showPopoutButton"
      :show-end-conversation-button="false"
    />
  </header>
</template>
