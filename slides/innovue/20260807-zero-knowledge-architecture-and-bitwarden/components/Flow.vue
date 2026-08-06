<script setup lang="ts">
import { computed } from 'vue'

/**
 * 第四段：register → login → unlock → lock → logout 一步一步走。
 * 順序是刻意的：login 停在「東西拿回來但還鎖著」，接下來那段就是 unlock，
 * 平常被合在一起，這裡拆開來看。
 *
 * 客戶端分三塊，座標從頭到尾固定（視覺規則 B-1）：
 *   記憶體    —— 明文只住這裡，用完就清空
 *   硬碟      —— 只住鎖著的東西
 *   你自己拿著 —— session key 不留在裝置上，是交到使用者手上的
 *
 * 所以 lock 不是「清記憶體」（unlock 完記憶體本來就空了），
 * 而是把硬碟上「被 session key 鎖的那一份」刪掉 —— 舊的 session key
 * 就此作廢：不是被撤銷，是它能開的東西不見了。
 *
 * 每個 frame 只列出「這一刻存在的東西」；hot 是剛動到的格子，
 * dim 是還在但已經沒用的，hints 是它右邊那句話。
 *
 * SVG 文字一律用 inline style 設 font-size（presentation attribute 會被 theme 蓋掉）。
 */
const props = withDefaults(defineProps<{ phase?: string; step?: number }>(), {
  phase: 'register',
  step: 0,
})

const C = {
  seed: '#a78bfa',
  key: '#2dd4bf',
  hash: '#fbbf24',
  data: '#38bdf8',
}

type Obj = { x: number; y: number; w: number; h: number; c: string; t: string; lock?: boolean }

const MW = 200
const SW = 240

const OBJ: Record<string, Obj> = {
  // 記憶體
  pw:    { x: 36, y: 66,  w: MW, h: 26, c: C.seed, t: 'master password' },
  mk:    { x: 36, y: 98,  w: MW, h: 26, c: C.key,  t: 'Master Key' },
  mph:   { x: 36, y: 130, w: MW, h: 26, c: C.hash, t: 'Master Password Hash' },
  sk:    { x: 36, y: 162, w: MW, h: 26, c: C.key,  t: 'Symmetric Key' },
  vault: { x: 36, y: 194, w: MW, h: 26, c: C.data, t: 'vault（明文）' },
  // 硬碟
  dpsk:    { x: 36, y: 256, w: MW, h: 26, c: C.key,  t: 'Protected Symmetric Key', lock: true },
  devault: { x: 36, y: 288, w: MW, h: 26, c: C.data, t: '加密的 vault', lock: true },
  dsess:   { x: 36, y: 320, w: MW, h: 26, c: C.seed, t: 'Symmetric Key', lock: true },
  // 你自己拿著
  sess:  { x: 36, y: 378, w: MW, h: 26, c: C.seed, t: 'session key' },
  // server
  smph:    { x: 515, y: 110, w: SW, h: 30, c: C.hash, t: 'Master Password Hash' },
  spsk:    { x: 515, y: 215, w: SW, h: 30, c: C.key,  t: 'Protected Symmetric Key', lock: true },
  sevault: { x: 515, y: 320, w: SW, h: 30, c: C.data, t: '加密的 vault', lock: true },
}

type Frame = {
  on: string[]
  hot?: string[]
  dim?: string[]
  hints?: Record<string, string>
  up?: boolean
  down?: boolean
}

const SERVER_ALL = ['smph', 'spsk', 'sevault']
const CLIENT_ALL = ['pw', 'mk', 'mph', 'sk', 'vault', 'dpsk', 'devault']
/** login 停下來的地方：東西拿回來了，但還是鎖著的 */
const FETCHED = [...SERVER_ALL, 'pw', 'mk', 'dpsk', 'devault']
/** unlock 完：記憶體全空，能開東西的只剩使用者手上那把 */
const UNLOCKED = ['sess', 'dpsk', 'devault', 'dsess', ...SERVER_ALL]
/** lock 完：硬碟上被 session key 鎖的那份被刪掉，session key 隨之作廢 */
const LOCKED = ['sess', 'dpsk', 'devault', ...SERVER_ALL]

const PHASES: Record<string, Frame[]> = {
  register: [
    { on: [] },
    { on: ['pw'], hot: ['pw'], hints: { pw: '你打進去的' } },
    { on: ['pw', 'mk'], hot: ['mk'], hints: { mk: '密碼算出來的' } },
    { on: ['pw', 'mk', 'mph'], hot: ['mph'], hints: { mph: '再算一次，給 server 看' } },
    { on: ['pw', 'mk', 'mph', 'sk'], hot: ['sk'], hints: { sk: '隨機生的，跟密碼無關' } },
    { on: ['pw', 'mk', 'mph', 'sk', 'vault'], hot: ['vault'], hints: { vault: '你要保護的東西' } },
    {
      on: ['pw', 'mk', 'mph', 'sk', 'vault', 'devault'],
      hot: ['devault'], hints: { devault: '被 Symmetric Key 鎖住' },
    },
    {
      on: ['pw', 'mk', 'mph', 'sk', 'vault', 'devault', 'dpsk'],
      hot: ['dpsk'], hints: { dpsk: '被 Master Key 鎖住' },
    },
    { on: [...CLIENT_ALL, ...SERVER_ALL], hot: SERVER_ALL, up: true },
    { on: SERVER_ALL },
  ],
  login: [
    { on: SERVER_ALL },
    { on: [...SERVER_ALL, 'pw'], hot: ['pw'], hints: { pw: '你打進去的' } },
    { on: [...SERVER_ALL, 'pw', 'mk'], hot: ['mk'], hints: { mk: '密碼算出來的' } },
    { on: [...SERVER_ALL, 'pw', 'mk', 'mph'], hot: ['mph'], hints: { mph: '要送出去的那個' } },
    { on: [...SERVER_ALL, 'pw', 'mk', 'mph'], hot: ['mph', 'smph'], up: true },
    {
      on: [...SERVER_ALL, 'pw', 'mk', 'mph', 'dpsk', 'devault'],
      hot: ['dpsk', 'devault'], down: true,
    },
    { on: FETCHED, hot: ['dpsk', 'devault'], hints: { dpsk: '還是鎖著的', devault: '還是鎖著的' } },
  ],
  unlock: [
    { on: FETCHED },
    { on: [...FETCHED, 'sk'], hot: ['sk'], hints: { sk: 'Master Key 解開的' } },
    { on: [...FETCHED, 'sk', 'sess'], hot: ['sess'], hints: { sess: '隨機生的，直接交給你' } },
    {
      on: [...FETCHED, 'sk', 'sess', 'dsess'],
      hot: ['dsess'], hints: { dsess: '被 session key 鎖住的那一份' },
    },
    { on: UNLOCKED, hot: ['sess'], hints: { sess: '能開硬碟那份的，只剩它' } },
  ],
  lock: [
    { on: UNLOCKED },
    { on: LOCKED, hot: ['dpsk', 'devault'], hints: { dpsk: '一個 byte 都沒動', devault: '一個 byte 都沒動' } },
    {
      on: LOCKED,
      dim: ['sess'],
      hints: { sess: '它能開的東西不見了 —— 等於作廢' },
    },
  ],
  logout: [
    { on: LOCKED, dim: ['sess'] },
    { on: SERVER_ALL },
    { on: SERVER_ALL, hot: SERVER_ALL },
  ],
}

const frame = computed<Frame>(() => {
  const fs = PHASES[props.phase] ?? PHASES.register
  return fs[Math.max(0, Math.min(props.step, fs.length - 1))]
})

const shown = (id: string) => frame.value.on.includes(id)
const isHot = (id: string) => Boolean(frame.value.hot?.includes(id))
const isDim = (id: string) => Boolean(frame.value.dim?.includes(id))
const hint = (id: string) => frame.value.hints?.[id] ?? ''
</script>

<template>
  <svg viewBox="0 0 780 436" class="w-full" style="max-height: 380px">
    <!-- 你的裝置 -->
    <rect x="10" y="24" width="410" height="398" rx="10"
          fill="#2dd4bf" fill-opacity="0.04" stroke="#2dd4bf" stroke-opacity="0.3" stroke-width="1.5" />
    <text x="24" y="42" fill="currentColor" :style="{ fontSize: '9.5px', letterSpacing: '1.4px', opacity: 0.45 }">
      你的裝置
    </text>

    <rect x="22" y="50" width="386" height="178" rx="8"
          fill="none" stroke="currentColor" stroke-opacity="0.22" stroke-width="1.2" stroke-dasharray="5 4" />
    <text x="32" y="62" fill="currentColor" :style="{ fontSize: '9px', opacity: 0.42 }">記憶體 —— 明文只住這裡，用完就清空</text>

    <rect x="22" y="240" width="386" height="112" rx="8"
          fill="none" stroke="currentColor" stroke-opacity="0.22" stroke-width="1.2" stroke-dasharray="5 4" />
    <text x="32" y="252" fill="currentColor" :style="{ fontSize: '9px', opacity: 0.42 }">硬碟 —— 只住鎖著的東西</text>

    <rect x="22" y="358" width="386" height="54" rx="8"
          fill="none" :stroke="C.seed" stroke-opacity="0.32" stroke-width="1.2" stroke-dasharray="5 4" />
    <text x="32" y="372" :fill="C.seed" :style="{ fontSize: '9px', opacity: 0.7 }">你自己拿著 —— 不在裝置上，只有你知道</text>

    <!-- SERVER -->
    <rect x="490" y="24" width="280" height="398" rx="10"
          fill="#94a3b8" fill-opacity="0.04" stroke="#94a3b8" stroke-opacity="0.3" stroke-width="1.5" />
    <text x="504" y="42" fill="currentColor" :style="{ fontSize: '9.5px', letterSpacing: '1.4px', opacity: 0.45 }">
      SERVER
    </text>

    <!-- 傳輸 -->
    <g class="transition-opacity duration-500" :style="{ opacity: frame.up ? 1 : 0 }">
      <path d="M428,230 H478" fill="none" :stroke="C.key" stroke-width="2.6" />
      <polygon points="478,223 490,230 478,237" :fill="C.key" />
      <text x="453" y="218" text-anchor="middle" :fill="C.key" :style="{ fontSize: '10px' }">送上去</text>
    </g>
    <g class="transition-opacity duration-500" :style="{ opacity: frame.down ? 1 : 0 }">
      <path d="M482,230 H432" fill="none" :stroke="C.data" stroke-width="2.6" />
      <polygon points="432,223 420,230 432,237" :fill="C.data" />
      <text x="455" y="218" text-anchor="middle" :fill="C.data" :style="{ fontSize: '10px' }">拉回來</text>
    </g>

    <!-- 格子 -->
    <g v-for="(o, id) in OBJ" :key="id" class="transition-opacity duration-500"
       :style="{ opacity: shown(id) ? (isDim(id) ? 0.32 : 1) : 0 }">
      <rect
        :x="o.x" :y="o.y" :width="o.w" :height="o.h" rx="6"
        :fill="o.c" :fill-opacity="isHot(id) ? 0.24 : 0.11"
        :stroke="o.c" :stroke-opacity="isHot(id) ? 1 : 0.6"
        :stroke-width="isHot(id) ? 2.4 : 1.4"
        class="transition-all duration-500"
      />
      <text :x="o.x + o.w / 2" :y="o.y + o.h / 2 + 4" text-anchor="middle" fill="currentColor"
            :style="{ fontSize: '11px', opacity: 0.95 }">{{ o.t }}</text>
      <LockG v-if="o.lock" :x="o.x + o.w - 12" :y="o.y + o.h / 2" :style="{ color: o.c }" />
    </g>

    <!-- hint 另外畫，才不會跟著 dim 一起變暗 -->
    <text
      v-for="(o, id) in OBJ" :key="`h-${id}`"
      v-show="o.x < 400"
      :x="o.x + o.w + 12" :y="o.y + o.h / 2 + 3" text-anchor="start" :fill="o.c"
      class="transition-opacity duration-500"
      :style="{ fontSize: '9.5px', opacity: shown(id) && hint(id) ? 0.9 : 0 }"
    >{{ hint(id) }}</text>
  </svg>
</template>
