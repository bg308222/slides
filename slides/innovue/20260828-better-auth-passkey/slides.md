---
theme: default
title: Better Auth Passkey：把 Passkey 接到既有 App，而不搬走使用者
info: |
  使用者留在 app、passkey 留在 auth server，
  兩邊靠註冊時建立的那一列 mapping 連起來。
  每一步都是上一步的痛點逼出來的。
class: text-center
transition: slide-left
colorSchema: dark
mdc: true
---

# Better Auth Passkey

把 passkey 接到既有 app，而不搬走使用者

<div class="pt-16 text-xs opacity-35">andy.lin · 2026-08-28</div>

---
layout: center
---

# 今天怎麼走

<div class="max-w-3xl mx-auto text-left mt-2 text-sm opacity-60">
這件事公司內已經做過兩次。今天講的是站在那個基礎上的第三種做法，差別在<b class="opacity-100">對 app 的影響</b>。
</div>

<div class="grid grid-cols-2 gap-x-10 mt-8 text-left max-w-3xl mx-auto">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第一段</div>

**Better Auth 是什麼**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
只講到「足夠讓第二段成立」為止。它不是背景介紹，是前置。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第二段</div>

**它的 passkey 怎麼跟既有 app 串起來**

<div class="text-sm opacity-65 mt-1 leading-relaxed">
使用者不搬家，那 auth server 要怎麼認得他？
</div>
</div>

</div>

<!--
第一段的存在理由要先講清楚，否則聽眾會以為前四頁是產品介紹。

「已經做過兩次」這裡刻意不點名，名字留到最後一頁出現一次就好。
這裡只承諾差別存在，不要先講差別是什麼。
-->

---
layout: section
---

# 第一段

Better Auth 是什麼

---

# ① 官方怎麼說

<div class="max-w-3xl mx-auto mt-10 text-left">

<div class="border-l-4 border-slate-400/40 pl-5 py-1">

Better Auth is a **framework-agnostic** authentication (and authorization) **framework** for TypeScript.

</div>

<div class="text-xs opacity-35 mt-2 pl-5">— GitHub README 第一句</div>

<div v-click class="mt-10 pl-5">

實際上，它給你的就是**兩包 library**。

<div class="mt-4 flex gap-3 text-sm">
<span class="rounded border border-teal-400/50 bg-teal-400/10 text-teal-200 px-3 py-1">server lib</span>
<span class="rounded border border-slate-400/40 bg-slate-400/10 px-3 py-1">client lib</span>
</div>

</div>

</div>

<!--
這裡只說「它給你兩包 library」，不要多解釋為什麼。

「為什麼它只是 library」交給接下來三頁的動畫去長出來 ——
觀眾會看到 db 與 instance 被建出來、卻沒有任何人打得到，
然後看到掛上 express 之後才長出 endpoint。
到那時候這個結論是他們自己得到的，不是這一頁塞給他們的。
-->

---
clicks: 2
---

# ② server lib 給了你兩個東西

<Lib :step="1 + $clicks" class="mt-2" />

<!--
step 3 是這一段的痛點：東西都建好了，右邊卻是一道封死的牆。

這一格要停一下。下一頁的 toNodeHandler 之所以不是「順便介紹的 API」，
就是因為觀眾在這裡先看見了「打不到」。
-->

---
clicks: 3
---

# ③ 掛上去，才長出一台 server

<Lib :step="Math.min(4 + $clicks, 6)" class="mt-2" />

<div v-click="3" class="absolute text-center" style="left: 0; right: 0; bottom: 1.5rem">
<span class="text-sm">所以它是一包 <b class="text-teal-300">library</b>，不是一台 server —— server 從頭到尾都是<b class="text-teal-300">你的</b>。</span>
</div>

<!--
adapter 那一整排是「framework-agnostic」最好的證據，比引用官網那句定義有力。
掃過去就好，不用逐個念。

外框到這裡才貼上「auth server」這個名字。後面全場都用這個名字稱呼它。
-->

---
clicks: 4
---

# ④ 它自己就是一套完整的使用者系統

<Stage :step="$clicks" class="mt-1" />

<!--
client lib 的用法就是 createAuthClient 給它網址。之後每呼叫一次，
就往 server 打一發，db 或畫面上就有東西變：

  signUp.email    → user 表多一列 andy
  signIn.email    → user 表亮起來（資料流進去），畫面顯示「登入成功」
  addPasskey      → passkey 表多一列，userId 指向 u_1
  signIn.passkey  → passkey 表亮起來，畫面一樣顯示登入成功，但這次沒有用到密碼

刻意不畫 session table：登入成功與否，使用者看到的是畫面，不是資料表。

最後一格要點出來：到這裡為止，註冊、登入、passkey 註冊、passkey 登入，
全部在這一格裡面跑完了。它不缺任何東西。

—— 這一頁是後面所有取捨的對照組。沒有它，下一頁的「不搬家」就沒有代價可言。
-->

---
layout: section
---

# 第二段

那我的 app 呢

---
clicks: 2
---

# ⑤ 使用者不在它手上

<Stage :step="4 + $clicks" class="mt-1" />

<!--
進來時畫面不變 —— 還是上一頁那個滿版的 auth server。兩個 click 要分開：

  1. auth server 主動縮到左半，右半長出等大的 app server。
     注意這時候 app server 的 user 表是「空的」—— 兩格出現，人還沒落位
  2. andy 滑到右邊，auth server 那一格整個清空（user 與 passkey 都空）

講這一格時要講清楚：**這不是把資料搬過去**。
上一頁那張圖是 Better Auth 自己做得到的示範；這一頁是把場景換成我們真正的起點 ——
auth server 本來就是全空的，使用者一直都只在 app 這一邊。
andy 往右滑只是在把場景擺好，不是 migration。

收在這裡：auth server 有一整套 passkey 的本事，卻不認識任何人。
下一頁就是要解這個問題。
-->

---
clicks: 5
---

# ⑥ 註冊：借 app cookie 裡的 JWT

<Stage :step="6 + $clicks" class="mt-1" />

<!--
  1. Alice 在 app 用帳密登入，app 用自己的私鑰簽一個 JWT（sub = app user id）放進 cookie
  2. app 頁面上那顆「新增 Passkey」是導頁 —— 使用者離開 app 的頁面，去到 auth server 的
     enroll 頁，cookie 隨請求一起送過去。app 不必引入任何 auth 依賴，這點最後一頁會回收
  3. 紅字：這個 cookie 送得到是有前提的
  4. auth server 用手上的公鑰驗簽，取出 app_user_id，建一個沒有密碼的 auth_user，
     寫下 mapping 那一列
  5. passkey 接上去，第 ⑤ 頁那條懸空的線終於有了對象

這一段的判詞：auth server 不認識 Alice，它只是「相信 app 說她是誰」。
信任的全部來源就是畫面上那對鑰匙 —— 沒有別的。

技術補充（被問到才講）：passkey plugin 的 registration.requireSession 預設是 true，
也就是原本這裡要一個 auth server 自己的 session。我們設成 false 並提供 resolveUser，
等於把那個位置換成 app 的 session。這是官方明確留的擴充點，不是繞路。
-->

---
clicks: 3
---

# ⑦ 登入：認人成功了，然後呢？

<Stage :step="11 + $clicks" class="mt-1" />

<!--
注意上方的箭頭重新指了一次 —— 這是**新的一輪**，跟上一頁的註冊不是同一件事。
使用者從 app 被導到 auth server 的 sign-in 頁。

  1. signIn.passkey() 成功 —— 左邊那格出現「✓ 已確認身分」
  2. 現在看右邊。什麼都沒有變。app 不知道剛才發生過任何事
  3. 而且那個確認只活 60 秒、還關掉了 refresh。它根本不打算當登入狀態

這一頁的痛點是用「空白」做出來的，不要用嘴巴補。
講完第二格停兩秒，讓大家自己看右邊那一格。

我們要的從來不是在 auth server 登入，是在 app 登入。
-->

---
clicks: 5
---

# ⑧ 把「這是誰」送過邊界

<Stage :step="14 + $clicks" class="mt-1" />

<!--
  1. auth server 換一頂帽子：它同時是 OIDC Provider，app 是 OIDC client
  2. 走一次標準 OIDC（上個月講過的那一條，這裡不展開），app 拿回 id_token
  3. 攤開 payload —— iss / aud / sub / nonce 都在，但今天只看最後那一個
  4. app_user_id 這條線回到第 ⑥ 頁建的那一列 mapping。註冊時建的那一列，
     就是為了這一刻
  5. app 用它找回自己 db 裡的 Alice，簽自己的 session。右邊那格終於變了

收句：auth server 從頭到尾沒有發過 app 的 session。
它只交出了「這是誰」這個判斷，session 永遠是 app 自己的。
-->

---
clicks: 4
---

# ⑨ 所以 app 到底多做了什麼

<div class="text-xs opacity-45 -mt-2 mb-2">
webpatx 與 ecsten 之前都是把整個 passkey 實作放在 app 身體裡 —— 那是可行的、也已經在跑。
</div>

<Minimal :step="$clicks" />

<div v-click="4" class="absolute text-center" style="left: 3.5rem; right: 3.5rem; bottom: 1.2rem">
<span class="text-sm">註冊與登入的<b class="text-teal-300">畫面都在 auth server</b> —— 它多支援一種登入方式，app 不用知道，使用者直接就多一個選項。</span>
</div>

<!--
這一頁刻意把 auth server 移出視線。要回答的是「app 這一格到底多做了什麼」，
auth server 還在畫面上，注意力就會繼續分過去。

  1. UI 加一個「新增 Passkey」入口 —— 箭頭直接指出框外。
     指出去就是重點：那件事 app 不用管了，auth server 的 enroll 頁會搞定，
     要支援哪些驗證方式、選項怎麼列、怎麼串，都在它那一側
  2. 一組 OIDC client。這個躲不掉 —— 但它是純標準的，
     authorize → token → 驗 id_token → 簽自己的 session
  3. UI 再加一個「使用 Passkey 登入」入口。它其實只是觸發自己的 OAuth，
     自然就被導到 auth server 的登入頁 —— 一樣指出框外
  4. 所以之後 auth server 多支援 Google、LDAP、SAML 或任何東西，
     app 這一邊一行都不用改，使用者在那兩個頁面上直接就多出選項

定調：webpatx 與 ecsten 那個版本不是反例，是已經在跑、而且是對的版本。
今天講的是站在它上面的下一步。（那兩個產品一個用 Better Auth、一個不是，
所以對照點不是「用了哪個 library」，而是「整套實作放在哪」。）
-->

---
layout: center
---

# 回顧

<div class="max-w-4xl mx-auto text-left mt-4">
<div class="text-xs opacity-40 mb-4">整場只問一個問題：<b class="opacity-100">此刻「這是誰」的判斷，握在哪一格手上？</b></div>

<div class="flex flex-col gap-2.5 text-sm">

<div class="flex gap-4"><span class="opacity-40 shrink-0" style="width: 3.5rem">①–④</span><span>只有 auth server —— 它自己就是全部</span></div>
<div class="flex gap-4"><span class="opacity-40 shrink-0" style="width: 3.5rem">⑤</span><span>使用者搬回 app，auth server <b class="text-amber-300">不認識任何人</b></span></div>
<div class="flex gap-4"><span class="opacity-40 shrink-0" style="width: 3.5rem">⑥</span><span>借 app 的簽章，第一次認得他 —— <b class="text-teal-300">mapping 建立</b></span></div>
<div class="flex gap-4"><span class="opacity-40 shrink-0" style="width: 3.5rem">⑦</span><span>認得出來了，但這個判斷<b class="text-amber-300">出不了那一格</b></span></div>
<div class="flex gap-4"><span class="opacity-40 shrink-0" style="width: 3.5rem">⑧</span><span>OIDC 把它送過邊界，<b class="text-teal-300">app 自己簽自己的 session</b></span></div>

</div>

<div class="mt-8 pt-5 border-t border-slate-400/20 text-sm opacity-80">
app 只留一個標準 OIDC client 與兩個入口。之後 auth server 多支援什麼登入方式，app 一行都不用改。
</div>

</div>

---
layout: center
---

# 參考資料

<div class="max-w-3xl mx-auto text-left mt-6 flex flex-col gap-3" style="font-size: 14px">

<div>

[Better Auth](https://github.com/better-auth/better-auth)

</div>

<div>

[Passkey — Better Auth Plugins](https://www.better-auth.com/docs/plugins/passkey)

</div>

<div>

[OAuth Provider — Better Auth Plugins](https://www.better-auth.com/docs/plugins/oauth-provider)

</div>

<div>

[OpenID Connect Core 1.0 incorporating errata set 2](https://openid.net/specs/openid-connect-core-1_0.html)

</div>

</div>
