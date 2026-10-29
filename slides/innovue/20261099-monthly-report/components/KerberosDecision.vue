<script setup>
defineProps({
  step: { type: Number, default: 0 },
})
</script>

<template>
  <svg viewBox="0 0 880 350" class="w-full h-full kd">
    <!-- 起點：瀏覽器要的是 EPS 的 Service Ticket -->
    <rect x="10" y="0" width="860" height="36" rx="6" fill="#3333b314" stroke="#3333b3" stroke-width="1.5" />
    <text x="440" y="24" text-anchor="middle" style="font-size: 14px" fill="currentColor">
      進入 EPS → 瀏覽器要拿出的是「EPS 的 Service Ticket」
    </text>

    <rect x="30" y="60" width="200" height="40" rx="6" fill="#ffffff" stroke="#64748b" stroke-width="1.5" />
    <text x="130" y="85" text-anchor="middle" style="font-size: 14px" fill="currentColor">有 Service Ticket？</text>

    <!-- ① 已有 ST -->
    <g v-if="step >= 1">
      <text x="300" y="72" style="font-size: 12px" fill="#0d9488" class="kd-label">有</text>
      <line
        x1="230" y1="80" x2="546" y2="80"
        stroke="#0d9488" stroke-width="2"
        stroke-dasharray="316" style="--len: 316"
        class="kd-draw"
      />
      <polygon points="546,74 560,80 546,86" fill="#0d9488" class="kd-head" />
      <g class="kd-label">
        <rect x="560" y="60" width="300" height="40" rx="6" fill="#0d94881a" stroke="#0d9488" stroke-width="1.5" />
        <text x="710" y="85" text-anchor="middle" style="font-size: 14px" fill="currentColor">直接用票證完成驗證 → 登入</text>
      </g>
    </g>

    <!-- ② 沒有 ST，但有 TGT -->
    <g v-if="step >= 2">
      <text x="140" y="130" style="font-size: 12px" fill="#64748b" class="kd-label">沒有</text>
      <line
        x1="130" y1="100" x2="130" y2="136"
        stroke="#64748b" stroke-width="2"
        stroke-dasharray="36" style="--len: 36"
        class="kd-draw"
      />
      <polygon points="124,136 130,150 136,136" fill="#64748b" class="kd-head" />
      <g class="kd-label">
        <rect x="30" y="150" width="200" height="40" rx="6" fill="#ffffff" stroke="#64748b" stroke-width="1.5" />
        <text x="130" y="175" text-anchor="middle" style="font-size: 14px" fill="currentColor">有 TGT？</text>
      </g>
      <text x="252" y="162" style="font-size: 12px" fill="#0d9488" class="kd-label">有</text>
      <line
        x1="230" y1="170" x2="286" y2="170"
        stroke="#0d9488" stroke-width="2"
        stroke-dasharray="56" style="--len: 56"
        class="kd-draw"
      />
      <polygon points="286,164 300,170 286,176" fill="#0d9488" class="kd-head" />
      <g class="kd-label">
        <rect x="300" y="150" width="210" height="40" rx="6" fill="#ffffff" stroke="#0d9488" stroke-width="1.5" />
        <text x="405" y="175" text-anchor="middle" style="font-size: 13px" fill="currentColor">用 TGT 向 KDC 換 ST</text>
      </g>
      <line
        x1="510" y1="170" x2="546" y2="170"
        stroke="#0d9488" stroke-width="2"
        stroke-dasharray="36" style="--len: 36"
        class="kd-draw"
      />
      <polygon points="546,164 560,170 546,176" fill="#0d9488" class="kd-head" />
      <g class="kd-label">
        <rect x="560" y="150" width="300" height="40" rx="6" fill="#0d94881a" stroke="#0d9488" stroke-width="1.5" />
        <text x="710" y="175" text-anchor="middle" style="font-size: 14px" fill="currentColor">帶票驗證 → 登入，不跳任何視窗</text>
      </g>
    </g>

    <!-- ③ 沒有 TGT -->
    <g v-if="step >= 3">
      <text x="140" y="220" style="font-size: 12px" fill="#64748b" class="kd-label">沒有</text>
      <line
        x1="130" y1="190" x2="130" y2="226"
        stroke="#64748b" stroke-width="2"
        stroke-dasharray="36" style="--len: 36"
        class="kd-draw"
      />
      <polygon points="124,226 130,240 136,226" fill="#64748b" class="kd-head" />
      <g class="kd-label">
        <rect x="30" y="240" width="200" height="40" rx="6" fill="#ffffff" stroke="#d97706" stroke-width="1.5" />
        <text x="130" y="265" text-anchor="middle" style="font-size: 14px" fill="currentColor">要先取得 TGT</text>
      </g>
      <line
        x1="230" y1="260" x2="286" y2="260"
        stroke="#dc2626" stroke-width="2"
        stroke-dasharray="56" style="--len: 56"
        class="kd-draw"
      />
      <polygon points="286,254 300,260 286,266" fill="#dc2626" class="kd-head" />
      <g class="kd-label">
        <rect x="300" y="232" width="560" height="56" rx="6" fill="#dc26260f" stroke="#dc2626" stroke-width="1.5" />
        <text x="314" y="255" style="font-size: 13px" fill="currentColor">會不會跳出登入窗，取決於瀏覽器與作業系統的設定</text>
        <text x="314" y="277" style="font-size: 13px" fill="#dc2626">ubuntu、mac 不會跳 → Kerberos SSO 失敗 → 401 不支援頁</text>
        <text x="852" y="277" text-anchor="end" style="font-size: 12px; font-weight: 700" fill="#dc2626">← 新 Mac</text>
      </g>
    </g>

    <!-- ④ 結論 -->
    <g v-if="step >= 4" class="kd-label">
      <rect x="10" y="306" width="860" height="40" rx="6" fill="#3333b31a" stroke="#3333b3" stroke-width="1.5" />
      <text x="440" y="331" text-anchor="middle" style="font-size: 15px; font-weight: 700" fill="currentColor">
        會不會直接登入，差別只在電腦上有沒有 TGT
      </text>
    </g>
  </svg>
</template>

<style scoped>
.kd-draw {
  animation: kd-draw 0.45s ease-out forwards;
}

@keyframes kd-draw {
  from {
    stroke-dashoffset: var(--len);
  }
  to {
    stroke-dashoffset: 0;
  }
}

.kd-head {
  opacity: 0;
  transform-box: fill-box;
  transform-origin: center;
  animation: kd-pop 0.2s ease-out 0.4s forwards;
}

@keyframes kd-pop {
  from {
    opacity: 0;
    transform: scale(0.4);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.kd-label {
  opacity: 0;
  animation: kd-fade 0.3s ease-out 0.15s forwards;
}

@keyframes kd-fade {
  to {
    opacity: 1;
  }
}
</style>
