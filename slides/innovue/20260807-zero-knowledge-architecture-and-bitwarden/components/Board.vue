<script setup lang="ts">
import { computed } from 'vue'

/**
 * 第四段的記分板。三欄從頭記到尾，每一步只有幾格會亮起或熄掉。
 * 所有格子一開始就全部畫出來（不在場的只是變暗），所以位置永遠不動（視覺規則 B-1）。
 */
const props = withDefaults(defineProps<{ stage?: number }>(), { stage: 0 })

const stages = [
  { name: 'register', note: '在這台裝置上把三樣東西算出來，上傳給 server', online: true },
  { name: 'login',    note: '換一台裝置登入 —— 把鎖著的兩樣抓下來', online: true },
  { name: 'lock',     note: 'memory 全部清空，硬碟原封不動', online: false },
  { name: 'unlock',   note: '重打一次 master password，全部重算回來', online: false },
  { name: 'logout',   note: '連硬碟上鎖著的那些也一起清掉', online: true },
]

type Item = { t: string; lock?: boolean; in: number[] }

const cols: { title: string; hint: string; color: string; items: Item[] }[] = [
  {
    title: 'SERVER',
    hint: '從頭到尾沒變過',
    color: 'slate',
    items: [
      { t: 'Master Password Hash', in: [0, 1, 2, 3, 4] },
      { t: 'Protected Symmetric Key', lock: true, in: [0, 1, 2, 3, 4] },
      { t: '加密的 vault', lock: true, in: [0, 1, 2, 3, 4] },
    ],
  },
  {
    title: '本機硬碟',
    hint: '決定 unlock 能不能離線',
    color: 'sky',
    items: [
      { t: 'Protected Symmetric Key', lock: true, in: [1, 2, 3] },
      { t: '加密的 vault', lock: true, in: [1, 2, 3] },
    ],
  },
  {
    title: '本機 MEMORY',
    hint: '唯一有明文的地方 · 關掉就沒了',
    color: 'violet',
    items: [
      { t: 'master password', in: [0, 1, 3] },
      { t: 'Master Key', in: [0, 1, 3] },
      { t: 'Symmetric Key', in: [0, 1, 3] },
      { t: 'vault（明文）', in: [0, 1, 3] },
    ],
  },
]

const shell: Record<string, string> = {
  slate:  'border-slate-400/35  bg-slate-400/5',
  sky:    'border-sky-400/35    bg-sky-400/5',
  violet: 'border-violet-400/35 bg-violet-400/5',
}
const chip: Record<string, string> = {
  slate:  'border-slate-400/70  bg-slate-400/10  text-slate-200',
  sky:    'border-sky-400/70    bg-sky-400/10    text-sky-200',
  violet: 'border-violet-400/70 bg-violet-400/10 text-violet-200',
}

const here = (it: Item) => it.in.includes(props.stage)
/** 跟上一步比，這一格剛剛被加進來或剛剛被抹掉 */
const changed = (it: Item) =>
  props.stage > 0 && it.in.includes(props.stage) !== it.in.includes(props.stage - 1)

const cur = computed(() => stages[Math.min(props.stage, stages.length - 1)])
</script>

<template>
  <div>
    <div class="flex items-center gap-2 mb-4">
      <template v-for="(s, i) in stages" :key="s.name">
        <div
          class="px-3 py-1 rounded-full font-mono transition-all duration-500"
          style="font-size: 12px"
          :class="i === stage
            ? 'border border-amber-400/70 bg-amber-400/15 text-amber-300'
            : 'border border-white/10 opacity-35'"
        >{{ s.name }}</div>
        <div v-if="i < stages.length - 1" class="opacity-20" style="font-size: 11px">›</div>
      </template>
    </div>

    <div class="grid grid-cols-3 gap-3">
      <div
        v-for="c in cols"
        :key="c.title"
        class="rounded-lg border-2 p-3"
        :class="shell[c.color]"
        style="min-height: 218px"
      >
        <div class="uppercase tracking-widest opacity-50" style="font-size: 10px">{{ c.title }}</div>
        <div class="opacity-35 mb-3" style="font-size: 10px">{{ c.hint }}</div>

        <div class="flex flex-col gap-1.5">
          <div v-for="it in c.items" :key="it.t" class="relative">
            <div
              class="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md border font-mono transition-opacity duration-500"
              style="font-size: 11.5px"
              :class="[chip[c.color], here(it) ? 'opacity-100' : 'opacity-15']"
            >
              <span class="flex-1">{{ it.t }}</span>
              <Lock v-if="it.lock" :size="12" :on="here(it)" class="opacity-80" />
            </div>
            <!-- 剛剛被加進來 / 剛剛被抹掉：外框不跟著變暗，才看得見 -->
            <div
              v-if="changed(it)"
              class="absolute inset-0 rounded-md ring-2 pointer-events-none"
              :class="here(it) ? 'ring-teal-400/80' : 'ring-red-400/70'"
            />
          </div>
        </div>
      </div>
    </div>

    <div class="mt-4 flex items-center gap-3">
      <div
        class="px-2.5 py-1 rounded font-mono shrink-0" style="font-size: 11px"
        :class="cur.online
          ? 'border border-slate-400/50 bg-slate-400/10 text-slate-300'
          : 'border border-teal-400/60 bg-teal-400/10 text-teal-300'"
      >{{ cur.online ? '需要 server' : 'server 完全沒參與' }}</div>
      <div class="opacity-75 flex-1" style="font-size: 13px">{{ cur.note }}</div>
      <div class="flex items-center gap-3 opacity-40 shrink-0" style="font-size: 10.5px">
        <span class="flex items-center gap-1">
          <span class="w-3 h-3 rounded-sm ring-2 ring-teal-400/80 inline-block" />剛加進來
        </span>
        <span class="flex items-center gap-1">
          <span class="w-3 h-3 rounded-sm ring-2 ring-red-400/70 inline-block" />剛被抹掉
        </span>
      </div>
    </div>
  </div>
</template>
