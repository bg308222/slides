<script setup lang="ts">
/**
 * 「一把鑰匙裂成兩把」的動畫。
 * 用 step 控制：step >= rootAt 顯示根，step >= splitAt 才裂開。
 */
withDefaults(defineProps<{
  rootLabel?: string
  root: string
  leftLabel?: string
  left: string
  leftNote?: string
  rightLabel?: string
  right: string
  rightNote?: string
  step?: number
  rootAt?: number
  splitAt?: number
}>(), { step: 99, rootAt: 0, splitAt: 1 })
</script>

<template>
  <div class="flex flex-col items-center w-full select-none">
    <div
      class="transition-all duration-500"
      :class="step >= rootAt ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-2'"
    >
      <div v-if="rootLabel" class="text-center opacity-55 mb-1" style="font-size: 11px">
        {{ rootLabel }}
      </div>
      <div
        class="px-4 py-2 rounded-md font-mono text-sm border border-violet-400/70 bg-violet-400/10 text-violet-300"
      >
        {{ root }}
      </div>
    </div>

    <svg
      viewBox="0 0 320 60"
      class="w-full transition-opacity duration-500"
      style="max-width: 30rem; height: 56px"
      :class="step >= splitAt ? 'opacity-45' : 'opacity-0'"
    >
      <path d="M160 0 L160 22 Q160 30 150 30 L70 30 Q60 30 60 38 L60 58" fill="none" stroke="currentColor" stroke-width="1.5" />
      <path d="M160 0 L160 22 Q160 30 170 30 L250 30 Q260 30 260 38 L260 58" fill="none" stroke="currentColor" stroke-width="1.5" />
      <polygon points="56,54 64,54 60,60" fill="currentColor" />
      <polygon points="256,54 264,54 260,60" fill="currentColor" />
    </svg>

    <div class="grid grid-cols-2 gap-8 w-full" style="max-width: 34rem">
      <div
        class="flex flex-col items-center transition-all duration-700"
        :class="step >= splitAt ? 'opacity-100 translate-x-0' : 'opacity-0 translate-x-8'"
      >
        <div v-if="leftLabel" class="text-center opacity-55 mb-1" style="font-size: 11px">
          {{ leftLabel }}
        </div>
        <div
          class="px-3 py-2 rounded-md font-mono text-center border border-amber-400/70 bg-amber-400/10 text-amber-300"
          style="font-size: 13px"
        >
          {{ left }}
        </div>
        <div v-if="leftNote" class="mt-1.5 text-center opacity-60 leading-snug" style="font-size: 11px" v-html="leftNote" />
      </div>

      <div
        class="flex flex-col items-center transition-all duration-700"
        :class="step >= splitAt ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-8'"
      >
        <div v-if="rightLabel" class="text-center opacity-55 mb-1" style="font-size: 11px">
          {{ rightLabel }}
        </div>
        <div
          class="px-3 py-2 rounded-md font-mono text-center border border-teal-400/70 bg-teal-400/10 text-teal-300"
          style="font-size: 13px"
        >
          {{ right }}
        </div>
        <div v-if="rightNote" class="mt-1.5 text-center opacity-60 leading-snug" style="font-size: 11px" v-html="rightNote" />
      </div>
    </div>
  </div>
</template>
