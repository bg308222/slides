<script setup lang="ts">
/** 全場重複出現的那把尺：「現在 server 手上有什麼？」 */
withDefaults(defineProps<{
  items: { text: string; safe?: boolean }[]
  verdict?: string
  title?: string
}>(), { title: '現在 server 手上有什麼？' })
</script>

<template>
  <div class="rounded-lg border border-amber-400/40 bg-amber-400/5 px-5 py-4">
    <div class="font-bold text-amber-300 mb-3 text-sm tracking-wide">{{ title }}</div>
    <ul class="space-y-2">
      <li v-for="(it, i) in items" :key="i" class="flex gap-2.5 items-start text-sm leading-snug">
        <span class="font-mono shrink-0" :class="it.safe ? 'text-teal-400' : 'text-red-400'">
          {{ it.safe ? '無害' : '危險' }}
        </span>
        <span class="opacity-85" v-html="it.text" />
      </li>
    </ul>
    <div
      v-if="verdict"
      class="mt-3 pt-3 border-t border-white/10 text-sm opacity-75"
      v-html="verdict"
    />
  </div>
</template>
