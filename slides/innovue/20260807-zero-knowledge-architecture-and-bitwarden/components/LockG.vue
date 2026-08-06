<script setup lang="ts">
/** 視覺規則 A 的 SVG 版：畫在節點右上角，出現/消失只改 opacity，不動版面。 */
withDefaults(defineProps<{ x: number; y: number; on?: boolean }>(), { on: true })
</script>

<template>
  <g
    :transform="`translate(${x},${y})`"
    class="transition-opacity duration-500"
    :style="{ opacity: on ? 0.9 : 0 }"
  >
    <rect
      x="-4.6" y="-1" width="9.2" height="6.4" rx="1.5"
      fill="currentColor" fill-opacity="0.3" stroke="currentColor" stroke-width="1"
    />
    <path
      d="M-2.4 -1 V-2.7 a2.4 2.4 0 0 1 4.8 0 V-1"
      fill="none" stroke="currentColor" stroke-width="1"
    />
  </g>
</template>
