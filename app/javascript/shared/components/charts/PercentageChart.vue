<script setup>
import { PercentageChart as VizPercentageChart } from '@chatwoot/viz';

defineProps({
  data: {
    type: Object,
    required: true,
  },
  ariaLabel: {
    type: String,
    required: true,
  },
});

defineOptions({ inheritAttrs: false });
</script>

<template>
  <VizPercentageChart
    v-bind="$attrs"
    :data="data"
    :aria-label="ariaLabel"
    class="[--cw-viz-percentage-label-color:rgb(var(--slate-11))] [--cw-viz-percentage-legend-value-color:rgb(var(--slate-12))] [--cw-viz-percentage-tooltip-background:rgb(var(--solid-2))] [--cw-viz-percentage-tooltip-border-color:rgb(var(--border-strong))] [--cw-viz-percentage-tooltip-label-color:rgb(var(--slate-11))] [--cw-viz-percentage-tooltip-value-color:rgb(var(--slate-12))] [--cw-viz-percentage-tooltip-description-color:rgb(var(--slate-11))] [--cw-viz-percentage-remainder-color:rgb(var(--slate-4))]"
  />
</template>
