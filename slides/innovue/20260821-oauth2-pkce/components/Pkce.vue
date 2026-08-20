<script setup lang="ts">
/**
 * PKCE 擋下 injection —— 這一頁唯一要讓人看懂的是「誰持有什麼」。
 *
 * 所以每一格東西都畫在持有者的框裡，不會憑空出現：
 *   上軌 client  →  verifier_V（這一趟現場產的，留在自己身上）
 *   上軌 AS      →  code_V ↔ challenge_V（AS 把 challenge 記在 code 旁邊）
 *   下軌 client  →  verifier_A（attacker 那一趟是**另一份**）
 *   攻擊者       →  只有 code_V，沒有任何 verifier
 *
 * 中間那條虛線帶是「走網址」的區間 —— 只有會出現在網址上的東西才進得去。
 * verifier 從頭到尾不進那條帶子，這就是整頁的結論。
 *
 * step: 1 client 產 verifier_V / 2 challenge_V 上網址 / 3 AS 記下並發 code_V
 *       4 攻擊者拿到 code_V（上一段那條路）/ 5 attacker 自己跑一趟，產出另一份
 *       6 注入：回程的 code_A 被換成 code_V
 *       7 client 誠實換 token：code_V + client_secret + verifier_A
 *       8 AS 重算比對 → 對不起來
 */
withDefaults(defineProps<{ step?: number; h?: number }>(), { step: 0, h: 322 })

const V = '#2dd4bf'
const A = '#e879f9'
const I = '#818cf8'
const S = '#38bdf8'
const R = '#f87171'
</script>

<template>
  <div :style="{ height: h + 'px' }">
  <svg viewBox="0 0 900 322" class="w-full h-full">

    <!-- ══ 上軌：victim ══ -->
    <text x="20" y="12" :fill="V" style="font-size: 11px">上軌 —— victim 的那一趟</text>

    <rect x="20" y="22" width="120" height="44" rx="8"
          :fill="V" fill-opacity="0.1" :stroke="V" stroke-opacity="0.7" stroke-width="2" />
    <text x="80" y="49" text-anchor="middle" :fill="V" style="font-size: 12px">victim</text>

    <rect x="290" y="18" width="210" height="90" rx="8" fill="none"
          :stroke="I" stroke-opacity="0.7" stroke-width="2" />
    <text x="395" y="36" text-anchor="middle" fill="#a5b4fc" style="font-size: 12px">Client</text>

    <rect x="690" y="18" width="190" height="90" rx="8" fill="none"
          :stroke="S" stroke-opacity="0.7" stroke-width="2" />
    <text x="785" y="36" text-anchor="middle" fill="#7dd3fc" style="font-size: 11px">Authorization Server</text>

    <g :style="{ opacity: step >= 1 ? 1 : 0, transition: 'opacity .5s' }">
      <rect x="300" y="46" width="120" height="22" rx="4"
            :fill="V" fill-opacity="0.18" :stroke="V" stroke-width="2" />
      <text x="360" y="61" text-anchor="middle" :fill="V" style="font-size: 10px"
            class="font-mono">verifier_V</text>
      <text x="300" y="84" fill="currentColor" opacity="0.5" style="font-size: 9px">
        這一趟現場產的，留在這裡
      </text>
    </g>

    <g :style="{ opacity: step >= 3 ? 1 : 0, transition: 'opacity .5s' }">
      <rect x="700" y="46" width="170" height="22" rx="4"
            :fill="S" fill-opacity="0.14" :stroke="S" stroke-width="2" />
      <text x="785" y="61" text-anchor="middle" fill="#7dd3fc" style="font-size: 10px"
            class="font-mono">code_V ↔ challenge_V</text>
      <text x="700" y="84" fill="currentColor" opacity="0.5" style="font-size: 9px">
        AS 把 challenge 記在 code 旁邊
      </text>
    </g>

    <!-- ══ 下軌：attacker ══ -->
    <text x="20" y="174" :fill="A" style="font-size: 11px">下軌 —— attacker 的那一趟</text>

    <rect x="20" y="184" width="120" height="44" rx="8"
          :fill="A" fill-opacity="0.1" :stroke="A" stroke-opacity="0.7" stroke-width="2" />
    <text x="80" y="211" text-anchor="middle" :fill="A" style="font-size: 12px">attacker</text>

    <rect x="290" y="180" width="210" height="90" rx="8" fill="none"
          :stroke="I" stroke-opacity="0.7" stroke-width="2" />
    <text x="395" y="198" text-anchor="middle" fill="#a5b4fc" style="font-size: 12px">Client</text>
    <text x="395" y="212" text-anchor="middle" fill="#a5b4fc" opacity="0.6"
          style="font-size: 9px">同一個，誠實的</text>

    <rect x="690" y="180" width="190" height="90" rx="8" fill="none"
          :stroke="S" stroke-opacity="0.7" stroke-width="2" />
    <text x="785" y="198" text-anchor="middle" fill="#7dd3fc" style="font-size: 11px">Authorization Server</text>

    <g :style="{ opacity: step >= 5 ? 1 : 0, transition: 'opacity .5s' }">
      <rect x="300" y="222" width="120" height="22" rx="4"
            :fill="A" fill-opacity="0.18" :stroke="A" stroke-width="2" />
      <text x="360" y="237" text-anchor="middle" :fill="A" style="font-size: 10px"
            class="font-mono">verifier_A</text>
      <text x="300" y="258" fill="currentColor" opacity="0.5" style="font-size: 9px">
        這一趟產的是<tspan style="font-weight: 700">另一份</tspan>
      </text>

      <rect x="700" y="222" width="170" height="22" rx="4"
            :fill="S" fill-opacity="0.14" :stroke="S" stroke-width="2" />
      <text x="785" y="237" text-anchor="middle" fill="#7dd3fc" style="font-size: 10px"
            class="font-mono">code_A ↔ challenge_A</text>
    </g>

    <!-- ══ 中間：走網址的區間。會外流的東西只會出現在這裡 ══ -->
    <g v-for="b in [{ y: 18 }, { y: 180 }]" :key="b.y">
      <rect x="516" :y="b.y" width="158" height="90" rx="8" fill="none"
            stroke="currentColor" stroke-opacity="0.22" stroke-width="2" stroke-dasharray="6 5" />
    </g>
    <text x="595" y="12" text-anchor="middle" fill="currentColor" opacity="0.45"
          style="font-size: 9px">走網址的只有這些</text>

    <!-- 上軌：challenge 出去、code 回來 -->
    <g :style="{ opacity: step >= 2 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="595" y="40" text-anchor="middle" :fill="V" style="font-size: 10px"
            class="font-mono">challenge_V</text>
      <line x1="524" y1="52" x2="660" y2="52" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" />
      <polygon points="660,47 672,52 660,57" fill="currentColor" fill-opacity="0.5" />
    </g>
    <g :style="{ opacity: step >= 3 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="595" y="82" text-anchor="middle" :fill="V" style="font-size: 10px"
            class="font-mono">code_V</text>
      <line x1="666" y1="94" x2="530" y2="94" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" />
      <polygon points="530,89 518,94 530,99" fill="currentColor" fill-opacity="0.5" />
    </g>

    <!-- 下軌：challenge_A 出去；回程被換掉 -->
    <g :style="{ opacity: step >= 5 && step < 7 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="595" y="202" text-anchor="middle" :fill="A" style="font-size: 10px"
            class="font-mono">challenge_A</text>
      <line x1="524" y1="214" x2="660" y2="214" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" />
      <polygon points="660,209 672,214 660,219" fill="currentColor" fill-opacity="0.5" />

      <line x1="666" y1="262" x2="530" y2="262" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" />
      <polygon points="530,257 518,262 530,267" fill="currentColor" fill-opacity="0.5" />

      <text v-if="step === 5" x="595" y="248" text-anchor="middle" :fill="A" style="font-size: 10px"
            class="font-mono">code_A</text>

      <g v-if="step >= 6">
        <text x="556" y="250" text-anchor="end" fill="currentColor" opacity="0.35"
              style="font-size: 9px; text-decoration: line-through" class="font-mono">code_A</text>
        <rect x="564" y="234" width="76" height="22" rx="4"
              :fill="V" fill-opacity="0.18" :stroke="V" stroke-width="2" />
        <text x="602" y="249" text-anchor="middle" :fill="V" style="font-size: 10px"
              class="font-mono">code_V</text>
        <rect v-if="step === 6" x="559" y="229" width="86" height="32" rx="6"
              fill="none" :stroke="R" stroke-width="2.5">
          <animate attributeName="opacity" values="1;0.15;1" dur="0.7s" repeatCount="4" />
        </rect>
      </g>
    </g>

    <!-- 下軌：誠實的 client 送出 code exchange -->
    <g :style="{ opacity: step >= 7 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="595" y="196" text-anchor="middle" fill="currentColor" opacity="0.85"
            style="font-size: 10px">client 誠實地送出 →</text>
      <rect x="522" y="202" width="146" height="62" rx="6"
            fill="#818cf826" :stroke="I" stroke-width="2" />
      <text x="534" y="219" :fill="V" style="font-size: 10px" class="font-mono">code_V</text>
      <text x="534" y="237" fill="#a5b4fc" style="font-size: 10px" class="font-mono">client_secret</text>
      <text x="534" y="255" :fill="A" style="font-size: 10px" class="font-mono">verifier_A</text>
      <polygon points="674,227 686,233 674,239" fill="currentColor" fill-opacity="0.5" />
    </g>

    <!-- 攻擊者手上：只有 code_V，沒有任何 verifier -->
    <g :style="{ opacity: step >= 4 ? 1 : 0, transition: 'opacity .5s' }">
      <rect x="20" y="236" width="250" height="34" rx="8"
            :fill="A" fill-opacity="0.08" :stroke="A" stroke-opacity="0.6"
            stroke-width="2" stroke-dasharray="5 4" />
      <text x="30" y="258" :fill="A" opacity="0.85" style="font-size: 10px">攻擊者手上：</text>
      <rect x="112" y="242" width="70" height="22" rx="4"
            :fill="V" fill-opacity="0.18" :stroke="V" stroke-width="2" />
      <text x="147" y="257" text-anchor="middle" :fill="V" style="font-size: 10px"
            class="font-mono">code_V</text>
      <text x="190" y="258" fill="currentColor" opacity="0.45" style="font-size: 9px">
        （上一段那條路）
      </text>
    </g>

    <!-- 比對失敗 -->
    <g :style="{ opacity: step >= 8 ? 1 : 0, transition: 'opacity .6s' }">
      <rect x="20" y="278" width="860" height="40" rx="8"
            fill="#f871711a" :stroke="R" stroke-width="2" />
      <text x="450" y="295" text-anchor="middle" fill="#fca5a5" style="font-size: 11px">
        Authorization Server 查 code_V 綁的是 challenge_V，但 client 交來的是 verifier_A
      </text>
      <text x="450" y="312" text-anchor="middle" :fill="R" style="font-size: 12.5px"
            font-weight="bold">
        S256(verifier_A) ≠ challenge_V → invalid_grant，不發 token
      </text>
    </g>

  </svg>
  </div>
</template>
