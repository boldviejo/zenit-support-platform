<script setup>
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import { useAccount } from 'dashboard/composables/useAccount';
import TagInput from 'dashboard/components-next/taginput/TagInput.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import SectionLayout from 'dashboard/routes/dashboard/settings/account/components/SectionLayout.vue';
import AutoDeleteSettings from 'dashboard/components-next/SocialComments/AutoDeleteSettings.vue';

const { t } = useI18n();
const store = useStore();
const { accountId, currentAccount, updateAccount } = useAccount();

const topics = ref(null);
const isSaving = ref(false);

// TagInput only reads its initial value, so render it once the account is loaded
watch(
  () => currentAccount.value?.comment_topic_options,
  options => {
    if (options && !topics.value) topics.value = [...options];
  },
  { immediate: true }
);

const save = async () => {
  isSaving.value = true;
  try {
    await updateAccount({
      comment_topics: topics.value.map(topic => topic.trim()).filter(Boolean),
    });
    // The update response omits the effective topic list, so refetch the account
    await store.dispatch('accounts/get', {
      silent: true,
      accountId: accountId.value,
    });
    useAlert(t('SOCIAL_COMMENTS.SETTINGS.SAVE_SUCCESS'));
  } catch {
    useAlert(t('SOCIAL_COMMENTS.SETTINGS.SAVE_ERROR'));
  } finally {
    isSaving.value = false;
  }
};
</script>

<template>
  <section class="flex flex-col w-full h-full overflow-y-auto bg-n-surface-1">
    <div class="w-full max-w-2xl px-6 pt-6 pb-8">
      <h1 class="text-xl font-medium text-n-slate-12">
        {{ t('SOCIAL_COMMENTS.SETTINGS.HEADER') }}
      </h1>
      <SectionLayout
        :title="t('SOCIAL_COMMENTS.SETTINGS.TOPICS_TITLE')"
        :description="t('SOCIAL_COMMENTS.SETTINGS.TOPICS_NOTE')"
      >
        <div v-if="topics" class="grid gap-4">
          <TagInput
            v-model="topics"
            :placeholder="t('SOCIAL_COMMENTS.SETTINGS.TOPICS_PLACEHOLDER')"
            :auto-open-dropdown="false"
            allow-create
            class="px-3 py-2 border rounded-lg border-n-weak"
          />
          <div>
            <Button
              :label="t('SOCIAL_COMMENTS.SETTINGS.SAVE')"
              :is-loading="isSaving"
              @click="save"
            />
          </div>
        </div>
      </SectionLayout>
      <AutoDeleteSettings />
      <SectionLayout
        :title="t('SOCIAL_COMMENTS.SETTINGS.SETUP_TITLE')"
        :description="t('SOCIAL_COMMENTS.SETTINGS.SETUP_NOTE')"
        with-border
        hide-content
      />
    </div>
  </section>
</template>
