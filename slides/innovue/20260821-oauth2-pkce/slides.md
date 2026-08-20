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

<!--
**投影片上兩句引文的出處：RFC 7636（2015-09）§1 Introduction，兩句都逐字無誤。**

第一句在 §1 第 2 段（完整原文）：

> In this attack, the attacker intercepts the authorization code returned from the authorization endpoint **within a communication path not protected by Transport Layer Security (TLS), such as inter-application communication within the client's operating system**.

第二句其實在 Figure 1 之後的「pre-conditions」清單第 1 項（仍屬 §1）。完整原文比投影片多一句，那一句才是真正的關鍵：

> 1. The attacker manages to register a malicious application on the client device and registers a custom URI scheme that is also used by another application. **The operating systems must allow a custom URI scheme to be registered by multiple applications.**

同節還有一句可以直接拿來回答「這是不是紙上談兵」：

> While this is a long list of pre-conditions, **the described attack has been observed in the wild** and has to be considered in OAuth 2.0 deployments.

以及 §1 的白話版：

> Note that it is possible for a malicious app to register itself as a handler for the custom scheme **in addition to** the legitimate OAuth 2.0 app. Once it does so, the malicious app is now able to intercept the authorization code in step (4).
-->

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

<!--
**這一頁的分岔就是 RFC 9700（2025-01, BCP 240）§4.5 開頭的分岔，逐字原文：**

> In the case that **the authorization code was created for a public client**, the attacker can send the authorization code to the token endpoint of the authorization server and thereby get an access token. This attack was described in Section 4.4.1.1 of [RFC6819].
>
> **For confidential clients**, or in some special situations, the attacker can execute an **authorization code injection attack**, as described in the following.

也就是說：左邊那條（public 直接換到 token）RFC 歸給 RFC 6819 §4.4.1.1；右邊那條（confidential）RFC 才另闢 §4.5 講 injection。下一段整段就是在走右邊。
-->

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

<!--
**出處：RFC 6749（2012-10）§2.1 Client Types。投影片的引文逐字正確，但兩段都被截尾了，完整原文各多一個轉折：**

> **confidential**
> Clients capable of maintaining the confidentiality of their credentials (e.g., client implemented on a secure server with restricted access to the client credentials), **or capable of secure client authentication using other means**.
>
> **public**
> Clients incapable of maintaining the confidentiality of their credentials (e.g., clients executing on the device used by the resource owner, such as an installed native application or a web browser-based application), **and incapable of secure client authentication via any other means**.

被截掉的那兩句其實有用：它說明分類的依據不是「有沒有 secret」，而是「有沒有任何安全的 client authentication 手段」。RFC 緊接著還補一句：

> The client type designation is **based on the authorization server's definition** of secure authentication and its acceptable exposure levels of client credentials. The authorization server **SHOULD NOT make assumptions** about the client type.

第三段（distributed）完整原文，投影片省略號處補回：

> A client may be implemented as a **distributed set of components, each with a different client type and security context** (e.g., a distributed client with both a confidential server-based component and a public browser-based component). If the authorization server does not provide support for such clients or does not provide guidance with regard to their registration, **the client SHOULD register each component as a separate client**.
-->

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

<!--
這一頁沒有直接引規格，兩層保障是從前面推來的。若被追問第 ① 層的規格依據：RFC 6749 §3.1.2.2 只要求 AS **SHOULD** 要求登記 scheme / authority / path，並沒有禁止 pattern；真正要求完全比對是 RFC 9700 §4.1.3（下一頁的註腳）。第 ② 層 `client_secret` 的依據是 §2.1 的 confidential 定義（上一頁）。
-->

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

<!--
**這一頁完全照 RFC 9700 §4.1.1「Redirect URI Validation Attacks on Authorization Code Grant」的原例，網址沒有改編。逐字原文：**

> Assume the redirection URL pattern `https://*.somesite.example/*` is registered for the client with the client ID s6BhdRkqt3. The intention is to allow any subdomain of somesite.example to be a valid redirection URI for the client, for example, `https://app1.somesite.example/redirect`. However, **a naive implementation on the authorization server might interpret the wildcard `*` as "any character" and not "any character valid for a domain name"**. The authorization server, therefore, might permit `https://attacker.example/.somesite.example` as a redirection URI, although attacker.example is a different domain potentially controlled by a malicious party.

RFC 給的完整 authorization request：

> GET /authorize?response\_type=code&client\_id=s6BhdRkqt3&state=9ad67f13&redirect\_uri=https%3A%2F%2Fattacker.example%2F.somesite.example HTTP/1.1
> Host: server.somesite.example

**§4.1.1 結尾自己接到下一段（⑪）：**

> This attack will not work as easily for confidential clients, since the code exchange requires authentication with the legitimate client's secret. However, **the attacker can use the legitimate confidential client to redeem the code by performing an authorization code injection attack; see Section 4.5.**

**「wildcard 真的能登記嗎」若被問到：** RFC 6749 §3.1.2.2 只說 AS *SHOULD* require 登記 scheme / authority / path，§3.1.2.3 說「**如果**登記的是完整 URI，才 MUST 用 simple string comparison」，所以規格層面本來就留了 partial 登記的縫。實務上 Auth0 明文支援 callback URL 的 wildcard（限最外層 subdomain、每個 URL 一個，且官方建議 production 不要用），Keycloak 的 Valid Redirect URIs 吃 `*`（其 Server Admin Guide 有一節 "Unspecific Redirect URIs" 專門警告）；Google、Okta、Entra ID 則只收完整 URI。

**投影片註腳（v-click 8）的出處，RFC 9700 §4.1.3 逐字：**

> This document therefore advises simplifying the required logic and configuration by using exact redirection URI matching. This means **the authorization server MUST ensure that the two URIs are equal**; see Section 6.2.1 of [RFC3986], Simple String Comparison, for details. **The only exception is native apps using a localhost URI**: In this case, the authorization server MUST allow variable port numbers as described in Section 7.3 of [RFC8252].

**額外一張牌（§4.1.1 最後一段）：** 就算 AS 把 wildcard 處理「正確」也還是有洞。

> It is important to note that redirection URI validation vulnerabilities **can also exist if the authorization server handles wildcards properly**. ... If an attacker manages to establish a host or subdomain in somesite.example, the attacker can impersonate the legitimate client. For example, this could be caused by a **subdomain takeover attack**, where an outdated CNAME record ... can be taken over by an attacker.
-->

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

<!--
**出處：RFC 9700 §4.5 / §4.5.1。攻擊目的的定義（§4.5）逐字：**

> In an authorization code injection attack, the attacker attempts to **inject a stolen authorization code into the attacker's own session with the client**. The aim is to **associate the attacker's session at the client with the victim's resources or identity**, thereby giving the attacker at least limited access to the victim's resources.

**§4.5.1 的六個步驟（逐字，若被問「他具體怎麼做」就是這段）：**

> 1. The attacker obtains an authorization code (see Attacker (A3) in Section 3). For the rest of the attack, only the capabilities of a web attacker (A1) are required.
> 2. **From the attacker's device, the attacker starts a regular OAuth authorization process with the legitimate client.**
> 3. In the response of the authorization server to the legitimate client, the attacker **replaces the newly created authorization code with the stolen authorization code**. Since **this response is passing through the attacker's device**, the attacker can use any tool that can intercept and manipulate the authorization response to this end. **The attacker does not need to control the network.**
> 4. The legitimate client sends the code to the authorization server's token endpoint, along with the redirect\_uri and the client's client ID and client secret.
> 5. The authorization server checks the client secret, whether the code was issued to the particular client, and whether the actual redirection URI matches the redirect\_uri parameter.
> 6. All checks succeed and the authorization server issues access and other tokens to the client. **The attacker has now associated their session with the legitimate client with the victim's resources and/or identity.**

**重點：他沒有架假網站，也沒有做假的 redirect。** 那個 302 本來就落在他自己的瀏覽器上，他只是在自己的裝置上改掉網址列裡的 `code`（`state` 保留自己那趟的，才過得了 client 的 state 檢查），再讓瀏覽器帶著 client 給他的 session cookie 送去**真的** callback。

**RFC 也列了「除了繞過 client authentication 之外」的其他動機：**

> * The attacker wants to access certain functions in this particular client. As an example, the attacker wants to **impersonate their victim in a certain app or on a certain website**.
> * The authorization or resource servers are limited to certain networks that the attacker is unable to access directly.

**講者要知道的細縫（§4.5.2）：** 如果這個 code 是靠**竄改 redirect\_uri**（上一頁那條路）拿到的，而 AS 有存下當初的完整 redirect URI 並在 token endpoint 比對，這次注入其實會被擋下：

> In the attack scenario described in Section 4.5.1, the legitimate client would use the correct redirection URI it always uses for authorization requests. But this URI would not match the tampered redirection URI used by the attacker. So, **the authorization server would detect the attack and refuse to exchange the code**.

RFC 緊接著說明為什麼實務上仍然守不住：

> it has been observed that **providers very often ignore the redirect\_uri check requirement at this stage**, maybe because it doesn't seem to be security-critical from reading the specification.
>
> Other providers **just pattern match** the redirect\_uri parameter against the registered redirection URI pattern. ... So, **any attempt to inject an authorization code obtained using the client\_id of a legitimate client or by utilizing the legitimate client on another device will not be detected** in the respective deployments.

若有人問「那 code 到底從哪來才注得進去」：任何**沒有動過 redirect\_uri** 的洩漏管道都行 —— Referer header（§4.2）、AS 或 proxy 的存取 log、瀏覽器歷史、同一個 client 在另一台裝置上的實例（§4.5.2 自己舉的）、以及第二段那個 custom scheme 劫持。這些 code 都是配著**正確的** redirect URI 發出來的，token endpoint 的比對完全無感。
-->

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
缺的是一個能回答第二題的東西：<b>把 code 綁到這一次請求</b>。
</div>

<!--
**⚠ 投影片這句引文的主詞被省略號吃掉了，講者要知道完整版。RFC 9700 §4.5.2 原文是：**

> **Asymmetric methods for client authentication** do not stop this attack, as the legitimate client authenticates at the token endpoint.

原句講的是**非對稱**的 client authentication（private\_key\_jwt、mTLS 這類），不是單指 `client_secret`。這其實讓論點更強而不是更弱 —— 連公私鑰等級的 client 認證都擋不住，`client_secret` 當然更不行，因為理由完全一樣：**送出認證的是那個誠實的 client 本人**。若現場有人抓這一點，就這樣回。

**同節的結論句（可直接引，這句才是完整的處方）：**

> This document therefore recommends instead **binding every authorization code to a certain client instance on a certain device (or in a certain user agent) in the context of a certain transaction** using one of the mechanisms described next.

這句就是第二根軸的規格版說法，也直接鋪好了下一頁的 PKCE。
-->

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

<!--
**出處：RFC 9700 §2.1.1 Authorization Code Grant。完整的三個 bullet（投影片只放了前兩個）：**

> Clients MUST prevent authorization code injection attacks (see Section 4.5) and misuse of authorization codes using one of the following options:
>
> * **Public clients MUST use PKCE** [RFC7636] to this end, as motivated in Section 4.5.3.1.
> * For confidential clients, the use of PKCE [RFC7636] is **RECOMMENDED**, as it provides strong protection against misuse and injection of authorization codes as described in Section 4.5.3.1. Also, **as a side effect, it prevents CSRF** even in the presence of strong attackers as described in Section 4.7.1.
> * With additional precautions, described in Section 4.5.3.2, **confidential OpenID Connect clients MAY use the nonce parameter** and the respective Claim in the ID Token instead.

第三個 bullet 就是最後一段 ㉓ 要講的那個例外，這裡先埋著即可。

**同節還有兩句對 AS 的硬性要求，可備用：**

> **Authorization servers MUST support PKCE** [RFC7636].
>
> If a client sends a valid PKCE code\_challenge parameter in the authorization request, **the authorization server MUST enforce the correct usage of code\_verifier at the token endpoint**.

以及那句常被引用的註記：

> Note: **Although PKCE was designed as a mechanism to protect native apps, this advice applies to all kinds of OAuth clients, including web applications.**
-->

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

<!--
**出處：RFC 6749 §1.3.2 Implicit。投影片引的那句逐字無誤，完整段落是：**

> **When issuing an access token during the implicit grant flow, the authorization server does not authenticate the client.** In some cases, the client identity can be verified via the redirection URI used to deliver the access token to the client. The access token may be exposed to the resource owner or other applications with access to the resource owner's user-agent.

中間那句「In some cases, the client identity can be verified via the redirection URI」值得留意 —— 2012 年 RFC 認為 redirect URI 可以當成一種弱的 client 識別，而第二段（⑩）已經示範了那個假設怎麼垮的。

第三句就是 ⑯ 那頁要用的警告，同一段。
-->

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

<!--
**出處：RFC 6749 §1.3.2。投影片引的兩個片段都逐字正確，但分屬兩段，講者可視情況補上完整句：**

第一句（§1.3.2 開頭）：

> The implicit grant is a **simplified authorization code flow optimized for clients implemented in a browser using a scripting language such as JavaScript**. In the implicit flow, instead of issuing the client an authorization code, **the client is issued an access token directly**.

第二句（§1.3.2 最後一段）：

> Implicit grants improve the responsiveness and efficiency of some clients (such as a client implemented as an in-browser application), **since it reduces the number of round trips required to obtain an access token**. **However, this convenience should be weighed against the security implications** of using implicit grants, such as those described in Sections 10.3 and 10.16, **especially when the authorization code grant type is available**.

後半句「這個方便性應該跟安全代價權衡」也是 2012 年就寫下的 —— 跟 ⑯ 那頁「規格自己警告過」是同一段話的兩半。
-->

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

<!--
**出處：RFC 6749 §1.3.2（2012-10）。投影片引的那句逐字無誤：**

> **The access token may be exposed to the resource owner or other applications with access to the resource owner's user-agent.**

它跟 ⑭ 那句（"does not authenticate the client"）是**同一段**的第一句與第三句，中間隔著 "In some cases, the client identity can be verified via the redirection URI..."。

RFC 6749 §10.3 與 §10.16 是這句話指向的完整討論；若被追問細節可以指過去。RFC 9700 §2.1.2 則把它升級成規範性的 SHOULD NOT（下一頁）。
-->

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

<!--
**兩個引用的出處與完整原文：**

RFC 9700 §2.1.2 Implicit Grant —— 投影片的省略號藏了一個 unless 條件，講者要知道：

> In order to avoid these issues, **clients SHOULD NOT use the implicit grant** (response type token) or other response types issuing access tokens in the authorization response, **unless access token injection in the authorization response is prevented and the aforementioned token leakage vectors are mitigated**.

同節給的替代方案，正好是這一頁的結論：

> Clients **SHOULD instead use the response type code** (i.e., authorization code grant type) as specified in Section 2.1.1 ... This allows the authorization server to **detect replay attempts** by attackers and generally **reduces the attack surface since access tokens are not exposed in URLs**.

OAuth 2.1（draft-ietf-oauth-v2-1-15, 2026-03-02）§10.1 Removal of the OAuth 2.0 Implicit grant：

> The OAuth 2.0 Implicit grant is **omitted from OAuth 2.1** as it was deprecated in [RFC9700].
>
> The intent of removing the Implicit grant is to **no longer issue access tokens in the authorization response**, as such tokens are vulnerable to leakage and injection, and are unable to be sender-constrained to a client. This behavior was indicated by clients using the response\_type=token parameter. **This value for the response\_type parameter is no longer defined in OAuth 2.1.**

注意措辭：OAuth 2.1 是「不再定義 response\_type=token」，等於移除；而 `response_type=id_token`（OIDC）不受影響，同節有明說。
-->

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
clicks: 4
---

# ⑲ PKCE

<div v-click="1" class="text-center text-3xl font-bold mt-3">
<span class="text-amber-300">P</span>roof
<span class="text-teal-300">K</span>ey
for <span class="text-indigo-300">C</span>ode <span class="text-indigo-300">E</span>xchange
</div>

<div v-click="2" class="grid grid-cols-3 gap-4 mt-5 max-w-4xl mx-auto text-left" style="font-size: 12px">

<div class="px-3 py-2 rounded bg-amber-400/10">

**Proof** — 一個證明（第三段缺的那個）

</div>

<div class="px-3 py-2 rounded bg-teal-400/10">

**Key** — 不是預先登記的 secret，是**臨時的**（第四段缺的那個）

</div>

<div class="px-3 py-2 rounded bg-indigo-400/10">

**for Code Exchange** — 保護的正是 code 換 token 那一步

</div>

</div>

<div v-click="3" class="mt-5 max-w-4xl mx-auto text-left" style="font-size: 12.5px">

| 參數 | 是什麼 | 誰產生、誰保管 |
|---|---|---|
| `code_verifier` | 每一次登入**現場產生**的高熵亂數 | client 產生，**留在自己身上，不上網址** |
| `code_challenge` | `S256(code_verifier)`，**反推不回去** | 放進 authorization request 的網址送出 |
| `code_challenge_method` | 用哪一種算法（`S256`） | 同上 |

</div>

<div v-click="4" class="mt-3 max-w-4xl mx-auto text-left opacity-65" style="font-size: 11px">

換 token 時才交出 `code_verifier` 原值，Authorization Server 重算一次、跟當初收到的 `code_challenge` 比對。
RFC 7636 §4.1／§4.2：verifier 為 43–128 字元的高熵亂數；*"If the client is capable of using 'S256', it MUST use 'S256'."*
而 `plain` 在 **OAuth 2.1 §7.5.2 已是明文禁止**。

</div>

<!--
**RFC 7636 §4.1 Client Creates a Code Verifier，逐字：**

> code\_verifier = **high-entropy cryptographic random STRING** using the unreserved characters [A-Z] / [a-z] / [0-9] / "-" / "." / "\_" / "~" from Section 2.3 of [RFC3986], with a **minimum length of 43 characters and a maximum length of 128 characters**.
>
> NOTE: The code verifier SHOULD have enough entropy to make it impractical to guess the value. It is **RECOMMENDED that the output of a suitable random number generator be used to create a 32-octet sequence**. The octet sequence is then base64url-encoded to produce a 43-octet URL safe string.

（§7.1 另有一句更硬的：*"The client SHOULD create a code\_verifier with a minimum of 256 bits of entropy."*）

**投影片說的「換 token 時才交出原值，AS 重算一次比對」＝ RFC 7636 §4.6 Server Verifies code\_verifier before Returning the Tokens：**

> Upon receipt of the request at the token endpoint, the server verifies it by **calculating the code challenge from the received "code\_verifier" and comparing it with the previously associated "code\_challenge"**, after first transforming it according to the "code\_challenge\_method" method specified by the client.
>
> If the "code\_challenge\_method" from Section 4.3 was "S256", the received "code\_verifier" is hashed by SHA-256, base64url-encoded, and then compared to the "code\_challenge", i.e.:
>
> `BASE64URL-ENCODE(SHA256(ASCII(code_verifier))) == code_challenge`
>
> If the values are equal, the token endpoint MUST continue processing as normal. **If the values are not equal, an error response indicating "invalid\_grant" as described in Section 5.2 of [RFC6749] MUST be returned.**

**RFC 7636 §4.2 Client Creates the Code Challenge，逐字：**

> plain　code\_challenge = code\_verifier
> S256　code\_challenge = BASE64URL-ENCODE(SHA256(ASCII(code\_verifier)))
>
> **If the client is capable of using "S256", it MUST use "S256"**, as "S256" is Mandatory To Implement (MTI) on the server. Clients are permitted to use "plain" only if they cannot support "S256" for some technical reason and know via out-of-band configuration that the server supports "plain".

**⚠ 投影片最後一句「plain 在 OAuth 2.1 §7.5.2 已是明文禁止」不成立，講者請勿照唸。**

draft-ietf-oauth-v2-1-15 §4.1.1 對 plain 的措辭跟 RFC 7636 幾乎一樣，**仍然保留它當 fallback**：

> If the client is capable of using S256, it MUST use S256, as S256 is Mandatory To Implement (MTI) on the server. **Clients are permitted to use plain only if they cannot support S256 for some technical reason**, for example constrained environments that do not have a hashing function available, and know via out-of-band configuration or via Authorization Server Metadata [RFC8414] that the server supports plain.

（且 §4.1.1 明寫 `code_challenge_method` **defaults to plain if not present**，連預設值都還在。）

現行文件裡對 plain 最強的措辭是 **RFC 7636 §7.2**，而且只到 SHOULD NOT：

> Because of this, **"plain" SHOULD NOT be used** and exists only for compatibility with deployed implementations where the request path is already protected. **The "plain" method SHOULD NOT be used in new implementations**, unless they cannot support "S256" for some technical reason.
>
> **Clients MUST NOT downgrade to "plain" after trying the "S256" method.**

安全的講法：「S256 是 MUST（只要做得到就必須用），plain 只剩 SHOULD NOT 等級的相容性存在，而且禁止從 S256 降級。」
-->

---
clicks: 9
layout: full
---

<div class="px-10 pt-2">

<div class="text-xl font-bold">⑳ 這一次，誰持有什麼</div>

<div class="opacity-70" style="font-size: 11.5px">

同一個攻擊、同一張圖 —— 只是這次每一趟登入，client 都會現場產生一份自己的 <code>code_verifier</code>。

</div>

<Pkce :step="$clicks" :h="322" />

<div v-click="9" class="mt-1 px-4 py-0 rounded bg-teal-400/10 border-l-4 border-teal-400 text-left"
     style="font-size: 12.5px">

攻擊者需要的是 `verifier_V`。而它**只存在上軌那一格 client 的記憶體裡**，從頭到尾沒有離開過 ——
網址上跑的只有 `challenge`（反推不回去）和 `code`，**就算兩個都被看光，也湊不出 `verifier_V`**。
而且這一整套**沒有用到任何事先登記過的秘密**，所以沒有 `client_secret` 的 public client 一樣做得到 —— 兩個缺口一起補上。

</div>

</div>

<!--
**這一頁的機制就是 RFC 9700 §4.5.3.1 PKCE，逐字原文（兩句話剛好對應圖上的兩個缺口）：**

> The PKCE mechanism specified in [RFC7636] can be used as a countermeasure (even though it was originally designed to secure native apps). **When the attacker attempts to inject an authorization code, the check of the code\_verifier fails: the client uses its correct verifier, but the code is associated with a code\_challenge that does not match this verifier.**
>
> PKCE not only protects against the authorization code injection attack but also **protects authorization codes created for public clients: PKCE ensures that an attacker cannot redeem a stolen authorization code at the token endpoint of the authorization server without knowledge of the code\_verifier.**

第一句 = 缺口一（綁到這一次請求），第二句 = 缺口二（public client 沒有預先共享的秘密也擋得住）。圖上「client 手上是 attacker 那趟的 verifier，code 綁的是 victim 那趟的 challenge」講的就是第一句。

**「網址上跑的只有 challenge、verifier 不上網址」的規格依據，RFC 9700 §2.1.1：**

> When using PKCE, clients SHOULD use PKCE code challenge methods that **do not expose the PKCE verifier in the authorization request**. Otherwise, **attackers that can read the authorization request** (cf. Attacker (A4) in Section 3) **can break the security provided by PKCE**. **Currently, S256 is the only such method.**

這句同時說明了為什麼投影片表格裡 method 只寫 `S256` —— 用 `plain` 的話 challenge 就等於 verifier，等於把 verifier 印在網址上，這一頁的論證會整個垮掉（RFC 7636 §7.2：*"the 'plain' method does not protect against the eavesdropping of the initial request"*）。

**「每一趟都要換新的」的規格依據，RFC 9700 §2.1.1：**

> In any case, the PKCE challenge or OpenID Connect nonce **MUST be transaction-specific and securely bound to the client and the user agent in which the transaction was started**.

OAuth 2.1 §7.5.1.1 還多要求一句：

> **If a transaction leads to an error, fresh values for code\_challenge or nonce MUST be chosen.**
-->

---
layout: center
class: text-center
---

# 回顧

<div class="max-w-4xl mx-auto text-left mt-6 flex flex-col gap-2.5" style="font-size: 14px">

<div class="px-4 py-2.5 rounded bg-gray-500/10">
<b class="text-indigo-300">①</b>　OAuth 主要就<b>三個角色</b> —— Resource Owner、Client、Authorization Server ——
<b>加一個 browser</b> 當載具。
</div>

<div class="px-4 py-2.5 rounded bg-gray-500/10">
<b class="text-indigo-300">②</b>　code 不論在 <b>native app</b> 還是 <b>web</b>，都有辦法被弄走。
</div>

<div class="px-4 py-2.5 rounded bg-red-400/10">
<b class="text-red-300">③</b>　<b>public client</b>：code 被偷就<b>沒救了</b> —— 換 token 那一關沒有東西擋得住。
</div>

<div class="px-4 py-2.5 rounded bg-amber-400/10">
<b class="text-amber-300">④</b>　<b>confidential client</b>：即使有 <code>client_secret</code> 保護，
那個 code <b>照樣能被拿去換到 token</b>。
</div>

<div class="px-4 py-2.5 rounded bg-teal-400/10">
<b class="text-teal-300">⑤</b>　只有 <b>PKCE</b> 確保了 ——
<b>發起 authorization request 的人</b>，和<b>來換 token 的人</b>，是<b>同一個</b>。
</div>

</div>

---
layout: center
---

# 參考資料

<div class="max-w-3xl mx-auto text-left mt-6 flex flex-col gap-3" style="font-size: 14px">

<div>

[RFC 6749 — The OAuth 2.0 Authorization Framework](https://www.rfc-editor.org/rfc/rfc6749)

</div>

<div>

[RFC 7636 — Proof Key for Code Exchange by OAuth Public Clients](https://www.rfc-editor.org/rfc/rfc7636)

</div>

<div>

[RFC 9700 — Best Current Practice for OAuth 2.0 Security](https://www.rfc-editor.org/rfc/rfc9700)

</div>

<div>

[The OAuth 2.1 Authorization Framework（draft-ietf-oauth-v2-1）](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1)

</div>

</div>

<!--
**這一頁四份文件的書目資料與狀態（Q&A 備查，可用來回答「這是什麼等級的文件」）：**

* **RFC 6749**，2012-10，Standards Track。*The OAuth 2.0 Authorization Framework* —— 本場 ②③⑧⑭⑮⑯ 的定義與引文都出自這裡。注意它已被 RFC 9700 **updates**，且會被 OAuth 2.1 **obsoletes**。
* **RFC 7636**，2015-09，Standards Track。標題就是 *Proof Key for Code Exchange by OAuth **Public** Clients* —— 表格說它「只談 public client」的依據就是標題本身。
* **RFC 9700**，2025-01，**Category: Best Current Practice，BCP 240**，**Updates: 6749, 6750, 6819**。標題 *Best Current Practice for OAuth 2.0 Security*。
* **OAuth 2.1**：目前仍是 Internet-Draft，最新版 **draft-ietf-oauth-v2-1-15，2026-03-02**（Hardt / Parecki / Lodderstedt），**尚未成為 RFC**。若被問「定了嗎」，答：還沒，但它明說 *"This specification replaces and obsoletes the OAuth 2.0 Authorization Framework described in RFC 6749 and the Bearer Token Usage in RFC 6750."*

**若被問「OAuth 2.1 到底怎麼規定 PKCE、有沒有例外」——出處是 draft-15 §7.5.1.1 Countermeasures**（§7.5.1 本身只是攻擊描述）。逐字原文：

> To prevent injection of authorization codes into the client, **using code\_challenge and code\_verifier is REQUIRED for clients, and authorization servers MUST enforce their use**, unless **both** of the following criteria are met:
>
> * The client is a **confidential client**.
> * In the specific deployment and the specific request, there is **reasonable assurance by the authorization server that the client implements the OpenID Connect nonce mechanism properly**.
>
> In this case, **using and enforcing code\_challenge and code\_verifier is still RECOMMENDED**.

**這個例外其實很弱，而且不是自行推論，OAuth 2.1 原文就是這樣說的，可直接引：**

> **Relying on the client to validate the OpenID Connect nonce parameter means the authorization server has no way to confirm that the client has actually protected itself** against authorization code injection attacks. If an attacker is able to inject an authorization code into a client, **the client would still exchange the injected authorization code and obtain tokens, and would only later reject the ID token** after validating the nonce and seeing that it doesn't match. In contrast, the authorization server enforcing the code\_challenge and code\_verifier parameters **provides a higher security outcome, since the authorization server is able to recognize the authorization code injection attack pre-emptively and avoid issuing any tokens in the first place**.

**若要收一句「PKCE 已經從 public client 的補丁變成預設」，OAuth 2.1 §7.5.1.1 的 Historic note 可以直接引：**

> Historic note: **Although PKCE was originally designed as a mechanism to protect native apps from authorization code exfiltration attacks, all kinds of OAuth clients, including web applications and other confidential clients, are susceptible to authorization code injection attacks**, which are solved by the code\_challenge and code\_verifier mechanism.

RFC 9700 對 PKCE 的規定見 ⑬ 的 notes（§2.1.1）；另有一句常用的：*"Authorization servers MUST support PKCE [RFC7636]."*

三份規格的態度變化，若要口頭總結：**RFC 7636（2015）只談 public client → RFC 9700（2025, BCP）public MUST／confidential RECOMMENDED → OAuth 2.1（draft）REQUIRED 且 AS MUST 強制，不再分 public / confidential。**
-->
