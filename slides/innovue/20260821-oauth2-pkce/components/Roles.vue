<script setup lang="ts">
import { computed } from 'vue'
/**
 * 第一段：從「大家熟悉的那張圖」長成規格的四個角色。
 *
 * 全場最重要的一次揭露在 step 4：user／browser／口語的「client 端」
 * 這三個一直被當成同義詞的東西，一起塌縮成單一個 Resource Owner。
 * 為了讓「三者」在畫面上真的是三個物件，step 1 先把口語的那個
 * 「client？」以虛線幽靈標籤顯現出來 —— 此刻畫面上同時存在兩個 client，
 * 那就是 1.1 要的痛點本身。
 *
 * 用 HTML 絕對定位而非 SVG：這頁只有方塊位移，沒有連線，
 * CSS transition 對 left/top/width/height 最可靠。
 * 座標寫死在 860×360 的內容區裡（視覺規則：三欄水平位置全場不得改變）。
 *
 * step: 0 舊圖 / 1 幽靈 client 出現 / 2 server→Client / 3 google→AS
 *       4 塌縮成 RO / 5 browser 以載具身分長出
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const collapsed = computed(() => props.step >= 4)

/** 三欄的位置與尺寸全場固定（視覺規則）。塌縮時左欄只換身份與顏色，
 *  「三者聚合」的位移感由 user 標籤與幽靈 client 標籤提供。 */
const L = { left: 0, top: 40, w: 210, h: 88 }
</script>

<template>
  <div class="relative mx-auto" style="width: 860px; height: 250px">

    <!-- 左欄：browser → Resource Owner -->
    <div
      class="absolute rounded-lg border-2 flex flex-col items-center justify-center transition-all duration-700"
      :class="collapsed
        ? 'border-violet-400/70 bg-violet-400/10'
        : 'border-slate-400/50 bg-slate-400/5'"
      :style="{ left: L.left + 'px', top: L.top + 'px', width: L.w + 'px', height: L.h + 'px' }"
    >
      <div class="font-bold transition-all duration-500"
           :class="collapsed ? 'text-violet-300 text-lg' : 'opacity-80'">
        {{ collapsed ? 'Resource Owner' : 'browser' }}
      </div>
      <div v-if="collapsed" class="opacity-55 mt-1" style="font-size: 11px">就是「我這個人」</div>
    </div>

    <!-- 「user」標籤：塌縮時往 RO 中心聚合 -->
    <div
      class="absolute text-center transition-all duration-700"
      :style="{
        left: '0px', width: '210px',
        top: collapsed ? '84px' : '10px',
        opacity: collapsed ? 0 : 1,
      }"
    >
      <span class="px-2 py-0.5 rounded bg-violet-400/15 text-violet-300 border border-violet-400/40"
            style="font-size: 11px">user</span>
    </div>

    <!-- 口語的「client 端」幽靈標籤：step 1 出現（兩個 client 同框），塌縮時往 RO 中心聚合 -->
    <div
      class="absolute text-center transition-all duration-700"
      :style="{
        left: '0px', width: '210px',
        top: collapsed ? '84px' : '140px',
        opacity: step >= 1 && !collapsed ? 1 : 0,
      }"
    >
      <span class="px-2 py-0.5 rounded border border-dashed border-red-400/70 bg-red-400/10 text-red-300"
            style="font-size: 11px">你們口語說的「client 端」</span>
    </div>

    <!-- 中欄：server → Client -->
    <div
      class="absolute rounded-lg border-2 flex flex-col items-center justify-center transition-all duration-700"
      :class="step >= 2 ? 'border-indigo-400/70 bg-indigo-400/10' : 'border-slate-400/50 bg-slate-400/5'"
      style="left: 325px; top: 40px; width: 210px; height: 88px"
    >
      <div class="font-bold transition-all duration-500"
           :class="step >= 2 ? 'text-indigo-300 text-lg' : 'opacity-80'">
        {{ step >= 2 ? 'Client' : 'server' }}
      </div>
      <div v-if="step >= 2" class="opacity-55 mt-1 text-center leading-tight px-2"
           style="font-size: 10.5px">
        做 code exchange 的那一個
      </div>
    </div>

    <!-- 中欄下方那個「client」標籤：正名後消失（它已經變成框本身） -->
    <div
      class="absolute text-center transition-all duration-700"
      style="left: 325px; width: 210px"
      :style="{ top: '140px', opacity: step >= 2 ? 0 : 1 }"
    >
      <span class="px-2 py-0.5 rounded bg-red-400/15 text-red-300 border border-red-400/40"
            style="font-size: 11px">client</span>
    </div>

    <!-- 右欄：google → Authorization Server -->
    <div
      class="absolute rounded-lg border-2 flex flex-col items-center justify-center transition-all duration-700"
      :class="step >= 3 ? 'border-sky-400/70 bg-sky-400/10' : 'border-slate-400/50 bg-slate-400/5'"
      style="left: 650px; top: 40px; width: 210px; height: 88px"
    >
      <div class="font-bold transition-all duration-500 text-center leading-tight"
           :class="step >= 3 ? 'text-sky-300 text-lg' : 'opacity-80'">
        {{ step >= 3 ? 'Authorization Server' : 'google' }}
      </div>
    </div>

    <!-- browser 以「載具」身分重新長出來（樣式刻意不同於角色框） -->
    <div
      class="absolute rounded-full border border-dashed border-amber-400/60 bg-amber-400/5 flex items-center justify-center transition-all duration-700"
      :style="{
        left: '25px', width: '160px', height: '46px',
        top: step >= 5 ? '142px' : '116px',
        opacity: step >= 5 ? 1 : 0,
      }"
    >
      <span class="text-amber-300" style="font-size: 12px">🚗 browser</span>
    </div>
    <div
      class="absolute text-center transition-opacity duration-700"
      style="left: 0px; width: 210px; top: 192px"
      :style="{ opacity: step >= 5 ? 1 : 0 }"
    >
      <span class="opacity-50" style="font-size: 10px">載具 —— 載著 RO 受 Client / AS 調度</span>
    </div>

    <!-- 兩個 client 同框時的痛點提示 -->
    <div
      class="absolute text-center transition-opacity duration-500"
      style="left: 0px; width: 860px; top: 218px"
      :style="{ opacity: step === 1 ? 1 : 0 }"
    >
      <span class="px-3 py-1 rounded bg-red-400/10 border border-red-400/40 text-red-300"
            style="font-size: 12px">
        同一個字，兩個位置 —— 所以「verifier 是 server 產還是 client 產」在這張圖上問不出答案
      </span>
    </div>
  </div>
</template>
