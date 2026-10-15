<script setup lang="ts">
/**
 * P8 與 P10 是同一列參數演化。P10 不另外畫新表，
 * 而是在「最後一行」原地長出第四格 —— 整列靠左，所以只往右長，
 * 已經在畫面上的 token 一個都不會動。
 */
withDefaults(defineProps<{
  /** 顯示前幾行（0–3） */
  reveal?: number
  /** 第三行長出第四個參數 */
  fourth?: boolean
  /** 高亮哪一個參數 */
  hi?: '' | 'it' | 'len'
  /** 預留第四格的位置（P10 用，讓「還少一格」看得見，且填進去時不會位移） */
  reserve?: boolean
}>(), { reveal: 3, fourth: false, hi: '', reserve: false })
</script>

<template>
<div class="font-mono inline-block text-left leading-none">
  <div class="whitespace-nowrap" style="font-size: 17px; padding: 8px 0" :style="{ opacity: reveal >= 1 ? 0.4 : 0, transition: 'opacity 380ms ease' }"><span>hash(&nbsp;</span><span class="text-violet-300">password</span><span>&nbsp;)</span></div>

  <div class="whitespace-nowrap" style="font-size: 17px; padding: 8px 0" :style="{ opacity: reveal >= 2 ? 0.55 : 0, transition: 'opacity 380ms ease 120ms' }"><span>hash(&nbsp;</span><span class="text-violet-300">password</span><span>,&nbsp;</span><span class="text-sky-300">salt</span><span>&nbsp;)</span></div>

  <div class="whitespace-nowrap" style="font-size: 19px; padding: 10px 0" :style="{ opacity: reveal >= 3 ? 1 : 0, transition: 'opacity 380ms ease 240ms' }"><span>pbkdf2(&nbsp;</span><span class="text-violet-300">password</span><span>,&nbsp;</span><span class="text-sky-300">salt</span><span>,&nbsp;</span><span :class="hi === 'it' ? 'text-teal-300 font-bold' : 'text-teal-300/80'">iterations</span><span v-if="reserve || fourth" :style="{ opacity: fourth ? 1 : 0, transition: 'opacity 420ms ease' }"><span>,&nbsp;</span><span :class="hi === 'len' ? 'text-amber-300 font-bold' : 'text-amber-300/80'">輸出長度</span></span><span>&nbsp;)</span></div>
</div>
</template>
