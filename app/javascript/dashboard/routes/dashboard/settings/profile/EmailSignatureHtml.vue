<script setup>
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import EmailSignatureHtmlEditor from 'dashboard/components-next/EmailSignature/EmailSignatureHtmlEditor.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  emailSignatureHtml: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['updateSignature']);

const { t } = useI18n();
const signature = ref(props.emailSignatureHtml ?? '');
watch(
  () => props.emailSignatureHtml ?? '',
  newValue => {
    signature.value = newValue;
  }
);

const updateSignature = () => {
  signature.value = signature.value.trim();
  emit('updateSignature', signature.value);
};
</script>

<template>
  <form class="flex flex-col gap-6" @submit.prevent="updateSignature()">
    <EmailSignatureHtmlEditor
      id="email-signature-html-input"
      v-model="signature"
    />
    <div>
      <NextButton
        type="submit"
        :label="
          t('PROFILE_SETTINGS.FORM.EMAIL_SIGNATURE_HTML_SECTION.BTN_TEXT')
        "
      />
    </div>
  </form>
</template>
