<script setup lang="ts">
/**
 * P7 與 P9 是同一張表。P7 只有「裸 SHA-256」那一欄，
 * 第二欄的位置從第一頁就留好了（欄寬寫死、內容只調 opacity），
 * 所以 P9 是「填進去」，不是「擠出來」—— 每一列的位置一格都不會動。
 *
 * 第一列是「算一次的單價」，後兩列才是「跑完整個空間」。
 * 有了單價那一列，×150 萬倍才是從表上直接讀出來的，不是講者宣稱的。
 *
 *   0  只有欄名
 *   1  算一次（單價）
 *   2  6 碼純數字
 *   3  8 碼英數                    ← P7 停在這裡
 *   4  PBKDF2 那一欄長出來
 *   5  橫著看：單價那一列 ×150 萬
 *   6  直著看：框住 6 碼數字那一列
 */
const props = withDefaults(defineProps<{
  step?: number
  /** 是否替「橫著看／直著看」預留空間。P7 用不到那兩句，關掉才不會把下面的東西擠出畫面。
   *  這個區塊在表格「下方」，關掉不會動到表格本身的位置，P7/P9 的表格仍然對齊。 */
  reserveConclusions?: boolean
}>(), { step: 0, reserveConclusions: true })

const rows = [
  {
    what: '算一次', sub: '單價',
    bare: '45 皮秒', bareSub: '一秒 220 億次',
    slow: '68 微秒', slowSub: '一秒 1.5 萬次',
  },
  {
    what: '跑完 6 碼純數字', sub: '10⁶ 種',
    bare: '45 微秒', slow: '約 1 分鐘',
  },
  {
    what: '跑完 8 碼英數', sub: '62⁸ ≈ 2.2 × 10¹⁴ 種',
    bare: '約 3 小時', slow: '約 470 年',
  },
]

const shown = (i: number) => props.step >= i + 1
const pb = () => props.step >= 4

/** 橫著看先亮單價那一列，直著看再框六碼數字那一列 */
const rowBg = (i: number) => {
  if (props.step === 5 && i === 0) return 'bg-teal-400/10'
  if (props.step >= 6 && i === 1) return 'bg-red-400/10'
  return ''
}
</script>

<template>
<div class="mx-auto" style="max-width: 740px">

  <table class="w-full text-left" style="table-layout: fixed; border-collapse: separate; border-spacing: 0 4px">
    <colgroup>
      <col style="width: 42%"><col style="width: 29%"><col style="width: 29%">
    </colgroup>
    <thead>
      <tr>
        <th class="pb-1 pl-3 font-normal opacity-40" style="font-size: 11px">單張 RTX 4090</th>
        <th class="pb-1 pl-3 font-normal text-amber-300/70" style="font-size: 11px">裸 SHA-256</th>
        <th
          class="pb-1 pl-3 font-normal text-teal-300/80" style="font-size: 11px"
          :style="{ opacity: pb() ? 1 : 0, transition: 'opacity 420ms ease' }"
        >PBKDF2-SHA256 @600k</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(r, i) in rows" :key="r.what"
        :style="{ opacity: shown(i) ? 1 : 0, transition: 'opacity 400ms ease' }"
      >
        <td class="pl-3 rounded-l" style="height: 52px" :class="rowBg(i)">
          <div :style="{ fontSize: '14px', fontWeight: i === 0 ? 600 : 400 }">{{ r.what }}</div>
          <div class="opacity-40 font-mono" style="font-size: 10.5px">{{ r.sub }}</div>
        </td>
        <td class="pl-3 text-amber-300" style="height: 52px" :class="rowBg(i)">
          <div style="font-size: 15px">{{ r.bare }}</div>
          <div class="opacity-50" style="font-size: 10.5px">{{ r.bareSub || '' }}</div>
        </td>
        <td
          class="pl-3 text-teal-300 rounded-r" style="height: 52px" :class="rowBg(i)"
          :style="{ opacity: pb() ? 1 : 0, transition: 'opacity 420ms ease 120ms' }"
        >
          <div style="font-size: 15px">{{ r.slow }}</div>
          <div class="opacity-50" style="font-size: 10.5px">{{ r.slowSub || '' }}</div>
        </td>
      </tr>
    </tbody>
  </table>

  <!-- 它在講「後兩列」，所以要等那兩列真的都在了才出現；用 opacity 而不是 v-if，位置一開始就佔住 -->
  <div class="mt-2 pl-3" style="font-size: 11px"
       :style="{ opacity: step >= 3 ? 0.5 : 0, transition: 'opacity 380ms ease' }">
    後兩列是<span class="text-amber-300/80">把整個空間跑完</span>的時間。真實攻擊會先跑字典與規則，通常還更快。
  </div>

  <!-- 兩個結論的空間一開始就留好，不會把表格往上頂 -->
  <div v-if="reserveConclusions" class="mt-4 space-y-2" style="min-height: 74px">
    <div
      class="flex items-baseline gap-3"
      :style="{ opacity: step >= 5 ? 1 : 0, transition: 'opacity 380ms ease' }"
    >
      <span class="text-teal-300 shrink-0" style="font-size: 12px; width: 62px">橫著看</span>
      <span style="font-size: 14px">
        同一個單價，被乘了 <b class="text-teal-300">約 150 萬倍</b>。這就是 iterations 買到的東西。
      </span>
    </div>
    <div
      class="flex items-baseline gap-3"
      :style="{ opacity: step >= 6 ? 1 : 0, transition: 'opacity 380ms ease' }"
    >
      <span class="text-red-300 shrink-0" style="font-size: 12px; width: 62px">直著看</span>
      <span style="font-size: 14px">
        六碼數字那格，乘完 <b class="text-red-300">也只有一分鐘</b>。它只是把每一格乘上同一個常數。
      </span>
    </div>
  </div>

</div>
</template>
