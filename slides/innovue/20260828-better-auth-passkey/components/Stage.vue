<script setup lang="ts">
import { computed } from 'vue'
/**
 * 第二段的主圖：從 ④ 一路撐到 ⑨，全程同一張圖、同一組座標。
 *
 * db 一律畫成真的表（欄位名 + 資料列），不是抽象方塊。
 * 觀眾要能直接讀出「這一列現在指向誰」，那是 ⑤⑥⑦ 全部劇情的所在。
 * 刻意只畫 user / passkey / mapping 三張表 —— session 不畫，
 * 登入成功與否改由「畫面上的結果」呈現，因為那才是使用者真正看到的東西。
 *
 * ⑤ 是全場唯一一次空間重排，而且拆成兩拍：
 *   先各半（app server 全空）→ 再讓 andy 滑到右邊，auth 那格整個清空。
 * 「兩格出現」與「人落到哪一邊」是兩件事，合成一拍觀眾就看不出誰動了。
 *
 * 注意這一步不是資料 migration。真實情況就是 auth server 全空、使用者只在 app；
 * ④ 那張圖是 Better Auth 自己能做到的示範，這裡是把場景換成我們真正的起點。
 *
 * 全場最重要的兩格：
 *  · step 13 —— passkey 登入成功了，右邊那格「什麼都沒有變」。痛點是用空白做的。
 *  · step 18 —— id_token 裡的 app_user_id 拉一條線回到 step 10 建的那一列。
 *
 * step: 0 起始 / 1 signUp / 2 signIn / 3 addPasskey / 4 signIn.passkey
 *       5 一分為二（app 全空）/ 6 andy 滑到 app，auth 回到它真正的起點：全空
 *       7 app 簽 JWT / 8 導頁帶 cookie / 9 網域前提 / 10 驗簽建 mapping / 11 passkey 接上
 *       12 passkey 登入成功 / 13 右邊沒有變 / 14 這個確認只活 60 秒
 *       15 換帽子成 IdP / 16 走一次 OIDC / 17 攤開 id_token / 18 回收 mapping / 19 app 簽自己的 session
 *       20 收束：只圈 app 那一格
 */
const props = withDefaults(defineProps<{ step?: number; focus?: boolean }>(), { step: 0, focus: false })
const s = computed(() => props.step)

const SIGNUP = 1, SIGNIN = 2, ADDPK = 3, PKLOGIN = 4
const SPLIT = 5, MOVED = 6
const APPJWT = 7, REDIRECT = 8, DOMAIN = 9, VERIFY = 10, BOUND = 11
const PKAUTH = 12, NOCHANGE = 13, SHORT = 14
const IDP = 15, OIDC = 16, PAYLOAD = 17, RECALL = 18, APPSESSION = 19

const split = computed(() => s.value >= SPLIT)
const authW = computed(() => (split.value ? 424 : 540))
const APP_X = 456, APP_W = 424
const PT = 48, PH = 282

/**
 * 四次呼叫是一份「累積」的清單，不是一次換一行：
 * 前面呼叫過的留在畫面上（淡化），當前這一支高亮，還沒輪到的保留空行。
 * 觀眾因此看得到「這一格已經做完幾件事」，而不是每次都在看一個孤立的呼叫。
 *
 * 後兩支 passkey 的說明要點出：瀏覽器會先跳出驗證器，
 * 使用者在裝置上完成之後，結果才送到 server —— 那一段根本不在 server 手上。
 */
const CALL_LIST = [
  { code: 'authClient.signUp.email()', hot: 'user',
    desc: 'user 表多了一列 andy', auth: false },
  { code: 'authClient.signIn.email()', hot: 'user',
    desc: '帳密驗過了，畫面顯示登入成功', auth: false },
  { code: 'authClient.passkey.addPasskey()', hot: 'passkey',
    desc: '瀏覽器先跳出驗證器（Touch ID／PIN／安全金鑰），使用者在裝置上完成之後，結果才送到 server', auth: true },
  { code: 'authClient.signIn.passkey()', hot: 'passkey',
    desc: '一樣先跳驗證器，通過之後 server 才認得他 —— 全程沒有用到密碼', auth: true },
]
const call = computed(() => (s.value >= SIGNUP && s.value <= PKLOGIN ? CALL_LIST[s.value - 1] : null))

/** 哪張表此刻有資料流進出 */
const hot = computed(() => {
  if (call.value) return call.value.hot
  if (s.value === VERIFY) return 'user+mapping'
  if (s.value === BOUND) return 'passkey'
  if (s.value === RECALL) return 'mapping'
  if (s.value === MOVED) return 'appuser'
  return ''
})
const isHot = (name: string) => hot.value.includes(name)

/**
 * auth.user：④ 那一格是 Better Auth 自己能做到的示範；step 6 之後回到真實情況 ——
 * auth server 本來就是空的，直到 step 10 才由 resolveUser 建出一筆佔位身分。
 * b 留空的那幾筆，email 由下面那顆會滑動的 andy 負責顯示。
 */
const authUsers = computed(() => {
  if (s.value >= VERIFY) return [{ a: 'u_2', b: 'app-user-7@invalid' }]
  if (s.value >= MOVED) return []
  if (s.value >= SIGNUP) return [{ a: 'u_1', b: '' }]
  return []
})

/** auth.passkey：step 6 之後同樣是空的，真正的那一把要到 step 11 才被建出來 */
const authPasskeys = computed(() => {
  if (s.value >= BOUND) return [{ a: 'pk_1', b: 'u_2' }]
  if (s.value >= MOVED) return []
  if (s.value >= ADDPK) return [{ a: 'pk_1', b: 'u_1' }]
  return []
})

const mappings = computed(() => (s.value >= VERIFY ? [{ a: 'u_2', b: '7' }] : []))
const appUsers = computed(() => (s.value >= MOVED ? [{ a: '7', b: '' }] : []))

/**
 * andy 本人。用同一個絕對定位節點在兩張表的 email 欄位之間水平滑動，
 * 而不是左邊消失、右邊冒出來 —— 觀眾要看見的是「同一個人」，不是兩筆資料。
 * 座標對齊 user 表的 email 欄：wrapper 30 + border 1 + px-2 8 + id 欄 72。
 */
const ANDY_X = computed(() => (s.value >= MOVED ? APP_X + 111 : 111))

const appSession = computed(() => {
  if (s.value >= APPSESSION) return { t: 'app session JWT', n: '這次由 passkey 換來的', hot: true }
  if (s.value >= APPJWT) return { t: 'app session JWT', n: '帳密登入簽的', hot: false }
  return null
})

/** 底下那一行判詞。紅字全場只出現一次（step 10），出現一次才有重量。 */
const note = computed(() => {
  if (props.focus) return null
  if (s.value === DOMAIN)
    return { t: '⚠ 前提：app 與 auth server 必須在同一個網域（example.com）底下，這個 cookie 才送得到', tone: 'red' }
  if (s.value === NOCHANGE)
    return { t: '右邊那一格從剛才到現在，什麼都沒有變 —— app 不知道發生過任何事', tone: 'amber' }
  if (s.value === MOVED)
    return { t: '這不是把資料搬過去 —— 真實情況本來就是：auth server 全空，使用者只在 app 這一邊', tone: 'amber' }
  if (s.value === RECALL)
    return { t: 'app_user_id 就是註冊時建的那一列 —— 這一刻它才被兌現', tone: 'teal' }
  if (s.value === APPSESSION)
    return { t: 'auth server 從頭到尾沒有發過 app 的 session，它只交出了「這是誰」', tone: 'teal' }
  return null
})
const noteClass = computed(() =>
  note.value?.tone === 'red' ? 'text-red-300'
    : note.value?.tone === 'amber' ? 'text-amber-300' : 'text-teal-300')

const showRedirect = computed(() => s.value >= REDIRECT && s.value <= BOUND)
/** 登入是另一輪，箭頭要重新指一次，不能沿用註冊那一條 */
const showLogin = computed(() => s.value >= PKAUTH && s.value <= SHORT)
const showOidc = computed(() => s.value >= OIDC && s.value <= APPSESSION)
</script>

<template>
  <div class="relative mx-auto" style="width: 880px; height: 380px">

    <!-- 跨邊界箭頭層 -->
    <svg viewBox="0 0 880 380" class="absolute inset-0 w-full h-full" style="pointer-events: none">
      <!-- ④ 每一次 client 呼叫都往 server 打一發 -->
      <g v-if="call" :key="'call' + s">
        <line class="stGrow" x1="594" y1="196" x2="556" y2="196"
              stroke="#fbbf24" stroke-width="2.5" style="--len: 38" />
        <polygon class="stHead" points="556,190 546,196 556,202" fill="#fbbf24" />
      </g>

      <!-- ⑥ 導頁：使用者離開 app 的頁面，cookie 隨請求一起過去 -->
      <g v-if="showRedirect">
        <text x="438" y="13" text-anchor="middle" fill="#fcd34d" style="font-size: 11px">
          導頁到 auth server 的 enroll 頁，App session cookie 隨行
        </text>
        <line class="stGrow" x1="660" y1="24" x2="216" y2="24"
              stroke="#fbbf24" stroke-width="2.5" stroke-linecap="round" style="--len: 444" />
        <polygon class="stHead" points="216,18 206,24 216,30" fill="#fbbf24" />
      </g>

      <!-- ⑦ 這是「登入」那一輪，跟上面註冊那次不是同一件事，所以箭頭重畫一次 -->
      <g v-if="showLogin">
        <text x="438" y="13" text-anchor="middle" fill="#fcd34d" style="font-size: 11px">
          新的一輪：導頁到 auth server 的 sign-in 頁，用 passkey 登入
        </text>
        <line class="stGrow" x1="660" y1="24" x2="216" y2="24"
              stroke="#fbbf24" stroke-width="2.5" stroke-linecap="round" style="--len: 444" />
        <polygon class="stHead" points="216,18 206,24 216,30" fill="#fbbf24" />
      </g>

      <!-- ⑧ OIDC：一來一回，刻意不展開細節 -->
      <g v-if="showOidc">
        <text x="438" y="11" text-anchor="middle" fill="#a5b4fc" style="font-size: 10.5px">authorize</text>
        <line x1="640" y1="19" x2="236" y2="19" stroke="#818cf8" stroke-width="2" />
        <polygon points="236,14 227,19 236,24" fill="#818cf8" />
        <line x1="236" y1="33" x2="640" y2="33" stroke="#2dd4bf" stroke-width="2.5" />
        <polygon points="640,28 649,33 640,38" fill="#2dd4bf" />
        <text x="438" y="45" text-anchor="middle" fill="#5eead4" style="font-size: 11px">id_token</text>
      </g>

      <!-- 回收線：id_token 的 app_user_id → 註冊時建的那一列 mapping -->
      <g v-if="s >= RECALL">
        <path class="stGrow" d="M 470 280 C 446 274, 436 250, 412 240"
              fill="none" stroke="#2dd4bf" stroke-width="2.5" style="--len: 140" />
        <polygon points="412,234 402,240 412,246" fill="#2dd4bf" />
      </g>
    </svg>

    <!-- ── auth server ────────────────────────────────────────────── -->
    <div class="absolute rounded-xl border-2 border-teal-400/60 bg-teal-400/5 transition-all duration-700"
         :style="{ left: '0px', top: PT + 'px', width: authW + 'px', height: PH + 'px' }" />
    <div class="absolute text-teal-300 font-bold"
         :style="{ left: '16px', top: (PT + 8) + 'px' }" style="font-size: 14px">auth server</div>

    <div v-if="s >= APPJWT"
         class="absolute rounded border border-sky-400/50 bg-sky-400/10 text-sky-200 px-2 py-0.5 transition-all duration-500"
         :style="{ left: (authW - 96) + 'px', top: (PT + 6) + 'px' }" style="font-size: 10.5px">🔓 App 公鑰</div>
    <div v-if="s >= IDP"
         class="absolute rounded border border-indigo-400/60 bg-indigo-400/15 text-indigo-200 px-2 py-0.5 transition-all duration-500"
         :style="{ left: (authW - 244) + 'px', top: (PT + 6) + 'px' }" style="font-size: 10.5px">同時是 OIDC Provider</div>

    <!-- auth 的 db -->
    <div class="absolute rounded-lg border border-slate-400/30 bg-slate-400/5 transition-all duration-700"
         :style="{ left: '16px', top: '86px', width: (authW - 32) + 'px', height: '192px' }">
      <div class="opacity-40 px-3 pt-1 text-right" style="font-size: 10px">db</div>
    </div>

    <!-- user 表 -->
    <div class="absolute transition-all duration-700" :style="{ left: '30px', top: '96px', width: (authW - 60) + 'px' }">
      <div class="opacity-45 mb-0.5" style="font-size: 10px">user</div>
      <div class="rounded border transition-all duration-300"
           :class="isHot('user') ? 'border-amber-400/80 bg-amber-400/10' : 'border-slate-400/30 bg-slate-400/5'">
        <div class="flex opacity-40 border-b border-slate-400/20 px-2 py-0.5" style="font-size: 9.5px">
          <span style="width: 72px">id</span><span>email</span>
        </div>
        <div v-for="r in authUsers" :key="r.a" class="flex px-2 py-0.5" style="font-size: 10.5px">
          <span class="font-mono text-teal-200" style="width: 72px">{{ r.a }}</span><span>{{ r.b }}</span>
        </div>
        <div v-if="!authUsers.length" class="px-2 py-0.5 opacity-25" style="font-size: 10.5px">（無資料）</div>
      </div>
    </div>

    <!-- passkey 表 -->
    <div class="absolute transition-all duration-700" :style="{ left: '30px', top: '154px', width: (authW - 60) + 'px' }">
      <div class="opacity-45 mb-0.5" style="font-size: 10px">passkey</div>
      <div class="rounded border transition-all duration-300"
           :class="isHot('passkey') ? 'border-amber-400/80 bg-amber-400/10' : 'border-slate-400/30 bg-slate-400/5'">
        <div class="flex opacity-40 border-b border-slate-400/20 px-2 py-0.5" style="font-size: 9.5px">
          <span style="width: 72px">id</span><span>userId</span>
        </div>
        <div v-for="r in authPasskeys" :key="r.a" class="flex px-2 py-0.5" style="font-size: 10.5px">
          <span class="font-mono text-violet-200" style="width: 72px">{{ r.a }}</span>
          <span class="font-mono text-teal-200">{{ r.b }}</span>
        </div>
        <div v-if="!authPasskeys.length" class="px-2 py-0.5 opacity-25" style="font-size: 10.5px">（無資料）</div>
      </div>
    </div>

    <!-- mapping 表：位置從 ⑤ 就預留，避免 ⑥ 填進來時把版面推走 -->
    <div class="absolute transition-all duration-700"
         :style="{ left: '30px', top: '212px', width: (authW - 60) + 'px', opacity: s >= SPLIT ? 1 : 0 }">
      <div class="opacity-45 mb-0.5" style="font-size: 10px">
        mapping <span class="opacity-60">· 自己加的表，不是 Better Auth 的</span>
      </div>
      <div class="rounded border transition-all duration-300"
           :class="isHot('mapping') ? 'border-teal-400/80 bg-teal-400/15' : 'border-slate-400/30 bg-slate-400/5'">
        <div class="flex opacity-40 border-b border-slate-400/20 px-2 py-0.5" style="font-size: 9.5px">
          <span style="width: 72px">auth_user_id</span><span>app_user_id</span>
        </div>
        <div v-for="r in mappings" :key="r.a" class="flex px-2 py-0.5" style="font-size: 10.5px">
          <span class="font-mono text-teal-200" style="width: 72px">{{ r.a }}</span>
          <span class="font-mono text-teal-200">{{ r.b }}</span>
        </div>
        <div v-if="!mappings.length" class="px-2 py-0.5 opacity-25" style="font-size: 10.5px">（無資料）</div>
      </div>
    </div>

    <!-- ⑦ 認人的結果：不是一列資料，是一個狀態 -->
    <div v-if="s >= PKAUTH"
         class="absolute flex items-center gap-2 transition-all duration-500"
         :style="{ left: '30px', top: '290px' }">
      <span class="rounded border border-amber-400/60 bg-amber-400/15 text-amber-200 px-2 py-0.5"
            style="font-size: 11px">✓ 已確認身分</span>
      <span v-if="s >= SHORT" class="text-amber-300/70" style="font-size: 10px">但這個確認只活 60 秒，而且不 refresh</span>
    </div>

    <!-- ── client lib（只在還沒分家之前存在）───────────────────────── -->
    <div v-if="!split"
         class="absolute rounded-lg border-2 border-slate-400/50 bg-slate-400/5 px-3 py-2 transition-all duration-500"
         style="left: 600px; top: 92px; width: 280px; height: 214px">
      <div class="opacity-80 font-bold" style="font-size: 13px">client lib</div>
      <div class="font-mono opacity-55 mt-1 leading-relaxed" style="font-size: 9.5px">
        <div>const authClient =</div>
        <div class="pl-3">createAuthClient({ baseURL })</div>
      </div>
      <!-- 四行位置固定：還沒輪到的留空行，呼叫過的留在畫面上 -->
      <div class="border-t border-slate-400/20 mt-2 pt-1.5 font-mono" style="font-size: 10px">
        <div v-for="(c, i) in CALL_LIST" :key="c.code"
             class="transition-all duration-300"
             style="height: 18px; line-height: 18px"
             :class="s === i + 1 ? 'text-amber-200' : s > i + 1 ? 'opacity-30' : 'opacity-0'">{{ c.code }}</div>
      </div>
      <div v-if="call" class="border-t border-slate-400/20 mt-1.5 pt-1.5 leading-snug"
           :class="call.auth ? 'text-amber-300/90' : 'opacity-60'" style="font-size: 10px">{{ call.desc }}</div>
    </div>

    <!-- ── app server ─────────────────────────────────────────────── -->
    <template v-if="split">
      <div class="absolute rounded-xl border-2 transition-all duration-700"
           :class="(s === NOCHANGE || s === SHORT || focus) ? 'border-amber-400/80 bg-amber-400/10' : 'border-sky-400/60 bg-sky-400/5'"
           :style="{ left: APP_X + 'px', top: PT + 'px', width: APP_W + 'px', height: PH + 'px' }" />
      <div class="absolute text-sky-300 font-bold"
           :style="{ left: (APP_X + 16) + 'px', top: (PT + 8) + 'px' }" style="font-size: 14px">app server</div>

      <div v-if="s >= APPJWT"
           class="absolute rounded border border-sky-400/50 bg-sky-400/10 text-sky-200 px-2 py-0.5 transition-all duration-500"
           :style="{ left: (APP_X + APP_W - 96) + 'px', top: (PT + 6) + 'px' }" style="font-size: 10.5px">🔑 App 私鑰</div>

      <!-- app 的 db -->
      <div class="absolute rounded-lg border border-slate-400/30 bg-slate-400/5"
           :style="{ left: (APP_X + 16) + 'px', top: '86px', width: (APP_W - 32) + 'px', height: '76px' }">
        <div class="opacity-40 px-3 pt-1 text-right" style="font-size: 10px">db</div>
      </div>
      <div class="absolute" :style="{ left: (APP_X + 30) + 'px', top: '96px', width: (APP_W - 60) + 'px' }">
        <div class="opacity-45 mb-0.5" style="font-size: 10px">user</div>
        <div class="rounded border transition-all duration-300"
             :class="isHot('appuser') ? 'border-amber-400/80 bg-amber-400/10' : 'border-slate-400/30 bg-slate-400/5'">
          <div class="flex opacity-40 border-b border-slate-400/20 px-2 py-0.5" style="font-size: 9.5px">
            <span style="width: 72px">id</span><span>email</span>
          </div>
          <div v-for="r in appUsers" :key="r.a" class="flex px-2 py-0.5" style="font-size: 10.5px">
            <span class="font-mono text-sky-200" style="width: 72px">{{ r.a }}</span><span>{{ r.b }}</span>
          </div>
          <div v-if="!appUsers.length" class="px-2 py-0.5 opacity-25" style="font-size: 10.5px">（無資料）</div>
        </div>
      </div>

      <!-- app 自己的 session -->
      <div class="absolute flex items-center gap-2" style="height: 26px"
           :style="{ left: (APP_X + 30) + 'px', top: '176px' }">
        <span class="opacity-45 shrink-0" style="font-size: 10.5px; width: 58px">session</span>
        <!--
          這是全場的落點：app 終於簽出自己的 session。
          只把顏色調亮太安靜了，所以那一格同時做兩件事 ——
          pill 自己彈一下並發光，背後再擴散一圈往外散開的環。
        -->
        <span v-if="appSession" class="relative inline-flex items-center">
          <span v-if="appSession.hot" class="stBurst absolute rounded-md" style="inset: -7px" />
          <span class="relative rounded px-2 py-0.5 transition-all duration-500"
                :class="appSession.hot ? 'bg-teal-400/20 text-teal-200 border border-teal-400/60 stPop'
                  : 'bg-slate-400/15 opacity-85 border border-slate-400/30'"
                style="font-size: 11px">{{ appSession.t }}</span>
        </span>
        <span v-if="appSession" class="opacity-45" style="font-size: 10px">{{ appSession.n }}</span>
        <span v-if="!appSession" class="opacity-25" style="font-size: 11px">—</span>
      </div>

      <!-- app 新增的東西：一組純標準的 OIDC client -->
      <div v-if="s >= IDP"
           class="absolute rounded-lg border border-indigo-400/50 bg-indigo-400/10 px-3 py-1.5 transition-all duration-500"
           :style="{ left: (APP_X + 30) + 'px', top: '212px', width: (APP_W - 60) + 'px' }">
        <span class="text-indigo-200" style="font-size: 11px">OIDC client</span>
        <span class="opacity-45 ml-2" style="font-size: 10px">純標準，沒有一行是 Better Auth 專屬的</span>
      </div>

      <!-- id_token：只 highlight 最後那一個 claim -->
      <div v-if="s >= PAYLOAD"
           class="absolute rounded-lg border border-teal-400/40 bg-teal-400/5 px-3 py-1.5 transition-all duration-500"
           :style="{ left: (APP_X + 30) + 'px', top: '256px', width: (APP_W - 60) + 'px' }">
        <div class="opacity-45 mb-1" style="font-size: 10px">id_token</div>
        <div class="flex flex-wrap gap-1">
          <span v-for="c in ['iss', 'aud', 'sub', 'nonce']" :key="c"
                class="rounded bg-slate-400/15 px-1.5 py-0.5 opacity-55" style="font-size: 10px">{{ c }}</span>
          <span class="rounded border px-1.5 py-0.5 transition-all duration-500"
                :class="s >= RECALL ? 'border-teal-400/70 bg-teal-400/20 text-teal-200'
                  : 'border-teal-400/40 bg-teal-400/10 text-teal-200/80'"
                style="font-size: 10px">app_user_id: "7"</span>
        </div>
      </div>
    </template>

    <!-- andy 本人：同一個節點從左滑到右 -->
    <div v-if="s >= SIGNUP"
         class="absolute transition-all ease-in-out"
         style="top: 135px; font-size: 10.5px; transition-duration: 750ms"
         :style="{ left: ANDY_X + 'px' }">andy@example.com</div>

    <!-- 判詞 -->
    <div v-if="note" class="absolute text-center" style="left: 0; top: 348px; width: 880px">
      <span :class="noteClass" style="font-size: 12.5px">{{ note.t }}</span>
    </div>

  </div>
</template>

<style scoped>
.stGrow { stroke-dasharray: var(--len); animation: stDraw 0.32s cubic-bezier(.4, 0, .2, 1) forwards; }
@keyframes stDraw { from { stroke-dashoffset: var(--len); } to { stroke-dashoffset: 0; } }
.stHead { transform-box: fill-box; transform-origin: center; animation: stHeadPop 0.16s ease-out 0.26s both; }
@keyframes stHeadPop { from { opacity: 0; transform: scale(0.3); } to { opacity: 1; transform: scale(1); } }

/* app 簽出自己的 session 那一瞬間：彈一下 + 發光，最後留一點餘光 */
.stPop { animation: stPopIn 0.8s cubic-bezier(.2, 1.35, .4, 1) both; }
@keyframes stPopIn {
  0%   { transform: scale(1);    box-shadow: 0 0 0 0 rgba(45, 212, 191, 0); }
  18%  { transform: scale(1.24); box-shadow: 0 0 24px 7px rgba(45, 212, 191, .6); }
  46%  { transform: scale(0.97); box-shadow: 0 0 14px 3px rgba(45, 212, 191, .32); }
  100% { transform: scale(1);    box-shadow: 0 0 11px 1px rgba(45, 212, 191, .24); }
}

/* 往外擴散的一圈，讓視線一定被拉過來 */
.stBurst { border: 2px solid #2dd4bf; animation: stBurstOut 0.9s ease-out both; }
@keyframes stBurstOut {
  0%   { opacity: .85; transform: scale(0.86); }
  100% { opacity: 0;   transform: scale(1.85); }
}
</style>
