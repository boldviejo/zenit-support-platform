<script setup>
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useAccount } from 'dashboard/composables/useAccount';
import Switch from 'dashboard/components-next/switch/Switch.vue';
import Select from 'dashboard/components-next/select/Select.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import SectionLayout from 'dashboard/routes/dashboard/settings/account/components/SectionLayout.vue';
import {
  AUTO_DELETE_THRESHOLDS,
  DEFAULT_AUTO_DELETE_THRESHOLD,
} from './constants';

const { t } = useI18n();
const { currentAccount, updateAccount } = useAccount();

const isEnabled = ref(false);
const threshold = ref(String(DEFAULT_AUTO_DELETE_THRESHOLD));
const isSaving = ref(false);

watch(
  () => currentAccount.value?.settings,
  settings => {
    isEnabled.value = !!settings?.comment_auto_delete;
    threshold.value = String(
      settings?.comment_auto_delete_threshold || DEFAULT_AUTO_DELETE_THRESHOLD
    );
  },
  { immediate: true }
);

const thresholdOptions = computed(() =>
  AUTO_DELETE_THRESHOLDS.map(value => ({
    value: String(value),
    label: t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_THRESHOLD_OPTION', {
      confidence: Math.round(value * 100),
    }),
  }))
);

const save = async () => {
  isSaving.value = true;
  try {
    await updateAccount({
      comment_auto_delete: isEnabled.value,
      comment_auto_delete_threshold: Number(threshold.value),
    });
    useAlert(t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_SUCCESS'));
  } catch {
    useAlert(t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_ERROR'));
  } finally {
    isSaving.value = false;
  }
};
</script>

<template>
  <SectionLayout
    :title="t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_TITLE')"
    :description="t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_NOTE')"
    with-border
  >
    <template #headerActions>
      <div class="flex justify-end">
        <Switch v-model="isEnabled" />
      </div>
    </template>
    <div class="grid gap-4">
      <label class="grid gap-1 text-sm text-n-slate-12">
        {{ t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_THRESHOLD') }}
        <Select
          v-model="threshold"
          :options="thresholdOptions"
          :disabled="!isEnabled"
          class="w-64"
        />
      </label>
      <div>
        <Button
          :label="t('SOCIAL_COMMENTS.SETTINGS.AUTO_DELETE_SAVE')"
          :is-loading="isSaving"
          @click="save"
        />
      </div>
    </div>
  </SectionLayout>
</template>
