<script setup lang="ts">
/**
 * 第二、三章共用的同一張圖：user ｜ AD ｜ app ｜ app2 四欄固定。
 * 整段推導是一串 frame，每一頁只傳入「目前第幾個 frame」。
 * frame n 的狀態 = 從初始狀態依序套用 patch 0..n，所以跨頁時物件身份不會變。
 *
 * 圖下方每一格只放一句很短的動作描述（step），不重述圖上已揭露的結果；完整講稿（say）放在講者備註。
 *
 * 視覺語意：
 *   鎖頭（加密）顏色 = 能解開它的那把對稱金鑰的顏色；金鑰在哪一欄 = 在誰手上。
 *   盒子裡是身分（andy）；盒子外的吊牌是「給誰」。
 *   灰 = 共用；藍 = app；綠 = app2；金 = AD 自己。
 */
import { computed } from 'vue'
import Arrow from './Arrow.vue'

const props = defineProps<{ frame: number }>()

const C = {
  grey: '#9ca3af',
  blue: '#60a5fa',
  green: '#4ade80',
  gold: '#fbbf24',
  red: '#f87171',
  accent: '#fda4af',
  line: '#e2e8f0',
}

const U = 95, AD = 330, A1 = 585, A2 = 785
const S1 = 245, S2 = 330
const SWAP = 392
// AD 左組（驗密碼）裡的兩個金鑰位置：灰/藍、綠
const KA = 240, KB = 296
// 兩個窗口：票從哪個窗口出現，就是哪個窗口發的
const AS_X = 267, ISSUE_Y = 228
// 換票窗口發的票，出現在金票停靠位置的正下方，兩者平行移動不重疊
const TGS_Y = 322

type Ticket = {
  x: number; y: number; show: boolean
  lock: keyof typeof C | null
  text: string; tag: string
  maker?: string; bad?: boolean; dashed?: boolean
  kind?: 'tgt' | 'st'
}

function initial() {
  const t = (x: number, y: number, o: Partial<Ticket> = {}): Ticket =>
    ({ x, y, show: false, lock: null, text: 'andy', tag: '給 app', ...o })
  return {
    app2: false,
    keys: { ad0: null, ad1: null, ad2: null, app: null, app2: null } as Record<string, keyof typeof C | null>,
    // app / app2 的那份金鑰：還沒交出去前停在 AD 那一格，交出去時滑過去
    keyAt: { app: 'ad', app2: 'ad' } as Record<string, 'ad' | 'own'>,
    register: false,
    swap: false,
    login: false,
    callback: 'none' as 'none' | 'on' | 'cut',
    req: false,
    reqText: '',
    prompt: false,
    status: { app: '', app2: '' } as Record<string, string>,
    tone: { app: 'ok', app2: 'ok' } as Record<string, 'ok' | 'bad' | 'ask'>,
    names: {} as Record<string, boolean>,
    tickets: {
      T: t(AS_X, ISSUE_Y),
      T2: t(AS_X, ISSUE_Y),
      F: t(A2, S2, { lock: 'grey', maker: 'app2 自己做的', bad: true }),
      F2: t(A2, S2, { dashed: true, maker: 'app2 想做' }),
      // 驗密碼（AS）直接發的票
      B: t(AS_X, ISSUE_Y, { lock: 'blue' }),
      Gr: t(AS_X, ISSUE_Y, { lock: 'green', tag: '給 app2' }),
      G: t(AS_X, ISSUE_Y, { lock: 'gold', tag: '給 AD', kind: 'tgt' }),
      // 換票（TGS）拿金票換出來的票
      B2: t(SWAP, TGS_Y, { lock: 'blue', kind: 'st' }),
      Gr2: t(SWAP, TGS_Y, { lock: 'green', tag: '給 app2', kind: 'st' }),
    } as Record<string, Ticket>,
  }
}
type State = ReturnType<typeof initial>

// 每個 frame 的 patch：只寫這一格「唯一改變」的東西
const frames: any[] = [
  // ── 2-0 證據怎麼送到 app（0–4）
  { step: '你登入 AD', login: true, callback: 'on',
    say: ['你在 AD 登入了。', '照 OIDC 的做法，接下來要靠瀏覽器跳轉，把結果帶回 app。'] },
  { step: '跳轉這條路不通', callback: 'cut', status: { app: '？' }, tone: { app: 'ask' },
    say: ['可是檔案分享、SQL Server、遠端桌面這些連線，沒有跳轉可用；Kerberos 也設計成 app 不必回頭問 AD。',
      '你確實登入了 AD，但 app 拿不到你已登入的證據。'] },
  { step: 'AD 發一張票', tickets: { T: { show: true } },
    say: ['不靠跳轉：AD 在你登入時，發一張票。'] },
  { step: '票交給你', tickets: { T: { x: U, y: S1 } },
    say: ['由你自己帶著，夾在連線裡交給 app。'] },
  { step: '你把票交給 app', tickets: { T: { x: A1 } }, status: { app: '這張票是誰寫的？' },
    say: ['app 沒理由相信一張來歷不明的票：', '誰都寫得出「我是 andy」。'] },

  // ── 2-1 共用一把對稱金鑰（5–10）
  { step: 'app 向 AD 註冊', tickets: { T: { show: false } }, status: { app: '' }, callback: 'none', login: false,
    register: true,
    say: ['事前準備：app 先向 AD 註冊。', '這時還沒有任何人登入。'] },
  { step: 'AD 產生一把對稱金鑰', keys: { ad0: 'grey' },
    say: ['AD 產生一把對稱金鑰，自己留一份——'] },
  { step: '金鑰交一份給 app', keys: { app: 'grey' }, keyAt: { app: 'own' }, register: false,
    say: ['——另一份交給 app。', '從此 AD 和 app 共用這把金鑰。'] },
  { step: '你登入，AD 產出票', login: true, tickets: { T2: { show: true } },
    say: ['準備好之後，你才登入：AD 產出一張票。'] },
  { step: '用金鑰加密，交給你', tickets: { T2: { lock: 'grey', x: U, y: S1 } },
    say: ['AD 用這把金鑰把票加密，交給你。', '你拿著一張自己解不開的票。'] },
  { step: '交給 app 解開', tickets: { T2: { x: A1 } }, status: { app: '✓ 解得開，沒被動過' }, tone: { app: 'ok' },
    say: ['app 解得開，而且內容沒被動過。這把金鑰只有 AD 和 app 有，', '不是 app 自己加密的——那就只能是 AD。'] },

  // ── 2-2a 所有 app 共用一把金鑰（11–14）
  { step: 'app2 註冊，拿到同一把金鑰', app2: true, keys: { app2: 'grey' }, keyAt: { app2: 'own' }, tickets: { T2: { x: U, tag: '給任何 app' } },
    status: { app: '' }, login: false,
    say: ['加入 app2，它也向 AD 註冊。', '最省事的做法：交給它同一把金鑰。'] },
  { step: '同一張票交給 app2', tickets: { T2: { x: A2 } }, status: { app2: '✓ 也解得開' }, tone: { app2: 'ok' },
    say: ['同一張票走遍所有 app——SSO 成立。'] },
  { step: 'app2 自己做一張票', tickets: { T2: { x: U }, F: { show: true } }, status: { app2: '' },
    say: ['可是對稱金鑰能解密，也能加密：', 'app2 用手上這把灰色金鑰，自己做了一張「我是 andy」。'] },
  { step: '這張票交給 app', tickets: { F: { x: A1 } }, status: { app: '✓ 收下——分不出來' }, tone: { app: 'bad' },
    say: ['app 解開一看，完全分不出這不是 AD 做的。',
      '這張票誰做得出來？每一個拿到灰色金鑰的人。'] },

  // ── 2-2b 每個 app 一把金鑰（15–16）
  { step: '改成每個 app 各一把金鑰', tickets: { F: { show: false }, T2: { show: false } }, status: { app: '' },
    keys: { ad0: 'blue', ad1: 'green', app: 'blue', app2: 'green' },
    say: ['每個 app 和 AD 各自共用一把專屬的對稱金鑰。'] },
  { step: 'app2 想做一張給 app 的票', tickets: { F2: { show: true } }, status: { app2: '✕ 沒有藍色金鑰，做不出來' }, tone: { app2: 'bad' },
    say: ['app2 做不出、也解不開給 app 的票。', 'app 解開藍票時，「是 AD 做的」重新成立。'] },

  // ── 2-3 要進第二個 app（17–28）
  { step: '你登入，拿到藍票', tickets: { F2: { show: false }, B: { show: true, x: U, y: S1 } }, status: { app2: '' }, login: true,
    say: ['你登入，AD 發給你一張給 app 的藍票。'] },
  { step: '藍票交給 app', tickets: { B: { x: A1 } }, status: { app: '✓' }, tone: { app: 'ok' },
    say: ['藍票交給 app，app 解得開，登入成功。'] },
  { step: '藍票交給 app2', tickets: { B: { x: A2 } }, status: { app2: '✕ 解不開藍票' }, tone: { app2: 'bad' },
    say: ['現在想登入 app2：手上只有藍票，app2 的綠色金鑰解不開。'] },
  { step: '再向 AD 要票：再輸一次密碼', tickets: { B: { x: U } }, status: { app2: '' },
    req: true, reqText: '我要 app2 的票', prompt: true,
    say: ['只好再向 AD 要一張：AD 要發票，得先確認你還是你，只能再問一次密碼。'] },
  { step: '拿到綠票', req: false, prompt: false, tickets: { Gr: { show: true, x: U, y: S2 } },
    say: ['拿到綠票。'] },
  { step: '每多一個 app，就要多輸一次密碼', tone2: 'pain',
    say: ['痛點：每多一個 app，就要多輸一次密碼——SSO 消失。圖不動，讓這句話停一下。'] },
  { step: '改成：登入時多發一張給 AD 的票', tickets: { B: { show: false }, Gr: { show: false }, G: { show: true, x: U, y: S1 } },
    status: { app: '' }, keys: { ad2: 'gold' }, swap: true,
    say: ['於是 AD 在你登入時，多發一張給 AD 自己的票，用只有 AD 有的那把金鑰（金色）加密。',
      '吊牌寫「給 AD」：它就是 AD 把自己當成一個 app 的專用票。'] },
  { step: '帶著金票去換票', req: true, reqText: '金票 ＋ 我要 app 的票', tickets: { G: { x: SWAP } },
    say: ['要進 app 時，帶著金票去換票。'] },
  { step: '換到藍票', req: false, tickets: { G: { x: U }, B2: { show: true, x: U, y: S2 } },
    say: ['AD 用自己的金鑰解開金票：你在有效期限內登入過。不用再問密碼，發出藍票。'] },
  { step: '藍票交給 app', tickets: { B2: { x: A1, y: S1 } }, status: { app: '✓' }, tone: { app: 'ok' },
    say: ['藍票交給 app。'] },
  { step: '同一張金票，再換綠票', req: true, reqText: '金票 ＋ 我要 app2 的票', tickets: { Gr2: { show: true, x: U, y: S2 } },
    say: ['要進 app2 時，同一張金票再換一張綠票，一樣不用輸密碼。'] },
  { step: '綠票交給 app2', req: false, tickets: { Gr2: { x: A2, y: S1 } }, status: { app2: '✓' }, tone: { app2: 'ok' },
    say: ['綠票交給 app2。一張金票換出多張專用票 → SSO；每張專用票仍只有自己的 app 解得開 → 隔離。'] },

  // ── 第三章：圖不動，只貼名字（29–38）
  { step: '貼上正式名稱', status: { app: '', app2: '' }, login: false,
    say: ['圖不動，只把名字貼上去。'] },
  { step: 'AD → KDC', names: { kdc: true }, say: ['AD 那一整欄：KDC（Key Distribution Center）'] },
  { step: '驗密碼 → AS', names: { as: true }, say: ['輸入密碼、拿金票的那一關：AS（Authentication Server）'] },
  { step: '換票 → TGS', names: { tgs: true }, say: ['拿金票換專用票的那一關：TGS（Ticket-Granting Server）'] },
  { step: '金票 → TGT', names: { tgt: true }, say: ['金票：TGT（Ticket-Granting Ticket）'] },
  { step: '藍票、綠票 → service ticket', names: { st: true }, say: ['藍票、綠票：service ticket'] },
  { step: 'app → Application Server', names: { srv: true }, say: ['app、app2：Application Server'] },
  { step: '吊牌 → SPN', names: { spn: true }, say: ['吊牌上的「給 app」：SPN（service principal name）'] },
  { step: 'app 的金鑰 → secret key', names: { key: true }, say: ['app 手上的那把對稱金鑰：服務帳號的 secret key', '（Linux / Java 服務會把它存成 keytab 檔）'] },
  { step: '誰發了哪張票', names: { issued: true },
    say: ['最後把兩個窗口和它發的票連起來：AS 發 TGT，TGS 拿 TGT 換出 service ticket。'] },
]

function apply(s: State, p: any) {
  for (const k of Object.keys(p)) {
    if (k === 'tickets') {
      for (const id of Object.keys(p.tickets))
        s.tickets[id] = { ...s.tickets[id], ...p.tickets[id] }
    }
    else if (['keys', 'keyAt', 'status', 'tone', 'names'].includes(k)) {
      Object.assign((s as any)[k], p[k])
    }
    else {
      (s as any)[k] = p[k]
    }
  }
}

// 每一格只放一句很短的「這一格在做什麼」，不重述圖上已經看得到的結果
const step = computed(() => frames[Math.min(props.frame, frames.length - 1)].step ?? '')
// 痛點那一格的文字用淡紅色，和一般動作描述區分
const stepPain = computed(() => frames[Math.min(props.frame, frames.length - 1)].tone2 === 'pain')

const st = computed(() => {
  const s = initial()
  const n = Math.min(props.frame, frames.length - 1)
  for (let i = 0; i <= n; i++) apply(s, frames[i])
  return s
})

const toneColor = (t: string) => t === 'bad' ? C.red : t === 'ask' ? '#cbd5e1' : '#e5e7eb'

// 粗估吊牌寬度：中日韓字約 11px、其他約 6.2px
function tagW(s: string) {
  let w = 0
  for (const ch of s) w += /[　-鿿＀-￯]/.test(ch) ? 11 : 7
  return Math.round(w + 16)
}

function spnText(id: string) {
  if (id === 'B2') return 'HTTP/app.corp.local'
  if (id === 'Gr2') return 'HTTP/app2.corp.local'
  return ''
}

const lanes = computed(() => [
  { x: 20, w: 150, cx: U, title: 'user', show: true },
  { x: 205, w: 250, cx: AD, title: 'AD', show: true },
  { x: 490, w: 190, cx: A1, title: 'app', show: true },
  { x: 700, w: 170, cx: A2, title: 'app2', show: st.value.app2 },
])
</script>

<template>
  <div>
    <svg viewBox="0 0 880 380" class="w-full" style="height: 376px">
      <!-- 四欄：位置從頭到尾固定；app2 先預留 -->
      <g v-for="l in lanes" :key="l.title">
        <rect :x="l.x" y="10" :width="l.w" height="364" rx="10"
              fill="#ffffff05"
              :stroke="l.show ? '#ffffff22' : '#ffffff12'"
              :stroke-dasharray="l.show ? '0' : '5 5'" />
        <rect :x="l.x" y="10" :width="l.w" height="36" rx="10"
              fill="#ffffff0d" :style="{ opacity: l.show ? 1 : 0, transition: 'opacity 400ms' }" />
        <text :x="l.cx" y="34" text-anchor="middle" fill="#f1f5f9"
              style="font-size: 16px; font-weight: 700"
              :style="{ opacity: l.show ? 1 : 0, transition: 'opacity 400ms' }">{{ l.title }}</text>
      </g>

      <!-- 第三章貼上的名字（欄位層級） -->
      <text :x="AD" y="64" text-anchor="middle" :fill="C.accent" style="font-size: 12px"
            :style="{ opacity: st.names.kdc ? 1 : 0, transition: 'opacity 400ms' }">KDC（Key Distribution Center）</text>
      <text v-for="x in [A1, A2]" :key="'srv' + x" :x="x" y="64" text-anchor="middle" :fill="C.accent"
            style="font-size: 12px"
            :style="{ opacity: st.names.srv ? 1 : 0, transition: 'opacity 400ms' }">Application Server</text>

      <!-- 金鑰：在哪一欄 = 在誰手上 -->
      <g v-for="k in [
        { id: 'ad0', x: KA }, { id: 'ad1', x: KB }, { id: 'ad2', x: SWAP },
        { id: 'app', x: A1 }, { id: 'app2', x: A2 },
      ]" :key="k.id"
         :style="{
           opacity: st.keys[k.id] ? 1 : 0,
           transform: `translate(${(st.keyAt[k.id] === 'ad' ? KA : k.x) - 17}px, 90px)`,
           transition: 'opacity 450ms, transform 800ms ease',
         }">
        <g>
          <circle cx="7" cy="0" r="7" fill="none" stroke-width="3"
                  :style="{ stroke: C[st.keys[k.id] ?? 'grey'], transition: 'stroke 600ms' }" />
          <path d="M14 0 H34 M28 0 V6 M33 0 V5" fill="none" stroke-width="3" stroke-linecap="round"
                :style="{ stroke: C[st.keys[k.id] ?? 'grey'], transition: 'stroke 600ms' }" />
        </g>
      </g>
      <g v-for="x in [A1, A2]" :key="'key' + x"
         :style="{ opacity: st.names.key ? 1 : 0, transition: 'opacity 400ms' }">
        <text :x="x" y="116" text-anchor="middle" :fill="C.accent" style="font-size: 12px">secret key</text>
        <text :x="x" y="130" text-anchor="middle" fill="#cbd5e1" style="font-size: 10.5px; opacity: .7">（keytab 檔）</text>
      </g>

      <!-- AD 的金鑰（一排，用小字分等級）與兩個窗口：票從哪個窗口出現，就是哪個窗口發的 -->
      <text :x="(KA + KB) / 2" y="113" text-anchor="middle" fill="#cbd5e1" style="font-size: 10px"
            :style="{ opacity: st.keys.ad0 ? .7 : 0, transition: 'opacity 400ms' }">和 app 共用</text>
      <text :x="SWAP" y="113" text-anchor="middle" :fill="C.gold" style="font-size: 10px"
            :style="{ opacity: st.keys.ad2 ? .85 : 0, transition: 'opacity 400ms' }">只有 AD 有</text>
      <!-- 驗密碼（AS）：功能描述置中；貼上名稱時，描述往下讓出位置，名稱出現在上方 -->
      <g>
        <rect x="210" y="128" width="115" height="40" rx="7" fill="#ffffff0a" stroke="#ffffff40" />
        <text x="267" y="153" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px"
              :style="{ transform: st.names.as ? 'translateY(10px)' : 'none', opacity: st.names.as ? .8 : 1,
                        transition: 'transform 450ms ease, opacity 300ms' }">驗密碼</text>
        <text x="267" y="146" text-anchor="middle" :fill="C.accent" style="font-size: 15px; font-weight: 700"
              :style="{ opacity: st.names.as ? 1 : 0, transition: 'opacity 300ms 200ms' }">AS</text>
      </g>
      <!-- 已登入：貼在驗密碼框右上角的小徽章，不佔框內位置 -->
      <g :style="{ opacity: st.login && !st.names.as ? 1 : 0, transition: 'opacity 300ms' }">
        <rect x="286" y="119" width="48" height="16" rx="8" fill="#0b1526" stroke="#cbd5e1" stroke-opacity=".5" />
        <text x="310" y="131" text-anchor="middle" fill="#e5e7eb" style="font-size: 10px">andy ✓</text>
      </g>
      <!-- 換票（TGS）：中性邊框，避免和金票（金色）混成一組 -->
      <g :style="{ opacity: st.swap ? 1 : 0, transition: 'opacity 450ms' }">
        <rect x="335" y="128" width="115" height="40" rx="7" fill="#ffffff0a" stroke="#ffffff40" />
        <text :x="SWAP" y="153" text-anchor="middle" fill="#f1f5f9" style="font-size: 13px"
              :style="{ transform: st.names.tgs ? 'translateY(10px)' : 'none', opacity: st.names.tgs ? .8 : 1,
                        transition: 'transform 450ms ease, opacity 300ms' }">換票</text>
        <text :x="SWAP" y="146" text-anchor="middle" :fill="C.accent" style="font-size: 15px; font-weight: 700"
              :style="{ opacity: st.names.tgs ? 1 : 0, transition: 'opacity 300ms 200ms' }">TGS</text>
      </g>
      <text x="212" y="186" :fill="C.accent" style="font-size: 11px"
            :style="{ opacity: st.names.as ? 1 : 0, transition: 'opacity 400ms' }">AS = Authentication Server</text>
      <text x="212" y="201" :fill="C.accent" style="font-size: 11px"
            :style="{ opacity: st.names.tgs ? 1 : 0, transition: 'opacity 400ms' }">TGS = Ticket-Granting Server</text>

      <!-- 第三章最後：誰發了哪張票（AS → TGT；TGS → service ticket） -->
      <Arrow d="M210 160 C 175 160, 172 245, 145 245" tip="152,240 143,245 152,250"
             :on="!!st.names.issued" :color="C.accent" :opacity="0.75" />
      <Arrow d="M450 160 C 492 160, 492 256, 535 256" tip="528,251 537,256 528,261"
             :on="!!st.names.issued" :color="C.accent" :opacity="0.75" :delay="300" />
      <Arrow d="M450 152 H 684 C 702 152, 696 256, 735 256" tip="728,251 737,256 728,261"
             :on="!!st.names.issued" :color="C.accent" :opacity="0.75" :delay="450" />

      <!-- 事前註冊：app → AD -->
      <Arrow d="M560 110 H334" tip="340,105 332,110 340,115" :on="st.register" :color="C.line" />
      <text x="446" y="102" text-anchor="middle" fill="#cbd5e1" style="font-size: 11px"
            :style="{ opacity: st.register ? .85 : 0, transition: 'opacity 300ms' }">註冊 app</text>

      <!-- 登入：user → 驗密碼 -->
      <Arrow d="M150 148 H206" tip="200,143 208,148 200,153" :on="st.login" :color="C.line" />
      <text x="178" y="140" text-anchor="middle" fill="#cbd5e1" style="font-size: 11px"
            :style="{ opacity: st.login ? .8 : 0, transition: 'opacity 300ms' }">帳密</text>

      <!-- OIDC 式的跳轉：先畫出來，再被切斷 -->
      <Arrow d="M327 148 H574" tip="568,143 576,148 568,153"
             :on="st.callback !== 'none'" :opacity="st.callback === 'cut' ? 0.15 : 0.55"
             :color="C.line" />
      <text x="452" y="131" text-anchor="middle" fill="#cbd5e1" style="font-size: 11px"
            :style="{ opacity: st.callback === 'on' ? .8 : st.callback === 'cut' ? .25 : 0, transition: 'opacity 300ms' }">跳轉帶回 app</text>
      <g :style="{ opacity: st.callback === 'cut' ? 1 : 0, transition: 'opacity 300ms' }">
        <path d="M444 140 L460 156 M460 140 L444 156" :stroke="C.red" stroke-width="3" stroke-linecap="round" />
        <text x="452" y="176" text-anchor="middle" :fill="C.red" style="font-size: 11px">沒有跳轉可用</text>
      </g>

      <!-- 換票請求 -->
      <Arrow d="M150 184 H267 V172" tip="262,178 267,170 272,178" :on="st.req && !st.swap" :color="C.line" />
      <Arrow d="M150 184 H362 V172" tip="357,178 362,170 367,178" :on="st.req && st.swap" :color="C.line" />
      <text :x="st.swap ? 256 : 200" y="201" text-anchor="middle" fill="#e5e7eb" style="font-size: 11.5px"
            :style="{ opacity: st.req ? .9 : 0, transition: 'opacity 300ms' }">{{ st.reqText }}</text>

      <!-- 再輸入一次密碼 -->
      <g :style="{ opacity: st.prompt ? 1 : 0, transition: 'opacity 350ms' }">
        <rect x="28" y="96" width="134" height="46" rx="7" fill="#f8717114" :stroke="C.red" />
        <text :x="U" y="115" text-anchor="middle" fill="#fecaca" style="font-size: 12px">再輸入一次密碼</text>
        <text :x="U" y="133" text-anchor="middle" fill="#fecaca" style="font-size: 12px; letter-spacing: 2px">••••••</text>
      </g>

      <!-- 各欄的判斷結果 -->
      <text v-for="s in [{ id: 'app', x: A1 }, { id: 'app2', x: A2 }]" :key="'s' + s.id"
            :x="s.x" y="186" text-anchor="middle" style="font-size: 14px"
            :fill="toneColor(st.tone[s.id])"
            :style="{ opacity: st.status[s.id] ? 1 : 0, transition: 'opacity 300ms' }">{{ st.status[s.id] }}</text>

      <!-- 票：盒子裡是身分，盒子外的吊牌是給誰 -->
      <g v-for="(t, id) in st.tickets" :key="id"
         :style="{
           transform: `translate(${t.x}px, ${t.y}px)`,
           opacity: t.show ? 1 : 0,
           transition: 'transform 650ms ease, opacity 400ms ease',
         }">
        <line x1="0" y1="-20" x2="0" y2="-31" stroke="#cbd5e1" stroke-width="1" opacity=".6" />
        <g :style="{ opacity: st.names.spn && spnText(String(id)) ? 0 : 1, transition: 'opacity 500ms' }">
          <rect :x="-tagW(t.tag) / 2" y="-47" :width="tagW(t.tag)" height="16" rx="3"
                fill="#0b1526" stroke="#cbd5e1" stroke-opacity=".5" />
          <text x="0" y="-35" text-anchor="middle" fill="#e2e8f0" style="font-size: 10.5px">{{ t.tag }}</text>
        </g>
        <g v-if="spnText(String(id))" :style="{ opacity: st.names.spn ? 1 : 0, transition: 'opacity 500ms' }">
          <rect :x="-tagW(spnText(String(id))) / 2" y="-47" :width="tagW(spnText(String(id)))" height="16" rx="3"
                fill="#0b1526" :stroke="C.accent" stroke-opacity=".7" />
          <text x="0" y="-35" text-anchor="middle" :fill="C.accent" style="font-size: 10.5px">{{ spnText(String(id)) }}</text>
          <text x="0" y="-53" text-anchor="middle" :fill="C.accent" style="font-size: 10px; opacity: .85">SPN（service principal name）</text>
        </g>

        <rect x="-46" y="-20" width="92" height="40" rx="6"
              :fill="t.bad ? '#f8717112' : '#ffffff0d'"
              :stroke="t.lock ? C[t.lock] : '#cbd5e1'"
              :stroke-opacity="t.lock ? 1 : .45"
              :stroke-dasharray="t.dashed ? '4 4' : '0'"
              stroke-width="1.6"
              style="transition: stroke 500ms" />
        <text x="0" y="5" text-anchor="middle" fill="#f8fafc" style="font-size: 13px">{{ t.text }}</text>

        <!-- 鎖頭：顏色 = 能解開它的金鑰 -->
        <g transform="translate(-46, -20)" :style="{ opacity: t.lock ? 1 : 0, transition: 'opacity 350ms' }">
          <path d="M-5 -1 V-6 A5 5 0 0 1 5 -6 V-1" fill="none" stroke-width="2"
                :style="{ stroke: t.lock ? C[t.lock] : 'transparent' }" />
          <rect x="-7" y="-2" width="14" height="11" rx="2"
                :style="{ fill: t.lock ? C[t.lock] : 'transparent' }" />
        </g>

        <text v-if="t.maker" x="0" y="36" text-anchor="middle" :fill="C.red" style="font-size: 11px">{{ t.maker }}</text>
        <text v-if="t.kind === 'tgt'" x="0" y="36" text-anchor="middle" :fill="C.accent" style="font-size: 12px; font-weight: 700"
              :style="{ opacity: st.names.tgt ? 1 : 0, transition: 'opacity 400ms' }">TGT</text>
        <text v-if="t.kind === 'tgt'" x="0" y="50" text-anchor="middle" fill="#cbd5e1" style="font-size: 10.5px"
              :style="{ opacity: st.names.tgt ? .8 : 0, transition: 'opacity 400ms' }">Ticket-Granting Ticket</text>
        <text v-if="t.kind === 'st'" x="0" y="36" text-anchor="middle" :fill="C.accent" style="font-size: 12px; font-weight: 700"
              :style="{ opacity: st.names.st ? 1 : 0, transition: 'opacity 400ms' }">service ticket</text>
      </g>
    </svg>
    <div class="text-center" style="height: 30px; line-height: 30px; font-size: 15px"
         :style="{ color: stepPain ? '#fca5a5' : '#cbd5e1', opacity: stepPain ? 1 : .8 }">{{ step }}</div>
  </div>
</template>
