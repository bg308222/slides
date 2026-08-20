<script setup lang="ts">
/**
 * 第二段的收束：同一個被偷走的 code 送到 token endpoint，
 * 兩種應用得到完全不同的結果 —— 聽眾自己看出「client 其實有兩種」。
 *
 * 刻意不出現 public / confidential 這兩個詞。那是下一段才給的名字，
 * 這裡只給聽眾看得見的差別：有沒有 server。
 * （下一段會再把這個直覺的說法校正成「誰做 code exchange」。）
 *
 * 檢查項目只留 code 與 client_secret —— 前面講換 token 時就只講了這兩個，
 * 這裡不要多出聽眾沒看過的欄位。
 *
 * 勾叉的語意固定為「這一格檢查過不過」：
 *   ✓ = 攻擊者過關（對他有利）  ✕ = 卡住了（擋下攻擊）
 * 所以每一格旁邊都寫死結論，不讓顏色自己講話。
 *
 * step: 1 code 這格（他手上那個是真的，擋不住）
 *       2 client_secret 這格 —— 答案要看是哪一種應用
 *       3 左：沒有 server 的應用
 *       4 右：有 server 的應用
 */
withDefaults(defineProps<{ step?: number }>(), { step: 0 })

const MARK = 'inline-flex items-center justify-center rounded font-bold shrink-0'
</script>

<template>
  <div class="mx-auto" style="max-width: 700px">

    <!-- token endpoint 的檢查：只有兩格 -->
    <div class="mx-auto rounded-lg border border-slate-400/30 bg-slate-400/5 px-4 py-3"
         style="max-width: 470px">
      <div class="uppercase tracking-widest opacity-40 mb-2.5" style="font-size: 10px">
        Authorization Server 在 token endpoint 檢查什麼
      </div>

      <div class="flex flex-col gap-1.5">
        <div class="flex items-center gap-2.5 transition-opacity duration-500"
             :class="step >= 1 ? 'opacity-100' : 'opacity-0'" style="min-height: 26px">
          <span :class="MARK" class="bg-emerald-400/15 text-emerald-300 border border-emerald-400/50"
                style="width: 20px; height: 20px; font-size: 12px">✓</span>
          <code class="font-mono" style="font-size: 13px">code</code>
          <span class="opacity-45" style="font-size: 11px">他手上那個是真的 —— 這格擋不住</span>
        </div>

        <div class="flex items-center gap-2.5 transition-opacity duration-500"
             :class="step >= 2 ? 'opacity-100' : 'opacity-0'" style="min-height: 26px">
          <span :class="MARK" class="bg-amber-400/15 text-amber-300 border border-amber-400/60"
                style="width: 20px; height: 20px; font-size: 12px">?</span>
          <code class="font-mono" style="font-size: 13px">client_secret</code>
          <span class="opacity-45" style="font-size: 11px">這一格的答案，要看它是哪一種應用</span>
        </div>
      </div>
    </div>

    <!-- 往下展開 -->
    <svg viewBox="0 0 700 40" class="w-full"
         :style="{ height: '40px', opacity: step >= 3 ? 1 : 0, transition: 'opacity .5s' }">
      <path d="M350 2 V20 M170 20 H530 M170 20 V38 M530 20 V38"
            fill="none" stroke="currentColor" stroke-opacity="0.3" stroke-width="2" />
    </svg>

    <div class="grid grid-cols-2 gap-5 text-left">

      <div class="rounded-lg border-2 border-red-400/50 bg-red-400/5 px-4 py-3
                  transition-opacity duration-500"
           :class="step >= 3 ? 'opacity-100' : 'opacity-0'">
        <div class="font-bold text-red-300" style="font-size: 13.5px">沒有 server 的應用</div>
        <div class="opacity-50 mt-0.5" style="font-size: 11px">換 token 這件事，在使用者手上的程式裡做</div>

        <div class="flex items-center gap-2.5 mt-2.5">
          <span :class="MARK" class="bg-emerald-400/15 text-emerald-300 border border-emerald-400/50"
                style="width: 20px; height: 20px; font-size: 12px">✓</span>
          <code class="font-mono" style="font-size: 12.5px">client_secret</code>
        </div>
        <div class="opacity-55 mt-1.5 leading-snug" style="font-size: 11px">
          它<b>根本沒有</b>這個東西可以查 —— 這一格照樣過
        </div>

        <div class="mt-2.5 rounded px-2.5 py-1.5 bg-red-400/15 text-red-300 font-bold"
             style="font-size: 12.5px">→ code 被偷 = token 被偷</div>
      </div>

      <div class="rounded-lg border-2 border-teal-400/50 bg-teal-400/5 px-4 py-3
                  transition-opacity duration-500"
           :class="step >= 4 ? 'opacity-100' : 'opacity-0'">
        <div class="font-bold text-teal-300" style="font-size: 13.5px">有 server 的應用</div>
        <div class="opacity-50 mt-0.5" style="font-size: 11px">換 token 這件事，在自己控制的機器上做</div>

        <div class="flex items-center gap-2.5 mt-2.5">
          <span :class="MARK" class="bg-red-400/15 text-red-300 border border-red-400/60"
                style="width: 20px; height: 20px; font-size: 12px">✕</span>
          <code class="font-mono" style="font-size: 12.5px">client_secret</code>
        </div>
        <div class="opacity-55 mt-1.5 leading-snug" style="font-size: 11px">
          攻擊者<b>拿不到</b>它 —— 這一格過不了
        </div>

        <div class="mt-2.5 rounded px-2.5 py-1.5 bg-teal-400/15 text-teal-300 font-bold"
             style="font-size: 12.5px">→ 換不到 token，擋下來了</div>
      </div>

    </div>
  </div>
</template>
