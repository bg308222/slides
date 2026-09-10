<script setup lang="ts">
/**
 * P8 的最簡模型。刻意只傳達兩件事，其餘全部進隱藏頁：
 *   1. 上一輪的結果是下一輪的輸入 → 這條鏈只能一輪一輪走
 *   2. password 每一輪都要用到     → 沒有一輪可以先算好、跳過
 * 不出現 XOR、不出現 block index、不出現 HMAC 這個詞。
 *
 *   step 0  隱藏
 *   step 1  整條鏈畫出來
 *   step 2  高亮每一輪的 password 入口
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const C = { pw: '#a78bfa', salt: '#38bdf8', box: '#94a3b8', hot: '#2dd4bf' }

const on = () => props.step >= 1
const hot = () => props.step >= 2

const rounds = [176, 356, 536]
const mids = [276, 456]
const RW = 84
const MW = 64
</script>

<template>
<svg viewBox="0 0 760 200" class="w-full">

  <!-- password 與它的橫桿 -->
  <g :style="{ opacity: on() ? 1 : 0, transition: 'opacity 380ms ease' }">
    <rect
      x="20" y="10" width="124" height="34" rx="7"
      :fill="C.pw" fill-opacity="0.14"
      :stroke="hot() ? C.hot : C.pw" :stroke-opacity="hot() ? 1 : 0.7" :stroke-width="hot() ? 2 : 1.4"
      style="transition: stroke 300ms ease, stroke-width 300ms ease"
    />
    <text x="82" y="32" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '13px', opacity: 0.95, fontFamily: 'ui-monospace, monospace' }">password</text>
  </g>

  <Arrow d="M144,27 H600" :on="on()" :color="hot() ? C.hot : C.pw"
         :opacity="hot() ? 0.9 : 0.4" :width="hot() ? 2 : 1.4" />

  <!-- 每一輪都從橫桿垂下來一條線 -->
  <Arrow
    v-for="(x, i) in rounds" :key="'d' + x"
    :d="`M${x + RW / 2},27 V83`"
    :tip="`${x + RW / 2},91 ${x + RW / 2 - 5},82 ${x + RW / 2 + 5},82`"
    :on="on()" :color="hot() ? C.hot : C.pw"
    :opacity="hot() ? 0.9 : 0.4" :width="hot() ? 2 : 1.4" :delay="200 + i * 90"
  />

  <!-- salt 只進第一輪 -->
  <g :style="{ opacity: on() ? 1 : 0, transition: 'opacity 380ms ease 120ms' }">
    <rect
      x="20" y="94" width="124" height="38" rx="7"
      :fill="C.salt" fill-opacity="0.14"
      :stroke="C.salt" stroke-opacity="0.7" stroke-width="1.4"
    />
    <text x="82" y="118" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '13px', opacity: 0.95, fontFamily: 'ui-monospace, monospace' }">salt</text>
  </g>
  <Arrow d="M144,113 H168" tip="176,113 167,108 167,118" :on="on()" :color="C.salt" :opacity="0.7" :delay="160" />

  <!-- 三輪 -->
  <g v-for="(x, i) in rounds" :key="'r' + x"
     :style="{ opacity: on() ? 1 : 0, transition: `opacity 380ms ease ${140 + i * 90}ms` }">
    <rect
      :x="x" y="91" :width="RW" height="44" rx="7"
      :fill="C.box" fill-opacity="0.10"
      :stroke="C.box" stroke-opacity="0.55" stroke-width="1.4"
    />
    <text :x="x + RW / 2" y="118" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '13px', opacity: 0.9 }">算一次</text>
  </g>

  <!-- 中間值 -->
  <g v-for="(x, i) in mids" :key="'m' + x"
     :style="{ opacity: on() ? 1 : 0, transition: `opacity 380ms ease ${200 + i * 90}ms` }">
    <rect
      :x="x" y="94" :width="MW" height="38" rx="7"
      fill="#fbbf24" fill-opacity="0.12"
      stroke="#fbbf24" stroke-opacity="0.6" stroke-width="1.2"
    />
    <text :x="x + MW / 2" y="118" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '11.5px', opacity: 0.85 }">中間值</text>
  </g>

  <!-- 鏈上的橫向箭頭：這一段就是「上一輪餵給下一輪」 -->
  <Arrow d="M260,113 H268" tip="276,113 267,108 267,118" :on="on()" :color="'#fbbf24'" :opacity="0.7" :delay="240" />
  <Arrow d="M340,113 H348" tip="356,113 347,108 347,118" :on="on()" :color="'#fbbf24'" :opacity="0.7" :delay="300" />
  <Arrow d="M440,113 H448" tip="456,113 447,108 447,118" :on="on()" :color="'#fbbf24'" :opacity="0.7" :delay="360" />
  <Arrow d="M520,113 H528" tip="536,113 527,108 527,118" :on="on()" :color="'#fbbf24'" :opacity="0.7" :delay="420" />
  <Arrow d="M620,113 H632" :on="on()" :color="'#fbbf24'" :opacity="0.5" :delay="480" />

  <text x="640" y="118" fill="currentColor"
        :style="{ fontSize: '12.5px', opacity: on() ? 0.55 : 0, transition: 'opacity 380ms ease 520ms' }">⋯ 共 600,000 輪</text>

  <!-- 兩句結論 -->
  <text x="20" y="168" fill="currentColor"
        :style="{ fontSize: '13px', opacity: on() ? 0.9 : 0, transition: 'opacity 380ms ease 560ms' }">
    上一輪的結果，就是下一輪的輸入 —— 這條鏈只能一輪一輪走。
  </text>
  <text x="20" y="190" :fill="C.hot"
        :style="{ fontSize: '13px', opacity: hot() ? 1 : 0, transition: 'opacity 340ms ease' }">
    而 password 每一輪都要用到 —— 沒有哪一輪可以先算好、跳過。
  </text>

</svg>
</template>
