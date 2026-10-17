<script setup>
import { ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'dashboard/composables/store';
import { useAlert } from 'dashboard/composables';
import { useAccount } from 'dashboard/composables/useAccount';
import MetaAppAPI from 'dashboard/api/metaApp';
import SectionLayout from './SectionLayout.vue';
import WithLabel from 'v3/components/Form/WithLabel.vue';
import NextInput from 'next/input/Input.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

const { t } = useI18n();
const store = useStore();
const { accountId } = useAccount();

const config = ref(null);
const isSaving = ref(false);
const form = ref({
  facebook_app_id: '',
  facebook_app_secret: '',
  instagram_app_id: '',
  instagram_app_secret: '',
});

const applyConfig = data => {
  config.value = data;
  form.value = {
    facebook_app_id: data.facebook_app_id || '',
    facebook_app_secret: '',
    instagram_app_id: data.instagram_app_id || '',
    instagram_app_secret: '',
  };
};

const secretPlaceholder = isConfigured =>
  isConfigured
    ? t('GENERAL_SETTINGS.FORM.META_APP.SECRET_CONFIGURED')
    : t('GENERAL_SETTINGS.FORM.META_APP.SECRET_PLACEHOLDER');

onMounted(async () => {
  try {
    const { data } = await MetaAppAPI.get();
    applyConfig(data);
  } catch {
    useAlert(t('GENERAL_SETTINGS.FORM.META_APP.API.FETCH_ERROR'));
  }
});

const save = async () => {
  isSaving.value = true;
  try {
    const { data } = await MetaAppAPI.update(form.value);
    applyConfig(data);
    // Refresh the account so the channel list picks up the new app ids
    await store.dispatch('accounts/get', {
      silent: true,
      accountId: accountId.value,
    });
    useAlert(t('GENERAL_SETTINGS.FORM.META_APP.API.SUCCESS'));
  } catch (error) {
    useAlert(
      error?.response?.data?.message ||
        t('GENERAL_SETTINGS.FORM.META_APP.API.ERROR')
    );
  } finally {
    isSaving.value = false;
  }
};
</script>

<template>
  <SectionLayout
    :title="t('GENERAL_SETTINGS.FORM.META_APP.TITLE')"
    :description="t('GENERAL_SETTINGS.FORM.META_APP.NOTE')"
    with-border
  >
    <form v-if="config" class="grid gap-4" @submit.prevent="save">
      <WithLabel
        name="facebook-app-id"
        :label="t('GENERAL_SETTINGS.FORM.META_APP.FACEBOOK_APP_ID')"
      >
        <NextInput v-model="form.facebook_app_id" type="text" class="w-full" />
      </WithLabel>
      <WithLabel
        name="facebook-app-secret"
        :label="t('GENERAL_SETTINGS.FORM.META_APP.FACEBOOK_APP_SECRET')"
      >
        <NextInput
          v-model="form.facebook_app_secret"
          type="password"
          class="w-full"
          :placeholder="
            secretPlaceholder(config.facebook_app_secret_configured)
          "
        />
      </WithLabel>
      <WithLabel
        name="instagram-app-id"
        :label="t('GENERAL_SETTINGS.FORM.META_APP.INSTAGRAM_APP_ID')"
        :help-message="t('GENERAL_SETTINGS.FORM.META_APP.INSTAGRAM_HELP')"
      >
        <NextInput v-model="form.instagram_app_id" type="text" class="w-full" />
      </WithLabel>
      <WithLabel
        name="instagram-app-secret"
        :label="t('GENERAL_SETTINGS.FORM.META_APP.INSTAGRAM_APP_SECRET')"
      >
        <NextInput
          v-model="form.instagram_app_secret"
          type="password"
          class="w-full"
          :placeholder="
            secretPlaceholder(config.instagram_app_secret_configured)
          "
        />
      </WithLabel>
      <div>
        <NextButton blue :is-loading="isSaving" type="submit">
          {{ t('GENERAL_SETTINGS.FORM.META_APP.SUBMIT') }}
        </NextButton>
      </div>

      <div v-if="config.verify_token" class="grid gap-4 pt-2">
        <p class="text-body-main text-n-slate-11">
          {{ t('GENERAL_SETTINGS.FORM.META_APP.WEBHOOKS_NOTE') }}
        </p>
        <WithLabel
          name="meta-verify-token"
          :label="t('GENERAL_SETTINGS.FORM.META_APP.VERIFY_TOKEN')"
        >
          <woot-code :script="config.verify_token" lang="text" class="w-full" />
        </WithLabel>
        <WithLabel
          name="messenger-webhook-url"
          :label="t('GENERAL_SETTINGS.FORM.META_APP.MESSENGER_WEBHOOK_URL')"
        >
          <woot-code
            :script="config.messenger_webhook_url"
            lang="text"
            class="w-full"
          />
        </WithLabel>
        <WithLabel
          name="instagram-webhook-url"
          :label="t('GENERAL_SETTINGS.FORM.META_APP.INSTAGRAM_WEBHOOK_URL')"
        >
          <woot-code
            :script="config.instagram_webhook_url"
            lang="text"
            class="w-full"
          />
        </WithLabel>
        <WithLabel
          name="instagram-redirect-uri"
          :label="t('GENERAL_SETTINGS.FORM.META_APP.INSTAGRAM_REDIRECT_URI')"
        >
          <woot-code
            :script="config.instagram_redirect_uri"
            lang="text"
            class="w-full"
          />
        </WithLabel>
      </div>
    </form>
  </SectionLayout>
</template>
