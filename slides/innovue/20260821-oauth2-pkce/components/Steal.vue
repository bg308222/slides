<script setup lang="ts">
import { computed } from 'vue'
/**
 * 第二段的洞：code 究竟怎麼離開 browser、怎麼落到惡意 app 手上。
 * 這一頁只演「怎麼被偷」——token endpoint 檢查什麼是下一頁的事，不要混進來。
 *
 * 主角是那塊「網址牌」：code 是寫在網址上的，不是躺在管線裡的貨。
 * 牌子從 Authorization Server 出發、沿 HTTPS 管線送到 browser，
 * 然後在 browser 這裡掉出管線、交給作業系統 ——
 * 這一交之後就沒有 HTTPS 了，誰接到全看 scheme 註冊表說了算。
 * （原本 2.1 那張獨立的管線圖已刪除，那個前提改由這一頁直接演出來。）
 *
 * step: 1 Authorization Server 回 302，code 就寫在網址上
 *       2 沿管線送回 browser
 *       3 myapp:// 不是 https → browser 交給作業系統（跨過 HTTPS 那條線）
 *       4 查註冊表 → 我們的 app，正常落地
 *       5 惡意 app 也登記了同一個 scheme
 *       6 同一個 callback 再來一次 → 這次交給惡意 app
 *
 * SVG 的 fill 一律用 8 位 hex（CSS Color 4 的 `rgb(... / ...)` 在 attribute 裡會光柵化錯誤），
 * font-size 一律 inline style（presentation attribute 會被 theme 蓋掉）。
 */
const props = withDefaults(defineProps<{ step?: number; h?: number }>(), { step: 0, h: 292 })

const T = '#2dd4bf'   // 安全／我們的 app
const R = '#f87171'   // code 牌子／惡意 app

/** 網址牌的位置：AS → browser → 交給作業系統 → 我們的 app →（同一件事再一次）→ 惡意 app */
const platePos = computed(() => {
  const s = props.step
  if (s <= 1) return 'translate(40, 56)'
  if (s === 2) return 'translate(423, 56)'
  if (s === 3) return 'translate(423, 116)'
  if (s === 4) return 'translate(186, 266)'
  if (s === 5) return 'translate(423, 116)'
  return 'translate(556, 266)'
})
</script>

<template>
  <div :style="{ height: h + 'px' }">
  <svg viewBox="0 0 900 306" class="w-full h-full">

    <!-- ── HTTPS 的世界：Authorization Server → 管線 → browser ── -->
    <text x="314" y="15" text-anchor="middle" :fill="T" opacity="0.75" style="font-size: 10.5px">
      HTTPS
    </text>
    <rect x="214" y="22" width="200" height="72" rx="36"
          fill="#2dd4bf0f" stroke="#2dd4bf73" stroke-width="2" />

    <rect x="30" y="22" width="180" height="72" rx="10"
          fill="#94a3b80f" stroke="currentColor" stroke-opacity="0.35" stroke-width="2" />
    <text x="120" y="44" text-anchor="middle" fill="currentColor" opacity="0.75"
          style="font-size: 12.5px">Authorization Server</text>

    <rect x="418" y="22" width="180" height="72" rx="10"
          fill="#94a3b80f" stroke="currentColor" stroke-opacity="0.35" stroke-width="2" />
    <text x="508" y="44" text-anchor="middle" fill="currentColor" opacity="0.75"
          style="font-size: 12.5px">browser</text>

    <!-- ── HTTPS 的邊界。牌子跨過這條線，就再也沒有保護了 ── -->
    <g :style="{ opacity: step >= 3 ? 1 : 0, transition: 'opacity .6s' }">
      <line x1="20" y1="108" x2="880" y2="108"
            :stroke="R" stroke-opacity="0.55" stroke-width="2" stroke-dasharray="8 6" />
      <text x="876" y="101" text-anchor="end" :fill="R" style="font-size: 11.5px">
        HTTPS 的保護到此為止
      </text>
    </g>

    <!-- ── 作業系統的 scheme 註冊表 ── -->
    <g :style="{ opacity: step >= 3 ? 1 : 0.15, transition: 'opacity .6s' }">
      <rect x="250" y="152" width="400" height="76" rx="10"
            fill="#94a3b80f" stroke="currentColor" stroke-opacity="0.3" stroke-width="2" />
      <text x="450" y="173" text-anchor="middle" fill="currentColor" opacity="0.7"
            style="font-size: 12.5px">作業系統：誰註冊了 myapp:// ？</text>

      <g :style="{ opacity: step >= 4 ? 1 : 0, transition: 'opacity .5s' }">
        <text x="272" y="196" :fill="T" style="font-size: 12px" class="font-mono">myapp://</text>
        <text x="352" y="196" fill="currentColor" opacity="0.45" style="font-size: 12px">→</text>
        <text x="376" y="196" :fill="T" style="font-size: 12px">我們的 app</text>
      </g>

      <g :style="{ opacity: step >= 5 ? 1 : 0, transition: 'opacity .5s' }">
        <text x="272" y="218" :fill="R" style="font-size: 12px" class="font-mono">myapp://</text>
        <text x="352" y="218" fill="currentColor" opacity="0.45" style="font-size: 12px">→</text>
        <text x="376" y="218" :fill="R" style="font-size: 12px">惡意 app</text>
        <text x="466" y="218" :fill="R" opacity="0.7" style="font-size: 10.5px">
          ← 誰都能登記，沒有所有權驗證
        </text>
      </g>
    </g>

    <!-- ── 兩個接得到 callback 的 app ── -->
    <g :style="{ opacity: step >= 3 ? 1 : 0.15, transition: 'opacity .6s' }">
      <rect x="150" y="240" width="230" height="62" rx="10"
            fill="#2dd4bf0f" :stroke="T" stroke-opacity="0.6" stroke-width="2" />
      <text x="265" y="259" text-anchor="middle" :fill="T" style="font-size: 12.5px">
        我們的 app（Client）
      </text>
    </g>

    <g :style="{ opacity: step >= 5 ? 1 : 0, transition: 'opacity .6s' }">
      <rect x="520" y="240" width="230" height="62" rx="10"
            fill="#f871711a" :stroke="R" stroke-opacity="0.7" stroke-width="2" />
      <text x="635" y="259" text-anchor="middle" :fill="R" style="font-size: 12.5px">惡意 app</text>
    </g>

    <!-- ── 網址牌本體：code 就寫在上面 ── -->
    <g :transform="platePos"
       :style="{ opacity: step >= 1 ? 1 : 0,
                 transition: 'transform 1s cubic-bezier(.4,0,.2,1), opacity .4s' }">
      <rect x="0" y="0" width="158" height="30" rx="6"
            fill="#f8717126" :stroke="R" stroke-width="2" />
      <text x="10" y="20" style="font-size: 10.5px" class="font-mono">
        <tspan fill="#fca5a5" opacity="0.7">myapp://cb?</tspan><tspan
          fill="#fca5a5" style="font-weight: 700">code=AbC9x…</tspan>
      </text>
    </g>

  </svg>
  </div>
</template>
