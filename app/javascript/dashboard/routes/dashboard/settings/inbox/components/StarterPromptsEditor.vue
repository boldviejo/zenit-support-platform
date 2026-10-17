<script setup>
import { computed } from 'vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const MAX_PROMPTS = 5;

const prompts = defineModel({ type: Array, default: () => [] });

const canAdd = computed(() => prompts.value.length < MAX_PROMPTS);

const updatePrompt = (index, value) => {
  prompts.value = prompts.value.map((prompt, i) =>
    i === index ? value : prompt
  );
};

const addPrompt = () => {
  prompts.value = [...prompts.value, ''];
};

const removePrompt = index => {
  prompts.value = prompts.value.filter((_, i) => i !== index);
};
</script>

<template>
  <div class="flex flex-col gap-2">
    <div
      v-for="(prompt, index) in prompts"
      :key="index"
      class="flex items-center gap-2"
    >
      <Input
        :model-value="prompt"
        class="flex-1"
        :placeholder="
          $t('INBOX_MGMT.ADD.WEBSITE_CHANNEL.STARTER_PROMPTS.PLACEHOLDER')
        "
        @update:model-value="value => updatePrompt(index, value)"
      />
      <Button
        icon="i-lucide-trash-2"
        slate
        ghost
        sm
        :aria-label="
          $t('INBOX_MGMT.ADD.WEBSITE_CHANNEL.STARTER_PROMPTS.REMOVE')
        "
        @click="removePrompt(index)"
      />
    </div>
    <div>
      <Button
        v-if="canAdd"
        icon="i-lucide-plus"
        :label="$t('INBOX_MGMT.ADD.WEBSITE_CHANNEL.STARTER_PROMPTS.ADD')"
        slate
        faded
        sm
        @click="addPrompt"
      />
    </div>
  </div>
</template>
