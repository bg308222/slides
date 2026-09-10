<script setup lang="ts">
/**
 * P11：PBKDF2 就只是一個「input 一樣就穩定產出、而且算起來很貴」的 bytes 產生器。
 *
 * 刻意**不**把它畫成兩條固定的分岔 —— RFC 沒有規定任何用途，
 * 它管到 DK 產出來為止就結束了。右邊那些只是「你可以拿它做的事」的例子，
 * 觀眾要帶走的是「隨你」，不是「就這兩條」。
 *
 *   step 1  函式 + 那串 bytes（可重現、很貴）
 *   step 2  你可以拿它幹嘛（一次散開，不強調順序）
 *   step 3  RFC 的邊界線
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const C = {
  pw: '#a78bfa',
  out: '#e2e8f0',
  hash: '#fbbf24',
  key: '#2dd4bf',
  data: '#38bdf8',
  mute: '#94a3b8',
}

const args = [
  { k: 'password', v: 'hunter2', c: C.pw },
  { k: 'salt', v: 'x7Kq…', c: C.data },
  { k: 'iterations', v: '600,000', c: C.key },
  { k: '長度', v: '32', c: C.hash },
]

/** 這些只是例子，不是規格。順序、數量都不重要。 */
const uses = [
  { y: 26, c: C.hash, t: '送出去，讓 server 比對', s: '那它此刻的身份就是「指紋」' },
  { y: 82, c: C.key, t: '留在本機，拿去解資料', s: '那它此刻就是「鑰匙」' },
  { y: 138, c: C.data, t: '抽 64 bytes，自己切一半', s: '前 32 加密、後 32 算 MAC' },
  { y: 194, c: C.mute, t: '或者你只是想要一串難猜的 bytes', s: '它不在乎你拿它幹嘛' },
]

const on1 = () => props.step >= 1
const on2 = () => props.step >= 2
const on3 = () => props.step >= 3
</script>

<template>
<svg viewBox="0 0 760 330" class="w-full">

  <!-- ── 呼叫：四個 input ─────────────────────────────── -->
  <g :style="{ opacity: on1() ? 1 : 0, transition: 'opacity 400ms ease' }">
    <rect x="18" y="34" width="250" height="150" rx="9"
          fill="#94a3b8" fill-opacity="0.06" stroke="#94a3b8" stroke-opacity="0.4" stroke-width="1.5" />
    <text x="32" y="56" fill="currentColor"
          :style="{ fontSize: '13px', fontFamily: 'ui-monospace, monospace', opacity: 0.9 }">pbkdf2(</text>

    <g v-for="(a, i) in args" :key="a.k">
      <text :x="48" :y="79 + i * 22" :fill="a.c"
            :style="{ fontSize: '12px', fontFamily: 'ui-monospace, monospace', opacity: 0.95 }">{{ a.k }}</text>
      <text :x="256" :y="79 + i * 22" text-anchor="end" fill="currentColor"
            :style="{ fontSize: '12px', fontFamily: 'ui-monospace, monospace', opacity: 0.6 }">{{ a.v }}</text>
    </g>

    <text x="32" y="172" fill="currentColor"
          :style="{ fontSize: '13px', fontFamily: 'ui-monospace, monospace', opacity: 0.9 }">)</text>

    <text x="18" y="208" fill="currentColor" :style="{ fontSize: '11.5px', opacity: 0.6 }">
      同樣這四個 input → 永遠是同一串
    </text>
    <text x="18" y="228" :fill="C.key" :style="{ fontSize: '11.5px', opacity: 0.85 }">
      而且算一次很貴（68 微秒）
    </text>
  </g>

  <!-- ── 產出：一串 bytes，沒有身份 ────────────────────── -->
  <Arrow d="M268,109 H300" tip="310,109 300,104 300,114" :on="on1()" :color="C.out" :opacity="0.5" :delay="300" />

  <g :style="{ opacity: on1() ? 1 : 0, transition: 'opacity 400ms ease 260ms' }">
    <rect x="310" y="86" width="156" height="46" rx="8"
          fill="#e2e8f0" fill-opacity="0.10" stroke="#e2e8f0" stroke-opacity="0.6" stroke-width="1.5" />
    <text x="388" y="106" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '13px', fontFamily: 'ui-monospace, monospace', opacity: 0.95 }">a3f1 9c2e …</text>
    <text x="388" y="122" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '10px', opacity: 0.5 }">32 bytes</text>
    <text x="388" y="152" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '11px', opacity: 0.45 }">就這樣。它沒有身份。</text>
  </g>

  <!-- ── 你可以拿它幹嘛（例子，不是規格）───────────────── -->
  <Arrow
    v-for="(u, i) in uses" :key="'a' + u.y"
    :d="`M466,109 H486 V${u.y + 23} H498`"
    :tip="`508,${u.y + 23} 498,${u.y + 18} 498,${u.y + 28}`"
    :color="u.c" :on="on2()" :opacity="0.55" :delay="i * 110"
  />

  <g v-for="(u, i) in uses" :key="u.y"
     :style="{ opacity: on2() ? 1 : 0, transition: `opacity 380ms ease ${i * 110}ms` }">
    <rect :x="508" :y="u.y" width="236" height="46" rx="8"
          :fill="u.c" fill-opacity="0.09" :stroke="u.c" stroke-opacity="0.5" stroke-width="1.3" />
    <text :x="522" :y="u.y + 20" fill="currentColor"
          :style="{ fontSize: '12px', opacity: 0.95 }">{{ u.t }}</text>
    <text :x="522" :y="u.y + 36" :fill="u.c"
          :style="{ fontSize: '10.5px', opacity: 0.8 }">{{ u.s }}</text>
  </g>

  <!-- ── RFC 的邊界 ───────────────────────────────────── -->
  <g :style="{ opacity: on3() ? 1 : 0, transition: 'opacity 360ms ease' }">
    <path d="M482,16 V262" fill="none" stroke="#f87171" stroke-width="1.6"
          stroke-dasharray="5 5" stroke-opacity="0.65" />
    <text x="474" y="288" text-anchor="end" :fill="C.mute"
          :style="{ fontSize: '11.5px', opacity: 0.9 }">RFC 8018 管到這裡為止</text>
    <text x="492" y="288" :fill="'#f87171'"
          :style="{ fontSize: '11.5px', opacity: 0.9 }">右邊這些，規格書一個字都沒寫</text>
  </g>

</svg>
</template>
