<script setup lang="ts">
withDefaults(defineProps<{
  clientTitle?: string
  serverTitle?: string
  wireLabel?: string
  /** 隱藏中間的傳輸線（例如純本機運算的畫面） */
  noWire?: boolean
}>(), {
  clientTitle: 'CLIENT — 你的裝置',
  serverTitle: 'SERVER',
  wireLabel: 'https',
  noWire: false,
})
</script>

<template>
  <div class="grid items-stretch gap-3 my-3" style="grid-template-columns: 1fr auto 1fr">
    <div class="rounded-lg border-2 border-teal-500/40 bg-teal-500/5 p-3 flex flex-col">
      <div class="uppercase tracking-widest opacity-45 mb-2" style="font-size: 10px">
        {{ clientTitle }}
      </div>
      <div class="flex-1 flex flex-col items-center justify-center gap-2">
        <slot name="client" />
      </div>
    </div>

    <div class="flex flex-col items-center justify-center gap-1.5 px-1" style="min-width: 9rem">
      <slot name="wire" />
      <template v-if="!noWire">
        <svg viewBox="0 0 100 10" class="w-full opacity-35" style="height: 12px">
          <line x1="0" y1="5" x2="91" y2="5" stroke="currentColor" stroke-width="1" stroke-dasharray="4 3" />
          <polygon points="91,1 100,5 91,9" fill="currentColor" />
        </svg>
        <div class="opacity-35" style="font-size: 10px">{{ wireLabel }}</div>
      </template>
    </div>

    <div class="rounded-lg border-2 border-slate-400/40 bg-slate-400/5 p-3 flex flex-col">
      <div class="uppercase tracking-widest opacity-45 mb-2" style="font-size: 10px">
        {{ serverTitle }}
      </div>
      <div class="flex-1 flex flex-col items-center justify-center gap-2">
        <slot name="server" />
      </div>
    </div>
  </div>
</template>
