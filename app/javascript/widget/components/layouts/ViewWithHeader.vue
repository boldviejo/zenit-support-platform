<script>
import Banner from '../Banner.vue';
import Branding from 'shared/components/Branding.vue';
import ChatHeader from '../ChatHeader.vue';
import ChatHeaderExpanded from '../ChatHeaderExpanded.vue';
import configMixin from '../../mixins/configMixin';
import { mapGetters } from 'vuex';
import { IFrameHelper } from 'widget/helpers/utils';

export default {
  components: {
    Banner,
    Branding,
    ChatHeader,
    ChatHeaderExpanded,
  },
  mixins: [configMixin],
  data() {
    return {
      disableBranding: window.chatwootWebChannel.disableBranding || false,
    };
  },
  computed: {
    ...mapGetters({
      appConfig: 'appConfig/getAppConfig',
      availableAgents: 'agent/availableAgents',
    }),
    showBackButton() {
      return ['article-viewer', 'messages', 'prechat-form'].includes(
        this.$route.name
      );
    },
    isOnArticleViewer() {
      return ['article-viewer'].includes(this.$route.name);
    },
    isOnHomeView() {
      return ['home'].includes(this.$route.name);
    },
  },
  methods: {
    closeWindow() {
      IFrameHelper.sendMessage({ event: 'closeWindow' });
    },
  },
};
</script>

<template>
  <div class="w-full h-full bg-n-solid-1" @keydown.esc="closeWindow">
    <div class="relative flex flex-col h-full">
      <ChatHeaderExpanded
        v-if="isOnHomeView"
        :avatar-url="channelConfig.avatarUrl"
        :show-popout-button="appConfig.showPopoutButton"
      />
      <ChatHeader
        v-else
        class="border-b border-n-weak"
        :title="channelConfig.websiteName"
        :avatar-url="channelConfig.avatarUrl"
        :show-popout-button="appConfig.showPopoutButton"
        :available-agents="availableAgents"
        :show-back-button="showBackButton"
      />
      <Banner />
      <router-view />

      <Branding v-if="!isOnArticleViewer" :disable-branding="disableBranding" />
    </div>
  </div>
</template>
