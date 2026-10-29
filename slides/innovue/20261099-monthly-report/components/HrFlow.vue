<script setup>
defineProps({
  step: { type: Number, default: 0 },
})
</script>

<template>
  <svg viewBox="0 0 880 70" class="w-full h-full hr">
    <rect x="10" y="10" width="220" height="50" rx="8" fill="#3333b314" stroke="#3333b3" stroke-width="1.5" />
    <text x="120" y="41" text-anchor="middle" style="font-size: 15px" fill="currentColor">call 人資 API</text>

    <g v-if="step >= 1">
      <line
        x1="230" y1="35" x2="306" y2="35"
        stroke="#3333b3" stroke-width="2"
        stroke-dasharray="76" style="--len: 76"
        class="hr-draw"
      />
      <polygon points="306,29 320,35 306,41" fill="#3333b3" class="hr-head" />
      <g class="hr-label">
        <rect x="320" y="10" width="240" height="50" rx="8" fill="#3333b314" stroke="#3333b3" stroke-width="1.5" />
        <text x="440" y="41" text-anchor="middle" style="font-size: 15px" fill="currentColor">取得人員／部門資料</text>
      </g>
    </g>

    <g v-if="step >= 2">
      <line
        x1="560" y1="35" x2="636" y2="35"
        stroke="#0d9488" stroke-width="2"
        stroke-dasharray="76" style="--len: 76"
        class="hr-draw"
      />
      <polygon points="636,29 650,35 636,41" fill="#0d9488" class="hr-head" />
      <g class="hr-label">
        <rect x="650" y="10" width="220" height="50" rx="8" fill="#0d94881a" stroke="#0d9488" stroke-width="1.5" />
        <text x="760" y="41" text-anchor="middle" style="font-size: 15px" fill="currentColor">map 進三表</text>
      </g>
    </g>
  </svg>
</template>

<style scoped>
.hr-draw {
  animation: hr-draw 0.45s ease-out forwards;
}

@keyframes hr-draw {
  from {
    stroke-dashoffset: var(--len);
  }
  to {
    stroke-dashoffset: 0;
  }
}

.hr-head {
  opacity: 0;
  transform-box: fill-box;
  transform-origin: center;
  animation: hr-pop 0.2s ease-out 0.4s forwards;
}

@keyframes hr-pop {
  from {
    opacity: 0;
    transform: scale(0.4);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.hr-label {
  opacity: 0;
  animation: hr-fade 0.3s ease-out 0.35s forwards;
}

@keyframes hr-fade {
  to {
    opacity: 1;
  }
}
</style>
