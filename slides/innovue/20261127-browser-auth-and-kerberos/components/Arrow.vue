<script setup lang="ts">
/**
 * 全場唯一的箭頭語彙：線一律「沿路徑畫出來」，不准憑空出現。
 * 用 pathLength="1" 把長度正規化，dashoffset 從 1 跑到 0，
 * 箭頭頭再用延遲的 opacity 補在最後 —— 方向本身就是動畫的一部分。
 */
withDefaults(defineProps<{
  d: string
  on?: boolean
  /** 三個點，例如 "336,74 344,69 344,79" */
  tip?: string
  color?: string
  width?: number
  /** 毫秒 */
  delay?: number
  opacity?: number
}>(), {
  on: false,
  color: 'currentColor',
  width: 1.5,
  delay: 0,
  opacity: 0.55,
})
</script>

<template>
  <g>
    <path
      :d="d"
      fill="none"
      :stroke="color"
      :stroke-width="width"
      stroke-linecap="round"
      stroke-linejoin="round"
      pathLength="1"
      stroke-dasharray="1"
      :style="{
        strokeDashoffset: on ? 0 : 1,
        opacity: on ? opacity : 0,
        transition: `stroke-dashoffset 620ms ease ${delay}ms, opacity 160ms ease ${delay}ms`,
      }"
    />
    <polygon
      v-if="tip"
      :points="tip"
      :fill="color"
      :style="{
        opacity: on ? Math.min(opacity + 0.25, 1) : 0,
        transition: `opacity 200ms ease ${on ? delay + 580 : delay}ms`,
      }"
    />
  </g>
</template>
