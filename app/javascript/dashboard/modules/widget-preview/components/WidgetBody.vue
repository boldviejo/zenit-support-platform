<template>
  <div class="h-[calc(2rem*10)] px-4 pt-4 overflow-y-auto">
    <div class="flex justify-end mb-4">
      <p
        class="max-w-[85%] px-4 py-2.5 m-0 text-sm rounded-3xl bg-n-slate-3 text-n-slate-12"
      >
        {{ $t('INBOX_MGMT.WIDGET_BUILDER.BODY.USER_MESSAGE') }}
      </p>
    </div>
    <p class="m-0 text-sm leading-relaxed text-n-slate-12">
      {{ $t('INBOX_MGMT.WIDGET_BUILDER.BODY.AGENT_MESSAGE') }}
    </p>
  </div>
</template>
