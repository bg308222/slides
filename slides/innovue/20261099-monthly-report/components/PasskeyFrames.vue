<script setup>
defineProps({
  step: { type: Number, default: 0 },
})
</script>

<template>
  <svg viewBox="0 0 880 290" class="w-full h-full pk">
    <!-- 左：原本 -->
    <text x="20" y="20" style="font-size: 14px; font-weight: 700" fill="currentColor">原本：WebAuthn 在 iframe 裡發生</text>
    <rect x="20" y="36" width="260" height="236" rx="8" fill="#64748b0f" stroke="#64748b" stroke-width="1.5" />
    <text x="32" y="56" style="font-size: 12px" fill="#64748b">top</text>
    <rect x="40" y="110" width="220" height="146" rx="6" fill="#3333b30f" stroke="#3333b3" stroke-width="1.5" />
    <text x="52" y="244" style="font-size: 12px" fill="#3333b3">子 iframe（EPS 主要頁面）</text>
    <rect x="60" y="150" width="180" height="36" rx="18" fill="#ffffff" stroke="#3333b3" stroke-width="1.5" />
    <text x="150" y="173" text-anchor="middle" style="font-size: 13px" fill="currentColor">呼叫 WebAuthn</text>
    <rect x="300" y="130" width="120" height="76" rx="8" fill="#64748b14" stroke="#64748b" stroke-width="1.5" />
    <text x="360" y="165" text-anchor="middle" style="font-size: 14px; font-weight: 700" fill="currentColor">Bitwarden</text>
    <text x="360" y="185" text-anchor="middle" style="font-size: 11px" fill="#64748b">瀏覽器擴充套件</text>

    <g v-if="step >= 1">
      <line
        x1="240" y1="168" x2="286" y2="168"
        stroke="#dc2626" stroke-width="2"
        stroke-dasharray="46" style="--len: 46"
        class="pk-draw"
      />
      <polygon points="286,162 300,168 286,174" fill="#dc2626" class="pk-head" />
      <g class="pk-label">
        <text x="360" y="230" text-anchor="middle" style="font-size: 12px" fill="#dc2626">✗ 目前不是 top frame</text>
        <text x="360" y="248" text-anchor="middle" style="font-size: 12px" fill="#dc2626">不跳 authenticator</text>
      </g>
    </g>

    <!-- 右：現在 -->
    <g v-if="step >= 2" class="pk-label">
      <text x="470" y="20" style="font-size: 14px; font-weight: 700" fill="currentColor">現在：WebAuthn 改在 top 發生</text>
      <rect x="470" y="36" width="265" height="236" rx="8" fill="#64748b0f" stroke="#64748b" stroke-width="1.5" />
      <text x="482" y="56" style="font-size: 12px" fill="#64748b">top</text>
      <rect x="490" y="66" width="225" height="34" rx="17" fill="#ffffff" stroke="#0d9488" stroke-width="1.5" />
      <text x="602" y="88" text-anchor="middle" style="font-size: 12px; font-family: 'Fira Code', monospace" fill="currentColor">window.passkeyRegistration</text>
      <rect x="485" y="120" width="235" height="136" rx="6" fill="#3333b30f" stroke="#3333b3" stroke-width="1.5" />
      <text x="497" y="244" style="font-size: 12px" fill="#3333b3">子 iframe（EPS 主要頁面）</text>
      <rect x="495" y="160" width="215" height="36" rx="18" fill="#ffffff" stroke="#3333b3" stroke-width="1.5" />
      <text x="602" y="182" text-anchor="middle" style="font-size: 11px; font-family: 'Fira Code', monospace" fill="currentColor">window.top.passkeyRegistration</text>
      <rect x="752" y="45" width="118" height="76" rx="8" fill="#64748b14" stroke="#64748b" stroke-width="1.5" />
      <text x="811" y="80" text-anchor="middle" style="font-size: 14px; font-weight: 700" fill="currentColor">Bitwarden</text>
      <text x="811" y="100" text-anchor="middle" style="font-size: 11px" fill="#64748b">瀏覽器擴充套件</text>
    </g>

    <g v-if="step >= 3">
      <line
        x1="602" y1="160" x2="602" y2="114"
        stroke="#0d9488" stroke-width="2"
        stroke-dasharray="46" style="--len: 46"
        class="pk-draw"
      />
      <polygon points="596,114 602,100 608,114" fill="#0d9488" class="pk-head" />
      <text x="612" y="140" style="font-size: 11px" fill="#0d9488" class="pk-label">呼叫 top 提供的方法</text>
    </g>

    <g v-if="step >= 4">
      <line
        x1="715" y1="83" x2="738" y2="83"
        stroke="#0d9488" stroke-width="2"
        stroke-dasharray="23" style="--len: 23"
        class="pk-draw"
      />
      <polygon points="738,77 752,83 738,89" fill="#0d9488" class="pk-head" />
      <g class="pk-label">
        <text x="811" y="145" text-anchor="middle" style="font-size: 12px" fill="#0d9488">✓ 在 top frame</text>
        <text x="811" y="163" text-anchor="middle" style="font-size: 12px" fill="#0d9488">跳出 authenticator</text>
      </g>
    </g>
  </svg>
</template>

<style scoped>
.pk-draw {
  animation: pk-draw 0.45s ease-out forwards;
}

@keyframes pk-draw {
  from {
    stroke-dashoffset: var(--len);
  }
  to {
    stroke-dashoffset: 0;
  }
}

.pk-head {
  opacity: 0;
  transform-box: fill-box;
  transform-origin: center;
  animation: pk-pop 0.2s ease-out 0.4s forwards;
}

@keyframes pk-pop {
  from {
    opacity: 0;
    transform: scale(0.4);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.pk-label {
  opacity: 0;
  animation: pk-fade 0.3s ease-out 0.15s forwards;
}

@keyframes pk-fade {
  to {
    opacity: 1;
  }
}
</style>
