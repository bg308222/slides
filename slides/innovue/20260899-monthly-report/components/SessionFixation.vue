<script setup>
defineProps({
  step: { type: Number, default: 0 },
})
</script>

<template>
  <svg viewBox="0 0 880 348" class="w-full h-full sf">
    <!-- 三條泳道 -->
    <g>
      <rect x="15" y="8" width="180" height="44" rx="6" fill="#ef444414" stroke="#ef4444" stroke-width="1.5" />
      <text x="105" y="36" text-anchor="middle" style="font-size: 15px" fill="currentColor">攻擊者</text>
      <line x1="105" y1="56" x2="105" y2="340" stroke="#94a3b8" stroke-width="1" stroke-dasharray="3 4" />
    </g>
    <g>
      <rect x="350" y="8" width="180" height="44" rx="6" fill="#f59e0b14" stroke="#f59e0b" stroke-width="1.5" />
      <text x="440" y="36" text-anchor="middle" style="font-size: 15px" fill="currentColor">受害者</text>
      <line x1="440" y1="56" x2="440" y2="340" stroke="#94a3b8" stroke-width="1" stroke-dasharray="3 4" />
    </g>
    <g>
      <rect x="685" y="8" width="180" height="44" rx="6" fill="#64748b14" stroke="#64748b" stroke-width="1.5" />
      <text x="775" y="36" text-anchor="middle" style="font-size: 15px" fill="currentColor">EPSNet 站台</text>
      <line x1="775" y1="56" x2="775" y2="340" stroke="#94a3b8" stroke-width="1" stroke-dasharray="3 4" />
    </g>

    <!-- ① 攻擊者先向站台要一個 session id -->
    <g v-if="step >= 1">
      <text x="115" y="105" style="font-size: 13px" fill="currentColor" class="sf-label">
        ① 先自己連上站台，取得一個乾淨的 session id（S1）
      </text>
      <line
        x1="105" y1="118" x2="761" y2="118"
        stroke="#ef4444" stroke-width="2"
        stroke-dasharray="656" style="--len: 656"
        class="sf-draw"
      />
      <polygon points="761,112 775,118 761,124" fill="#ef4444" class="sf-head" />
    </g>

    <!-- ② 攻擊者把帶 S1 的連結給受害者 -->
    <g v-if="step >= 2">
      <text x="115" y="177" style="font-size: 13px" fill="currentColor" class="sf-label">
        ② 用帶著 S1 的連結，誘使受害者進入登入頁
      </text>
      <line
        x1="105" y1="190" x2="426" y2="190"
        stroke="#ef4444" stroke-width="2"
        stroke-dasharray="321" style="--len: 321"
        class="sf-draw"
      />
      <polygon points="426,184 440,190 426,196" fill="#ef4444" class="sf-head" />
    </g>

    <!-- ③ 受害者登入，站台沒換發 session -->
    <g v-if="step >= 3">
      <text x="450" y="249" style="font-size: 13px" fill="currentColor" class="sf-label">
        ③ 受害者用 S1 登入成功，站台沒有換發新的 session
      </text>
      <line
        x1="440" y1="262" x2="761" y2="262"
        stroke="#f59e0b" stroke-width="2"
        stroke-dasharray="321" style="--len: 321"
        class="sf-draw"
      />
      <polygon points="761,256 775,262 761,268" fill="#f59e0b" class="sf-head" />
    </g>

    <!-- ④ 結論 -->
    <g v-if="step >= 4" class="sf-label">
      <rect x="15" y="298" width="850" height="42" rx="6" fill="#ef44441f" stroke="#ef4444" stroke-width="1.5" />
      <text x="440" y="325" text-anchor="middle" style="font-size: 14px" fill="currentColor">
        ④ 攻擊者手上原本那組 S1，現在就是一個已登入的 session
      </text>
    </g>
  </svg>
</template>

<style scoped>
.sf-draw {
  animation: sf-draw 0.55s ease-out forwards;
}

@keyframes sf-draw {
  from {
    stroke-dashoffset: var(--len);
  }
  to {
    stroke-dashoffset: 0;
  }
}

.sf-head {
  opacity: 0;
  transform-box: fill-box;
  transform-origin: center;
  animation: sf-pop 0.2s ease-out 0.5s forwards;
}

@keyframes sf-pop {
  from {
    opacity: 0;
    transform: scale(0.4);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.sf-label {
  opacity: 0;
  animation: sf-fade 0.3s ease-out 0.15s forwards;
}

@keyframes sf-fade {
  to {
    opacity: 1;
  }
}
</style>
