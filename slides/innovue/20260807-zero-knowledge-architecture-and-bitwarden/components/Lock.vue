<script setup lang="ts">
/**
 * 視覺規則 A：只要是「被加密過的東西」就掛這個 badge。
 * HTML 版（SVG 圖裡請用 LockG）。
 */
withDefaults(defineProps<{ size?: number; on?: boolean }>(), { size: 12, on: true })
</script>

<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 12 12"
    class="inline-block shrink-0 transition-opacity duration-500"
    :style="{ opacity: on ? 1 : 0, verticalAlign: '-0.12em' }"
  >
    <rect
      x="1.6" y="5.1" width="8.8" height="6.1" rx="1.5"
      fill="currentColor" fill-opacity="0.3" stroke="currentColor" stroke-width="1"
    />
    <path
      d="M3.9 5.1 V3.5 a2.1 2.1 0 0 1 4.2 0 V5.1"
      fill="none" stroke="currentColor" stroke-width="1"
    />
  </svg>
</template>
