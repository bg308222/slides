<script setup lang="ts">
/**
 * 2.1 的視覺基礎：code 不是躺在車廂裡的貨，是掛在車身外側的牌子。
 * 管線 = HTTPS。車在管線裡時牌子當然安全；車一到站，牌子還掛在那裡。
 * 這個語意在 2.3 與 3.4.0 都要被再引用一次。
 * step: 0 車在管線內 / 1 車已到站，牌子仍在 / 2 標出會抄走牌子的地方
 */
withDefaults(defineProps<{ step?: number }>(), { step: 0 })
</script>

<template>
  <div style="height: 200px">
  <svg viewBox="0 0 860 210" class="w-full h-full">
    <!-- HTTPS 管線 -->
    <rect x="20" y="55" width="560" height="86" rx="43"
          fill="#2dd4bf0f" stroke="#2dd4bf73" stroke-width="2" />
    <text x="42" y="46" fill="#2dd4bfcc" style="font-size: 12px">HTTPS 管線</text>
    <text x="42" y="164" fill="currentColor" opacity="0.4" style="font-size: 11px">
      裡面的內容偷不走 —— 這是事實
    </text>

    <!-- 到站 -->
    <line x1="600" y1="40" x2="600" y2="160" stroke="currentColor" stroke-opacity="0.25"
          stroke-width="2" stroke-dasharray="5 4" />
    <text x="612" y="46" fill="currentColor" opacity="0.45" style="font-size: 11px">到站</text>

    <!-- 車（含車身外的牌子），位置隨 step 位移 -->
    <g :transform="step >= 1 ? 'translate(640, 0)' : 'translate(120, 0)'"
       style="transition: transform 1s ease-in-out">
      <rect x="0" y="80" width="110" height="42" rx="10"
            fill="#fbbf241f" stroke="#fbbf24b2" stroke-width="2" />
      <text x="55" y="106" text-anchor="middle" fill="#fcd34d" style="font-size: 13px">🚗</text>
      <circle cx="26" cy="126" r="7" fill="none" stroke="#fbbf2499" stroke-width="2" />
      <circle cx="84" cy="126" r="7" fill="none" stroke="#fbbf2499" stroke-width="2" />

      <!-- 牌子：掛在車身「外面」，用一根短桿連著 -->
      <line x1="95" y1="80" x2="95" y2="62" stroke="#f87171b2" stroke-width="2" />
      <rect x="58" y="34" width="86" height="28" rx="5"
            fill="#f8717126" stroke="#f87171cc" stroke-width="2" />
      <text x="101" y="53" text-anchor="middle" fill="#fca5a5"
            style="font-size: 12px" class="font-mono">code</text>
    </g>

    <!-- 到站後的結論 -->
    <g :style="{ opacity: step >= 1 ? 1 : 0, transition: 'opacity .6s' }">
      <text x="852" y="186" text-anchor="end" fill="#fca5a5" style="font-size: 13px">
        車出了管線，牌子還掛在那裡 —— code 寫在 URL 上
      </text>
    </g>

    <g :style="{ opacity: step >= 2 ? 1 : 0, transition: 'opacity .6s' }">
      <text x="20" y="196" fill="currentColor" opacity="0.55" style="font-size: 11px">
        凡是會記錄或轉傳 URL 的地方，都在 HTTPS 的保護範圍之外
      </text>
    </g>
  </svg>
  </div>
</template>
