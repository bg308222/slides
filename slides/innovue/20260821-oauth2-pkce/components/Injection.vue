<script setup lang="ts">
import { computed } from 'vue'
/**
 * 3.4 authorization code injection —— 全場唯一無法用文字取代的一頁。
 * 5.3 重用同一個元件，只把 pkce 打開：同一張圖，不同結果。
 *
 * 兩條軌道刻意用完全相同的三欄座標（上 victim / 下 attacker）。
 * 最容易被誤解的是「攻擊者架了假 client」—— 他沒有，所以 Client 欄與 Authorization Server 欄
 * 被一個垂直虛線框貫穿，明寫「同一個」。
 *
 * 顏色即身份：victim = teal，attacker = fuchsia。
 * 最後一格 attacker 的欄位裡掛著一個 teal 的 token，顏色錯位就是那個洞。
 *
 * code_V 的兩段飛行都刻意跨越整個畫面（(285,58)→(690,362)→(285,234)），
 * 不是原地變色 —— 作者要求這一格顯眼到不可能感覺不到。
 *
 * SVG 文字一律用 inline style 設 font-size（presentation attribute 會被 theme 蓋掉）。
 */
const props = withDefaults(defineProps<{ step?: number; pkce?: boolean; h?: number }>(), {
  step: 0, pkce: false, h: 290,
})

const V = '#2dd4bf'     // victim
const A = '#e879f9'    // attacker
const N = 'currentColor'

/** code_V 的位置：上軌門口 → 攻擊者手上 → 下軌車上 */
const codeVPos = computed(() => {
  if (props.step <= 1) return 'translate(285, 42)'
  if (props.step <= 3) return 'translate(690, 252)'
  return 'translate(285, 170)'
})
const upDim = computed(() => (props.step >= 2 ? 0.28 : 1))
/** PKCE 開著時，比對在 step 6 就失敗，後面不再發 token */
const rejected = computed(() => props.pkce && props.step >= 6)
const issued = computed(() => !props.pkce && props.step >= 7)
</script>

<template>
  <div :style="{ height: h + 'px' }">
  <svg viewBox="0 0 900 290" class="w-full h-full">

    <!-- 貫穿兩軌的「同一個 client、同一個 Authorization Server」 -->
    <rect x="318" y="8" width="568" height="212" rx="10"
          fill="none" stroke="currentColor" stroke-opacity="0.3"
          stroke-width="2" stroke-dasharray="7 5" />
    <text x="602" y="238" text-anchor="middle" fill="currentColor"
          :opacity="rejected ? 0 : 0.55" style="font-size: 12px; transition: opacity .5s">
      同一個 client、同一個 Authorization Server —— 攻擊者沒有架假網站，他就是去用我們的網站
    </text>

    <!-- ── 上軌：victim ── -->
    <g :style="{ opacity: upDim, transition: 'opacity .7s' }">
      <text x="20" y="20" :fill="V" style="font-size: 12px">上軌 —— victim 的那一趟</text>
      <rect x="20" y="30" width="140" height="50" rx="8"
            :fill="V" fill-opacity="0.1"
            :stroke="V" stroke-opacity="0.7" stroke-width="2" />
      <text x="90" y="52" text-anchor="middle" :fill="V" style="font-size: 12px">Resource Owner</text>
      <text x="90" y="70" text-anchor="middle" :fill="V" style="font-size: 11px">（victim）</text>

      <rect x="330" y="30" width="190" height="50" rx="8" fill="none"
            stroke="#818cf8" stroke-opacity="0.7" stroke-width="2" />
      <text x="425" y="60" text-anchor="middle" fill="#a5b4fc" style="font-size: 13px">Client</text>

      <rect x="700" y="30" width="180" height="50" rx="8" fill="none"
            stroke="#38bdf8" stroke-opacity="0.7" stroke-width="2" />
      <text x="790" y="52" text-anchor="middle" fill="#7dd3fc" style="font-size: 12px">Authorization</text>
      <text x="790" y="70" text-anchor="middle" fill="#7dd3fc" style="font-size: 12px">Server</text>

      <text v-if="step >= 2" x="20" y="96" :fill="V" opacity="0.8" style="font-size: 11px">
        victim 這一趟甚至可能成功登入了 —— 他毫無感覺
      </text>
    </g>

    <!-- ── 下軌：attacker ── -->
    <g>
      <text x="20" y="146" :fill="A" style="font-size: 12px">下軌 —— attacker 的那一趟</text>
      <rect x="20" y="156" width="140" height="50" rx="8" fill-opacity="0.1"
            :fill="A" :stroke="A" stroke-opacity="0.7" stroke-width="2" />
      <text x="90" y="178" text-anchor="middle" :fill="A" style="font-size: 12px">Resource Owner</text>
      <text x="90" y="196" text-anchor="middle" :fill="A" style="font-size: 11px">（attacker）</text>

      <rect x="330" y="156" width="190" height="50" rx="8" fill="none"
            stroke="#818cf8" stroke-opacity="0.7" stroke-width="2" />
      <text x="425" y="178" text-anchor="middle" fill="#a5b4fc" style="font-size: 13px">Client</text>
      <text x="425" y="196" text-anchor="middle" fill="#a5b4fc" opacity="0.6"
            style="font-size: 10px">誠實的</text>

      <rect x="700" y="156" width="180" height="50" rx="8" fill="none"
            stroke="#38bdf8" stroke-opacity="0.7" stroke-width="2" />
      <text x="790" y="178" text-anchor="middle" fill="#7dd3fc" style="font-size: 12px">Authorization</text>
      <text x="790" y="196" text-anchor="middle" fill="#7dd3fc" style="font-size: 12px">Server</text>
    </g>

    <!-- 攻擊者手上（畫面外側的暫存格） -->
    <g :style="{ opacity: rejected ? 0 : (step >= 4 ? 0.25 : (step >= 2 ? 1 : 0)), transition: 'opacity .5s' }">
      <rect x="660" y="244" width="212" height="44" rx="8"
            :fill="A" fill-opacity="0.08" :stroke="A" stroke-opacity="0.6"
            stroke-width="2" stroke-dasharray="5 4" />
      <text x="766" y="272" text-anchor="middle" :fill="A" opacity="0.85"
            style="font-size: 11px">攻擊者手上</text>
    </g>

    <!-- attacker 自己那趟拿到的 code_A：注入時被丟掉 -->
    <g :transform="step >= 4 ? 'translate(285, 236)' : 'translate(285, 170)'"
       :style="{ opacity: step < 3 ? 0 : (step >= 4 ? 0 : 1), transition: 'all .8s ease-in-out' }">
      <rect x="0" y="0" width="86" height="30" rx="5" :fill="A" fill-opacity="0.15"
            :stroke="A" stroke-opacity="0.8" stroke-width="2" />
      <text x="43" y="20" text-anchor="middle" :fill="A" style="font-size: 12px">code_A</text>
    </g>

    <!-- ★ code_V：兩段長距離飛行 -->
    <g :transform="codeVPos" style="transition: transform 1.1s cubic-bezier(.6,0,.3,1)"
       :style="{ opacity: step >= 1 ? 1 : 0 }">
      <rect x="0" y="0" width="86" height="30" rx="5" :fill="V" fill-opacity="0.18"
            :stroke="V" stroke-width="2.5" />
      <text x="43" y="20" text-anchor="middle" :fill="V" style="font-size: 12px">code_V</text>
      <!-- 注入瞬間的紅閃 -->
      <rect v-if="step === 4" x="-5" y="-5" width="96" height="40" rx="7"
            fill="none" stroke="#f87171" stroke-width="3">
        <animate attributeName="opacity" values="1;0.15;1" dur="0.7s" repeatCount="4" />
      </rect>
    </g>

    <!-- 注入標記 -->
    <g :style="{ opacity: step === 4 ? 1 : 0, transition: 'opacity .4s' }">
      <text x="252" y="226" fill="#f87171" style="font-size: 15px" font-weight="bold">
        ↑ 這一格就是整場的洞
      </text>
    </g>

    <!-- Client 舉起 client_secret -->
    <g :style="{ opacity: step >= 5 ? 1 : 0, transition: 'opacity .5s' }">
      <rect x="386" y="112" width="128" height="28" rx="5"
            fill="#818cf826" stroke="#818cf8" stroke-width="2" />
      <text x="450" y="131" text-anchor="middle" fill="#a5b4fc"
            style="font-size: 11px">client_secret ✓ 用上了</text>
    </g>

    <!-- PKCE：Client 手上是 attacker 那趟的 verifier -->
    <g v-if="pkce" :style="{ opacity: step >= 5 ? 1 : 0, transition: 'opacity .5s' }">
      <rect x="386" y="80" width="128" height="28" rx="5"
            :fill="A" fill-opacity="0.12" :stroke="A" stroke-width="2" />
      <text x="450" y="99" text-anchor="middle" :fill="A" style="font-size: 11px">verifier（attacker 的）</text>
    </g>

    <!-- Client → Authorization Server 換 token -->
    <g :style="{ opacity: step >= 6 ? 1 : 0, transition: 'opacity .5s' }">
      <line x1="524" y1="182" x2="694" y2="182" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" />
      <polygon points="694,177 704,182 694,187" fill="currentColor" fill-opacity="0.5" />
    </g>

    <!-- 結果 A：沒有 PKCE → 發出 victim 的 token -->
    <g :style="{ opacity: issued ? 1 : 0, transition: 'opacity .6s' }">
      <g :transform="step >= 8 ? 'translate(28, 214)' : 'translate(700, 214)'"
         style="transition: transform 1s ease-in-out">
        <rect x="0" y="0" width="124" height="32" rx="5" :fill="V" fill-opacity="0.2"
              :stroke="V" stroke-width="2.5" />
        <text x="62" y="21" text-anchor="middle" :fill="V" style="font-size: 12px">victim 的 token</text>
      </g>
      <text v-if="step >= 8" x="20" y="266" :fill="A" style="font-size: 13px" font-weight="bold">
        attacker 的 session 裡，掛著一個屬於 victim 的 token
      </text>
    </g>

    <!-- 結果 B：有 PKCE → 比對不上，Authorization Server 拒絕 -->
    <g :style="{ opacity: rejected ? 1 : 0, transition: 'opacity .6s' }">
      <rect x="20" y="224" width="860" height="62" rx="8"
            fill="#f871711a" stroke="#f87171" stroke-width="2" />
      <text x="450" y="246" text-anchor="middle" fill="#fca5a5" style="font-size: 12px">
        code_V 綁的是 victim 那趟的挑戰值，Client 手上是 attacker 那趟的原值 —— 對不起來
      </text>
      <text x="450" y="270" text-anchor="middle" fill="#f87171" style="font-size: 14px"
            font-weight="bold">
        invalid_grant —— Authorization Server 不會發出任何 token，顏色錯位不會發生
      </text>
    </g>
  </svg>
  </div>
</template>
