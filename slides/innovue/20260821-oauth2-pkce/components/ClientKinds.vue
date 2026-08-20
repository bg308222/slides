<script setup lang="ts">
/**
 * 兩種 client 的樣子。先給 RFC 6749 §2.1 的定義（在 slides.md 上），
 * 這裡才把定義畫成我們自己的圖。
 *
 * confidential 那一欄刻意把「應用的前端」也畫出來並標成 app 的 client ——
 * 因為聽眾口語裡的 client 指的就是它。OAuth 的 client 是保管 secret、
 * 做 code exchange 的 server 那一格，這件事在第一段講過一次，這裡是第二次。
 *
 * step: 1 public / 2 confidential
 */
withDefaults(defineProps<{ step?: number }>(), { step: 0 })
</script>

<template>
  <div class="grid grid-cols-2 gap-5 text-left">

    <div class="rounded-lg border-2 border-red-400/50 bg-red-400/5 px-4 py-3
                transition-opacity duration-500"
         :class="step >= 1 ? 'opacity-100' : 'opacity-0'">
      <div class="opacity-50 mb-2" style="font-size: 11px">SPA（瀏覽器裡的前端）／ native app</div>

      <div class="rounded border border-red-400/40 px-3 py-2">
        <div class="opacity-40 mb-1.5" style="font-size: 10px">使用者的裝置</div>
        <div class="flex items-center gap-3 font-mono" style="font-size: 12px">
          <span>client_id</span>
          <span class="text-red-300 line-through opacity-70">client_secret</span>
        </div>
      </div>

      <div class="mt-2.5 leading-snug" style="font-size: 11.5px">
        沒有 server，secret 只能跟著程式一起交到使用者手上 ——
        <b class="text-red-300">等於公開，放了也沒有意義。</b>
      </div>
    </div>

    <div class="rounded-lg border-2 border-teal-400/50 bg-teal-400/5 px-4 py-3
                transition-opacity duration-500"
         :class="step >= 2 ? 'opacity-100' : 'opacity-0'">
      <div class="opacity-50 mb-2" style="font-size: 11px">我們的應用 —— 它自己就分成兩半</div>

      <div class="flex items-stretch gap-2">
        <div class="flex-1 rounded border border-slate-400/40 px-3 py-2">
          <div class="font-mono" style="font-size: 12px">app 的 client</div>
          <div class="opacity-45 mt-1 leading-snug" style="font-size: 10px">
            前端。我們口語叫它 client —— 但它不是 OAuth 的 client
          </div>
        </div>

        <div class="self-center opacity-35" style="font-size: 15px">→</div>

        <div class="flex-1 rounded border border-teal-400/50 bg-teal-400/10 px-3 py-2">
          <div class="font-mono" style="font-size: 12px">server</div>
          <div class="mt-1 font-mono text-teal-300" style="font-size: 11px">🔒 client_secret</div>
        </div>
      </div>

      <div class="mt-2.5 leading-snug" style="font-size: 11.5px">
        secret 由 server 保管，前端拿不到 ——
        <b class="text-teal-300">OAuth 的 client 是 server 這一格。</b>
      </div>
    </div>

  </div>
</template>
