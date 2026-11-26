<script setup lang="ts">
/**
 * 第二章：server 出題、client 作答。左欄作答的一方、右欄 server，時間往下走。
 * `<方式>` 在同一個位置，各頁只換字（Basic / Bearer / Negotiate）。
 */
import { computed } from 'vue'
import Arrow from './Arrow.vue'

const props = defineProps<{ frame: number }>()

const C = { accent: '#f9a8d4', line: '#e2e8f0', red: '#f87171' }
const GENERIC = '<方式>'
const DATA: Record<string, string> = {
  [GENERIC]: '<資料>',
  Basic: 'base64(andy:P@ssw0rd)',
  Bearer: 'eyJhbGciOi…',
  Negotiate: '…',
}

function initial() {
  return {
    rows: 0,
    m2: GENERIC, // 出題那一列的方式
    m3: GENERIC, // 作答那一列的方式
    dialog: 'closed' as 'closed' | 'open' | 'filled',
    float: 'none' as 'none' | 'center' | 'landed',
    shortcut: false, // Bearer 的日常：請求一開始就帶著 Authorization，直接 200
    who: '瀏覽器',
    os: false,
  }
}

const frames: any[] = [
  // 2-1（0–4）
  { step: '' },
  { step: '瀏覽器送出請求', rows: 1 },
  { step: 'server 出題：401 ＋ WWW-Authenticate', rows: 2 },
  { step: 'client 作答：Authorization', rows: 3 },
  { step: '答對了：200', rows: 4 },
  // 2-2 Basic（5–12）：箭頭一條一條出現，401 一出現就是 Basic
  { step: '', rows: 0 },
  { step: '瀏覽器送出請求', rows: 1 },
  { step: 'server 出題：Basic', rows: 2, m2: 'Basic' },
  { step: '瀏覽器自己跳出帳密框', dialog: 'open' },
  { step: '輸入帳密', dialog: 'filled' },
  { step: '瀏覽器自己送出 Authorization', dialog: 'closed', rows: 3, m3: 'Basic' },
  { step: '答對了：200', rows: 4 },
  { step: '跳框、送出、記住，全是瀏覽器自己做的', tone: 'key' },
  // 2-3 Bearer（13–18）：先只有每天在送的那一行；平常一開始就帶著，所以看不到出題
  { step: '你們每天都在送的這一行', rows: 0, m2: GENERIC, m3: GENERIC, float: 'center' },
  { step: '平常一開始就帶著它，所以從來沒看過 401', float: 'none', shortcut: true, who: '你的前端程式' },
  { step: '但 HTTP 的約定是：server 先出題', shortcut: false, rows: 2, m2: 'Bearer' },
  { step: '你們送的那一行，其實是作答', rows: 3, m3: 'Bearer' },
  { step: '答對了：200', rows: 4 },
  { step: '同一套一問一答，只是你們的前端程式一開始就先帶著答案', tone: 'key' },
  // 2-4 Negotiate（19–25）：箭頭一條一條出現，401 一出現就是 Negotiate
  { step: '', rows: 0, m2: GENERIC, m3: GENERIC, float: 'none', who: '瀏覽器' },
  { step: '瀏覽器送出請求', rows: 1 },
  { step: 'server 出題：Negotiate', rows: 2, m2: 'Negotiate' },
  { step: '瀏覽器去問 OS：幫我證明我是誰', os: true },
  { step: '瀏覽器把 OS 給的答案送出', rows: 3, m3: 'Negotiate' },
  { step: '答對了：200', rows: 4 },
  { step: '作答的還是瀏覽器，只是它去問 OS', tone: 'key' },
]

const idx = computed(() => Math.min(props.frame, frames.length - 1))
const st = computed(() => {
  const s = initial()
  for (let i = 0; i <= idx.value; i++) {
    const { step, tone, ...rest } = frames[i]
    Object.assign(s, rest)
  }
  return s
})
const step = computed(() => frames[idx.value].step ?? '')
const tone = computed(() => frames[idx.value].tone ?? '')

const L = 160, R = 720
const ROW = [86, 136, 186, 236]
</script>

<template>
  <div class="relative">
    <svg viewBox="0 0 880 380" class="w-full" style="height: 376px">
      <!-- 兩欄 -->
      <rect x="40" y="10" width="240" height="34" rx="8" fill="#ffffff0d" stroke="#ffffff22" />
      <text :x="L" y="33" text-anchor="middle" fill="#f1f5f9" style="font-size: 16px; font-weight: 700">{{ st.who }}</text>
      <rect x="600" y="10" width="240" height="34" rx="8" fill="#ffffff0d" stroke="#ffffff22" />
      <text :x="R" y="33" text-anchor="middle" fill="#f1f5f9" style="font-size: 16px; font-weight: 700">server</text>
      <line :x1="L" y1="46" :x2="L" y2="262" stroke="#ffffff30" stroke-dasharray="4 5" />
      <line :x1="R" y1="46" :x2="R" y2="262" stroke="#ffffff30" stroke-dasharray="4 5" />

      <!-- 第 1 列：請求 -->
      <Arrow :d="`M${L + 4} ${ROW[0]} H${R - 4}`" :tip="`${R - 10},${ROW[0] - 5} ${R - 2},${ROW[0]} ${R - 10},${ROW[0] + 5}`"
             :on="st.rows >= 1" :color="C.line" />
      <text x="440" :y="ROW[0] - 9" text-anchor="middle" fill="#e5e7eb"
            style="font-size: 14px; font-family: 'JetBrains Mono', monospace"
            :style="{ opacity: st.rows >= 1 ? 1 : 0, transition: 'opacity 300ms' }">GET /report</text>

      <!-- 第 2 列：出題 -->
      <Arrow :d="`M${R - 4} ${ROW[1]} H${L + 4}`" :tip="`${L + 10},${ROW[1] - 5} ${L + 2},${ROW[1]} ${L + 10},${ROW[1] + 5}`"
             :on="st.rows >= 2" :color="C.line" />
      <text x="440" :y="ROW[1] - 9" text-anchor="middle" fill="#e5e7eb"
            style="font-size: 14px; font-family: 'JetBrains Mono', monospace"
            :style="{ opacity: st.rows >= 2 ? 1 : 0, transition: 'opacity 300ms' }">401  WWW-Authenticate: <tspan :fill="C.accent">{{ st.m2 }}</tspan></text>

      <!-- 第 3 列：作答 -->
      <Arrow :d="`M${L + 4} ${ROW[2]} H${R - 4}`" :tip="`${R - 10},${ROW[2] - 5} ${R - 2},${ROW[2]} ${R - 10},${ROW[2] + 5}`"
             :on="st.rows >= 3" :color="C.line" />
      <text x="440" :y="ROW[2] - 9" text-anchor="middle" fill="#e5e7eb"
            style="font-size: 14px; font-family: 'JetBrains Mono', monospace"
            :style="{ opacity: st.rows >= 3 && st.float === 'none' ? 1 : 0, transition: 'opacity 300ms' }">Authorization: <tspan :fill="C.accent">{{ st.m3 }}</tspan> {{ DATA[st.m3] }}</text>

      <!-- Bearer：你們每天在送的那一行，從下方落進作答那一格 -->
      <g :style="{
           transform: st.float === 'landed' ? `translate(440px, ${ROW[2] - 9}px) scale(1)` : 'translate(440px, 318px) scale(1.3)',
           opacity: st.float === 'none' ? 0 : 1,
           transition: 'transform 800ms ease, opacity 400ms',
         }">
        <text x="0" y="0" text-anchor="middle" fill="#e5e7eb"
              style="font-size: 14px; font-family: 'JetBrains Mono', monospace">Authorization: <tspan :fill="C.accent">Bearer</tspan> eyJhbGciOi…</text>
      </g>

      <!-- Bearer 的日常：一開始就帶著答案，沒有出題這一步 -->
      <Arrow :d="`M${L + 4} ${ROW[0]} H${R - 4}`" :tip="`${R - 10},${ROW[0] - 5} ${R - 2},${ROW[0]} ${R - 10},${ROW[0] + 5}`"
             :on="st.shortcut" :color="C.line" />
      <text x="440" :y="ROW[0] - 9" text-anchor="middle" fill="#e5e7eb"
            style="font-size: 14px; font-family: 'JetBrains Mono', monospace"
            :style="{ opacity: st.shortcut ? 1 : 0, transition: 'opacity 300ms' }">GET /report  Authorization: <tspan :fill="C.accent">Bearer</tspan> eyJhbGciOi…</text>
      <Arrow :d="`M${R - 4} ${ROW[1]} H${L + 4}`" :tip="`${L + 10},${ROW[1] - 5} ${L + 2},${ROW[1]} ${L + 10},${ROW[1] + 5}`"
             :on="st.shortcut" :color="C.line" :delay="500" />
      <text x="440" :y="ROW[1] - 9" text-anchor="middle" fill="#e5e7eb"
            style="font-size: 14px; font-family: 'JetBrains Mono', monospace"
            :style="{ opacity: st.shortcut ? 1 : 0, transition: `opacity 300ms ${st.shortcut ? 500 : 0}ms` }">200 OK</text>

      <!-- 第 4 列：通過 -->
      <Arrow :d="`M${R - 4} ${ROW[3]} H${L + 4}`" :tip="`${L + 10},${ROW[3] - 5} ${L + 2},${ROW[3]} ${L + 10},${ROW[3] + 5}`"
             :on="st.rows >= 4" :color="C.line" />
      <text x="440" :y="ROW[3] - 9" text-anchor="middle" fill="#e5e7eb"
            style="font-size: 14px; font-family: 'JetBrains Mono', monospace"
            :style="{ opacity: st.rows >= 4 ? 1 : 0, transition: 'opacity 300ms' }">200 OK</text>


      <!-- Negotiate：瀏覽器往下問 OS -->
      <Arrow :d="`M${L} 264 V298`" :tip="`${L - 5},292 ${L},300 ${L + 5},292`" :on="st.os" :color="C.accent" :opacity="0.85" />
      <g :style="{ opacity: st.os ? 1 : 0, transition: 'opacity 400ms 300ms' }">
        <rect x="60" y="302" width="200" height="50" rx="8" fill="#ffffff0a" stroke="#ffffff40" />
        <text :x="L" y="324" text-anchor="middle" fill="#f1f5f9" style="font-size: 14px; font-weight: 700">OS</text>
        <text :x="L" y="342" text-anchor="middle" fill="#cbd5e1" style="font-size: 11px">幫我證明我是誰</text>
      </g>
    </svg>
    <div class="text-center" style="height: 30px; line-height: 30px; font-size: 15px"
         :style="{ color: tone === 'key' ? C.accent : '#cbd5e1', opacity: tone ? 1 : .85 }">{{ step }}</div>

    <!-- Basic：瀏覽器原生的帳密 dialog，浮在頁面上方 -->
    <div class="native-dialog"
         :style="{
           opacity: st.dialog === 'closed' ? 0 : 1,
           transform: st.dialog === 'closed' ? 'translate(-50%, -12px)' : 'translate(-50%, 0)',
           pointerEvents: 'none',
         }">
      <div class="nd-title">登入</div>
      <div class="nd-url">https://app.corp.local</div>
      <div class="nd-row">
        <label>使用者名稱</label>
        <div class="nd-input" :class="{ focus: st.dialog === 'open' }">
          <span :style="{ opacity: st.dialog === 'filled' ? 1 : 0 }">andy</span>
        </div>
      </div>
      <div class="nd-row">
        <label>密碼</label>
        <div class="nd-input">
          <span class="nd-dots" :style="{ opacity: st.dialog === 'filled' ? 1 : 0 }">••••••••</span>
        </div>
      </div>
      <div class="nd-actions">
        <div class="nd-btn primary">登入</div>
        <div class="nd-btn">取消</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 仿 Chrome 原生 HTTP 驗證對話框（淺色系統樣式），刻意和投影片的深色風格不同 */
.native-dialog {
  position: absolute;
  top: -4px;
  left: 50%;
  width: 380px;
  padding: 20px 22px 18px;
  background: #ffffff;
  color: #202124;
  border-radius: 8px;
  box-shadow: 0 4px 8px 3px rgba(0, 0, 0, .25), 0 1px 3px rgba(0, 0, 0, .35);
  font-family: 'Segoe UI', Roboto, 'Noto Sans TC', sans-serif;
  text-align: left;
  transition: opacity 260ms ease, transform 260ms ease;
  z-index: 10;
}
.nd-title { font-size: 17px; font-weight: 500; margin-bottom: 4px; }
.nd-url { font-size: 12.5px; color: #5f6368; margin-bottom: 16px; }
.nd-row { display: flex; align-items: center; margin-bottom: 10px; }
.nd-row label { width: 84px; font-size: 13px; color: #202124; }
.nd-input {
  flex: 1;
  height: 30px;
  line-height: 28px;
  padding: 0 8px;
  border: 1px solid #dadce0;
  border-radius: 4px;
  font-size: 13.5px;
  color: #202124;
}
.nd-input.focus { border: 2px solid #1a73e8; padding: 0 7px; line-height: 26px; }
.nd-input span { transition: opacity 400ms ease; }
.nd-dots { letter-spacing: -1px; font-size: 15px; font-family: Arial, sans-serif; }
.nd-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
.nd-btn {
  height: 32px;
  line-height: 30px;
  padding: 0 16px;
  border: 1px solid #dadce0;
  border-radius: 4px;
  font-size: 13px;
  font-weight: 500;
  color: #1a73e8;
}
.nd-btn.primary { background: #1a73e8; border-color: #1a73e8; color: #ffffff; }
</style>
