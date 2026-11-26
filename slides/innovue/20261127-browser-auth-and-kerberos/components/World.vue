<script setup lang="ts">
/**
 * 第一、三、四章共用的同一張圖：你的電腦（上層瀏覽器、下層 OS）｜AD｜app 三欄固定。
 * 整段是一串 frame；frame n 的狀態 = 初始狀態依序套用 patch 0..n，所以跨頁時物件身份不變。
 * 每一頁只傳入「目前第幾個 frame」。
 *
 * 視覺語意：
 *   金 = TGT；藍 = ST（service ticket）與 app 的金鑰；紅 = 明文密碼；紫 = 由密碼算出的值（NT hash）；白 = 隨機數。
 *   票與 NT hash 只放在 OS 層；你的電腦與右側之間的虛線 = 網路邊界。
 *   AD 欄固定兩個窗口：驗密碼、發 TGT；拿 TGT 換 ST。
 */
import { computed } from 'vue'
import Arrow from './Arrow.vue'

const props = defineProps<{ frame: number }>()

const C = {
  gold: '#fbbf24',
  blue: '#60a5fa',
  red: '#f87171',
  purple: '#c084fc',
  white: '#f8fafc',
  accent: '#f9a8d4',
  line: '#e2e8f0',
  dim: '#94a3b8',
}

// 位置
const OS_TGT = { x: 85, y: 215 }
const OS_ST = { x: 85, y: 268 }
const BOX = { x: 415, y: 265 } // 換 ST 的窗口
const AS = { x: 415, y: 200 }
const KL = { x: 200, y: 232 } // klist 視窗裡
const BROWSER = { x: 120, y: 104 }
const APP_TGT = { x: 650, y: 300 }
const APP_ST = { x: 770, y: 300 }

type Tk = { show: boolean; x: number; y: number; color: 'gold' | 'blue'; label: string; dim?: boolean; glow?: boolean }

function initial() {
  return {
    form: 'none' as 'none' | 'login' | 'filled' | 'prompt' | 'filledPrompt',
    box: 'swap' as 'swap' | 'tgsX',
    tickets: {
      tgt: { show: false, ...AS, color: 'gold', label: 'TGT' },
      tgt2: { show: false, ...AS, color: 'gold', label: 'server 的 TGT' },
      b1: { show: false, ...BOX, color: 'blue', label: 'ST' },
      b2: { show: false, ...BOX, color: 'blue', label: 'ST' },
    } as Record<string, Tk>,
    pw: { show: false, x: 120, y: 150, glow: false },
    login: false,
    layers: false,
    osNote: false,
    arrows: {} as Record<string, boolean>,
    labels: {} as Record<string, string>,
    status: { app: '', ad: '' } as Record<string, string>,
    tone: { app: 'ok' } as Record<string, 'ok' | 'bad' | 'ask'>,
    spn: '',
    klist: null as null | string[],
    list: { show: false, pick: 0, name: false },
    nt: { show: false, name: false, glow: false },
    adNt: false,
    rnd: { show: false, x: 600, y: 105 },
    resp: { show: false, x: 236, y: 225 },
  }
}
type State = ReturnType<typeof initial>

// 每個 frame 只寫這一格「唯一改變」的東西；clear = 換頁時清掉箭頭與判斷文字
const frames: any[] = [
  // ── 0-1 上週走過的 Kerberos：只有 user、AD、app（0–5）
  { step: '' },
  { step: '用 AD 帳號登入 Windows', login: true },
  { step: '向 AD 證明身分，拿到 TGT', arrows: { login: true }, tickets: { tgt: { show: true, ...OS_TGT } } },
  { step: '拿 TGT 去換 ST', arrows: { login: false, osbox: true, boxos: true }, tickets: { b1: { show: true, ...OS_ST } } },
  { step: 'ST 交給 app', arrows: { osbox: false, boxos: false }, tickets: { b1: { ...APP_ST } }, status: { app: '✓ 用自己的金鑰解開' } },
  { step: 'Kerberos 懂了，但我們的 app 碰得到這整個流程嗎？', tone2: 'pain', login: false,
    status: { app: '我們的 app 怎麼接上？' }, tone: { app: 'ask' } },

  // ── 1-1 server 自己拿帳密去換票（6–12）：不假設你的電腦上已經有 TGT
  { clear: true, step: '網頁放一個登入表單', form: 'login', layers: true,
    tickets: { b1: { show: false, ...KL }, tgt: { show: false, ...AS } } },
  { step: '輸入帳密', form: 'filled', pw: { show: true } },
  { step: '帳密送到 server', arrows: { req2: true }, labels: { req2: '帳密' }, pw: { x: 640, y: 160 } },
  { step: 'server 拿去向 AD 換 TGT', arrows: { appas: true, asapp: true }, labels: { appas: '帳密 → 換 TGT' },
    tickets: { tgt2: { show: true, ...APP_TGT } } },
  { step: 'server 換到 ST，自己解開', arrows: { appas: false, asapp: false, apptgs: true, tgsapp: true }, labels: { apptgs: 'TGT → 換 ST' },
    tickets: { b2: { show: true, ...APP_ST } }, status: { app: '✓ 用自己的金鑰解開' } },
  { step: '密碼進到 server 了；TGT 也沒留在你的電腦，下次又要重登', tone2: 'pain',
    pw: { glow: true }, tickets: { tgt2: { glow: true } }, osNote: true },
  { step: '那能不能不經過 server 登入？', tone2: 'key' },

  // ── 3-1 瀏覽器去問 OS（13–15）
  { clear: true, step: '', form: 'none', osNote: false, pw: { show: false, x: 120, y: 150 },
    tickets: { tgt2: { show: false, glow: false, ...AS }, b2: { show: false, ...BOX } } },
  { step: '收到 401 Negotiate', arrows: { res: true }, labels: { res: '401 ＋ WWW-Authenticate: Negotiate' } },
  { step: '瀏覽器請 OS：幫我向這個網站證明我是誰', spn: 'HTTP/app.corp.local', arrows: { down: true } },

  // ── 3-2 OS 怎麼拿到 ST：三種情況（16–23）
  { clear: true, step: '', klist: ['krbtgt/CORP.LOCAL', 'HTTP/app.corp.local'], tickets: { tgt: { show: true, ...OS_TGT } } },
  { step: '已經有 ST → 直接用，不找 AD', tickets: { b1: { show: true, ...OS_ST } }, status: { ad: '（沒動）' } },
  { step: '換一種情況：沒有 ST，但有 TGT', klist: ['krbtgt/CORP.LOCAL'], tickets: { b1: { show: false, ...KL } }, status: { ad: '' } },
  { step: '拿 TGT 去 AD 換 ST', arrows: { osbox: true, boxos: true },
    tickets: { b2: { show: true, ...OS_ST } }, klist: ['krbtgt/CORP.LOCAL', 'HTTP/app.corp.local'] },
  { step: '再換一種情況：什麼都沒有', arrows: { osbox: false, boxos: false }, klist: [],
    tickets: { tgt: { show: false, ...AS }, b2: { show: false, ...BOX } } },
  { step: '瀏覽器跳出帳密框', form: 'prompt' },
  { step: '帳密交給 OS，向 AD 換到 TGT', arrows: { down: true, login: true }, form: 'filledPrompt',
    tickets: { tgt: { show: true, ...OS_TGT } }, klist: ['krbtgt/CORP.LOCAL'] },
  { step: '再拿 TGT 換 ST', arrows: { down: false, login: false, osbox: true, boxos: true },
    tickets: { b2: { show: true, ...OS_ST } }, klist: ['krbtgt/CORP.LOCAL', 'HTTP/app.corp.local'] },

  // ── 3-3 送出與驗證（24–29）
  { clear: true, step: '', form: 'none' },
  { step: 'OS 把 ST 交回瀏覽器', arrows: { up: true }, tickets: { b2: { ...BROWSER } } },
  { step: '送給 server', arrows: { req2: true }, labels: { req2: 'Authorization: Negotiate …' }, tickets: { b2: { ...APP_ST } } },
  { step: 'server 自己解開', status: { app: '✓ 用自己的金鑰解開', ad: '（不必問 AD）' } },
  { step: '越過網路邊界的，只有 ST', tone2: 'key', tickets: { tgt: { glow: true } } },
  { step: '瀏覽器只是呼叫 OS，整套 Kerberos 都由 OS 完成', tone2: 'key', tickets: { tgt: { glow: false } } },

  // ── 附錄 A-1 用 IP 連線（30–36）
  { clear: true, step: '', klist: ['krbtgt/CORP.LOCAL'], tickets: { b2: { show: false, ...BOX } } },
  { step: '網址改成 10.0.0.5', spn: 'HTTP/10.0.0.5' },
  { step: '拿 TGT 去換 ST → AD 沒有這個 SPN', arrows: { osbox: true }, box: 'tgsX' },
  { step: '現場 demo：沒跳框，還是登入了', status: { app: '✓ 還是登入了' } },
  { step: 'klist 沒有新票；DevTools 出現兩次 401', arrows: { osbox: false } },
  { step: '沒有 ST，那它拿什麼證明你是你？', tone2: 'pain' },
  { step: 'Kerberos 換不到時，OS 改用另一種方式：NTLM', tone2: 'key' },

  // ── 附錄 A-2 挑戰與回應（37–42）
  { clear: true, step: '', box: 'swap', spn: '', klist: null, nt: { show: true }, tickets: { tgt: { dim: true } } },
  { step: '瀏覽器：我要用 NTLM', arrows: { req1: true }, labels: { req1: '我要用 NTLM' } },
  { step: 'server 回 401，附上一個隨機數', arrows: { res: true }, labels: { res: '401 ＋ 隨機數' }, rnd: { show: true } },
  { step: '用那個值，對隨機數算出回應', rnd: { x: 178, y: 225 }, resp: { show: true } },
  { step: '送出 andy ＋ 回應', arrows: { req2: true }, labels: { req2: 'andy ＋ 回應' }, resp: { x: 640, y: 160 } },
  { step: 'server 驗不了', tone2: 'pain', status: { app: '？ 手上沒有那個值' }, tone: { app: 'ask' } },

  // ── 附錄 A-3 server 轉問 AD（43–47）
  { clear: true, step: '', adNt: true, rnd: { show: false }, resp: { x: 640, y: 160 } },
  { step: 'server 轉問 AD', arrows: { appnt: true }, labels: { appnt: 'andy、隨機數、回應' } },
  { step: 'AD 算一次，回答對不對', arrows: { ntapp: true }, labels: { ntapp: '✓ 對' } },
  { step: '登入成功', arrows: { res: true }, labels: { res: '200' }, status: { app: '✓' }, tone: { app: 'ok' } },
  { step: 'server 自己驗不了，每次都要問 AD', tone2: 'key' },

  // ── 附錄 A-4 那個值是什麼（48–52）
  { clear: true, step: '', resp: { show: false } },
  { step: '這個值叫 NT hash', nt: { name: true } },
  { step: '它住在 OS 的記憶體裡，所以不用打密碼', nt: { glow: true } },
  { step: '算回應只需要它，不需要原本的密碼——拿到它就能登入', tone2: 'pain' },
  { step: '資料庫裡這個值，也能直接通過登入', tone2: 'key' },
]

function merge(target: any, patch: any) {
  for (const k of Object.keys(patch)) {
    const v = patch[k]
    if (v && typeof v === 'object' && !Array.isArray(v) && target[k] && typeof target[k] === 'object' && !Array.isArray(target[k]))
      merge(target[k], v)
    else
      target[k] = v
  }
}

function apply(s: State, p: any) {
  if (p.clear) {
    s.arrows = {}
    s.labels = {}
    s.status = { app: '', ad: '' }
    s.tone = { app: 'ok' }
  }
  const { clear, step, tone2, ...rest } = p
  merge(s, rest)
}

const idx = computed(() => Math.min(props.frame, frames.length - 1))
const step = computed(() => frames[idx.value].step ?? '')
const stepTone = computed(() => frames[idx.value].tone2 ?? '')

const st = computed(() => {
  const s = initial()
  for (let i = 0; i <= idx.value; i++) apply(s, frames[i])
  return s
})

const toneColor = (t: string) => t === 'bad' ? C.red : t === 'ask' ? '#e2e8f0' : '#e5e7eb'
const on = (id: string) => !!st.value.arrows[id]
const lb = (id: string) => st.value.labels[id] ?? ''
const isPrompt = computed(() => st.value.form === 'prompt' || st.value.form === 'filledPrompt')
</script>

<template>
  <div>
    <svg viewBox="0 0 880 380" class="w-full" style="height: 376px">
      <!-- 三欄：位置從頭到尾固定 -->
      <g>
        <rect x="15" y="10" width="260" height="364" rx="10" fill="#ffffff05" stroke="#ffffff22" />
        <rect x="15" y="10" width="260" height="34" rx="10" fill="#ffffff0d" />
        <text x="145" y="33" text-anchor="middle" fill="#f1f5f9" style="font-size: 16px; font-weight: 700">{{ st.layers ? '你的電腦' : 'user' }}</text>

        <rect x="305" y="10" width="220" height="364" rx="10" fill="#ffffff05" stroke="#ffffff22" />
        <rect x="305" y="10" width="220" height="34" rx="10" fill="#ffffff0d" />
        <text x="415" y="33" text-anchor="middle" fill="#f1f5f9" style="font-size: 16px; font-weight: 700">AD</text>

        <rect x="540" y="10" width="325" height="364" rx="10" fill="#ffffff05" stroke="#ffffff22" />
        <rect x="540" y="10" width="325" height="34" rx="10" fill="#ffffff0d" />
        <text x="702" y="33" text-anchor="middle" fill="#f1f5f9" style="font-size: 16px; font-weight: 700">app（網站）</text>
      </g>

      <!-- 你的電腦分兩層：上層瀏覽器、下層 OS -->
      <g :style="{ opacity: st.layers ? 1 : 0, transition: 'opacity 500ms' }">
        <rect x="25" y="52" width="240" height="114" rx="7" fill="#ffffff06" stroke="#ffffff1c" />
        <text x="34" y="67" fill="#cbd5e1" style="font-size: 11px; opacity: .75">瀏覽器</text>
        <rect x="25" y="176" width="240" height="190" rx="7" fill="#ffffff06" stroke="#ffffff1c" />
        <text x="34" y="191" fill="#cbd5e1" style="font-size: 11px; opacity: .75">OS</text>
      </g>

      <!-- 網路邊界 -->
      <line x1="290" y1="14" x2="290" y2="370" stroke="#ffffff40" stroke-dasharray="5 5" />
      <text x="290" y="378" text-anchor="middle" fill="#94a3b8" style="font-size: 9.5px">網路</text>

      <!-- app 的金鑰 -->
      <g transform="translate(790, 72)">
        <circle cx="7" cy="0" r="7" fill="none" :stroke="C.blue" stroke-width="3" />
        <path d="M14 0 H34 M28 0 V6 M33 0 V5" fill="none" :stroke="C.blue" stroke-width="3" stroke-linecap="round" />
      </g>
      <text x="807" y="96" text-anchor="middle" fill="#cbd5e1" style="font-size: 10px; opacity: .8">app 的金鑰</text>

      <!-- AD：上週的 Kerberos 兩個窗口，每一頁都在 -->
      <rect x="318" y="182" width="194" height="36" rx="7" fill="#ffffff0a" stroke="#ffffff40" />
      <text x="415" y="205" text-anchor="middle" fill="#f1f5f9" style="font-size: 12.5px">驗密碼，發 TGT</text>
      <rect x="318" y="247" width="194" height="36" rx="7" fill="#ffffff0a" stroke="#ffffff40" />
      <text x="415" y="270" text-anchor="middle" fill="#f1f5f9" style="font-size: 12.5px">拿 TGT 換 ST</text>
      <g :style="{ opacity: st.box === 'tgsX' ? 1 : 0, transition: 'opacity 300ms' }">
        <path d="M490 258 L502 270 M502 258 L490 270" :stroke="C.red" stroke-width="3" stroke-linecap="round" />
        <text x="415" y="302" text-anchor="middle" :fill="C.red" style="font-size: 12px">AD 沒有這個 SPN</text>
      </g>
      <text x="415" y="154" text-anchor="middle" fill="#94a3b8" style="font-size: 11.5px"
            :style="{ opacity: st.status.ad ? 1 : 0, transition: 'opacity 300ms' }">{{ st.status.ad }}</text>

      <!-- AD 也有那個值（第四章） -->
      <g :style="{ opacity: st.adNt ? 1 : 0, transition: 'opacity 400ms' }">
        <rect x="325" y="300" width="180" height="36" rx="8" :fill="C.purple + '22'" :stroke="C.purple" stroke-width="1.6" />
        <text x="415" y="322" text-anchor="middle" fill="#f3e8ff" style="font-size: 10.5px">{{ st.nt.name ? 'NT hash' : '由密碼算出的值' }}</text>
      </g>

      <!-- 瀏覽器層：網頁表單 / 瀏覽器跳出的帳密框 -->
      <g :style="{ opacity: st.form === 'none' ? 0 : 1, transition: 'opacity 400ms' }">
        <rect x="40" y="74" width="160" height="62" rx="6"
              :fill="isPrompt ? '#f9a8d414' : '#ffffff0a'"
              :stroke="isPrompt ? C.accent : '#ffffff40'" />
        <text x="50" y="90" fill="#e2e8f0" style="font-size: 10.5px">{{ isPrompt ? '瀏覽器跳出的帳密框' : '網頁的登入表單' }}</text>
        <text x="50" y="108" fill="#cbd5e1" style="font-size: 10.5px">帳號</text>
        <rect x="80" y="97" width="110" height="15" rx="3" fill="#00000040" stroke="#ffffff30" />
        <text x="85" y="108" fill="#f8fafc" style="font-size: 10px"
              :style="{ opacity: st.form === 'login' || st.form === 'prompt' ? 0 : 1, transition: 'opacity 300ms' }">andy</text>
        <text x="50" y="127" fill="#cbd5e1" style="font-size: 10.5px">密碼</text>
        <rect x="80" y="116" width="110" height="15" rx="3" fill="#00000040" stroke="#ffffff30" />
        <text x="85" y="127" fill="#f8fafc" style="font-size: 10px; letter-spacing: 2px"
              :style="{ opacity: st.form === 'login' || st.form === 'prompt' ? 0 : 1, transition: 'opacity 300ms' }">••••••••</text>
      </g>

      <!-- SPN 標籤 -->
      <g :style="{ opacity: st.spn ? 1 : 0, transition: 'opacity 300ms' }">
        <rect x="70" y="146" width="128" height="16" rx="3" fill="#0b1f24" :stroke="C.accent" stroke-opacity=".7" />
        <text x="134" y="158" text-anchor="middle" :fill="C.accent" style="font-size: 10.5px">{{ st.spn }}</text>
      </g>

      <!-- 登入 Windows（開場） -->
      <g :style="{ opacity: st.login ? 1 : 0, transition: 'opacity 400ms' }">
        <rect x="150" y="186" width="110" height="28" rx="6" fill="#ffffff0a" stroke="#ffffff50" />
        <text x="205" y="204" text-anchor="middle" fill="#f1f5f9" style="font-size: 11px">登入 Windows</text>
      </g>
      <Arrow d="M262 200 H313" tip="307,195 315,200 307,205" :on="on('login')" :color="C.line" />

      <!-- 你的電腦上沒有 TGT（第一章的痛點） -->
      <g :style="{ opacity: st.osNote ? 1 : 0, transition: 'opacity 400ms' }">
        <rect x="53" y="201" width="64" height="28" rx="5" fill="none" stroke="#f8717199" stroke-dasharray="4 3" />
        <text x="85" y="245" text-anchor="middle" fill="#fca5a5" style="font-size: 10.5px">沒有 TGT</text>
      </g>

      <!-- klist 視窗 -->
      <g :style="{ opacity: st.klist ? 1 : 0, transition: 'opacity 300ms' }">
        <rect x="142" y="186" width="120" height="64" rx="5" fill="#00000055" stroke="#ffffff30" />
        <text x="149" y="199" fill="#94a3b8" style="font-size: 9.5px; font-family: 'JetBrains Mono', monospace">&gt; klist</text>
        <text v-for="(l, i) in (st.klist ?? [])" :key="l" x="149" :y="216 + i * 16"
              :fill="l.startsWith('krbtgt') ? C.gold : C.blue"
              style="font-size: 9px; font-family: 'JetBrains Mono', monospace">{{ l }}</text>
        <text x="149" y="216" fill="#94a3b8" style="font-size: 9.5px"
              :style="{ opacity: st.klist && st.klist.length === 0 ? 1 : 0, transition: 'opacity 300ms' }">（沒有票）</text>
      </g>

      <!-- OS 會的方式 → SPNEGO -->
      <g :style="{ opacity: st.list.show ? 1 : 0, transition: 'opacity 300ms' }">
        <rect x="150" y="296" width="110" height="58" rx="5" fill="#ffffff08"
              :stroke="st.list.name ? C.accent : '#ffffff30'" style="transition: stroke 400ms" />
        <text x="205" y="310" text-anchor="middle" fill="#cbd5e1" style="font-size: 10px"
              :style="{ opacity: st.list.name ? 0 : .85, transition: 'opacity 300ms' }">我會的方式</text>
        <text x="205" y="311" text-anchor="middle" :fill="C.accent" style="font-size: 12px; font-weight: 700"
              :style="{ opacity: st.list.name ? 1 : 0, transition: 'opacity 300ms 150ms' }">SPNEGO</text>
        <g v-for="(m, i) in ['① Kerberos', '② NTLM']" :key="m">
          <rect x="158" :y="317 + i * 17" width="94" height="15" rx="3"
                :fill="st.list.pick === i + 1 ? C.accent + '33' : 'transparent'" style="transition: fill 400ms" />
          <text x="164" :y="328 + i * 17" fill="#f1f5f9" style="font-size: 10.5px">{{ m }}{{ st.list.pick === i + 1 ? '  ✓' : '' }}</text>
        </g>
      </g>

      <!-- NT hash（OS 層） -->
      <g :style="{ opacity: st.nt.show ? 1 : 0, transition: 'opacity 400ms' }">
        <rect x="39" y="295" width="92" height="28" rx="6" :fill="C.purple + '22'" :stroke="C.purple"
              :stroke-width="st.nt.glow ? 2.8 : 1.6" style="transition: stroke-width 300ms" />
        <text x="85" y="313" text-anchor="middle" fill="#f3e8ff" style="font-size: 10.5px">{{ st.nt.name ? 'NT hash' : '由密碼算出的值' }}</text>
        <text x="85" y="338" text-anchor="middle" :fill="C.purple" style="font-size: 10.5px"
              :style="{ opacity: st.nt.name ? 1 : 0, transition: 'opacity 300ms' }">＝ MD4(密碼)</text>
      </g>

      <!-- 隨機數與回應 -->
      <g :style="{ transform: `translate(${st.rnd.x}px, ${st.rnd.y}px)`, opacity: st.rnd.show ? 1 : 0,
                   transition: 'transform 650ms ease, opacity 350ms' }">
        <rect x="-25" y="-10" width="50" height="20" rx="4" fill="#ffffff22" :stroke="C.white" />
        <text x="0" y="4" text-anchor="middle" fill="#f8fafc" style="font-size: 10px">隨機數</text>
      </g>
      <g :style="{ transform: `translate(${st.resp.x}px, ${st.resp.y}px)`, opacity: st.resp.show ? 1 : 0,
                   transition: 'transform 650ms ease, opacity 350ms' }">
        <rect x="-25" y="-10" width="50" height="20" rx="4" :fill="C.purple + '22'" :stroke="C.purple" stroke-dasharray="3 2" />
        <text x="0" y="4" text-anchor="middle" fill="#f3e8ff" style="font-size: 10px">回應</text>
      </g>

      <!-- 明文帳密 -->
      <g :style="{ transform: `translate(${st.pw.x}px, ${st.pw.y}px)`, opacity: st.pw.show ? 1 : 0,
                   transition: 'transform 700ms ease, opacity 350ms' }">
        <rect x="-58" y="-10" width="116" height="20" rx="10" :fill="C.red + '22'" :stroke="C.red"
              :stroke-width="st.pw.glow ? 2.8 : 1.4" style="transition: stroke-width 300ms" />
        <text x="0" y="4" text-anchor="middle" fill="#fecaca" style="font-size: 10.5px">andy / P@ssw0rd</text>
      </g>

      <!-- 箭頭：一律沿路徑畫出來 -->
      <Arrow d="M266 75 H536" tip="530,70 538,75 530,80" :on="on('req1')" :color="C.line" />
      <text x="415" y="68" text-anchor="middle" fill="#e5e7eb" style="font-size: 11.5px"
            :style="{ opacity: on('req1') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('req1') }}</text>
      <Arrow d="M538 105 H270" tip="276,100 268,105 276,110" :on="on('res')" :color="C.line" />
      <text x="415" y="98" text-anchor="middle" fill="#e5e7eb" style="font-size: 11.5px"
            :style="{ opacity: on('res') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('res') }}</text>
      <Arrow d="M266 135 H536" tip="530,130 538,135 530,140" :on="on('req2')" :color="C.line" />
      <text x="415" y="128" text-anchor="middle" fill="#e5e7eb" style="font-size: 11.5px"
            :style="{ opacity: on('req2') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('req2') }}</text>

      <Arrow d="M538 195 H516" tip="522,190 514,195 522,200" :on="on('appas')" :color="C.line" />
      <Arrow d="M514 209 H536" tip="530,204 538,209 530,214" :on="on('asapp')" :color="C.line" :delay="250" />
      <text x="548" y="189" fill="#e5e7eb" style="font-size: 11px"
            :style="{ opacity: on('appas') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('appas') }}</text>
      <Arrow d="M538 258 H516" tip="522,253 514,258 522,263" :on="on('apptgs')" :color="C.line" />
      <Arrow d="M514 272 H536" tip="530,267 538,272 530,277" :on="on('tgsapp')" :color="C.line" :delay="250" />
      <text x="548" y="252" fill="#e5e7eb" style="font-size: 11px"
            :style="{ opacity: on('apptgs') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('apptgs') }}</text>

      <Arrow d="M538 310 H509" tip="515,305 507,310 515,315" :on="on('appnt')" :color="C.line" />
      <text x="548" y="304" fill="#e5e7eb" style="font-size: 11px"
            :style="{ opacity: on('appnt') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('appnt') }}</text>
      <Arrow d="M507 326 H536" tip="530,321 538,326 530,331" :on="on('ntapp')" :color="C.line" :delay="250" />
      <text x="548" y="344" fill="#e5e7eb" style="font-size: 11px"
            :style="{ opacity: on('ntapp') ? .95 : 0, transition: 'opacity 300ms' }">{{ lb('ntapp') }}</text>

      <Arrow d="M119 215 C 136 215, 132 258, 152 258 H311" tip="305,253 313,258 305,263" :on="on('osbox')" :color="C.line" />
      <Arrow d="M313 272 H124" tip="130,267 122,272 130,277" :on="on('boxos')" :color="C.line" :delay="250" />

      <Arrow d="M240 112 V182" tip="235,176 240,184 245,176" :on="on('down')" :color="C.accent" :opacity="0.8" />
      <Arrow d="M252 180 V118" tip="247,124 252,116 257,124" :on="on('up')" :color="C.accent" :opacity="0.8" />

      <!-- app 的判斷結果 -->
      <text x="702" y="192" text-anchor="middle" style="font-size: 14px"
            :fill="toneColor(st.tone.app)"
            :style="{ opacity: st.status.app ? 1 : 0, transition: 'opacity 300ms' }">{{ st.status.app }}</text>

      <!-- 票 -->
      <g v-for="(t, id) in st.tickets" :key="id"
         :style="{
           transform: `translate(${t.x}px, ${t.y}px)`,
           opacity: t.show ? (t.dim ? 0.3 : 1) : 0,
           transition: 'transform 700ms ease, opacity 400ms ease',
         }">
        <rect x="-32" y="-14" width="64" height="28" rx="5" fill="#ffffff0d"
              :stroke="C[t.color]" :stroke-width="t.glow ? 2.8 : 1.6" style="transition: stroke-width 300ms" />
        <text x="0" y="4" text-anchor="middle" fill="#f8fafc" style="font-size: 11px">andy</text>
        <g transform="translate(-32, -14)">
          <path d="M-4 -1 V-5 A4 4 0 0 1 4 -5 V-1" fill="none" stroke-width="1.8" :stroke="C[t.color]" />
          <rect x="-6" y="-2" width="12" height="9" rx="2" :fill="C[t.color]" />
        </g>
        <text x="0" y="27" text-anchor="middle" :fill="C[t.color]" style="font-size: 10px">{{ t.label }}</text>
      </g>
    </svg>
    <div class="text-center" style="height: 30px; line-height: 30px; font-size: 15px"
         :style="{
           color: stepTone === 'pain' ? '#fca5a5' : stepTone === 'key' ? C.accent : '#cbd5e1',
           opacity: stepTone ? 1 : .85,
         }">{{ step }}</div>
  </div>
</template>
