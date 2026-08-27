<script setup lang="ts">
import { computed } from 'vue'
/**
 * 第一段：從「兩包 library」長成「一台 auth server」。
 *
 * 這張圖橫跨兩頁（② step 1–3、③ step 4–6），座標全程不動，
 * 讓觀眾看見的是同一張圖在長東西，不是換了三張圖。
 *
 * 每一欄底下都掛著真正跑得動的那幾行程式：
 * 讓觀眾直接對上「這段程式長出 db、那段程式長出 instance、
 * 那一行 express 掛載長出 endpoints」，而不是聽講者描述。
 *
 * 這一段最重要的一格是 step 3：instance 建好了，右邊卻是一道封死的牆。
 * 「外面打不到它」這件事必須先被看見，step 4 的 toNodeHandler 才不是
 * 「順便介紹的 API」，而是被上一格逼出來的一步。
 *
 * step: 0 空 / 1 migration 建好 schema / 2 betterAuth() 建出 instance
 *       3 但外面打不到它 / 4 掛上去 → 長出 endpoints / 5 官方 adapter 一整排
 *       6 外框成形，此刻才叫它 auth server
 */
const props = withDefaults(defineProps<{ step?: number }>(), { step: 0 })
const s = computed(() => props.step)

const TABLES = ['user', 'session', 'account', 'passkey', 'oauthClient']
const ROUTES = ['/sign-up/email', '/sign-in/email', '/passkey/*', '/oauth2/*', '/.well-known/*']
const ADAPTERS = ['node', 'next-js', 'svelte-kit', 'solid-start', 'tanstack-start']
</script>

<template>
  <div class="relative mx-auto" style="width: 880px; height: 358px">

    <!-- 外框：step 6 才出現，也才貼上名字。在那之前畫面上沒有「server」這個東西 -->
    <div
      class="absolute rounded-xl border-2 transition-all duration-700"
      :class="s >= 6 ? 'border-teal-400/70 bg-teal-400/5' : 'border-transparent'"
      style="left: 26px; top: 56px; width: 834px; height: 288px"
      :style="{ opacity: s >= 6 ? 1 : 0 }"
    />
    <div v-if="s >= 6" class="absolute text-teal-300 font-bold"
         style="left: 40px; top: 32px; font-size: 15px">auth server</div>
    <div v-if="s >= 6" class="absolute opacity-45"
         style="left: 160px; top: 36px; font-size: 11px">← 這一整框是你的 server，Better Auth 只是長在裡面</div>

    <!-- 連線層 -->
    <svg viewBox="0 0 880 358" class="absolute inset-0 w-full h-full" style="pointer-events: none">
      <line v-if="s >= 2" x1="281" y1="165" x2="339" y2="165" stroke="#94a3b8" stroke-width="2" />
      <g v-if="s >= 4">
        <line class="libGrow" x1="566" y1="165" x2="618" y2="165"
              stroke="#2dd4bf" stroke-width="2.5" style="--len: 52" />
        <polygon points="618,159 628,165 618,171" fill="#2dd4bf" />
      </g>
      <!-- step 3：右邊是一道封死的牆 -->
      <g v-if="s === 3">
        <line x1="580" y1="112" x2="580" y2="218" stroke="#f87171" stroke-width="2.5" stroke-dasharray="6 5" />
        <line x1="566" y1="150" x2="596" y2="180" stroke="#f87171" stroke-width="2.5" />
        <line x1="596" y1="150" x2="566" y2="180" stroke="#f87171" stroke-width="2.5" />
      </g>
    </svg>

    <!-- db -->
    <div class="absolute rounded-lg border-2 border-slate-400/50 bg-slate-400/5 transition-all duration-500"
         style="left: 70px; top: 90px; width: 211px; height: 150px"
         :style="{ opacity: s >= 1 ? 1 : 0, transform: s >= 1 ? 'none' : 'translateY(8px)' }">
      <div class="opacity-45 px-3 pt-2" style="font-size: 10px">db</div>
      <div class="px-3 pt-1 flex flex-col gap-1">
        <div v-for="t in TABLES" :key="t"
             class="rounded bg-slate-400/10 px-2 py-0.5 opacity-70" style="font-size: 10.5px">{{ t }}</div>
      </div>
    </div>

    <!-- instance -->
    <div class="absolute rounded-lg border-2 flex flex-col items-center justify-center transition-all duration-500"
         :class="s >= 2 ? 'border-indigo-400/70 bg-indigo-400/10' : 'border-transparent'"
         style="left: 345px; top: 118px; width: 221px; height: 94px"
         :style="{ opacity: s >= 2 ? 1 : 0, transform: s >= 2 ? 'none' : 'translateY(8px)' }">
      <div class="text-indigo-300 font-bold" style="font-size: 14px">instance</div>
      <div class="opacity-50 mt-1" style="font-size: 10.5px">建好了，但它只是一個物件</div>
    </div>

    <div v-if="s === 3" class="absolute text-center"
         style="left: 470px; top: 222px; width: 240px">
      <span class="text-red-300" style="font-size: 12px">外面打不到它</span>
    </div>

    <!-- endpoints -->
    <div class="absolute rounded-lg border-2 border-teal-400/70 bg-teal-400/10 transition-all duration-500"
         style="left: 630px; top: 90px; width: 201px; height: 150px"
         :style="{ opacity: s >= 4 ? 1 : 0, transform: s >= 4 ? 'none' : 'translateX(-10px)' }">
      <div class="text-teal-300/70 px-3 pt-2" style="font-size: 10px">/api/auth</div>
      <div class="px-3 pt-1 flex flex-col gap-1">
        <div v-for="r in ROUTES" :key="r"
             class="rounded bg-teal-400/10 text-teal-200/90 px-2 py-0.5" style="font-size: 10.5px">{{ r }}</div>
      </div>
    </div>

    <!-- 三段程式：每一欄底下掛著真正長出它的那幾行 -->
    <div class="absolute rounded border border-slate-400/25 bg-slate-400/5 px-2.5 py-1.5 transition-all duration-500"
         style="left: 34px; top: 250px; width: 283px"
         :style="{ opacity: s >= 1 ? 1 : 0 }">
      <div class="font-mono leading-relaxed opacity-80" style="font-size: 9.5px">
        <div>const m = await <span class="text-teal-300">getMigrations</span>(auth.options)</div>
        <div>await m.<span class="text-teal-300">runMigrations</span>()</div>
      </div>
    </div>

    <div class="absolute rounded border border-slate-400/25 bg-slate-400/5 px-2.5 py-1.5 transition-all duration-500"
         style="left: 330px; top: 250px; width: 251px"
         :style="{ opacity: s >= 2 ? 1 : 0 }">
      <div class="font-mono leading-relaxed opacity-80" style="font-size: 9.5px">
        <div>const auth = <span class="text-indigo-300">betterAuth</span>({</div>
        <div class="pl-3">database, plugins: [ ... ],</div>
        <div>})</div>
      </div>
    </div>

    <div class="absolute rounded border border-teal-400/30 bg-teal-400/5 px-2.5 py-1.5 transition-all duration-500"
         style="left: 594px; top: 250px; width: 266px"
         :style="{ opacity: s >= 4 ? 1 : 0 }">
      <div class="font-mono leading-relaxed opacity-80" style="font-size: 9.5px">
        <div>app.<span class="text-teal-300">all</span>("/api/auth/*splat",</div>
        <div class="pl-3"><span class="text-teal-300">toNodeHandler</span>(auth))</div>
      </div>
    </div>

    <!-- 官方 adapter 一整排 -->
    <div class="absolute flex items-center gap-2 transition-all duration-500"
         style="left: 330px; top: 316px"
         :style="{ opacity: s >= 5 ? 1 : 0 }">
      <span class="opacity-40" style="font-size: 10.5px">官方 adapter：</span>
      <span v-for="a in ADAPTERS" :key="a"
            class="rounded border border-amber-400/40 bg-amber-400/10 text-amber-200 px-2 py-0.5"
            style="font-size: 10.5px">{{ a }}</span>
    </div>

  </div>
</template>

<style scoped>
.libGrow { stroke-dasharray: var(--len); animation: libDraw 0.3s cubic-bezier(.4, 0, .2, 1) forwards; }
@keyframes libDraw { from { stroke-dashoffset: var(--len); } to { stroke-dashoffset: 0; } }
</style>
