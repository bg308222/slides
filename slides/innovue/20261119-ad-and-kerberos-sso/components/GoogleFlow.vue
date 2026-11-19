<script setup lang="ts">
/**
 * 第一章：把上次的 OIDC 流程搬過來，然後在同一張圖上圈出三塊。
 * step
 *   0 三欄
 *   1 第一次：導去 Google → 輸入帳密 → 帶著 id_token 回來
 *   2 第二次：同樣的流程，但 Google 已經記得你
 *   3 圈出 SSO        4 圈出 OIDC        5 圈出 Google
 *   6 換成這次的主題：OIDC → Kerberos、Google → AD
 */
import Arrow from './Arrow.vue'

const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const C = { line: '#e2e8f0', sso: '#fda4af', proto: '#93c5fd', idp: '#fcd34d' }
const vis = (on: boolean, o = 1) => ({ opacity: on ? o : 0, transition: 'opacity 400ms' })
</script>

<template>
  <svg viewBox="0 0 880 330" class="w-full" style="height: 330px">
    <!-- 三欄 -->
    <g v-for="c in [{ x: 30, cx: 120, t: '你（瀏覽器）' }, { x: 350, cx: 440, t: 'app' }, { x: 670, cx: 760, t: 'Google' }]" :key="c.t">
      <rect :x="c.x" y="20" width="180" height="36" rx="8" fill="#ffffff0d" stroke="#ffffff22" />
      <text :x="c.cx" y="44" text-anchor="middle" fill="#f1f5f9" style="font-size: 15px; font-weight: 700"
            :style="vis(!(c.t === 'Google' && props.step >= 6))">{{ c.t }}</text>
    </g>
    <text x="760" y="44" text-anchor="middle" :fill="C.idp" style="font-size: 15px; font-weight: 700"
          :style="vis(props.step >= 6)">AD</text>

    <!-- 第一次 -->
    <text x="22" y="110" fill="#cbd5e1" style="font-size: 11px" :style="vis(props.step >= 1, .7)">第一次</text>
    <Arrow d="M150 102 H420" tip="414,97 422,102 414,107" :on="props.step >= 1" :color="C.line" />
    <text x="285" y="94" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px" :style="vis(props.step >= 1, .85)">點「用 Google 登入」</text>
    <Arrow d="M460 102 H740" tip="734,97 742,102 734,107" :on="props.step >= 1" :color="C.line" :delay="250" />
    <text x="600" y="94" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px" :style="vis(props.step >= 1, .85)">導去 Google</text>
    <g :style="vis(props.step >= 1)">
      <rect x="712" y="112" width="96" height="26" rx="6" fill="#ffffff0a" stroke="#ffffff44" />
      <text x="760" y="130" text-anchor="middle" fill="#f1f5f9" style="font-size: 12px">輸入帳密</text>
    </g>
    <Arrow d="M740 150 H462" tip="468,145 460,150 468,155" :on="props.step >= 1" :color="C.line" :delay="500" />
    <text x="600" y="166" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px" :style="vis(props.step >= 1, .85)">帶著 id_token 回來</text>
    <text x="400" y="178" text-anchor="middle" fill="#f1f5f9" style="font-size: 12px" :style="vis(props.step >= 1)">✓ 登入</text>

    <!-- 第二次 -->
    <text x="22" y="230" fill="#cbd5e1" style="font-size: 11px" :style="vis(props.step >= 2, .7)">第二次</text>
    <Arrow d="M150 222 H420" tip="414,217 422,222 414,227" :on="props.step >= 2" :color="C.line" />
    <text x="285" y="214" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px" :style="vis(props.step >= 2, .85)">點「用 Google 登入」</text>
    <Arrow d="M460 222 H740" tip="734,217 742,222 734,227" :on="props.step >= 2" :color="C.line" :delay="250" />
    <text x="600" y="214" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px" :style="vis(props.step >= 2, .85)">導去 Google</text>
    <g :style="vis(props.step >= 2)">
      <rect x="712" y="232" width="96" height="26" rx="6" fill="#ffffff0a" stroke="#ffffff44" />
      <text x="760" y="250" text-anchor="middle" fill="#f1f5f9" style="font-size: 12px">記得你，免輸入</text>
    </g>
    <Arrow d="M740 270 H462" tip="468,265 460,270 468,275" :on="props.step >= 2" :color="C.line" :delay="500" />
    <text x="600" y="286" text-anchor="middle" fill="#cbd5e1" style="font-size: 11.5px" :style="vis(props.step >= 2, .85)">帶著 id_token 回來</text>
    <text x="400" y="292" text-anchor="middle" fill="#f1f5f9" style="font-size: 12px" :style="vis(props.step >= 2)">✓ 直接進去</text>

    <!-- 三個圈 -->
    <g :style="vis(props.step >= 3)">
      <rect x="14" y="198" width="852" height="106" rx="14" fill="none" :stroke="C.sso" stroke-width="2" stroke-dasharray="7 5" />
      <text x="26" y="322" :fill="C.sso" style="font-size: 14px; font-weight: 700">SSO：登入一次，之後直接進去</text>
    </g>
    <g :style="vis(props.step >= 4)">
      <rect x="455" y="72" width="235" height="226" rx="14" fill="none" :stroke="C.proto" stroke-width="2" stroke-dasharray="7 5" />
      <text x="572" y="322" text-anchor="middle" :fill="C.proto" style="font-size: 14px; font-weight: 700">{{ props.step >= 6 ? 'OIDC → Kerberos' : 'OIDC：整個流程' }}</text>
    </g>
    <g :style="vis(props.step >= 5)">
      <rect x="700" y="66" width="160" height="232" rx="14" fill="none" :stroke="C.idp" stroke-width="2" stroke-dasharray="7 5" />
      <text x="780" y="322" text-anchor="middle" :fill="C.idp" style="font-size: 14px; font-weight: 700">{{ props.step >= 6 ? 'Google → AD' : '身分擁有者' }}</text>
    </g>
  </svg>
</template>
