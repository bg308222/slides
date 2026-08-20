<script setup lang="ts">
import { computed } from 'vue'
/**
 * 第一段：從「大家熟悉的那張圖」長成規格的四個角色。
 *
 * 全場最重要的一次揭露在 step 4：user／browser／口語的「client 端」
 * 這三個一直被當成同義詞的東西，一起塌縮成單一個 Resource Owner。
 * step 0 只呈現大家腦中原本的模型（browser / server / google），不預先貼任何標籤，
 * 流程直接用箭頭在圖上演一遍。演完之後 step 1 才讓三個口語詞同時浮現 ——
 * 此刻畫面上同時存在兩個 client，那就是這一段要的痛點本身。
 *
 * 方塊用 HTML 絕對定位（CSS transition 對 left/top/width/height 最可靠），
 * 流程箭頭另外疊一層 SVG。座標寫死在 860×250 的內容區裡
 * （視覺規則：三欄水平位置全場不得改變）。
 *
 * step: 0 舊圖 / 1 server→Client / 2 google→Authorization Server
 *       3 browser→Resource Owner / 4 browser 以載具身分長出
 */
const props = withDefaults(defineProps<{ step?: number; flow?: number }>(), { step: 0, flow: 0 })

/** 三個框的邊界與中心；箭頭接在框緣，不從框中心長出來 */
const BOX = {
  browser: { l: 0,   r: 210, c: 105 },
  server:  { l: 325, r: 535, c: 430 },
  google:  { l: 650, r: 860, c: 755 },
}
/** 框的垂直範圍，與下方的絕對定位保持一致 */
const BOX_TOP = 40, BOX_H = 88
/** 箭頭不要貼死框緣，兩端各留一點空隙 */
const GAP = 5
/**
 * 車道。server ↔ google 之間往返四次，若共用一條線會出現反向箭頭對打，
 * 所以拆成上行（往左）與下行（往右）兩條；跨過中間那格的走最下面一條。
 */
const LANE = { up: 62, down: 106, low: 172 }

type Move = { from?: keyof typeof BOX; to?: keyof typeof BOX; pulse?: keyof typeof BOX; lane?: keyof typeof LANE; t: string }

/** 大家腦中原本那條流程。step 0 時直接在圖上演，一次一步。 */
const FLOW: Move[] = [
  { from: 'browser', to: 'google', lane: 'low',  t: '① user 被導到 google' },
  { pulse: 'google', t: '② user 在 google 登入' },
  { from: 'google', to: 'server', lane: 'up',   t: '③ google callback 回 server，帶著 code' },
  { from: 'server', to: 'google', lane: 'down', t: '④ server 帶 code + client_secret 去換' },
  { from: 'google', to: 'server', lane: 'up',   t: '⑤ google 回 token' },
  { from: 'server', to: 'google', lane: 'down', t: '⑥ 用 token 取得 user 資料' },
]

/** 把一步換算成畫得出來的線段：從來源框緣出發，停在目標框緣前 6px */
function geom(m: Move) {
  if (!m.from || !m.to) return null
  const a = BOX[m.from], b = BOX[m.to]
  const rightward = b.c > a.c
  const x1 = rightward ? a.r + GAP : a.l - GAP
  const x2 = rightward ? b.l - GAP : b.r + GAP
  const y = LANE[m.lane ?? 'up']
  return { x1, x2, y, len: Math.abs(x2 - x1), rightward }
}

const active = computed(() => (props.step === 0 ? Math.min(props.flow, FLOW.length) : 0))
/** 已經走過的步驟：留下淡痕，讓當前這一步不是長在空白上 */
const trail = computed(() =>
  FLOW.slice(0, Math.max(active.value - 1, 0)).map(geom).filter(Boolean),
)
const cur = computed(() => (active.value >= 1 ? FLOW[active.value - 1] : null))
const curGeom = computed(() => (cur.value ? geom(cur.value) : null))

const collapsed = computed(() => props.step >= 3)

/** 三欄的位置與尺寸全場固定（視覺規則）。塌縮時左欄只換身份與顏色，
 *  「三者聚合」的位移感由 user 標籤與幽靈 client 標籤提供。 */
const L = { left: 0, top: 40, w: 210, h: 88 }
</script>

<template>
  <div class="relative mx-auto" style="width: 860px; height: 232px">

    <!--
      大家腦中那條流程：直接在圖上演，一次一步。這裡還沒有「車」的概念，用箭頭就好。
      為了不讓箭頭憑空出現又憑空消失：
        · 底層永遠有一條淡通道，箭頭是長在既有的路上，不是長在空白裡
        · 當前這一步用 stroke-dashoffset 沿路徑「畫」出來，箭頭頭最後才落下
        · 走過的步驟留下淡痕，看得出流程在累積
    -->
    <svg viewBox="0 0 860 232" class="absolute inset-0 w-full h-full"
         style="pointer-events: none">

      <!-- 走過的淡痕 -->
      <g v-for="(g, i) in trail" :key="'t' + i" opacity="0.22">
        <line :x1="g.x1" :y1="g.y" :x2="g.x2" :y2="g.y"
              stroke="#fbbf24" stroke-width="2" />
        <polygon :points="`${g.x2},${g.y - 5} ${g.x2 + (g.rightward ? 9 : -9)},${g.y} ${g.x2},${g.y + 5}`"
                 fill="#fbbf24" />
      </g>

      <!-- 當前這一步：沿路徑畫出來 -->
      <g v-if="curGeom" :key="'c' + active">
        <line class="rolesGrow" :x1="curGeom.x1" :y1="curGeom.y" :x2="curGeom.x2" :y2="curGeom.y"
              stroke="#fbbf24" stroke-width="3" stroke-linecap="round"
              :style="{ '--len': curGeom.len }" />
        <polygon class="rolesHead"
                 :points="`${curGeom.x2},${curGeom.y - 6} ${curGeom.x2 + (curGeom.rightward ? 11 : -11)},${curGeom.y} ${curGeom.x2},${curGeom.y + 6}`"
                 fill="#fbbf24" />
      </g>

      <!-- ② 沒有跨角色的移動，改成把 google 那一格點亮 -->
      <g v-if="cur && cur.pulse" :key="'p' + active">
        <rect class="rolesPulse" :x="BOX[cur.pulse].l" :y="BOX_TOP"
              :width="BOX[cur.pulse].r - BOX[cur.pulse].l" :height="BOX_H" rx="8"
              fill="none" stroke="#fbbf24" stroke-width="3" />
      </g>

      <text v-if="cur" :key="'x' + active" class="rolesLabel" x="430" y="212"
            text-anchor="middle" fill="#fcd34d" style="font-size: 13px">{{ cur.t }}</text>
    </svg>

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



    <!-- 中欄：server → Client -->
    <div
      class="absolute rounded-lg border-2 flex flex-col items-center justify-center transition-all duration-700"
      :class="step >= 1 ? 'border-indigo-400/70 bg-indigo-400/10' : 'border-slate-400/50 bg-slate-400/5'"
      style="left: 325px; top: 40px; width: 210px; height: 88px"
    >
      <div class="font-bold transition-all duration-500"
           :class="step >= 1 ? 'text-indigo-300 text-lg' : 'opacity-80'">
        {{ step >= 1 ? 'Client' : 'server' }}
      </div>
      <div v-if="step >= 1" class="opacity-55 mt-1 text-center leading-tight px-2"
           style="font-size: 10.5px">
        做 code exchange 的那一個
      </div>
    </div>


    <!-- 右欄：google → Authorization Server -->
    <div
      class="absolute rounded-lg border-2 flex flex-col items-center justify-center transition-all duration-700"
      :class="step >= 2 ? 'border-sky-400/70 bg-sky-400/10' : 'border-slate-400/50 bg-slate-400/5'"
      style="left: 650px; top: 40px; width: 210px; height: 88px"
    >
      <div class="font-bold transition-all duration-500 text-center leading-tight"
           :class="step >= 2 ? 'text-sky-300 text-lg' : 'opacity-80'">
        {{ step >= 2 ? 'Authorization Server' : 'google' }}
      </div>
    </div>

    <!-- browser 以「載具」身分重新長出來（樣式刻意不同於角色框）。
         step<4 不渲染：第一段那張「大家腦中的模型」不該有這個東西。 -->
    <div
      v-if="step >= 3"
      class="absolute rounded-full border border-dashed border-amber-400/60 bg-amber-400/5 flex items-center justify-center transition-all duration-700"
      :style="{
        left: '25px', width: '160px', height: '46px',
        top: step >= 4 ? '142px' : '116px',
        opacity: step >= 4 ? 1 : 0,
      }"
    >
      <span class="text-amber-300" style="font-size: 12px">🚗 browser</span>
    </div>
    <div
      v-if="step >= 3"
      class="absolute text-center transition-opacity duration-700"
      style="left: 0px; width: 210px; top: 192px"
      :style="{ opacity: step >= 4 ? 1 : 0 }"
    >
      <span class="opacity-50" style="font-size: 10px">Resource Owner 透過它移動</span>
    </div>

  </div>
</template>

<style scoped>
.rolesGrow {
  stroke-dasharray: var(--len);
  animation: rolesDraw 0.28s cubic-bezier(.4, 0, .2, 1) forwards;
}
@keyframes rolesDraw {
  from { stroke-dashoffset: var(--len); }
  to   { stroke-dashoffset: 0; }
}
.rolesHead {
  transform-box: fill-box;
  transform-origin: center;
  animation: rolesPop 0.16s ease-out 0.24s both;
}
@keyframes rolesPop {
  from { opacity: 0; transform: scale(0.3); }
  to   { opacity: 1; transform: scale(1); }
}
.rolesPulse { animation: rolesPulse 1s ease-in-out infinite; }
@keyframes rolesPulse {
  0%, 100% { opacity: 0.3; }
  50%      { opacity: 1; }
}
.rolesLabel { animation: rolesFade 0.25s ease-out 0.08s both; }
@keyframes rolesFade {
  from { opacity: 0; }
  to   { opacity: 1; }
}
</style>
