<script setup lang="ts">
import { computed } from 'vue'
/**
 * 1.3：在固定的三欄上實際跑一次 OAuth。
 * 重點不是流程本身（聽眾已經會了），是 Resource Owner 透過瀏覽器移動這件事 ——
 * 他只在 Authorization Server 登入那一小段參與，其餘都是 Client 與 Authorization Server 在往來。
 * 車只是圖上的視覺隱喻，講稿與標籤一律用正式名詞。
 * 第 6 步之後車不再動，這件事必須看得出來。
 *
 * 三欄水平座標與 Roles.vue 對齊（視覺規則：全場不得改變）。
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

/** 車的位置：Resource Owner 處 → Authorization Server → 回 Client → 從此不動 */
const carX = computed(() => {
  if (props.step <= 2) return 40
  if (props.step <= 4) return 700
  return 350
})
const hasCode = computed(() => props.step >= 5)
</script>

<template>
  <div style="height: 232px">
  <svg viewBox="0 0 860 250" class="w-full h-full">
    <!-- 三欄 -->
    <rect x="20" y="30" width="150" height="70" rx="8"
          fill="#a78bfa1a" stroke="#a78bfab2" stroke-width="2" />
    <text x="95" y="60" text-anchor="middle" fill="#c4b5fd" style="font-size: 13px">Resource</text>
    <text x="95" y="78" text-anchor="middle" fill="#c4b5fd" style="font-size: 13px">Owner</text>

    <rect x="330" y="30" width="190" height="70" rx="8"
          fill="#818cf81a" stroke="#818cf8b2" stroke-width="2" />
    <text x="425" y="58" text-anchor="middle" fill="#a5b4fc" style="font-size: 14px">Client</text>
    <g :style="{ opacity: step >= 1 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="425" y="84" text-anchor="middle" fill="#a5b4fc" opacity="0.75"
            style="font-size: 10px">client_id · client_secret</text>
    </g>

    <rect x="690" y="30" width="150" height="70" rx="8"
          fill="#38bdf81a" stroke="#38bdf8b2" stroke-width="2" />
    <text x="765" y="60" text-anchor="middle" fill="#7dd3fc" style="font-size: 13px">Authorization</text>
    <text x="765" y="78" text-anchor="middle" fill="#7dd3fc" style="font-size: 13px">Server</text>

    <!-- 車道 -->
    <line x1="30" y1="180" x2="830" y2="180" stroke="currentColor" stroke-opacity="0.12"
          stroke-width="2" stroke-dasharray="6 6" />

    <!-- 車：Resource Owner 移動時的載具（純視覺） -->
    <g :transform="`translate(${carX}, 0)`" style="transition: transform 1.1s cubic-bezier(.5,0,.3,1)"
       :style="{ opacity: step >= 3 ? 1 : (step >= 2 ? 1 : 0.35) }">
      <rect x="0" y="140" width="120" height="44" rx="10"
            fill="#fbbf241f" stroke="#fbbf24bf" stroke-width="2" />
      <text x="60" y="160" text-anchor="middle" fill="#fcd34d" style="font-size: 11px">🚗 browser</text>
      <text x="60" y="176" text-anchor="middle" fill="#c4b5fd" style="font-size: 10px">Resource Owner</text>
      <circle cx="28" cy="188" r="7" fill="none" stroke="#fbbf2499" stroke-width="2" />
      <circle cx="92" cy="188" r="7" fill="none" stroke="#fbbf2499" stroke-width="2" />

      <!-- 牌子（code）掛在車身外 -->
      <g :style="{ opacity: hasCode ? 1 : 0, transition: 'opacity .5s' }">
        <line x1="104" y1="140" x2="104" y2="124" stroke="#f87171b2" stroke-width="2" />
        <rect x="68" y="98" width="76" height="26" rx="5"
              fill="#f8717126" stroke="#f87171d9" stroke-width="2" />
        <text x="106" y="116" text-anchor="middle" fill="#fca5a5" style="font-size: 11px">code</text>
      </g>
    </g>

    <!-- 車停住的標記 -->
    <g :style="{ opacity: step >= 6 ? 1 : 0, transition: 'opacity .5s' }">
      <text x="350" y="218" fill="currentColor" opacity="0.5" style="font-size: 11px">
        從這裡開始車就不再動了
      </text>
    </g>

    <!-- Client ⇄ Authorization Server：換 token、問資料 -->
    <g :style="{ opacity: step >= 6 ? 1 : 0, transition: 'opacity .5s' }">
      <line x1="524" y1="58" x2="684" y2="58" stroke="#a5b4fc99" stroke-width="2" />
      <polygon points="684,53 694,58 684,63" fill="#a5b4fc99" />
      <text x="604" y="48" text-anchor="middle" fill="#a5b4fc" opacity="0.8"
            style="font-size: 10px">code + client_secret</text>
    </g>
    <g :style="{ opacity: step >= 7 ? 1 : 0, transition: 'opacity .5s' }">
      <line x1="684" y1="86" x2="528" y2="86" stroke="#2dd4bfb2" stroke-width="2" />
      <polygon points="528,81 518,86 528,91" fill="#2dd4bfb2" />
      <text x="604" y="102" text-anchor="middle" fill="#5eead4" style="font-size: 10px">token</text>
    </g>
  </svg>
  </div>
</template>
