<script setup lang="ts">
/**
 * token endpoint 的檢查清單 —— 全場出現三次，版面必須逐像素一致：
 *   2.3 四格全綠   → 沒有一格擋得住
 *   3.2 五格三綠一紅 → 多的那一格擋住了
 *   3.4 五格又全綠   → 清單變長了，卻又沒有一格擋得住
 * 這條軸線是第二、三段之間的接縫，所以格子高度、字級、間距都寫死。
 */
withDefaults(defineProps<{
  items: { label: string; ok: boolean; note?: string }[]
  /** 揭露到第幾項（1-based）；0 = 全部隱藏，-1 = 全部顯示 */
  reveal?: number
  title?: string
  verdict?: string
  verdictTone?: 'bad' | 'good'
}>(), { reveal: -1, title: 'AS 在 token endpoint 檢查什麼', verdictTone: 'bad' })
</script>

<template>
  <div class="rounded-lg border border-slate-400/30 bg-slate-400/5 px-4 py-3">
    <div class="uppercase tracking-widest opacity-40 mb-2.5" style="font-size: 10px">
      {{ title }}
    </div>

    <div class="flex flex-col gap-1.5">
      <div
        v-for="(it, i) in items"
        :key="it.label"
        class="flex items-center gap-2.5 transition-opacity duration-500"
        :class="(reveal === -1 || i < reveal) ? 'opacity-100' : 'opacity-0'"
        style="min-height: 26px"
      >
        <span
          class="inline-flex items-center justify-center rounded font-bold shrink-0"
          style="width: 20px; height: 20px; font-size: 12px"
          :class="it.ok
            ? 'bg-emerald-400/15 text-emerald-300 border border-emerald-400/50'
            : 'bg-red-400/15 text-red-300 border border-red-400/60'"
        >{{ it.ok ? '✓' : '✕' }}</span>
        <code class="font-mono" style="font-size: 13px">{{ it.label }}</code>
        <span v-if="it.note" class="opacity-45" style="font-size: 11px">{{ it.note }}</span>
      </div>
    </div>

    <div
      v-if="verdict"
      class="mt-3 pt-2.5 border-t border-slate-400/20 leading-snug"
      style="font-size: 12px"
      :class="verdictTone === 'bad' ? 'text-red-300' : 'text-emerald-300'"
      v-html="verdict"
    />
  </div>
</template>
