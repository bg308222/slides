<script setup lang="ts">
/** 第四段每一頁頂上的進度條，讓觀眾知道現在走到哪一個動作。 */
defineProps<{ now: string }>()

const items = ['register', 'login', 'unlock', 'lock', 'logout']
</script>

<template>
  <div class="flex items-center gap-2">
    <template v-for="(s, i) in items" :key="s">
      <div
        class="px-3 py-1 rounded-full font-mono"
        style="font-size: 12px"
        :class="s === now
          ? 'border border-amber-400/70 bg-amber-400/15 text-amber-300'
          : 'border border-white/10 opacity-30'"
      >{{ s }}</div>
      <div v-if="i < items.length - 1" class="opacity-20" style="font-size: 11px">›</div>
    </template>
  </div>
</template>
