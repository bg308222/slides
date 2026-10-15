<script setup lang="ts">
/**
 * P4–P6 是同一張表在原位演化，所以只有這一個元件，step 跨頁連續遞增：
 *   0  明文表，attacker 那格是空的
 *   1  整張表被複製到 attacker            (P4 click 1)
 *   2  表格與副本同時換成 hash            (P5 click 1)
 *   3  andy / bob 兩格一模一樣            (P5 click 2)
 *   4  猜一次 → 一條線同時指向兩列         (P5 click 3)
 *   5  salt 欄長出來，存進去的值全部改變   (P6 click 1)
 *   6  線分裂成 N 條                      (P6 click 2)
 *
 * 空間規則：帳號欄與三個列的 y 座標從頭到尾固定。
 * 唯一的刻意位移是 salt 欄插進來時「hash 欄右移 + 外框變寬」，
 * 而那一刻沒有任何箭頭在畫面上，所以不會有東西跟著跳。
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const C = {
  pw: '#a78bfa',
  hash: '#fbbf24',
  salt: '#38bdf8',
  bad: '#f87171',
  good: '#2dd4bf',
}

const rows = [
  { acct: 'andy', plain: 'hunter2', h0: '9f2a…', salt: 'x7Kq…', h1: '3c7d…' },
  { acct: 'bob', plain: 'hunter2', h0: '9f2a…', salt: 'm2Vd…', h1: '4b8e…' },
  { acct: 'carol', plain: 'p@ssw0rd', h0: 'c41d…', salt: 's4Lm…', h1: '8a11…' },
]

const RY = [56, 98, 140]
const RH = 36
const cy = (i: number) => RY[i] + RH / 2

const salted = () => props.step >= 5
const stolen = () => props.step >= 1
const guessing = () => props.step >= 4

const val = (r: (typeof rows)[0]) =>
  props.step < 2 ? r.plain : salted() ? r.h1 : r.h0
const valColor = () => (props.step < 2 ? C.pw : C.hash)
const colTitle = () => (props.step < 2 ? '密碼' : 'hash')

/** salt 欄插進來時，hash 欄右移、外框跟著變寬。 */
const shift = () => (salted() ? 96 : 0)
const panelW = () => (salted() ? 328 : 232)
const rowRight = () => 232 + shift()

/** 兩格一模一樣：step 3 之後、加 salt 之前，圈住 andy / bob 的值 */
const ringed = (i: number) => props.step >= 3 && !salted() && i < 2

/** 攻擊者這一次要算幾遍。step 5 全部熄掉：他的答案剛剛失效了。 */
const beam = (i: number) => (props.step === 4 && i < 2) || props.step >= 6

const verdict = () => {
  if (props.step >= 6) return { t: '每一列都得從頭再算一次', c: C.good }
  if (props.step === 5) return { t: '他算出來的值，對不上任何一列了', c: C.good }
  return { t: '算出來的這一個，可以比對全庫', c: C.bad }
}

const caption = () => {
  switch (props.step) {
    case 0:
      return { t: '最直覺的答案：那就存起來啊。他登入的時候比對一下就好。', c: '' }
    case 1:
      return { t: '他不用猜，他直接讀 —— 而且這些密碼在別的網站大概也能用。', c: C.bad }
    case 2:
    case 3:
      return { t: '反推不回來是真的。但 andy 跟 bob 存進去的，是一模一樣的東西。', c: '' }
    case 4:
      return { t: '他算一次 hash，拿去跟每一列比。andy 中了，bob 也跟著一起中 —— 他一次都沒多算。', c: C.bad }
    case 5:
      return { t: '同一個密碼，現在每一列存進去的值都不一樣了。', c: '' }
    case 6:
      return { t: '這一列算完，對下一列完全沒用 —— 不管猜中沒有，每一列都得從頭再來。', c: C.good }
    default:
      return { t: '', c: '' }
  }
}
</script>

<template>
  <svg viewBox="0 0 760 272" class="w-full">
    <!-- ── 資料庫 ────────────────────────────────────────────── -->
    <rect
      x="16" y="8" :width="panelW()" height="196" rx="10"
      fill="#94a3b8" fill-opacity="0.05"
      stroke="#94a3b8" stroke-opacity="0.34" stroke-width="1.5"
      style="transition: width 520ms ease"
    />
    <text
      x="32" y="30" fill="currentColor"
      :style="{ fontSize: '9.5px', letterSpacing: '1.6px', opacity: 0.45 }"
    >資料庫</text>

    <text
      x="36" y="49" fill="currentColor"
      :style="{ fontSize: '10px', opacity: 0.4 }"
    >帳號</text>
    <text
      x="140" y="49" :fill="C.salt"
      :style="{ fontSize: '10px', opacity: salted() ? 0.75 : 0, transition: 'opacity 420ms ease 220ms' }"
    >salt</text>

    <!-- 每一列 -->
    <g v-for="(r, i) in rows" :key="r.acct">
      <!-- 帳號：從頭到尾不動 -->
      <rect
        x="36" :y="RY[i]" width="96" :height="RH" rx="6"
        fill="#94a3b8" fill-opacity="0.10"
        stroke="#94a3b8" stroke-opacity="0.28" stroke-width="1"
      />
      <text
        x="84" :y="cy(i) + 4" text-anchor="middle" fill="currentColor"
        :style="{ fontSize: '12px', opacity: 0.8 }"
      >{{ r.acct }}</text>

      <!-- salt：step 5 才長出來，填進本來就空著的位置 -->
      <g :style="{ opacity: salted() ? 1 : 0, transition: 'opacity 420ms ease 220ms' }">
        <rect
          x="140" :y="RY[i]" width="88" :height="RH" rx="6"
          :fill="C.salt" fill-opacity="0.12"
          :stroke="C.salt" stroke-opacity="0.6" stroke-width="1"
        />
        <text
          x="184" :y="cy(i) + 4" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '11.5px', opacity: 0.9, fontFamily: 'ui-monospace, monospace' }"
        >{{ r.salt }}</text>
      </g>
    </g>

    <!-- 密碼 / hash 欄：同一組格子，只換值；salt 出現時整欄右移 -->
    <g :style="{ transform: `translateX(${shift()}px)`, transition: 'transform 520ms ease' }">
      <text
        x="140" y="49" :fill="valColor()"
        :style="{ fontSize: '10px', opacity: 0.75, transition: 'fill 400ms ease' }"
      >{{ colTitle() }}</text>

      <g v-for="(r, i) in rows" :key="'v' + r.acct">
        <rect
          x="140" :y="RY[i]" width="92" :height="RH" rx="6"
          :fill="valColor()" fill-opacity="0.13"
          :stroke="valColor()" stroke-opacity="0.7" stroke-width="1"
          style="transition: fill 400ms ease, stroke 400ms ease"
        />
        <rect
          x="136" :y="RY[i] - 4" width="100" :height="RH + 8" rx="8"
          fill="none" :stroke="C.bad" stroke-width="2"
          :style="{ opacity: ringed(i) ? 0.95 : 0, transition: 'opacity 320ms ease' }"
        />
        <text
          x="186" :y="cy(i) + 4" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '12px', opacity: 0.95, fontFamily: 'ui-monospace, monospace' }"
        >{{ val(r) }}</text>
      </g>

      <text
        x="186" y="192" text-anchor="middle" :fill="C.bad"
        :style="{ fontSize: '10.5px', opacity: ringed(0) ? 0.95 : 0, transition: 'opacity 320ms ease' }"
      >一模一樣</text>
    </g>

    <!-- ── attacker ─────────────────────────────────────────── -->
    <rect
      x="400" y="8" width="344" height="196" rx="10"
      :fill="C.bad" fill-opacity="0.05"
      :stroke="C.bad" stroke-opacity="0.34" stroke-width="1.5"
    />
    <text
      x="416" y="30" :fill="C.bad"
      :style="{ fontSize: '9.5px', letterSpacing: '1.6px', opacity: 0.75 }"
    >ATTACKER</text>

    <!-- 偷走的副本：位置固定，值跟著 db 一起換 -->
    <g :style="{ opacity: stolen() ? 1 : 0, transition: 'opacity 420ms ease' }">
      <text
        x="592" y="49" fill="currentColor"
        :style="{ fontSize: '10px', opacity: 0.4 }"
      >偷走的副本</text>
      <g v-for="(r, i) in rows" :key="'s' + r.acct">
        <rect
          x="592" :y="RY[i]" width="140" :height="RH" rx="6"
          :fill="valColor()" fill-opacity="0.10"
          :stroke="valColor()" stroke-opacity="0.5" stroke-width="1"
          style="transition: fill 400ms ease, stroke 400ms ease"
        />
        <text
          x="662" :y="cy(i) + 4" text-anchor="middle" fill="currentColor"
          :style="{ fontSize: '11.5px', opacity: 0.8, fontFamily: 'ui-monospace, monospace' }"
        >{{ salted() ? r.salt + ' · ' + val(r) : val(r) }}</text>
      </g>
      <text
        x="592" y="196" fill="currentColor"
        :style="{ fontSize: '10px', opacity: salted() ? 0.5 : 0, transition: 'opacity 420ms ease 220ms' }"
      >salt 不是秘密，一起被偷</text>
    </g>

    <!-- 猜一次：位置固定，只換字，不換框 -->
    <g :style="{ opacity: guessing() ? 1 : 0, transition: 'opacity 380ms ease' }">
      <rect
        x="412" y="48" width="164" height="34" rx="6"
        :fill="C.pw" fill-opacity="0.12"
        :stroke="C.pw" stroke-opacity="0.6" stroke-width="1"
      />
      <text
        x="494" y="69" text-anchor="middle" fill="currentColor"
        :style="{ fontSize: '12px', opacity: 0.95 }"
      >猜一個：hunter2</text>

      <rect
        x="412" y="100" width="164" height="34" rx="6"
        :fill="C.hash" fill-opacity="0.12"
        :stroke="C.hash" stroke-opacity="0.6" stroke-width="1"
      />
      <text
        x="494" y="121" text-anchor="middle" fill="currentColor"
        :style="{ fontSize: '12px', opacity: 0.95 }"
      >{{ step >= 6 ? '每列各算一次' : '算出 9f2a…' }}</text>

      <text
        x="494" y="163" text-anchor="middle" :fill="verdict().c"
        :style="{ fontSize: '12.5px', opacity: 0.95, transition: 'fill 300ms ease' }"
      >{{ verdict().t }}</text>
    </g>

    <!-- 從「算出來的值」指回 db 的列 -->
    <Arrow
      v-for="i in [0, 1, 2]" :key="'b' + i"
      :d="`M412,117 H${rowRight() + 44} V${cy(i)} H${rowRight() + 9}`"
      :tip="`${rowRight()},${cy(i)} ${rowRight() + 10},${cy(i) - 5} ${rowRight() + 10},${cy(i) + 5}`"
      :color="C.hash"
      :on="beam(i)"
      :delay="i * 100"
      :opacity="0.7"
    />

    <!-- db → attacker：整張表被複製過去 -->
    <Arrow
      d="M256,106 H583"
      tip="592,106 582,101 582,111"
      :color="C.bad"
      :on="step === 1"
      :opacity="0.7"
    />

    <!-- ── 一句話 ───────────────────────────────────────────── -->
    <text
      x="16" y="248" :fill="caption().c || 'currentColor'"
      :style="{ fontSize: '13.5px', opacity: caption().t ? 0.95 : 0, transition: 'opacity 300ms ease' }"
    >{{ caption().t }}</text>
  </svg>
</template>
