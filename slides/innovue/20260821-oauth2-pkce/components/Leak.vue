<script setup lang="ts">
import { computed } from 'vue'
/**
 * 「他到底怎麼拿到 code 的」—— 演 RFC 9700 §4.1.1 的那個例子。
 *
 * 選這條路而不是 Referer／log，是因為它同時滿足兩件事：
 *   1. 每一段都是完好的 HTTPS，沒有一段被破 —— 洞不在傳輸上
 *   2. code 是 Authorization Server「自己送去」攻擊者網域的，
 *      因為終點是 redirect_uri 說了算，而那個值被攻擊者填了
 * 這正好呼應第二段：HTTPS 管的是路上，不管終點是誰。
 *
 * 網址與 pattern 都照 RFC 9700 §4.1.1 的原例，不要自己改編：
 *   登記 pattern  https://*.somesite.example/*
 *   攻擊者填的    https://attacker.example/.somesite.example
 *
 * step: 1 兩張網址並排 / 2 AS 比對通過 / 3 victim 在真的 AS 正常登入
 *       4 AS 發出 code / 5 code 被送去 attacker.example / 6 全線 HTTPS 都完好
 */
const props = withDefaults(defineProps<{ step?: number; h?: number }>(), { step: 0, h: 196 })

const T = '#2dd4bf'
const R = '#f87171'
const S = '#38bdf8'

/** code 從 Authorization Server 出發，落到攻擊者網域 */
const codePos = computed(() => (props.step >= 5 ? 'translate(754, 140)' : 'translate(404, 140)'))
</script>

<template>
  <div :style="{ height: h + 'px' }">
  <svg viewBox="0 0 900 196" class="w-full h-full">

    <!-- ── 兩張網址：登記的 pattern vs 攻擊者填的 redirect_uri ── -->
    <g :style="{ opacity: step >= 1 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="20" y="10" fill="currentColor" opacity="0.45" style="font-size: 10px">
        client 在 Authorization Server 登記的 pattern
      </text>
      <rect x="20" y="16" width="330" height="26" rx="5"
            fill="#2dd4bf0f" :stroke="T" stroke-opacity="0.6" stroke-width="2" />
      <text x="30" y="34" style="font-size: 11px" class="font-mono">
        <tspan fill="currentColor" opacity="0.75">https://</tspan><tspan
          :fill="T" style="font-weight: 700">*</tspan><tspan
          fill="currentColor" opacity="0.75">.somesite.example/</tspan><tspan
          :fill="T" style="font-weight: 700">*</tspan>
      </text>

      <text x="380" y="10" fill="currentColor" opacity="0.45" style="font-size: 10px">
        攻擊者送出的 authorization request 裡填的 redirect_uri
      </text>
      <rect x="380" y="16" width="400" height="26" rx="5"
            fill="#f871711a" :stroke="R" stroke-opacity="0.7" stroke-width="2" />
      <text x="390" y="34" style="font-size: 11px" class="font-mono">
        <tspan fill="currentColor" opacity="0.6">https://</tspan><tspan
          :fill="R" style="font-weight: 700">attacker.example</tspan><tspan
          fill="currentColor" opacity="0.6">/.somesite.example</tspan>
      </text>
    </g>

    <!-- AS 的比對結果 -->
    <text v-if="step >= 2" x="20" y="60" fill="currentColor" opacity="0.8" style="font-size: 11px">
      Authorization Server 拿 pattern 去比對 —— <tspan :fill="T" style="font-weight: 700">*</tspan>
      被當成「任何字元」，不是「網域名稱能用的字元」，所以這個網址
      <tspan :fill="R" style="font-weight: 700">通過了 ✓</tspan>
    </text>

    <!-- ── 三個節點 ── -->
    <rect x="20" y="76" width="160" height="54" rx="8"
          fill="#94a3b80f" stroke="currentColor" stroke-opacity="0.35" stroke-width="2" />
    <text x="100" y="107" text-anchor="middle" fill="currentColor" opacity="0.75"
          style="font-size: 12px">browser（victim）</text>

    <rect x="320" y="76" width="240" height="54" rx="8"
          fill="#38bdf80f" :stroke="S" stroke-opacity="0.7" stroke-width="2" />
    <text x="440" y="99" text-anchor="middle" :fill="S" style="font-size: 12px">Authorization Server</text>
    <text v-if="step >= 3" x="440" y="117" text-anchor="middle" :fill="S" opacity="0.7"
          style="font-size: 10px">victim 在這裡正常登入了</text>

    <rect x="700" y="76" width="180" height="54" rx="8"
          :fill="R" :fill-opacity="step >= 5 ? 0.16 : 0.04"
          :stroke="R" :stroke-opacity="step >= 5 ? 0.9 : 0.4" stroke-width="2"
          style="transition: all .6s" />
    <text x="790" y="99" text-anchor="middle" :fill="R" style="font-size: 12px">attacker.example</text>
    <text x="790" y="117" text-anchor="middle" :fill="R" opacity="0.6"
          style="font-size: 10px">攻擊者的網域</text>

    <!-- ── 兩段連線，每一段都是完好的 HTTPS ── -->
    <g v-for="seg in [{ x: 190, on: 3 }, { x: 570, on: 5 }]" :key="seg.x"
       :style="{ opacity: step >= seg.on ? 1 : 0.12, transition: 'opacity .5s' }">
      <rect :x="seg.x" y="84" width="120" height="38" rx="19"
            fill="#2dd4bf0f" :stroke="T" stroke-opacity="0.6" stroke-width="2" />
      <text :x="seg.x + 60" y="99" text-anchor="middle" :fill="T" style="font-size: 9px">
        HTTPS<tspan v-if="step >= 6" style="font-weight: 700"> ✓</tspan>
      </text>
      <line :x1="seg.x + 12" y1="112" :x2="seg.x + 96" y2="112"
            stroke="currentColor" stroke-opacity="0.55" stroke-width="2" />
      <polygon :points="`${seg.x + 96},107 ${seg.x + 108},112 ${seg.x + 96},117`"
               fill="currentColor" fill-opacity="0.55" />
    </g>

    <!-- ── code：Authorization Server 自己把它送去那個網址 ── -->
    <g :transform="codePos"
       :style="{ opacity: step >= 4 ? 1 : 0,
                 transition: 'transform 1s cubic-bezier(.5,0,.3,1), opacity .4s' }">
      <rect x="0" y="0" width="72" height="24" rx="4"
            fill="#f8717126" :stroke="R" stroke-width="2" />
      <text x="36" y="17" text-anchor="middle" :fill="R" style="font-size: 11px"
            class="font-mono">code</text>
    </g>

    <text v-if="step >= 5" x="880" y="186" text-anchor="end" :fill="R" style="font-size: 11px">
      code 落在攻擊者手上 —— 而我們的 client 從頭到尾不知道有這件事
    </text>

  </svg>
  </div>
</template>
