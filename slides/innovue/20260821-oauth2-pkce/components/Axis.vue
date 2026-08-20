<script setup lang="ts">
/**
 * 全場那把尺。刻意分兩次立起來：
 *   3.3 只給第一根（你是誰）—— 此時聽眾以為一根就夠
 *   3.4 之後才由聽眾自己發現第二根
 * 所以 second 預設關閉。
 */
withDefaults(defineProps<{
  second?: boolean
  firstAnswer?: string
  secondAnswer?: string
}>(), { second: false })
</script>

<template>
  <div class="grid gap-3" :class="second ? 'grid-cols-2' : 'grid-cols-1 max-w-xl mx-auto'">
    <div class="rounded-lg border-2 border-indigo-400/45 bg-indigo-400/5 px-4 py-3">
      <div class="uppercase tracking-widest opacity-40 mb-1.5" style="font-size: 10px">第一根軸</div>
      <div class="font-bold text-indigo-300 mb-2">你是誰？</div>
      <div class="opacity-70 leading-snug" style="font-size: 12px">
        來換 token 的，是不是我登記過的那個 client？
      </div>
      <div v-if="firstAnswer" class="mt-2.5 pt-2 border-t border-indigo-400/20 leading-snug"
           style="font-size: 12px" v-html="firstAnswer" />
    </div>

    <div v-if="second"
         class="rounded-lg border-2 border-amber-400/50 bg-amber-400/5 px-4 py-3">
      <div class="uppercase tracking-widest opacity-40 mb-1.5" style="font-size: 10px">第二根軸</div>
      <div class="font-bold text-amber-300 mb-2">這個 code 是不是你剛才要的那一個？</div>
      <div class="opacity-70 leading-snug" style="font-size: 12px">
        這一次 token 請求，跟當初那次 authorization 請求，是同一趟嗎？
      </div>
      <div v-if="secondAnswer" class="mt-2.5 pt-2 border-t border-amber-400/20 leading-snug"
           style="font-size: 12px" v-html="secondAnswer" />
    </div>
  </div>
</template>
