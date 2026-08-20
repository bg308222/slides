<script setup lang="ts">
/**
 * 第二段：整趟旅程逐步檢查。
 * 2.2 七步全綠 → 製造「咦，都很安全？」
 * 2.3 把第 5 步換成 app，其餘不動（一次只揭露一件事）
 */
withDefaults(defineProps<{
  reveal?: number
  /** 第 5 步改成 custom scheme callback */
  breakStep5?: boolean
  /** 惡意 app 出現 */
  evil?: boolean
}>(), { reveal: -1, breakStep5: false, evil: false })

const steps = [
  { n: 1, t: 'Client 向 AS 申請 client_id / client_secret', why: '人工操作' },
  { n: 2, t: 'RO 發起登入', why: 'https' },
  { n: 3, t: 'Client 叫車載 RO 去 AS', why: 'https' },
  { n: 4, t: 'RO 在 AS 登入', why: 'https' },
  { n: 5, t: 'AS 叫車把 RO 載回 Client（車上多了 code）', why: 'https' },
  { n: 6, t: 'Client 拿 code 去 AS 換 token', why: 'https' },
  { n: 7, t: 'Client 拿 token 問 user 資料', why: 'https' },
]
</script>

<template>
  <div class="flex flex-col gap-1">
    <div
      v-for="(s, i) in steps"
      :key="s.n"
      class="flex items-center gap-3 rounded px-3 py-1.5 transition-all duration-500"
      :class="[
        (reveal === -1 || i < reveal) ? 'opacity-100' : 'opacity-0',
        (breakStep5 && s.n === 5)
          ? 'bg-red-400/10 border border-red-400/50'
          : 'border border-transparent',
      ]"
    >
      <span class="opacity-35 font-mono shrink-0" style="font-size: 11px; width: 14px">{{ s.n }}</span>

      <span class="flex-1" style="font-size: 13px">
        <template v-if="breakStep5 && s.n === 5">
          AS 叫車把 RO 載回 Client —— 但這次終點<b class="text-red-300">不是網址，是一個 app</b>
        </template>
        <template v-else>{{ s.t }}</template>
      </span>

      <span
        v-if="!(breakStep5 && s.n === 5)"
        class="inline-flex items-center gap-1.5 shrink-0 text-emerald-300/80"
        style="font-size: 11px"
      >
        <span>{{ s.why }}</span>
        <span class="font-bold">✓</span>
      </span>
      <span v-else class="inline-flex items-center gap-1.5 shrink-0 text-red-300"
            style="font-size: 11px">
        <span>另一個體系</span><span class="font-bold">✕</span>
      </span>
    </div>

    <div v-if="evil"
         class="mt-2 ml-8 rounded px-3 py-2 border-l-4 border-red-400 bg-red-400/10 leading-snug"
         style="font-size: 12px">
      custom URI scheme <b>沒有所有權驗證</b>：另一個 app 只要註冊同一個 scheme，
      車就可能開進它的門。<b class="text-red-300">牌子（code）就落在它手上。</b>
    </div>
  </div>
</template>
