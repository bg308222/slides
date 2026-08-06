<script setup lang="ts">
/**
 * 最後才出現的完整架構圖 —— 是獎賞，不是教材。
 * step 控制逐段揭露：1 根、2 兩條分岔、3 認證那條、4 資料那條。
 */
withDefaults(defineProps<{ step?: number }>(), { step: 99 })

const C = {
  seed: '#a78bfa',
  key: '#2dd4bf',
  hash: '#fbbf24',
  data: '#38bdf8',
  lock: '#94a3b8',
}

const nodes = [
  { id: 'input', x: 95, y: 25, w: 260, h: 38, c: C.seed, at: 1, lines: ['email + master password'] },
  { id: 'mk', x: 145, y: 95, w: 160, h: 34, c: C.key, at: 1, lines: ['Master Key'] },
  { id: 'mph', x: 25, y: 162, w: 180, h: 38, c: C.hash, at: 2, lines: ['Master Password Hash'] },
  { id: 'smk', x: 225, y: 162, w: 180, h: 38, c: C.key, at: 2, lines: ['Stretched Master Key'] },
  { id: 'sk', x: 235, y: 252, w: 160, h: 34, c: C.key, at: 4, lines: ['Symmetric Key'] },
  { id: 'vault', x: 235, y: 332, w: 160, h: 34, c: C.data, at: 4, lines: ['vault（明文）'] },
  { id: 'smph', x: 490, y: 162, w: 230, h: 38, c: C.lock, at: 3, lines: ['Master Password Hash', '（server 再 hash 一次才存）'] },
  { id: 'spsk', x: 490, y: 252, w: 230, h: 34, c: C.lock, at: 4, lines: ['Protected Symmetric Key'] },
  { id: 'svault', x: 490, y: 332, w: 230, h: 34, c: C.lock, at: 4, lines: ['加密的 vault'] },
]

const edges = [
  { d: 'M225 63 L225 95', at: 1 },
  { d: 'M225 129 L225 145 Q225 152 218 152 L122 152 Q115 152 115 159 L115 162', at: 2 },
  { d: 'M225 129 L225 145 Q225 152 232 152 L308 152 Q315 152 315 159 L315 162', at: 2 },
  { d: 'M205 181 L488 181', at: 3, label: '送出 → 認證', lx: 347, ly: 174 },
  { d: 'M315 200 L315 252', at: 4, label: '解開', lx: 337, ly: 228 },
  { d: 'M488 269 L397 269', at: 4, label: '取回', lx: 442, ly: 262 },
  { d: 'M315 286 L315 332', at: 4, label: '解開', lx: 337, ly: 312 },
  { d: 'M488 349 L397 349', at: 4, label: '取回', lx: 442, ly: 342 },
]
</script>

<template>
  <svg viewBox="0 0 760 430" class="w-full" style="max-height: 400px">
    <rect x="20" y="8" width="410" height="410" rx="10" fill="#2dd4bf" fill-opacity="0.04"
          stroke="#2dd4bf" stroke-opacity="0.35" stroke-width="1.5" />
    <text x="34" y="26" font-size="11" fill="currentColor" opacity="0.5" letter-spacing="1.5">
      CLIENT — 你的裝置
    </text>

    <rect x="470" y="8" width="270" height="410" rx="10" fill="#94a3b8" fill-opacity="0.04"
          stroke="#94a3b8" stroke-opacity="0.35" stroke-width="1.5" />
    <text x="484" y="26" font-size="11" fill="currentColor" opacity="0.5" letter-spacing="1.5">
      SERVER
    </text>

    <g v-for="e in edges" :key="e.d" class="transition-opacity duration-500"
       :style="{ opacity: step >= e.at ? 0.5 : 0 }">
      <path :d="e.d" fill="none" stroke="currentColor" stroke-width="1.5" />
      <text v-if="e.label" :x="e.lx" :y="e.ly" font-size="10" fill="currentColor"
            text-anchor="middle" opacity="0.9">{{ e.label }}</text>
    </g>

    <g v-for="n in nodes" :key="n.id" class="transition-opacity duration-500"
       :style="{ opacity: step >= n.at ? 1 : 0 }">
      <rect :x="n.x" :y="n.y" :width="n.w" :height="n.h" rx="6"
            :fill="n.c" fill-opacity="0.13" :stroke="n.c" stroke-opacity="0.75" stroke-width="1.5" />
      <text
        v-for="(line, i) in n.lines"
        :key="i"
        :x="n.x + n.w / 2"
        :y="n.y + n.h / 2 + (n.lines.length === 1 ? 4 : i === 0 ? -2 : 11)"
        :font-size="n.lines.length === 1 ? 12 : i === 0 ? 12 : 9.5"
        text-anchor="middle"
        fill="currentColor"
        :opacity="i === 0 ? 0.95 : 0.6"
      >{{ line }}</text>
    </g>

    <text x="605" y="400" font-size="11" text-anchor="middle" fill="currentColor" opacity="0.6">
      server 只有這三樣 —— 全部打不開
    </text>
  </svg>
</template>
