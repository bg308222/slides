<script setup lang="ts">
/**
 * 4-5：server 不用證明自己。
 * 上半：Kerberos 的 200 帶著「我是真的」；NTLM 沒有。
 * 下半：中間的假 server 把真 server 的隨機數轉給你，再把你的回應轉回去。
 */
import { computed } from 'vue'
import Arrow from './Arrow.vue'

const props = defineProps<{ frame: number }>()
const C = { accent: '#f9a8d4', line: '#e2e8f0', red: '#f87171', white: '#f8fafc', purple: '#c084fc' }

const frames = [
  { step: '' },
  { step: 'Kerberos：server 可以回一份「我是真的」' },
  { step: 'NTLM：沒有這一份' },
  { step: '假 server 把真 server 的隨機數轉給你' },
  { step: '再把你的回應轉回去 → 以 andy 的身分登入' },
  { step: '你從來不知道對面是誰', tone: 'key' },
]
const f = computed(() => Math.min(props.frame, frames.length - 1))
const step = computed(() => frames[f.value].step)
const tone = computed(() => (frames[f.value] as any).tone ?? '')
</script>

<template>
  <div>
    <svg viewBox="0 0 880 370" class="w-full" style="height: 366px">
      <!-- 上半：兩列對照 -->
      <g :style="{ opacity: f >= 1 ? 1 : 0, transition: 'opacity 400ms' }">
        <text x="40" y="66" fill="#f1f5f9" style="font-size: 15px; font-weight: 700">Kerberos</text>
        <rect x="170" y="46" width="90" height="32" rx="6" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="215" y="67" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">你</text>
        <rect x="690" y="46" width="110" height="32" rx="6" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="745" y="67" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">server</text>
        <text x="475" y="54" text-anchor="middle" fill="#e5e7eb" style="font-size: 12px">200 ＋「我是真的」</text>
      </g>
      <Arrow d="M688 62 H264" tip="270,57 262,62 270,67" :on="f >= 1" :color="C.line" />
      <text x="215" y="96" text-anchor="middle" fill="#86efac" style="font-size: 12px"
            :style="{ opacity: f >= 1 ? 1 : 0, transition: 'opacity 300ms 600ms' }">✓ 確認對面是真的</text>

      <g :style="{ opacity: f >= 2 ? 1 : 0, transition: 'opacity 400ms' }">
        <text x="40" y="146" fill="#f1f5f9" style="font-size: 15px; font-weight: 700">NTLM</text>
        <rect x="170" y="126" width="90" height="32" rx="6" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="215" y="147" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">你</text>
        <rect x="690" y="126" width="110" height="32" rx="6" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="745" y="147" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px">server</text>
        <text x="475" y="134" text-anchor="middle" fill="#e5e7eb" style="font-size: 12px">200</text>
      </g>
      <Arrow d="M688 142 H264" tip="270,137 262,142 270,147" :on="f >= 2" :color="C.line" />
      <text x="215" y="176" text-anchor="middle" fill="#e2e8f0" style="font-size: 12px"
            :style="{ opacity: f >= 2 ? 1 : 0, transition: 'opacity 300ms 600ms' }">？ 不知道對面是誰</text>

      <line x1="30" y1="198" x2="850" y2="198" stroke="#ffffff1a" />

      <!-- 下半：轉送 -->
      <g :style="{ opacity: f >= 3 ? 1 : 0, transition: 'opacity 400ms' }">
        <rect x="60" y="250" width="130" height="44" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="125" y="277" text-anchor="middle" fill="#f1f5f9" style="font-size: 14px">你</text>
        <rect x="375" y="250" width="130" height="44" rx="8" fill="#f8717114" :stroke="C.red" />
        <text x="440" y="277" text-anchor="middle" fill="#fecaca" style="font-size: 14px">假 server</text>
        <rect x="690" y="250" width="130" height="44" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="755" y="277" text-anchor="middle" fill="#f1f5f9" style="font-size: 14px">真 server</text>
      </g>
      <Arrow d="M688 238 H508" tip="514,233 506,238 514,243" :on="f >= 3" :color="C.white" />
      <Arrow d="M373 238 H193" tip="199,233 191,238 199,243" :on="f >= 3" :color="C.white" :delay="500" />
      <text x="598" y="230" text-anchor="middle" fill="#f8fafc" style="font-size: 11.5px"
            :style="{ opacity: f >= 3 ? 1 : 0, transition: 'opacity 300ms' }">隨機數</text>
      <text x="283" y="230" text-anchor="middle" fill="#f8fafc" style="font-size: 11.5px"
            :style="{ opacity: f >= 3 ? 1 : 0, transition: 'opacity 300ms 500ms' }">隨機數（原封不動）</text>

      <Arrow d="M193 310 H373" tip="367,305 375,310 367,315" :on="f >= 4" :color="C.purple" />
      <Arrow d="M508 310 H688" tip="682,305 690,310 682,315" :on="f >= 4" :color="C.purple" :delay="500" />
      <text x="283" y="328" text-anchor="middle" fill="#f3e8ff" style="font-size: 11.5px"
            :style="{ opacity: f >= 4 ? 1 : 0, transition: 'opacity 300ms' }">andy ＋ 回應</text>
      <text x="598" y="328" text-anchor="middle" fill="#f3e8ff" style="font-size: 11.5px"
            :style="{ opacity: f >= 4 ? 1 : 0, transition: 'opacity 300ms 500ms' }">andy ＋ 回應（原封不動）</text>
      <text x="755" y="356" text-anchor="middle" :fill="C.red" style="font-size: 13px"
            :style="{ opacity: f >= 4 ? 1 : 0, transition: 'opacity 300ms 1100ms' }">✓ 以 andy 的身分登入</text>
    </svg>
    <div class="text-center" style="height: 30px; line-height: 30px; font-size: 15px"
         :style="{ color: tone === 'key' ? C.accent : '#cbd5e1', opacity: tone ? 1 : .85 }">{{ step }}</div>
  </div>
</template>
