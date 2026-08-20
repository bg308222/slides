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

<div class="pt-10 text-sm opacity-50">
  全場只問一個問題 ——
  <span class="text-indigo-300">這個機制回答的是「你是誰」</span>，
  還是 <span class="text-amber-300">「這個 code 是不是你剛才要的那一個」</span>？
</div>

<div class="pt-8 text-xs opacity-35">andy.lin · 2026-08-21</div>

---
layout: center
---

# 今天怎麼走

<div class="grid grid-cols-2 gap-x-10 gap-y-5 mt-6 text-left max-w-4xl mx-auto">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第一段</div>

**誰是 client**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
同一個字被用在兩個位置，所以那個問題一直吵不出答案。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第二段</div>

**洞在哪**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
每一段都被 HTTPS 保護得好好的。那洞在哪？
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第三段</div>

**client_secret 到底擋了什麼**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
它擋住了。但那是副作用，不是它的職責。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第四段</div>

**一個合理但走錯方向的嘗試**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
你們腦中已經有的那個 flow，當年是怎麼想的。
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
不提 Resource Server、不談 XSS。今天只講「東西在誰手上、這一趟是不是同一趟」。
</div>

---
layout: section
---

# 第一段

誰是 client

---
clicks: 7
---

# ① 我們已經知道的 OAuth

<Roles :step="$clicks >= 7 ? 1 : 0" />

<div class="absolute" style="left: 3.5rem; bottom: 2.2rem; right: 3.5rem">
<div class="grid grid-cols-3 gap-x-5 gap-y-1 text-left" style="font-size: 12px">
<div v-click="1" class="opacity-75">① user redirect 到 google</div>
<div v-click="2" class="opacity-75">② user 登入 google</div>
<div v-click="3" class="opacity-75">③ google callback 回 server</div>
<div v-click="4" class="opacity-75">④ server 帶 code + client_secret 去換</div>
<div v-click="5" class="opacity-75">⑤ google 回 token</div>
<div v-click="6" class="opacity-75">⑥ 用 token access API</div>
</div>

<div v-click="7" class="mt-3 text-sm">
這張圖<b class="text-teal-300">沒有錯</b>，你們每天在用。問題出在<b class="text-red-300">用詞</b>。
</div>
</div>

---
clicks: 4
---

# ② 翻譯成正式名詞

<Roles :step="$clicks + 1" />

<div class="absolute" style="left: 3.5rem; bottom: 2rem; right: 3.5rem">
<div v-click="3" class="text-sm">
最大的一次變化在<b class="text-violet-300">左邊那一格</b> ——
一個字被拆成了<b>「人」</b>和<b>「車」</b>。
</div>
<div v-click="4" class="mt-2 px-3 py-2 rounded bg-indigo-400/10 border-l-4 border-indigo-400 text-sm">

中間這個 **Client** 是 OAuth 定義的 client，**不是「應用的前端」**。

</div>
</div>

---
clicks: 7
---

# ③ 定住四者的關係

<Journey :step="$clicks" />

<div class="absolute" style="left: 3.5rem; bottom: 1.8rem; right: 3.5rem">
<div class="grid grid-cols-4 gap-x-4 gap-y-1 text-left" style="font-size: 11px">
<div v-click="1" class="opacity-70">① Client 向 AS 申請 id / secret</div>
<div v-click="2" class="opacity-70">② RO 發起登入</div>
<div v-click="3" class="opacity-70">③ Client 叫車載 RO 去 AS</div>
<div v-click="4" class="opacity-70">④ RO 在 AS 登入</div>
<div v-click="5" class="opacity-70">⑤ 車載回來，車上多了 code</div>
<div v-click="6" class="opacity-70">⑥ Client 自己去換 token</div>
<div v-click="7" class="opacity-70">⑦ Client 拿 token 問資料</div>
</div>

<div v-click="7" class="mt-3 px-3 py-2 rounded bg-teal-400/10 border-l-4 border-teal-400 text-sm">

**有 `client_id`、做 code exchange 的那一個，就是 client。**
RO 就只是「我這個人」，不代表 browser，也不代表任何前端程式碼。

</div>
</div>

---
layout: center
class: text-center
---

<div class="text-2xl opacity-80 leading-relaxed">
車上載過 code，code 落地在 Client 門口。
</div>

<div class="text-3xl font-bold mt-6 text-amber-300">
這一路上，有沒有哪一段<br>車上的東西會被別人拿走？
</div>

---
layout: section
---

# 第二段

洞在哪

---
clicks: 3
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

<Pipe :step="$clicks" class="mt-2" />

<div v-click="1" class="mt-1 px-3 py-2 rounded bg-red-400/10 border-l-4 border-red-400 text-left"
     style="font-size: 13px">

但是 —— **code 不是躺在車廂裡的。它是寫在車身外面的牌子上。**
車在管線裡跑時牌子當然安全；**車一到站，牌子還掛在那裡。**

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
clicks: 6
---

# ⑥ 洞在第 5 步

<div class="grid grid-cols-2 gap-5 mt-2">

<div>

<Trip :break-step5="$clicks >= 1" :evil="$clicks >= 2" />

</div>

<div>

<div v-click="3">
<CheckList
  :items="[
    { label: 'client_id', ok: true, note: '在 URL 上，本來就公開' },
    { label: 'redirect_uri', ok: true, note: '他註冊了同一個 scheme，當然知道' },
    { label: 'code 有效、未使用', ok: true },
    { label: 'client authentication', ok: true, note: 'public client 不做' },
  ]"
  :reveal="$clicks >= 4 ? -1 : 0"
  :verdict="$clicks >= 5 ? '<b>沒有任何一格是紅的。</b> code 被偷，就等於 token 被偷。' : ''"
/>
</div>

</div>

</div>

<div v-click="6" class="mt-4 px-4 py-2.5 rounded bg-amber-400/10 border-l-4 border-amber-400 text-center">

問題不在於他偷到了 code，而在於**這張清單上沒有一格擋得住他**。
<b class="text-amber-300">那要怎麼多一格？</b>

</div>

---
layout: section
---

# 第三段

client_secret 到底擋了什麼

---
clicks: 5
---

# ⑦ 怎麼多一格：誰有能力持有 secret

<div v-click="1" class="mt-2 px-4 py-2 rounded bg-indigo-400/10 border-l-4 border-indigo-400 text-left"
     style="font-size: 13px">

要在清單上多一格，那一格必須檢查**只有真正的 client 才知道的東西** —— 那就是 `client_secret`。
但不是每個 client 都**有能力**持有它。

</div>

<div class="grid grid-cols-2 gap-4 mt-4">

<div v-click="2" class="px-4 py-3 rounded-lg border-2 border-red-400/50 bg-red-400/5 text-left">

<div class="font-bold text-red-300 mb-2">public — 沒有能力</div>

<div style="font-size: 12px" class="opacity-80 leading-relaxed">

**純前端應用**：程式碼就在使用者手上。

**native app**：binary 可被反編譯，而且裡面的 secret 對**所有安裝者是同一份**。

</div>

</div>

<div v-click="3" class="px-4 py-3 rounded-lg border-2 border-teal-400/50 bg-teal-400/5 text-left">

<div class="font-bold text-teal-300 mb-2">confidential — 有能力</div>

<div style="font-size: 12px" class="opacity-80 leading-relaxed">

由**你自己控制的機器**持有 `client_id` 並做 code exchange。

</div>

</div>

</div>

<div v-click="4" class="mt-4 px-4 py-2 rounded bg-gray-500/10 text-left" style="font-size: 12px">

分的不是「這個應用有沒有 server」，而是
**那個持有 `client_id`、做 code exchange 的東西，跑在誰控制的機器上** ——
跟第一段的結論是同一句話。

</div>

<div v-click="5" class="mt-3 text-sm opacity-70">
RFC 8252 §8.5：對 public native app 要求 shared secret 認證
<b class="text-red-300">"serves little value beyond client identification"</b> ——
只剩「宣稱」，沒有「證明」。
</div>

---
clicks: 4
---

# ⑧ 同一張清單，只差一格

<div class="text-sm opacity-60 mb-3">
假設攻擊者用某種途徑拿到了 code —— 哪一種先不重要。
</div>

<div class="max-w-2xl mx-auto">
<CheckList
  :items="[
    { label: 'client_id', ok: true },
    { label: 'redirect_uri', ok: true },
    { label: 'code 有效、未使用', ok: true },
    { label: 'client_secret', ok: false, note: '← 新加的這一格' },
  ]"
  :reveal="$clicks >= 2 ? -1 : 3"
  :verdict="$clicks >= 3 ? '三綠一紅 —— <b>攻擊被擋住了。</b>' : ''"
  verdict-tone="good"
/>
</div>

<div v-click="4" class="mt-6 text-center text-xl text-teal-300">
看起來 client_secret 解決了問題。
</div>

---
clicks: 3
---

# ⑨ 但那是副作用，不是它的職責

<div class="max-w-2xl mx-auto mt-4">
<Axis
  :first-answer="$clicks >= 1
    ? '<code>client_secret</code> 回答的就是這一題。'
    : ''"
/>
</div>

<div v-click="2" class="mt-5 px-4 py-2.5 rounded bg-gray-500/10 text-left max-w-2xl mx-auto"
     style="font-size: 13px">

它擋住剛才那個攻擊，是因為那個攻擊者**正在冒充 client**。

它從來不回答 —— **「這個 code，是不是你剛才那一次請求要來的那一個？」**

</div>

<div v-click="3" class="mt-6 text-center text-2xl font-bold text-amber-300">
那如果攻擊者，根本不冒充 client 呢？
</div>

---
clicks: 3
---

# ⑩ 等一下 —— 他手上的 code 哪來的？

<div class="text-sm opacity-70 mb-3">
confidential client 通常是 web app，<b>沒有 custom scheme 可以搶</b>。那他怎麼拿到？
</div>

<div v-click="1" class="px-4 py-2 rounded bg-amber-400/10 border-l-4 border-amber-400 text-left mb-4">

回到那句前提 —— **只要 code 寫在 URL 上，就有路。**

</div>

<div v-click="2" class="grid grid-cols-2 gap-x-8 gap-y-2 text-left max-w-3xl mx-auto"
     style="font-size: 13px">

<div class="opacity-80">· browser history</div>
<div class="opacity-80">· Referer header</div>
<div class="opacity-80">· server / proxy 的 access log</div>
<div class="opacity-80">· 停錯站：<code>redirect_uri</code> 驗證不嚴、open redirector</div>
<div class="opacity-80 col-span-2">· 攻擊者假扮 AS（mix-up）</div>

</div>

<div v-click="3" class="mt-6 text-center">
<div class="text-lg text-red-300 font-bold">這些沒有任何一種需要破 HTTPS。</div>
<div class="text-sm opacity-60 mt-1">用哪一條不重要 —— 重點是他手上有了。</div>
</div>

---
clicks: 8
layout: full
---

<div class="px-10 pt-4">

<div class="text-xl font-bold mb-1">⑪ 他不冒充 client —— 他借用那個誠實的 client</div>

<Injection :step="$clicks" :h="252" />

<div class="grid grid-cols-2 gap-5 mt-1">

<div v-click="6">
<CheckList
  :items="[
    { label: 'client_secret', ok: true },
    { label: 'client_id', ok: true },
    { label: 'redirect_uri', ok: true },
    { label: 'code 有效、未使用', ok: true },
  ]"
  title="AS 在 token endpoint 檢查什麼"
  :verdict="$clicks >= 7 ? '清單<b>一樣長，卻又全綠了</b> —— 連新加的那一格都是綠的。' : ''"
/>
</div>

<div v-click="8" class="self-center px-4 py-3 rounded bg-red-400/10 border-l-4 border-red-400">

**secret 從頭到尾都正確，但 token 給錯人了。**

<div class="mt-2 opacity-60" style="font-size: 11px">

RFC 9700 §4.5.2：*"...do not stop this attack, as the legitimate client authenticates at the token endpoint."*

</div>

</div>

</div>

</div>

---
clicks: 2
---

# ⑫ 現在它有名字了：authorization code injection

<div class="max-w-4xl mx-auto mt-3">
<Axis
  second
  first-answer="<code>client_secret</code> —— <b>滿分</b>，而且全程被正確使用。"
  second-answer="沒有任何東西在回答這一題。<b class='text-red-300'>缺口在這裡。</b>"
/>
</div>

<div v-click="1" class="mt-5 px-4 py-3 rounded bg-gray-500/10 text-left max-w-4xl mx-auto"
     style="font-size: 12px">

OAuth 2.1 §7.5.1 的 Historic note ——
規格自己把這兩個攻擊分成**兩個詞**：

*"Although PKCE was originally designed as a mechanism to protect native apps from authorization code
**exfiltration** attacks, all kinds of OAuth clients, including web applications and other confidential
clients, are susceptible to authorization code **injection** attacks..."*

</div>

<div v-click="2" class="mt-4 text-center text-lg">
「你是誰」這根軸已經滿分了。<b class="text-amber-300">而這個缺口，confidential client 也有。</b>
</div>

---
layout: section
---

# 第四段

一個合理但走錯方向的嘗試

---
clicks: 3
---

# ⑬ 回到 public client：它連第一根軸都沒有

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

# ⑭ 早期的答案：那就別發 code 了

<div v-click="1" class="mt-4 text-center text-2xl">
既然那趟往返證明不了任何事 ——<br>
<b class="text-amber-300">直接在 authorization response 發 token。</b>
</div>

<div v-click="2" class="mt-6 text-center text-lg opacity-70">
這就是你們腦中的 <b>implicit flow</b>。
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

# ⑮ 代價：牌子上現在放的是「拿到就能用」的東西

<div class="mt-3">
<Trip break-step5 :evil="$clicks >= 1" />
</div>

<div v-click="2" class="mt-3 px-4 py-2.5 rounded bg-red-400/10 border-l-4 border-red-400 text-left">

同一個惡意 app，原封不動搬回來。它照樣接得到 ——
而**這次接到的不用再換**，連 token endpoint 那張檢查清單都不用經過。

</div>

<div v-click="3" class="mt-3 px-4 py-2.5 rounded bg-gray-500/10 text-left" style="font-size: 12px">

而 RFC 6749 §1.3.2 在 **2012 年就寫下了這句**：

*"The access token may be exposed to the resource owner or **other applications with access to the
resource owner's user-agent**."*

<div class="mt-1.5 opacity-70">

—— "other applications with access to the user-agent"，講的就是剛才那個 app。規格自己警告過，只是當年沒人當回事。

</div>

</div>

---
clicks: 3
---

# ⑯ 方向錯了

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

# ⑰ 我們手上有兩個缺口

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

public client 沒有任何能預先跟 AS 共享的東西。

</div>

</div>

</div>

<div v-click="2" class="mt-8 text-center text-lg opacity-70">
這是兩個<b>不同</b>的需求，來自兩個<b>不同</b>的失敗。
</div>

---
clicks: 6
---

# ⑱ 那我們自己來設計看看

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
⑤ 換 token 時才交出<b>原值</b>；AS 重算一次，比對。
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

<div class="text-xl font-bold mb-1">⑲ 同一張圖，這次不一樣</div>

<Injection :step="$clicks" pkce />

<div v-click="7" class="mt-2 grid grid-cols-2 gap-5">

<div class="px-4 py-2.5 rounded bg-amber-400/10 border-l-4 border-amber-400">

**缺口一補上了** — 原值每一趟現產，注入的 code 綁的是別趟的挑戰值。

</div>

<div class="px-4 py-2.5 rounded bg-teal-400/10 border-l-4 border-teal-400">

**缺口二補上了** — 全程不需要事先跟 AS 共享任何秘密。

</div>

</div>

</div>

---
clicks: 4
---

# ⑳ 現在才貼上名字

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

# ㉑ 回到一開始那個問題

<div class="text-center text-xl opacity-60 mt-4">
「verifier 是 server 產還是 client 產？」
</div>

<div v-click="1" class="mt-5 text-center text-3xl font-bold text-amber-300">
這個問題問錯了。
</div>

<div v-click="1" class="mt-2 text-center text-xl">
該問的是 —— <b>你的 OAuth client 是誰？</b>
</div>

<div v-click="2" class="mt-6 px-5 py-3 rounded-lg border-2 border-teal-400/50 bg-teal-400/5
     max-w-3xl mx-auto text-center text-lg">

誰發出 authorization request、誰保存 `code_verifier`、誰做 code exchange
—— **必須是同一個。**

</div>

<div v-click="3" class="grid grid-cols-2 gap-4 mt-5 max-w-4xl mx-auto text-left" style="font-size: 13px">

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

<div v-click="4" class="mt-5 text-center text-lg text-red-300 font-bold">
不是「有沒有 server」，是「誰做 code exchange」。
</div>

---
clicks: 3
---

# ㉒ 三份規格怎麼說

<div class="max-w-4xl mx-auto text-left mt-3" style="font-size: 12.5px">

| | 對 PKCE 的要求 |
|---|---|
| **RFC 7636**（2015） | 只談 public client |
| **RFC 9700**（2025, BCP） | public **MUST**；confidential **RECOMMENDED** |
| **OAuth 2.1** | **REQUIRED**，AS **MUST** 強制 —— 不再分 public / confidential |

</div>

<div v-click="1" class="mt-4 px-4 py-2.5 rounded bg-gray-500/10 max-w-4xl mx-auto text-left"
     style="font-size: 11.5px">

OAuth 2.1 §7.5.1 唯一的例外，要**同時**滿足兩個條件：
① client 是 confidential　② AS 有合理保證它正確實作了 OIDC `nonce`。
而且即便如此 —— *"using and enforcing code_challenge and code_verifier is **still RECOMMENDED**."*

</div>

<div v-click="2" class="mt-3 px-4 py-2.5 rounded bg-amber-400/10 border-l-4 border-amber-400
     max-w-4xl mx-auto text-left" style="font-size: 12px">

而且這個例外很弱：靠 client 自己驗 `nonce`，**AS 無從確認它真的做了**；
nonce 是**事後**才發現（token 已經發出去了），`code_challenge` 是**事前**擋掉。

</div>

<div v-click="3" class="mt-4 text-center text-lg">
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
所以 <b>verifier 由「你的 OAuth client」產</b> —— 發請求、存 verifier、做 exchange 是同一個。
</div>

</div>
