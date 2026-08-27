<script setup lang="ts">
import { computed } from 'vue'
/**
 * 收束頁：視線內只留 app server。
 *
 * 前面八頁都在看兩格，這一頁刻意把 auth server 移出視線 ——
 * 因為要回答的問題是「app 這一格到底多做了什麼」，
 * 只要 auth server 還在畫面上，觀眾的注意力就會繼續分給它。
 *
 * 兩個 UI 入口的箭頭都指向框外。指出去就是這一頁的全部論點：
 * 那件事 app 不用管了 —— 要支援哪些驗證方式、選項怎麼列、怎麼串，
 * 都在 auth server 那一側，app 只負責把人送過去。
 *
 * 中間那塊 OIDC client 是唯一躲不掉的實作，但它是純標準的，
 * 所以 step 4 的結論才成立：auth server 之後多支援什麼，app 都不用動。
 *
 * step: 0 只有空的 app server / 1 註冊入口 + 往外指 / 2 一組 OIDC client
 *       3 登入入口 + 往外指 / 4 auth server 之後可以多支援什麼
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })
const s = computed(() => props.step)

const FUTURE = ['Passkey', 'Google', 'LDAP', 'SAML', '⋯']
</script>

<template>
  <div class="relative mx-auto" style="width: 880px; height: 340px">

    <!-- 兩條往外指的箭頭 -->
    <svg viewBox="0 0 880 340" class="absolute inset-0 w-full h-full" style="pointer-events: none">
      <g v-if="s >= 1">
        <text x="428" y="79" text-anchor="middle" fill="#fcd34d" style="font-size: 10.5px">redirect</text>
        <line class="mnGrow" x1="272" y1="87" x2="584" y2="87"
              stroke="#fbbf24" stroke-width="2.5" stroke-linecap="round" style="--len: 312" />
        <polygon class="mnHead" points="584,81 594,87 584,93" fill="#fbbf24" />
      </g>
      <g v-if="s >= 3">
        <text x="428" y="271" text-anchor="middle" fill="#fcd34d" style="font-size: 10.5px">redirect</text>
        <line class="mnGrow" x1="272" y1="279" x2="584" y2="279"
              stroke="#fbbf24" stroke-width="2.5" stroke-linecap="round" style="--len: 312" />
        <polygon class="mnHead" points="584,273 594,279 584,285" fill="#fbbf24" />
      </g>
    </svg>

    <!-- ── app server：這一頁唯一在視線內的東西 ────────────────── -->
    <div class="absolute rounded-xl border-2 border-sky-400/60 bg-sky-400/5"
         style="left: 30px; top: 20px; width: 530px; height: 296px" />
    <div class="absolute text-sky-300 font-bold" style="left: 46px; top: 28px; font-size: 14px">app server</div>

    <!-- ① 註冊入口 -->
    <div class="absolute transition-all duration-500" style="left: 52px; top: 56px"
         :style="{ opacity: s >= 1 ? 1 : 0 }">
      <div class="opacity-40" style="font-size: 10px">UI 加一個入口</div>
    </div>
    <div class="absolute rounded-lg border border-amber-400/60 bg-amber-400/10 flex items-center justify-center transition-all duration-500"
         style="left: 52px; top: 70px; width: 214px; height: 34px"
         :style="{ opacity: s >= 1 ? 1 : 0, transform: s >= 1 ? 'none' : 'translateX(-8px)' }">
      <span class="text-amber-200" style="font-size: 12px">＋ 新增 Passkey</span>
    </div>

    <!-- ② 唯一躲不掉的實作 -->
    <div class="absolute rounded-lg border border-indigo-400/50 bg-indigo-400/10 px-3 py-2 transition-all duration-500"
         style="left: 52px; top: 132px; width: 482px; height: 96px"
         :style="{ opacity: s >= 2 ? 1 : 0, transform: s >= 2 ? 'none' : 'translateY(8px)' }">
      <div class="flex items-baseline gap-2">
        <span class="text-indigo-200 font-bold" style="font-size: 12px">一組 OIDC client</span>
        <span class="opacity-45" style="font-size: 10px">這個躲不掉 —— 但它是純標準的</span>
      </div>
      <div class="flex items-center gap-1.5 mt-2 font-mono">
        <span class="rounded bg-slate-400/15 px-2 py-0.5" style="font-size: 10px">authorize</span>
        <span class="opacity-30" style="font-size: 10px">→</span>
        <span class="rounded bg-slate-400/15 px-2 py-0.5" style="font-size: 10px">token</span>
        <span class="opacity-30" style="font-size: 10px">→</span>
        <span class="rounded bg-slate-400/15 px-2 py-0.5" style="font-size: 10px">驗 id_token</span>
        <span class="opacity-30" style="font-size: 10px">→</span>
        <span class="rounded bg-teal-400/15 text-teal-200 px-2 py-0.5" style="font-size: 10px">簽自己的 session</span>
      </div>
      <div class="opacity-45 mt-2" style="font-size: 10px">沒有一行是 Better Auth 專屬的</div>
    </div>

    <!-- ③ 登入入口 -->
    <div class="absolute transition-all duration-500" style="left: 52px; top: 248px"
         :style="{ opacity: s >= 3 ? 1 : 0 }">
      <div class="opacity-40" style="font-size: 10px">
        UI 再加一個入口<span class="opacity-70"> —— 其實只是觸發自己的 OAuth</span>
      </div>
    </div>
    <div class="absolute rounded-lg border border-amber-400/60 bg-amber-400/10 flex items-center justify-center transition-all duration-500"
         style="left: 52px; top: 262px; width: 214px; height: 34px"
         :style="{ opacity: s >= 3 ? 1 : 0, transform: s >= 3 ? 'none' : 'translateX(-8px)' }">
      <span class="text-amber-200" style="font-size: 12px">使用 Passkey 登入</span>
    </div>
    <!-- ── 框外：交出去的部分 ────────────────────────────────── -->
    <div class="absolute rounded-lg border border-dashed border-teal-400/50 bg-teal-400/5 px-3 py-1.5 transition-all duration-500"
         style="left: 600px; top: 66px; width: 262px"
         :style="{ opacity: s >= 1 ? 1 : 0 }">
      <div class="text-teal-200" style="font-size: 11px">auth server 的 enroll 頁</div>
      <div class="opacity-45 mt-0.5 leading-snug" style="font-size: 10px">支援哪些驗證方式、選項怎麼列、怎麼串，都是它自己的事</div>
    </div>

    <div class="absolute rounded-lg border border-dashed border-teal-400/50 bg-teal-400/5 px-3 py-1.5 transition-all duration-500"
         style="left: 600px; top: 258px; width: 262px"
         :style="{ opacity: s >= 3 ? 1 : 0 }">
      <div class="text-teal-200" style="font-size: 11px">auth server 的 sign-in 頁</div>
      <div class="opacity-45 mt-0.5 leading-snug" style="font-size: 10px">登入這一側也完全一樣</div>
    </div>

    <!-- ④ 之後多支援什麼，都長在框外 -->
    <div class="absolute transition-all duration-500"
         style="left: 600px; top: 152px; width: 262px"
         :style="{ opacity: s >= 4 ? 1 : 0, transform: s >= 4 ? 'none' : 'translateY(8px)' }">
      <div class="opacity-45 mb-1.5" style="font-size: 10px">auth server 之後多支援什麼</div>
      <div class="flex flex-wrap gap-1.5">
        <span v-for="f in FUTURE" :key="f"
              class="rounded border border-teal-400/50 bg-teal-400/10 text-teal-200 px-2 py-0.5"
              style="font-size: 11px">{{ f }}</span>
      </div>
      <div class="text-teal-300 mt-2 leading-snug" style="font-size: 11px">app 這一邊，一行都不用改</div>
    </div>

  </div>
</template>

<style scoped>
.mnGrow { stroke-dasharray: var(--len); animation: mnDraw 0.34s cubic-bezier(.4, 0, .2, 1) forwards; }
@keyframes mnDraw { from { stroke-dashoffset: var(--len); } to { stroke-dashoffset: 0; } }
.mnHead { transform-box: fill-box; transform-origin: center; animation: mnPop 0.16s ease-out 0.28s both; }
@keyframes mnPop { from { opacity: 0; transform: scale(0.3); } to { opacity: 1; transform: scale(1); } }
</style>
