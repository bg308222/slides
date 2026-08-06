<script setup lang="ts">
/**
 * 第三段的局部特寫：unlock 那一瞬間。
 *   1 Master Key 解開 Symmetric Key（鎖拿掉）
 *   2 隨機生出一把 session key
 *   3 用 session key 把 Symmetric Key 重新鎖一次，放進本機硬碟
 *   4 從此只要有 session key 就開得了 vault
 *
 * 每個格子的位置從一開始就固定，session key 與硬碟那份只是淡入（視覺規則 B-1）。
 * SVG 文字一律用 inline style 設 font-size（presentation attribute 會被 theme 蓋掉）。
 */
withDefaults(defineProps<{ step?: number }>(), { step: 99 })

const C = {
  key: '#2dd4bf',
  data: '#38bdf8',
  seed: '#a78bfa',
}
</script>

<template>
  <svg viewBox="0 0 760 340" class="w-full" style="max-height: 300px">
    <!-- ① Master Key 解開 Symmetric Key -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 4 ? 0.25 : 1 }">
      <rect x="40" y="40" width="180" height="44" rx="7"
            :fill="C.key" fill-opacity="0.13" :stroke="C.key" stroke-opacity="0.75" stroke-width="1.5" />
      <text x="130" y="61" text-anchor="middle" fill="currentColor"
            :style="{ fontSize: '12px', opacity: 0.95 }">Master Key</text>
      <text x="130" y="75" text-anchor="middle" :fill="C.key"
            :style="{ fontSize: '9.5px', opacity: 0.8 }">master password 算出來的</text>

      <path d="M220,62 H281" fill="none" stroke="currentColor" stroke-width="1.5"
            class="transition-opacity duration-500" :style="{ opacity: step >= 1 ? 0.5 : 0.15 }" />
      <polygon points="281,57 288,62 281,67" fill="currentColor"
               class="transition-opacity duration-500" :style="{ opacity: step >= 1 ? 0.75 : 0.15 }" />
      <text x="250" y="50" text-anchor="middle" fill="currentColor"
            class="transition-opacity duration-500"
            :style="{ fontSize: '10px', opacity: step >= 1 ? 0.8 : 0 }">① 解開</text>
    </g>

    <!-- Symmetric Key：同一個框，鎖只是被拿掉 -->
    <rect x="290" y="40" width="180" height="44" rx="7"
          :fill="C.key" fill-opacity="0.13" :stroke="C.key" stroke-opacity="0.75" stroke-width="1.5" />
    <text x="380" y="61" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '12px', opacity: 0.95 }">Symmetric Key</text>
    <text x="380" y="75" text-anchor="middle" :fill="C.key"
          :style="{ fontSize: '9.5px', opacity: 0.8 }">真正鎖著 vault 的那把</text>
    <LockG :x="459" :y="51" :on="step < 1" :style="{ color: C.key }" />

    <!-- 加密的 vault -->
    <path d="M470,62 H531" fill="none" stroke="currentColor" stroke-width="1.5" opacity="0.35" />
    <polygon points="531,57 538,62 531,67" fill="currentColor" opacity="0.5" />
    <rect x="540" y="40" width="180" height="44" rx="7"
          :fill="C.data" fill-opacity="0.13" :stroke="C.data" stroke-opacity="0.75" stroke-width="1.5" />
    <text x="630" y="66" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '12px', opacity: 0.95 }">加密的 vault</text>
    <LockG :x="709" :y="51" :style="{ color: C.data }" />

    <!-- ② session key -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 2 ? 1 : 0 }">
      <text x="630" y="128" text-anchor="middle" fill="currentColor"
            :style="{ fontSize: '10px', opacity: 0.7 }">② 憑空生一把</text>
      <rect x="540" y="150" width="180" height="44" rx="7"
            :fill="C.seed" fill-opacity="0.13" :stroke="C.seed" stroke-opacity="0.75" stroke-width="1.5" />
      <text x="630" y="171" text-anchor="middle" fill="currentColor"
            :style="{ fontSize: '12px', opacity: 0.95 }">session key</text>
      <text x="630" y="185" text-anchor="middle" :fill="C.seed"
            :style="{ fontSize: '9.5px', opacity: 0.8 }">隨機產生 · 只有這台裝置有</text>
    </g>

    <!-- ③ 放進硬碟 -->
    <path d="M380,84 V246" fill="none" stroke="currentColor" stroke-width="1.5"
          class="transition-opacity duration-500" :style="{ opacity: step >= 3 ? 0.5 : 0 }" />
    <polygon points="375,246 385,246 380,254" fill="currentColor"
             class="transition-opacity duration-500" :style="{ opacity: step >= 3 ? 0.75 : 0 }" />
    <path d="M538,172 H420 V246" fill="none" :stroke="C.seed" stroke-width="1.5"
          class="transition-opacity duration-500" :style="{ opacity: step >= 3 ? 0.7 : 0 }" />
    <text x="428" y="216" text-anchor="start" :fill="C.seed"
          class="transition-opacity duration-500"
          :style="{ fontSize: '10px', opacity: step >= 3 ? 0.9 : 0 }">③ 用它再鎖一次</text>

    <!-- 本機硬碟托盤 -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 3 ? 1 : 0.12 }">
      <rect x="250" y="255" width="260" height="70" rx="9"
            fill="currentColor" fill-opacity="0.03" stroke="currentColor" stroke-opacity="0.28"
            stroke-width="1.5" stroke-dasharray="5 4" />
      <text x="264" y="271" fill="currentColor"
            :style="{ fontSize: '9.5px', letterSpacing: '1.2px', opacity: 0.45 }">本機硬碟</text>
      <rect x="290" y="278" width="180" height="38" rx="7"
            :fill="C.key" fill-opacity="0.13" :stroke="C.key" stroke-opacity="0.75" stroke-width="1.5" />
      <text x="380" y="294" text-anchor="middle" fill="currentColor"
            :style="{ fontSize: '11.5px', opacity: 0.95 }">Symmetric Key</text>
      <text x="380" y="307" text-anchor="middle" :fill="C.key"
            :style="{ fontSize: '9px', opacity: 0.8 }">被 session key 鎖著</text>
      <LockG :x="459" :y="289" :on="step >= 3" :style="{ color: C.key }" />
    </g>

    <!-- ④ 之後只要 session key -->
    <text x="40" y="180" text-anchor="start" :fill="C.seed"
          class="transition-opacity duration-500"
          :style="{ fontSize: '13px', opacity: step >= 4 ? 1 : 0 }">
      ④ 從此 master password 可以走了
    </text>
    <text x="40" y="200" text-anchor="start" fill="currentColor"
          class="transition-opacity duration-500"
          :style="{ fontSize: '11px', opacity: step >= 4 ? 0.7 : 0 }">
      session key → 開硬碟那份 → 開 vault
    </text>
  </svg>
</template>
