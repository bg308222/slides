---
theme: default
title: PKCE：為什麼它存在，以及該由誰產
info: |
  從「client 這個字有兩個意思」一路推導到 PKCE。
  每一步都是上一步的痛點逼出來的。
class: text-center
transition: slide-left
colorSchema: dark
mdc: true
---

# PKCE

為什麼它存在，以及該由誰產

<div class="pt-16 text-xs opacity-35">andy.lin · 2026-08-21</div>

---
layout: center
---

# 今天怎麼走

<div class="grid grid-cols-2 gap-x-10 gap-y-5 mt-6 text-left max-w-4xl mx-auto">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第一段</div>

**把 OAuth 2.0 的名詞定住**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
同一個字被不同人拿來指不同東西，後面的討論就會一直發散。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第二段</div>

**純 OAuth 2.0 的洞在哪**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
每一步都被 HTTPS 保護得好好的。那洞在哪？
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第三段</div>

**client 其實有兩種**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
分清楚這兩種，<code>client_secret</code> 的角色才講得清楚。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第四段</div>

**Implicit：一個合理但走錯方向的嘗試**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
我們腦中已經有的那個 flow，當年是怎麼想的。
</div>
</div>

<div class="col-span-2">
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第五段</div>

**PKCE**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
它一次補上兩個來自不同段落的缺口。
</div>
</div>

</div>

<div class="mt-8 text-sm opacity-45">
不提 Resource Server、不談 XSS。今天只講「東西在誰手上、這一次是不是同一次」。
</div>

---
layout: section
---

# 第一段

把 OAuth 2.0 的名詞定住

---
clicks: 7
---

# ① 我們已經知道的 OAuth

<Roles :step="0" :flow="$clicks" class="mt-6" />

<div v-click="7" class="mt-8 text-sm opacity-75">
這張圖<b class="text-teal-300">沒有錯</b>，我們每天在用。
</div>

---
clicks: 5
---

# ② 翻譯成正式名詞

<Roles :step="Math.min($clicks, 4)" />

<div class="absolute" style="left: 3.5rem; bottom: 2rem; right: 3.5rem">
<div v-click="4" class="text-sm">
最大的一次變化在<b class="text-violet-300">左邊那一格</b> ——
一個字被拆成了<b>「人」</b>和<b>「他用的瀏覽器」</b>。
</div>
<div v-click="5" class="mt-2 px-3 py-2 rounded bg-indigo-400/10 border-l-4 border-indigo-400 text-sm">

中間這個 **Client** 是 OAuth 定義的 client，**不是「應用的前端」**。

</div>
</div>

---
clicks: 7
---

# ③ 定住四者的關係

<Journey :step="$clicks" />

<div class="absolute" style="left: 3.5rem; bottom: 1.8rem; right: 3.5rem">
<div class="grid grid-cols-2 gap-x-8 gap-y-1 text-left" style="font-size: 11.5px">
<div v-click="1" class="opacity-70">① Client 向 Authorization Server 申請 client_id / client_secret</div>
<div v-click="2" class="opacity-70">② Resource Owner 發起登入</div>
<div v-click="3" class="opacity-70">③ Client 將 Resource Owner 導向 Authorization Server</div>
<div v-click="4" class="opacity-70">④ Resource Owner 在 Authorization Server 登入</div>
<div v-click="5" class="opacity-70">⑤ 導回 Client，這次帶著 code</div>
<div v-click="6" class="opacity-70">⑥ Client 自己拿 code 去換 token</div>
<div v-click="7" class="opacity-70">⑦ Client 拿 token 問 user 資料</div>
</div>

<div v-click="7" class="mt-3 px-3 py-2 rounded bg-teal-400/10 border-l-4 border-teal-400 text-sm">

**有 `client_id`、做 code exchange 的那一個，就是 client。**
Resource Owner 就只是「我這個人」，不代表 browser，也不代表任何前端程式碼。

</div>
</div>

---
layout: center
class: text-center
---

<div class="text-2xl opacity-80 leading-relaxed">
這趟流程裡，code 一路傳遞，最後落在 Client 手上。
</div>

<div class="text-3xl font-bold mt-6 text-amber-300">
這一路上，有沒有哪一段<br>code 會被別人拿走？
</div>

---
layout: section
---

# 第二段

純 OAuth 2.0 的洞在哪

---
clicks: 1
---

# ④ 先講兩個前提

<div class="grid grid-cols-2 gap-4 mt-2 text-left" style="font-size: 13px">

<div class="px-3 py-2 rounded bg-gray-500/10 border-l-4 border-gray-400">

**前提一 —— 瀏覽器沒被 XSS**

頁面被完全操控的話幾乎什麼都能偷，那不是今天要談的。

</div>

<div class="px-3 py-2 rounded bg-gray-500/10 border-l-4 border-gray-400">

**前提二 —— HTTPS 管線裡面偷不走**

這是事實。所以不要去想 request / response 半路被攔截。

</div>

</div>

<div v-click="1" class="mt-8 text-center text-lg opacity-70">
這兩件事今天都當成<b class="text-teal-300">成立</b>。<br>
所以接下來要找的洞，<b>不能是「東西在傳輸中被攔截」</b>。
</div>

---
clicks: 7
---

# ⑤ 那就一段一段檢查

<Trip :reveal="$clicks" class="mt-3" />

<div v-click="7" class="mt-4 text-center text-xl text-amber-300">
奇怪了，看起來整段都被保護得好好的？
</div>

---
clicks: 8
---

# ⑥ 洞在第 5 步：終點不是網址，是一個 app

<Steal :step="$clicks" :h="276" class="mt-1" />

<div class="text-center mx-auto max-w-4xl mt-1"
     :style="{ minHeight: $clicks <= 6 ? '40px' : '0px', fontSize: '13px' }">

<div v-if="$clicks === 1">
Authorization Server 回一個 302 —— <b class="text-red-300">code 就寫在這個網址上</b>，不是藏在內文裡。
</div>

<div v-if="$clicks === 2">
網址沿著 HTTPS 送回 browser。到這裡為止，一切都還在管線裡。
</div>

<div v-if="$clicks === 3">
但 <code>myapp://</code> <b>不是 https</b>，browser 處理不了 —— 它把<b class="text-red-300">整個網址原封不動交給作業系統</b>。
</div>

<div v-if="$clicks === 4">
作業系統查註冊表：<code>myapp://</code> 是我們的 app 登記的 → code 正常落地。
</div>

<div v-if="$clicks === 5">
問題在這裡 —— <b class="text-red-300">custom scheme 沒有所有權驗證</b>，惡意 app 也能登記同一個 <code>myapp://</code>。
</div>

<div v-if="$clicks === 6">
同一個 callback 再來一次，作業系統這次把網址交給了它。<b class="text-red-300">code 落在惡意 app 手上。</b>
</div>

</div>

<div v-click="7" class="mt-1 px-4 py-0 rounded bg-red-400/10 border-l-4 border-red-400 text-left"
     style="font-size: 13px">

從頭到尾**沒有任何一步破了 HTTPS**。code 是自己走出管線的 ——
因為它**寫在網址上**，而網址要交給誰，是**作業系統**說了算。

</div>

<div v-click="8" class="mt-1 px-4 py-0 rounded bg-gray-500/10 text-left leading-relaxed"
     style="font-size: 10.5px">

RFC 7636 §1 —— 規格舉的就是這個例子，這個攻擊有正式名字：**authorization code interception attack**
<br>
*"...within a communication path **not protected by Transport Layer Security (TLS)**, such as **inter-application communication within the client's operating system**."*
<br>
*"The attacker manages to register a malicious application on the client device and **registers a custom URI scheme that is also used by another application**."*

</div>

---
clicks: 5
---

# ⑦ 那他拿著這個 code，換得到 token 嗎？

<div class="text-sm opacity-60 text-center mb-4">
惡意 app 把偷來的 code 直接送去 token endpoint。Authorization Server 會擋下來嗎？
</div>

<Fork :step="$clicks" />

<div v-click="5" class="mt-5 px-4 py-2.5 rounded bg-amber-400/10 border-l-4 border-amber-400 text-center">

同一個被偷走的 code，兩種應用的結局完全不同。
<b class="text-amber-300">原來 —— client 其實有兩種。</b>

</div>

---
layout: section
---

# 第三段

client 其實有兩種

---
clicks: 4
---

# ⑧ 規格怎麼定義這兩種 client

<div class="grid grid-cols-2 gap-5 mt-2 text-left">

<div v-click="1" class="rounded-lg border-2 border-red-400/50 bg-red-400/5 px-4 py-2.5">

<div class="font-bold text-red-300" style="font-size: 14px">public client</div>
<div class="opacity-40 mb-1.5" style="font-size: 10px">RFC 6749 §2.1</div>
<div class="italic opacity-80 leading-snug" style="font-size: 11.5px">

"Clients **incapable** of maintaining the confidentiality of their credentials
(e.g., clients executing on the **device used by the resource owner**, such as an
**installed native application** or a **web browser-based application**)"

</div>
</div>

<div v-click="2" class="rounded-lg border-2 border-teal-400/50 bg-teal-400/5 px-4 py-2.5">

<div class="font-bold text-teal-300" style="font-size: 14px">confidential client</div>
<div class="opacity-40 mb-1.5" style="font-size: 10px">RFC 6749 §2.1</div>
<div class="italic opacity-80 leading-snug" style="font-size: 11.5px">

"Clients **capable** of maintaining the confidentiality of their credentials
(e.g., client implemented on a **secure server** with restricted access to the
client credentials)"

</div>
</div>

</div>

<ClientKinds :step="$clicks - 2" class="mt-4" />

<div v-click="4" class="mt-3 px-4 py-0 rounded bg-gray-500/10 text-left" style="font-size: 10.5px">

RFC 6749 §2.1 自己就講了這種分兩半的情況：*"A client may be implemented as a **distributed set of components**, each with a different client type ... a distributed client with both a **confidential server-based component** and a **public browser-based component**."*

</div>

---
clicks: 5
---

# ⑨ 那 confidential 是不是就安全了？

<div v-click="1" class="mt-3 px-4 py-0 rounded bg-red-400/10 border-l-4 border-red-400 text-left"
     style="font-size: 13px">

前一段看到的是 public —— native app 的 callback 被另一個 app 接走，
**code 被偷 = token 被偷**。

</div>

<div v-click="2" class="mt-5 text-center opacity-65" style="font-size: 13px">
那 confidential 呢？它看起來有兩層保障：
</div>

<div class="grid grid-cols-2 gap-5 mt-3 text-left">

<div v-click="3" class="rounded-lg border-2 border-slate-400/40 bg-slate-400/5 px-4 py-3">

<div class="font-bold mb-1.5" style="font-size: 13.5px">① 它不出瀏覽器</div>
<div class="opacity-70 leading-snug" style="font-size: 11.5px">

callback 回的是自己網域的 https 網址，**沒有 custom scheme 可以搶**，
作業系統也不會插手。

</div>
</div>

<div v-click="4" class="rounded-lg border-2 border-slate-400/40 bg-slate-400/5 px-4 py-3">

<div class="font-bold mb-1.5" style="font-size: 13.5px">② 它還有 <code>client_secret</code></div>
<div class="opacity-70 leading-snug" style="font-size: 11.5px">

就算 code 不知道怎麼被拿到了，**換 token 那一關還有 secret 擋著**。

</div>
</div>

</div>

<div v-click="5" class="mt-7 text-center text-3xl font-bold text-amber-300">
那它是不是就安全了？
</div>

---
clicks: 8
---

# ⑩ 那 code 怎麼會跑到他手上？

<Leak :step="$clicks" class="mt-2" />

<div class="text-center mx-auto max-w-4xl"
     :style="{ minHeight: $clicks <= 5 ? '34px' : '0px', fontSize: '12.5px' }">

<div v-if="$clicks === 1">
攻擊者做的唯一一件事：把 authorization request 裡的 <code>redirect_uri</code> 換成自己的網域，<b class="text-red-300">後面接上看起來很像的那一段</b>。
</div>

<div v-if="$clicks === 2">
Authorization Server 只做 pattern 比對 —— 它<b>真的以為</b>這是 <code>somesite.example</code> 底下的網址。
</div>

<div v-if="$clicks === 3">
victim 點下去，在<b class="text-teal-300">真正的</b> Authorization Server 上，用<b class="text-teal-300">自己的帳號密碼</b>登入。這一步完全正常。
</div>

<div v-if="$clicks === 4">
授權成功，Authorization Server 發出 code —— 接下來要把它送到 <code>redirect_uri</code> 指定的地方。
</div>

<div v-if="$clicks === 5">
於是它<b class="text-red-300">自己把 code 送去了 attacker.example</b>。沒有人攔截，是它自己送的。
</div>

</div>

<div v-click="6" class="mt-2 px-4 py-0 rounded bg-teal-400/10 border-l-4 border-teal-400 text-left"
     style="font-size: 13px">

而這一整條路，**每一段都是完好的 HTTPS** —— 沒有一段被攔截、沒有一張憑證是假的。

</div>

<div v-click="7" class="mt-2 px-4 py-0 rounded bg-red-400/10 border-l-4 border-red-400 text-left"
     style="font-size: 13px">

因為 HTTPS 保證的是「**這條線的另一端真的是 attacker.example、路上沒人偷聽**」——
它從來不問「**你為什麼要把 code 送去那裡**」。
**終點是 `redirect_uri` 說了算，而那一格被攻擊者填了。**

</div>

<div v-click="8" class="mt-2 px-4 py-0 rounded bg-gray-500/10 text-left" style="font-size: 11px">

這一條路堵得掉 —— RFC 9700 §4.1.3 要求 Authorization Server 對 `redirect_uri` 做**完全比對**（*"MUST ensure that the two URIs are equal"*）。
但只要 code 還是寫在網址上、還是靠瀏覽器轉交，就會有下一條路。所以真正該問的是 ——
**code 落到別人手上的時候，它憑什麼還能用？**

</div>

---
clicks: 9
layout: full
---

<div class="px-10 pt-2">

<div class="text-xl font-bold">⑪ 他不冒充 client —— 他借用那個誠實的 client</div>

<div v-click="1" class="opacity-70" style="font-size: 11.5px">

他手上已經有 code 了 —— 就是上一頁那條路拿到的。那第 ② 層呢？<b>沒有 <code>client_secret</code>，他換得到 token 嗎？</b>

</div>

<Injection :step="$clicks - 1" :h="238" />

<div class="grid grid-cols-2 gap-5 mt-1">

<div v-click="7">
<CheckList
  :items="[
    { label: 'client_secret', ok: true, note: '誠實的 client 自己附上的' },
    { label: 'code 有效、未使用', ok: true },
  ]"
  title="Authorization Server 在 token endpoint 檢查什麼"
  :verdict="$clicks >= 8 ? '上一次 secret 那格是<b>紅的</b>，所以擋住了。這次它是<b>綠的</b> —— 因為附上它的，是那個誠實的 client。' : ''"
/>
</div>

<div v-click="9" class="self-center px-4 py-3 rounded bg-red-400/10 border-l-4 border-red-400">

**secret 從頭到尾都正確，但 token 給錯人了。**

<div class="mt-2 opacity-60" style="font-size: 11px">

這個攻擊有名字：**authorization code injection**

</div>

</div>

</div>

</div>

---
clicks: 3
---

# ⑫ secret 全程正確，但它答的是另一題

<div class="max-w-4xl mx-auto mt-3">
<Axis
  second
  first-answer="<code>client_secret</code> —— <b>滿分</b>，而且全程被正確使用。"
  second-answer="沒有任何東西在回答這一題。<b class='text-red-300'>缺口在這裡。</b>"
/>
</div>

<div v-click="1" class="mt-4 px-4 py-0 rounded bg-gray-500/10 text-left max-w-4xl mx-auto"
     style="font-size: 11.5px">

RFC 9700 §4.5.2 講得很直接 —— client authentication 擋不住這個攻擊：
*"...do not stop this attack, as **the legitimate client authenticates at the token endpoint**."*

</div>

<div v-click="2" class="mt-5 text-center text-xl">
所以 confidential <b class="text-red-300">並沒有比較安全</b> ——<br>
<span class="opacity-70" style="font-size: 15px">那層 <code>client_secret</code>，答的根本是另一題。</span>
</div>

<div v-click="3" class="mt-4 text-center opacity-60" style="font-size: 13px">
缺的是一個能回答第二根軸的東西：<b>把 code 綁到這一次請求</b>。
</div>

---
clicks: 3
---

# ⑬ 規格開的處方箋

<div v-click="1" class="mt-4 px-5 py-3 rounded-lg border-2 border-slate-400/40 bg-slate-400/5
     max-w-4xl mx-auto text-left" style="font-size: 13px">

RFC 9700 §2.1.1：

<div class="mt-2 flex flex-col gap-1.5">
<div>· <i>"Public clients <b>MUST</b> use PKCE [RFC7636] to this end."</i></div>
<div>· <i>"For confidential clients, the use of PKCE [RFC7636] is <b>RECOMMENDED</b>, as it provides strong protection against <b>misuse and injection of authorization codes</b>."</i></div>
</div>

</div>

<div v-click="2" class="mt-5 text-center text-lg">
兩種 client，指向同一個東西 —— 它叫 <b class="text-teal-300">PKCE</b>。<br>
<span class="opacity-55" style="font-size: 14px">它怎麼做到的，等一下我們自己推。</span>
</div>

<div v-click="3" class="mt-6 px-5 py-0 rounded bg-amber-400/10 border-l-4 border-amber-400
     max-w-4xl mx-auto text-left" style="font-size: 14px">

可是等一下 —— 規格說 public client **必須**用 PKCE，也就是**必須**走 code exchange。
那我們以前學的那個、**連 code 都不發、直接給 token** 的 implicit，
<b class="text-amber-300">到底是幹嘛的？</b>

</div>

---
layout: section
---

# 第四段

Implicit：一個合理但走錯方向的嘗試

---
clicks: 3
---

# ⑭ 回到 public client：它連第一根軸都沒有

<div v-click="1" class="mt-6 px-5 py-4 rounded-lg border-2 border-slate-400/40 bg-slate-400/5
     max-w-3xl mx-auto text-left">

RFC 6749 §1.3.2：

<div class="mt-2 text-lg text-amber-300">

*"When issuing an access token during the implicit grant flow,
the authorization server **does not authenticate the client**."*

</div>

</div>

<div v-click="2" class="mt-8 text-center text-2xl font-bold">
那對 public client 來說 ——<br>
<span class="text-amber-300">code exchange 那一趟往返，到底證明了什麼？</span>
</div>

<div v-click="3" class="mt-6 text-center text-xl opacity-70">
什麼都沒證明。它只是多一趟。
</div>

---
clicks: 3
---

# ⑮ 早期的答案：那就別發 code 了

<div v-click="1" class="mt-4 text-center text-2xl">
既然那趟往返證明不了任何事 ——<br>
<b class="text-amber-300">直接在 authorization response 發 token。</b>
</div>

<div v-click="2" class="mt-6 text-center text-lg opacity-70">
這就是我們腦中的 <b>implicit flow</b>。
</div>

<div v-click="3" class="mt-8 px-5 py-3 rounded bg-gray-500/10 max-w-3xl mx-auto text-left"
     style="font-size: 13px">

RFC 6749 §1.3.2 給的理由，就是這麼務實：

*"optimized for clients implemented in a browser using a scripting language such as JavaScript"*

*"**reduces the number of round trips** required to obtain an access token"*

</div>

---
clicks: 3
---

# ⑯ 代價：網址上現在放的是「拿到就能用」的東西

<div class="mt-2">
<Trip compact break-step5 :evil="$clicks >= 1" />
</div>

<div class="grid grid-cols-2 gap-4 mt-3">

<div v-click="2" class="px-4 py-2.5 rounded bg-red-400/10 border-l-4 border-red-400 text-left"
     style="font-size: 13px">

同一個惡意 app，原封不動搬回來。它照樣接得到 ——
而**這次接到的不用再換**，連 token endpoint 那張檢查清單都不用經過。

</div>

<div v-click="3" class="px-4 py-2.5 rounded bg-gray-500/10 text-left" style="font-size: 11px">

RFC 6749 §1.3.2 在 **2012 年就寫下了這句**：

*"The access token may be exposed to the resource owner or **other applications with access to the
resource owner's user-agent**."*

<div class="mt-1.5 opacity-70">

—— 講的就是剛才那個 app。規格自己警告過，只是當年沒人當回事。

</div>

</div>

</div>

---
clicks: 3
---

# ⑰ 方向錯了

<div v-click="1" class="mt-6 px-5 py-4 rounded-lg border-2 border-teal-400/50 bg-teal-400/5
     max-w-3xl mx-auto text-left text-lg">

code 這一層**間接**是有價值的 —— 它讓「**拿到**」和「**能用**」分開。

</div>

<div v-click="2" class="mt-6 text-center text-2xl font-bold text-amber-300">
不該拿掉 code exchange，<br>該給它一個 public client 也做得到的證明。
</div>

<div v-click="3" class="mt-8 text-center text-sm opacity-55">
RFC 9700 §2.1.2：<i>"Clients SHOULD NOT use the implicit grant..."</i>　·　
OAuth 2.1 §10.1 直接移除了它。
</div>

---
layout: section
---

# 第五段

PKCE

---
clicks: 2
---

# ⑱ 我們手上有兩個缺口

<div class="grid grid-cols-2 gap-5 mt-8 max-w-4xl mx-auto">

<div v-click="1" class="px-5 py-4 rounded-lg border-2 border-amber-400/50 bg-amber-400/5 text-left">

<div class="text-xs uppercase tracking-widest opacity-40 mb-2">來自第三段</div>

<div class="text-lg font-bold text-amber-300 mb-2">綁到這一次請求</div>

<div style="font-size: 12px" class="opacity-75 leading-relaxed">

`client_secret` 答不了。<b>confidential client 也缺這個。</b>

</div>

</div>

<div v-click="2" class="px-5 py-4 rounded-lg border-2 border-teal-400/50 bg-teal-400/5 text-left">

<div class="text-xs uppercase tracking-widest opacity-40 mb-2">來自第四段</div>

<div class="text-lg font-bold text-teal-300 mb-2">不需要預先登記的證明</div>

<div style="font-size: 12px" class="opacity-75 leading-relaxed">

public client 沒有任何能預先跟 Authorization Server 共享的東西。

</div>

</div>

</div>

<div v-click="2" class="mt-8 text-center text-lg opacity-70">
這是兩個<b>不同</b>的需求，來自兩個<b>不同</b>的失敗。
</div>

---
clicks: 6
---

# ⑲ 那我們自己來設計看看

<div class="max-w-3xl mx-auto text-left mt-4 flex flex-col gap-2.5">

<div v-click="1" class="px-4 py-2 rounded bg-gray-500/10" style="font-size: 14px">
① 「不需要預先登記」→ 那就 <b>當場產一個隨機值</b>。
</div>

<div v-click="2" class="px-4 py-2 rounded bg-gray-500/10" style="font-size: 14px">
② 「綁到這一次請求」→ 那就在<b>發出 authorization request 的當下</b>把它交出去。
</div>

<div v-click="3" class="px-4 py-2 rounded bg-red-400/10 border-l-4 border-red-400" style="font-size: 14px">
③ <b>但不能直接交</b> —— authorization request 走的是 URL，而 <b>URL 會離開管線</b>。直接交等於公開。
</div>

<div v-click="4" class="px-4 py-2 rounded bg-teal-400/10 border-l-4 border-teal-400" style="font-size: 14px">
④ → 那就交一個<b>由它算出來、但反推不回去的值</b>。
</div>

<div v-click="5" class="px-4 py-2 rounded bg-teal-400/10 border-l-4 border-teal-400" style="font-size: 14px">
⑤ 換 token 時才交出<b>原值</b>；Authorization Server 重算一次，比對。
</div>

</div>

<div v-click="6" class="mt-4 px-4 py-2 rounded bg-gray-500/10 max-w-3xl mx-auto text-left"
     style="font-size: 11px">

第 ③ 步不是我編的：OAuth 2.1 §7.5.2 說明 `plain` 為何被禁 ——
*"...the code verifier is transmitted in plaintext in the authorization request."*
**不做這個 transform，得到的就是 `plain`。**

</div>

---
clicks: 7
layout: full
---

<div class="px-10 pt-4">

<div class="text-xl font-bold mb-1">⑳ 同一張圖，這次不一樣</div>

<Injection :step="$clicks" pkce />

<div v-click="7" class="mt-2 grid grid-cols-2 gap-5">

<div class="px-4 py-2.5 rounded bg-amber-400/10 border-l-4 border-amber-400">

**缺口一補上了** — 原值每一趟現產，注入的 code 綁的是別趟的挑戰值。

</div>

<div class="px-4 py-2.5 rounded bg-teal-400/10 border-l-4 border-teal-400">

**缺口二補上了** — 全程不需要事先跟 Authorization Server 共享任何秘密。

</div>

</div>

</div>

---
clicks: 4
---

# ㉑ 現在才貼上名字

<div v-click="1" class="text-center text-3xl font-bold mt-4">
<span class="text-amber-300">P</span>roof
<span class="text-teal-300">K</span>ey
for <span class="text-indigo-300">C</span>ode <span class="text-indigo-300">E</span>xchange
</div>

<div v-click="2" class="grid grid-cols-3 gap-4 mt-6 max-w-4xl mx-auto text-left" style="font-size: 12px">

<div class="px-3 py-2 rounded bg-amber-400/10">

**Proof** — 我們需要一個證明（第三段缺的）

</div>

<div class="px-3 py-2 rounded bg-teal-400/10">

**Key** — 但不能是預先登記的 secret，要臨時的（第四段缺的）

</div>

<div class="px-3 py-2 rounded bg-indigo-400/10">

**for Code Exchange** — 保護的正是 code 換 token 那一步

</div>

</div>

<div v-click="3" class="mt-6 max-w-3xl mx-auto text-left" style="font-size: 13px">

| 剛才推導出來的東西 | 它的正式名字 |
|---|---|
| 當場產的那個原值 | `code_verifier` |
| 算出來、送得出去的那個 | `code_challenge` |
| 算法 | `code_challenge_method` |

</div>

<div v-click="4" class="mt-4 max-w-3xl mx-auto text-left opacity-65" style="font-size: 11px">

RFC 7636 §4.1／§4.2：verifier 為 43–128 字元的高熵亂數；
*"If the client is capable of using 'S256', it MUST use 'S256'."*
而 `plain` 在 **OAuth 2.1 §7.5.2 已是明文禁止**。

</div>

---
clicks: 4
---

# ㉒ 回到一開始那個問題

<div class="text-center text-xl opacity-60 mt-4">
「verifier 是 server 產還是 client 產？」
</div>

<div v-click="1" class="mt-5 text-center text-3xl font-bold text-amber-300">
這個問題問錯了。
</div>

<div v-click="1" class="mt-2 text-center text-xl">
該問的是 —— <b>我們的 OAuth client 是誰？</b>
</div>

<div v-click="2" class="mt-5 px-5 py-2.5 rounded-lg border-2 border-teal-400/50 bg-teal-400/5
     max-w-3xl mx-auto text-center text-base">

誰發出 authorization request、誰保存 `code_verifier`、誰做 code exchange
—— **必須是同一個。**

</div>

<div v-click="3" class="grid grid-cols-2 gap-4 mt-4 max-w-4xl mx-auto text-left" style="font-size: 12.5px">

<div class="px-4 py-3 rounded-lg border border-indigo-400/40 bg-indigo-400/5">

**BFF / 傳統 web app**

backend 持有 `client_id`、做 exchange
→ **backend 就是 Client** → backend 產

</div>

<div class="px-4 py-3 rounded-lg border border-indigo-400/40 bg-indigo-400/5">

**SPA / native app 直接當 client**

backend 只提供自家 API，不參與 OAuth
→ **app 本身就是 Client** → app 產

</div>

</div>

<div v-click="4" class="mt-4 text-center text-lg text-red-300 font-bold">
不是「有沒有 server」，是「誰做 code exchange」。
</div>

---
clicks: 3
---

# ㉓ 三份規格怎麼說

<div class="max-w-4xl mx-auto text-left mt-3" style="font-size: 12.5px">

| | 對 PKCE 的要求 |
|---|---|
| **RFC 7636**（2015） | 只談 public client |
| **RFC 9700**（2025, BCP） | public **MUST**；confidential **RECOMMENDED** |
| **OAuth 2.1** | **REQUIRED**，Authorization Server **MUST** 強制 —— 不再分 public / confidential |

</div>

<div v-click="1" class="mt-3 px-4 py-2 rounded bg-gray-500/10 max-w-4xl mx-auto text-left"
     style="font-size: 11px">

OAuth 2.1 §7.5.1 唯一的例外，要**同時**滿足兩個條件：
① client 是 confidential　② Authorization Server 有合理保證它正確實作了 OIDC `nonce`。
而且即便如此 —— *"using and enforcing code_challenge and code_verifier is **still RECOMMENDED**."*

</div>

<div v-click="2" class="mt-2.5 px-4 py-2 rounded bg-amber-400/10 border-l-4 border-amber-400
     max-w-4xl mx-auto text-left" style="font-size: 11.5px">

而且這個例外很弱：靠 client 自己驗 `nonce`，**Authorization Server 無從確認它真的做了**；
nonce 是**事後**才發現（token 已經發出去了），`code_challenge` 是**事前**擋掉。

</div>

<div v-click="3" class="mt-3 text-center text-base">
規格的態度已經從「public client 的補丁」<br>
走到 <b class="text-teal-300">authorization code flow 的預設</b>。
</div>

---
layout: center
class: text-center
---

# 收束

<div class="max-w-3xl mx-auto text-left mt-6 flex flex-col gap-3" style="font-size: 14px">

<div class="px-4 py-2.5 rounded bg-gray-500/10">
<b>誰是 client</b> —— 有 <code>client_id</code>、做 code exchange 的那一個。不是「有沒有 server」。
</div>

<div class="px-4 py-2.5 rounded bg-gray-500/10">
<b>code 為什麼會漏</b> —— 它寫在 URL 上，而 URL 會離開 HTTPS 管線。
</div>

<div class="px-4 py-2.5 rounded bg-indigo-400/10">
<b><code>client_secret</code></b> 回答的是「<b>你是誰</b>」。擋住 exfiltration 是副作用。
</div>

<div class="px-4 py-2.5 rounded bg-amber-400/10">
<b>PKCE</b> 回答的是「<b>這個 code 是不是你剛才要的那一個</b>」。injection 只有它擋得住。
</div>

<div class="px-4 py-2.5 rounded bg-teal-400/10">
所以 <b>verifier 由「我們的 OAuth client」產</b> —— 發請求、存 verifier、做 exchange 是同一個。
</div>

</div>
