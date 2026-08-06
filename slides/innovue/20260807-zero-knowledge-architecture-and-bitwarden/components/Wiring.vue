<script setup lang="ts">
/**
 * 第二、三段共用的同一張圖。整場只有這一張，用 step 貫穿三頁：
 *   1 key 長出來
 *   2 明文 vault 從 server 搬到 client
 *   3 key + vault → 加密的 vault 出現在 server
 *   4 貼上 Bitwarden 官方名字（小字）
 *   5 highlight「key 直接對 vault 做事」那條線
 *   6 Symmetric Key 插進那條線中間
 *   7 Protected Symmetric Key 存到 server
 *
 * 所有格子的座標從頭到尾固定，出現與否只改 opacity（視覺規則 B-1）。
 * 注意：SVG 文字一律用 inline style 設 font-size —— presentation attribute 會被 theme 的 CSS 蓋掉。
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 99 })

const C = {
  seed: '#a78bfa',
  key: '#2dd4bf',
  hash: '#fbbf24',
  data: '#38bdf8',
}

const W = 180
const H = 44

const nodes = [
  { id: 'pw',    x: 139, y: 26,  c: C.seed, at: 0, main: 'hunter2',              sub: 'master password' },
  { id: 'key',   x: 32,  y: 104, c: C.key,  at: 1, main: '留在本機那把 key',      sub: 'Master Key' },
  { id: 'hash',  x: 246, y: 104, c: C.hash, at: 0, main: '送出去那個 hash',       sub: 'Master Password Hash' },
  { id: 'sym',   x: 32,  y: 182, c: C.key,  at: 6, main: '真正鎖著 vault 的那把',  sub: 'Symmetric Key' },
  { id: 'hashS', x: 512, y: 104, c: C.hash, at: 0, main: '9f2a…',                sub: 'Master Password Hash' },
  { id: 'pskS',  x: 512, y: 182, c: C.key,  at: 7, main: '被鎖起來的那把',         sub: 'Protected Symmetric Key', lockAt: 7 },
  { id: 'encS',  x: 512, y: 330, c: C.data, at: 3, main: '加密的 vault',          sub: '',                        lockAt: 3 },
]

const edges = [
  { d: 'M229,70 V87 H336 V104', at: 0 },
  { d: 'M229,70 V87 H122 V104', at: 1 },
  { d: 'M426,126 H505',         at: 0, tip: '505,121 512,126 505,131' },
  { d: 'M122,148 V352 H505',    at: 3, tip: '505,347 512,352 505,357', hot: true },
  { d: 'M336,302 V326 H122',    at: 3 },
  { d: 'M212,204 H505',         at: 7, tip: '505,199 512,204 505,209' },
]

const isHot = (e: { hot?: boolean }) => Boolean(e.hot) && props.step === 5
/** 明文 vault 是同一個盒子在動：起點是 server 那格，step 2 之後滑到 client 那格。 */
const vaultDx = () => (props.step >= 2 ? -266 : 0)
</script>

<template>
  <svg viewBox="0 0 760 400" class="w-full" style="max-height: 340px">
    <rect
      x="16" y="8" width="424" height="380" rx="10"
      fill="#2dd4bf" fill-opacity="0.04" stroke="#2dd4bf" stroke-opacity="0.32" stroke-width="1.5"
    />
    <text x="30" y="23" fill="currentColor" :style="{ fontSize: '9.5px', letterSpacing: '1.4px', opacity: 0.45 }">
      CLIENT — 你的裝置
    </text>

    <rect
      x="480" y="8" width="264" height="380" rx="10"
      fill="#94a3b8" fill-opacity="0.04" stroke="#94a3b8" stroke-opacity="0.32" stroke-width="1.5"
    />
    <text x="494" y="23" fill="currentColor" :style="{ fontSize: '9.5px', letterSpacing: '1.4px', opacity: 0.45 }">
      SERVER
    </text>

    <!-- 線 -->
    <g v-for="e in edges" :key="e.d">
      <path
        :d="e.d"
        fill="none"
        :stroke="isHot(e) ? C.hash : 'currentColor'"
        :stroke-width="isHot(e) ? 2.6 : 1.5"
        class="transition-all duration-500"
        :style="{ opacity: step >= e.at ? (isHot(e) ? 1 : 0.45) : 0 }"
      />
      <polygon
        v-if="e.tip"
        :points="e.tip"
        :fill="isHot(e) ? C.hash : 'currentColor'"
        class="transition-opacity duration-500"
        :style="{ opacity: step >= e.at ? 0.75 : 0 }"
      />
    </g>

    <text
      x="152" y="250" :fill="C.hash"
      class="transition-opacity duration-500"
      :style="{ fontSize: '11px', opacity: step === 5 ? 1 : 0 }"
    >問題出在這一條</text>

    <!-- 固定位置的格子 -->
    <g v-for="n in nodes" :key="n.id" class="transition-opacity duration-500"
       :style="{ opacity: step >= n.at ? 1 : 0 }">
      <rect
        :x="n.x" :y="n.y" :width="W" :height="H" rx="7"
        :fill="n.c" fill-opacity="0.13" :stroke="n.c" stroke-opacity="0.75" stroke-width="1.5"
      />
      <text
        :x="n.x + W / 2" :y="n.y + 21" text-anchor="middle" fill="currentColor"
        :style="{ fontSize: '12px', opacity: 0.95 }"
      >{{ n.main }}</text>
      <text
        v-if="n.sub"
        :x="n.x + W / 2" :y="n.y + 35" text-anchor="middle" :fill="n.c"
        class="transition-opacity duration-500"
        :style="{ fontSize: '9.5px', opacity: step >= 4 ? 0.8 : 0 }"
      >{{ n.sub }}</text>
      <LockG
        v-if="n.lockAt"
        :x="n.x + W - 11" :y="n.y + 11"
        :on="step >= n.lockAt"
        :style="{ color: n.c }"
      />
    </g>

    <!-- 明文 vault：同一個盒子從 server 滑到 client -->
    <g
      class="transition-transform duration-700"
      :style="{ transform: `translateX(${vaultDx()}px)` }"
    >
      <rect
        x="512" y="258" :width="W" :height="H" rx="7"
        :fill="C.data" fill-opacity="0.13" :stroke="C.data" stroke-opacity="0.75" stroke-width="1.5"
      />
      <text
        x="602" y="285" text-anchor="middle" fill="currentColor"
        :style="{ fontSize: '12px', opacity: 0.95 }"
      >vault（明文）</text>
    </g>
  </svg>
</template>
