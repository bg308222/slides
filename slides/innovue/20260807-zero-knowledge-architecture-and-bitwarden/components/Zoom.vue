<script setup lang="ts">
/**
 * 局部特寫：Symmetric Key 到底怎麼解掉那個兩難。
 * 開場只有三個角色：Master Key（左上）、Symmetric Key（右上）、vault（右中）。
 *
 *   1 Symmetric Key 鎖住 vault
 *   2 Master Key 鎖住 Symmetric Key
 *   3 這兩包送去 server，用的時候一起拉回本機
 *   4 轉折：打密碼，解開的是右上那把 Symmetric Key（不是 vault）
 *   5 左下才長出 session key
 *   6 右下長出第二把被鎖的 Symmetric Key
 *   7 右上那把再鎖回去 —— 明文只存在剛剛那一瞬間
 *
 * 這一頁刻意不出現「unlock」這個字 —— 講的是機制，不是操作。
 * 所有格子座標固定，出現與否只改 opacity（視覺規則 B-1）。
 * SVG 文字一律用 inline style 設 font-size（presentation attribute 會被 theme 蓋掉）。
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 99 })

const C = {
  key: '#2dd4bf',
  data: '#38bdf8',
  seed: '#a78bfa',
  turn: '#fbbf24',
  bad: '#f87171',
  muted: '#94a3b8',
}

/** 右上那把：鎖 → 解 → 再鎖 */
const topLocked = () => (props.step >= 2 && props.step < 4) || props.step >= 7
</script>

<template>
  <svg viewBox="0 0 760 390" class="w-full" style="max-height: 300px">
    <rect
      x="10" y="8" width="560" height="364" rx="10"
      fill="#2dd4bf" fill-opacity="0.04" stroke="#2dd4bf" stroke-opacity="0.3" stroke-width="1.5"
    />
    <text x="24" y="26" fill="currentColor" :style="{ fontSize: '9.5px', letterSpacing: '1.4px', opacity: 0.45 }">
      你的裝置
    </text>

    <!-- ③ 這兩包鎖著的東西會來回 server -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 3 ? 1 : 0 }">
      <rect
        x="290" y="30" width="220" height="174" rx="9"
        fill="none" stroke="currentColor" stroke-opacity="0.3" stroke-width="1.5" stroke-dasharray="5 4"
      />
      <path d="M518,117 H592" fill="none" stroke="currentColor" stroke-width="1.5" opacity="0.45" />
      <polygon points="518,112 510,117 518,122" fill="currentColor" opacity="0.7" />
      <polygon points="592,112 600,117 592,122" fill="currentColor" opacity="0.7" />
      <text x="670" y="58" text-anchor="middle" fill="currentColor" :style="{ fontSize: '10px', opacity: 0.75 }">③ 這兩包送去 server</text>
      <text x="670" y="72" text-anchor="middle" fill="currentColor" :style="{ fontSize: '10px', opacity: 0.6 }">用的時候再一起拉回來</text>
      <rect
        x="600" y="95" width="140" height="44" rx="7"
        :fill="C.muted" fill-opacity="0.1" :stroke="C.muted" stroke-opacity="0.7" stroke-width="1.5"
      />
      <text x="670" y="116" text-anchor="middle" fill="currentColor" :style="{ fontSize: '12px', opacity: 0.95 }">SERVER</text>
      <text x="670" y="130" text-anchor="middle" :fill="C.muted" :style="{ fontSize: '9.5px', opacity: 0.85 }">兩包都打不開</text>
    </g>

    <!-- 左上：Master Key -->
    <rect x="36" y="40" width="180" height="44" rx="7"
          :fill="C.key" fill-opacity="0.13" :stroke="C.key" stroke-opacity="0.75" stroke-width="1.5" />
    <text x="126" y="61" text-anchor="middle" fill="currentColor" :style="{ fontSize: '12px', opacity: 0.95 }">Master Key</text>
    <text x="126" y="75" text-anchor="middle" :fill="C.key" :style="{ fontSize: '9.5px', opacity: 0.8 }">打密碼才算得出來</text>

    <!-- 右上：Symmetric Key 本尊（鎖 → 解 → 再鎖） -->
    <rect x="300" y="40" width="200" height="44" rx="7"
          :fill="C.key" fill-opacity="0.13" :stroke="C.key" stroke-opacity="0.75" stroke-width="1.5" />
    <text x="400" y="61" text-anchor="middle" fill="currentColor" :style="{ fontSize: '12px', opacity: 0.95 }">Symmetric Key</text>
    <text x="400" y="75" text-anchor="middle" :fill="C.key" :style="{ fontSize: '9.5px', opacity: 0.8 }">隨機生的，跟密碼無關</text>
    <LockG :x="489" :y="51" :on="topLocked()" :style="{ color: C.key }" />

    <!-- 右中：vault，鎖上去之後再也沒被打開過 -->
    <rect x="300" y="150" width="200" height="44" rx="7"
          :fill="C.data" fill-opacity="0.13" :stroke="C.data" stroke-opacity="0.75" stroke-width="1.5" />
    <text x="400" y="171" text-anchor="middle" fill="currentColor" :style="{ fontSize: '12px', opacity: 0.95 }">vault</text>
    <text x="400" y="185" text-anchor="middle" :fill="C.data" :style="{ fontSize: '9.5px', opacity: 0.8 }">你真正要保護的東西</text>
    <LockG :x="489" :y="161" :on="step >= 1" :style="{ color: C.data }" />

    <!-- ① 右上 → 右中：Symmetric Key 鎖住 vault -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 1 ? 1 : 0 }">
      <path d="M400,84 V142" fill="none" stroke="currentColor" stroke-width="1.5" opacity="0.45" />
      <polygon points="395,142 405,142 400,150" fill="currentColor" opacity="0.75" />
      <text x="414" y="120" text-anchor="start" fill="currentColor" :style="{ fontSize: '10px', opacity: 0.8 }">① 鎖住 vault</text>
    </g>

    <!-- ②／④ 左上 → 右上：先鎖起來，後來又解開 -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 2 ? 1 : 0 }">
      <path
        d="M216,62 H292" fill="none"
        :stroke="step >= 4 ? C.turn : 'currentColor'"
        :stroke-width="step === 4 ? 2.4 : 1.5"
        class="transition-all duration-500"
        :style="{ opacity: step === 4 ? 1 : step > 4 ? 0.7 : 0.45 }"
      />
      <polygon points="292,57 300,62 292,67"
               :fill="step >= 4 ? C.turn : 'currentColor'" :style="{ opacity: 0.8 }" />
      <text x="254" y="53" text-anchor="middle" fill="currentColor"
            class="transition-opacity duration-500"
            :style="{ fontSize: '10px', opacity: step >= 2 && step < 4 ? 0.8 : 0 }">② 鎖住</text>
      <text x="254" y="53" text-anchor="middle" :fill="C.turn"
            class="transition-opacity duration-500"
            :style="{ fontSize: '10.5px', opacity: step >= 4 ? 1 : 0 }">④ 解開</text>
    </g>

    <!-- ④ 原本那條「直接解 vault」已經不存在了 -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 4 ? 0.45 : 0 }">
      <path d="M36,66 H20 V222 H340 V200" fill="none" :stroke="C.bad" stroke-width="1.5" stroke-dasharray="4 4" />
      <path d="M13,137 L27,151 M27,137 L13,151" :stroke="C.bad" stroke-width="2" />
      <text x="196" y="214" text-anchor="middle" :fill="C.bad" :style="{ fontSize: '10px' }">原本是直接解 vault —— 這條路沒了</text>
    </g>

    <!-- ⑤ 左下：session key -->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 5 ? 1 : 0 }">
      <rect x="36" y="260" width="180" height="44" rx="7"
            :fill="C.seed" fill-opacity="0.13" :stroke="C.seed" stroke-opacity="0.75" stroke-width="1.5" />
      <text x="126" y="281" text-anchor="middle" fill="currentColor" :style="{ fontSize: '12px', opacity: 0.95 }">session key</text>
      <text x="126" y="295" text-anchor="middle" :fill="C.seed" :style="{ fontSize: '9.5px', opacity: 0.8 }">隨機生的，只有這台裝置有</text>
      <text x="126" y="248" text-anchor="middle" :fill="C.seed" :style="{ fontSize: '10px', opacity: 0.95 }">⑤ 這時候才憑空生一把</text>
    </g>

    <!-- ⑥ 右下：第二把被鎖的 Symmetric Key（由 session key + 右上那把明文產生）-->
    <g class="transition-opacity duration-500" :style="{ opacity: step >= 6 ? 1 : 0 }">
      <path d="M300,72 H258 V282" fill="none" :stroke="C.key" stroke-width="1.5" opacity="0.5" />
      <path d="M216,282 H292" fill="none" :stroke="C.seed" stroke-width="1.5" opacity="0.8" />
      <polygon points="292,277 300,282 292,287" :fill="C.seed" opacity="0.9" />
      <text x="256" y="322" text-anchor="middle" :fill="C.seed" :style="{ fontSize: '10px', opacity: 0.95 }">⑥ 鎖出第二把</text>
      <rect x="300" y="260" width="200" height="44" rx="7"
            :fill="C.key" fill-opacity="0.13" :stroke="C.key" stroke-opacity="0.75" stroke-width="1.5" />
      <text x="400" y="281" text-anchor="middle" fill="currentColor" :style="{ fontSize: '12px', opacity: 0.95 }">Symmetric Key</text>
      <text x="400" y="295" text-anchor="middle" :fill="C.seed" :style="{ fontSize: '9.5px', opacity: 0.95 }">被 session key 鎖的那一把</text>
      <LockG :x="489" :y="271" :style="{ color: C.key }" />
    </g>

    <!-- ⑦ 右上那把再鎖回去 -->
    <text x="366" y="112" text-anchor="end" :fill="C.key"
          class="transition-opacity duration-500"
          :style="{ fontSize: '10px', opacity: step >= 7 ? 0.95 : 0 }">⑦ 鎖回去</text>
  </svg>
</template>
