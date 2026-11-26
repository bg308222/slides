<script setup lang="ts">
/**
 * 4-6 全貌：401 Negotiate → 瀏覽器 → OS → Kerberos／NTLM 分岔 → Authorization: Negotiate … → server。
 */
import Arrow from './Arrow.vue'

const props = defineProps<{ on: boolean }>()
const C = { accent: '#f9a8d4', line: '#e2e8f0', gold: '#fbbf24', blue: '#60a5fa', purple: '#c084fc' }
</script>

<template>
  <svg viewBox="0 0 880 250" class="w-full" style="height: 246px">
    <g :style="{ opacity: props.on ? 1 : 0, transition: 'opacity 300ms' }">
      <rect x="10" y="100" width="130" height="50" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
      <text x="75" y="121" text-anchor="middle" fill="#f1f5f9" style="font-size: 12px">server 回</text>
      <text x="75" y="139" text-anchor="middle" :fill="C.accent" style="font-size: 12px">401 Negotiate</text>

      <rect x="180" y="100" width="100" height="50" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
      <text x="230" y="130" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">瀏覽器</text>

      <rect x="320" y="100" width="90" height="50" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
      <text x="365" y="130" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">OS</text>
    </g>

    <g :style="{ opacity: props.on ? 1 : 0, transition: 'opacity 300ms 900ms' }">
      <rect x="470" y="30" width="210" height="58" rx="8" fill="#60a5fa14" :stroke="C.blue" />
      <text x="575" y="54" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">換得到 ST → Kerberos</text>
      <text x="575" y="75" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px">server 用自己的金鑰驗</text>

      <rect x="470" y="162" width="210" height="58" rx="8" fill="#c084fc14" :stroke="C.purple" />
      <text x="575" y="186" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">換不到 → NTLM</text>
      <text x="575" y="207" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px">server 每次都問 AD</text>
    </g>

    <g :style="{ opacity: props.on ? 1 : 0, transition: 'opacity 300ms 1600ms' }">
      <rect x="720" y="92" width="150" height="66" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
      <text x="795" y="114" text-anchor="middle" fill="#e5e7eb" style="font-size: 11px">Authorization:</text>
      <text x="795" y="131" text-anchor="middle" fill="#e5e7eb" style="font-size: 11px">Negotiate …</text>
      <text x="795" y="150" text-anchor="middle" fill="#f1f5f9" style="font-size: 12px">→ server ✓</text>
    </g>

    <Arrow d="M142 125 H176" tip="170,120 178,125 170,130" :on="props.on" :color="C.line" :delay="200" />
    <Arrow d="M282 125 H316" tip="310,120 318,125 310,130" :on="props.on" :color="C.line" :delay="450" />
    <Arrow d="M412 118 C 440 118, 440 59, 466 59" tip="460,54 468,59 460,64" :on="props.on" :color="C.blue" :delay="700" />
    <Arrow d="M412 132 C 440 132, 440 191, 466 191" tip="460,186 468,191 460,196" :on="props.on" :color="C.purple" :delay="700" />
    <Arrow d="M682 59 C 700 59, 700 112, 716 112" tip="710,107 718,112 710,117" :on="props.on" :color="C.blue" :delay="1350" />
    <Arrow d="M682 191 C 700 191, 700 138, 716 138" tip="710,133 718,138 710,143" :on="props.on" :color="C.purple" :delay="1350" />
  </svg>
</template>
