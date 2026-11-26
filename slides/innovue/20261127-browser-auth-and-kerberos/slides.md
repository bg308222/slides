---
theme: default
title: Browser authentication & Kerberos
info: |
  server 回一個 401 Negotiate，瀏覽器就替你登入了。
  瀏覽器透過 OS，完成了整套 Kerberos 流程。
class: text-center
transition: slide-left
colorSchema: dark
mdc: true
fonts:
  sans: Noto Sans TC
  mono: JetBrains Mono
---

# Browser authentication & Kerberos

瀏覽器怎麼替你完成 Kerberos 登入

<div class="pt-16 text-xs opacity-35">andy.lin · 2026-11-27</div>

---
layout: center
---

# 今天要講的

<div class="flex flex-col gap-y-5 mt-8 text-left mx-auto" style="max-width: 640px">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第一章</div>

**最直觀的做法：server 自己拿帳密去換票**
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第二章</div>

**瀏覽器本來就會幫忙登入：401 與 WWW-Authenticate**
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第三章</div>

**Negotiate 跑了什麼流程**
</div>

<div class="text-sm opacity-50">附錄：Kerberos 用不了時的備案（NTLM）</div>

</div>

---
clicks: 5
transition: fade
---

# 先回顧上週的 Kerberos

<World :frame="$clicks" />

<!--
逐格講稿：
[click 0] 先把上週走一遍，這裡只有三個角色：user、AD、app。
[click 1] 你用 AD 帳號登入 Windows。
[click 2] 電腦向 AD 的「驗密碼」窗口證明你的身分（密碼本身不上網），拿到一張 TGT。
[click 3] 要進 app，就拿 TGT 去「換票」窗口換一張 ST。
[click 4] ST 交給 app，app 用自己的金鑰解開，你就進去了。
[click 5] Kerberos 的流程懂了。但回到我們自己寫的 app（網站）：它要怎麼接上這整個流程？我們的 app 有辦法直接碰到 Kerberos 嗎？

下一章從「最直觀的做法：全部交給 server 自己做」開始。
-->

---
layout: section
---

# 最直觀的做法：server 自己拿帳密去換票

---
clicks: 6
transition: fade
---

# server 自己拿帳密去換票

<World :frame="6 + $clicks" />

<!--
逐格講稿：
[click 0] 我們的 app 要接上 Kerberos，最直觀的做法：全部交給 server 自己做。網頁放一個登入表單。
[click 1] 使用者輸入帳密。
[click 2] 帳密送到 server。
[click 3] server 拿帳密去向 AD 換 TGT。
[click 4] 再用這張 TGT 換一張給自己的 ST，用自己的金鑰解開，確認身分。這是照著 Kerberos 走的，真的有人這樣做（Apache mod_auth_kerb 的密碼模式）。
[click 5] 兩個問題：第一，密碼進到 server 了，上週 Kerberos 的出發點就是不讓每個 app 看到密碼。第二，TGT 留在 server 手上，沒有留在你的電腦；下次、或換一個網站，又要重新登入一次，SSO 不成立。
[click 6] 那能不能不經過 server 登入？答案是有：瀏覽器本來就支援。

被問「最後換 ST 那步是不是多餘」時：只換到 TGT 就算登入成功的話，攻擊者可以假冒 AD 回應（mod_auth_kerb 稱為 KDC spoofing）；假 AD 不知道 server 的金鑰，做不出 server 解得開的 ST。server 驗身分靠的永遠是「我解得開這張 ST」（RFC 4120 §3.1.5、§10）。
-->

---
layout: section
---

# 瀏覽器本來就會幫忙登入：401 與 WWW-Authenticate

---
clicks: 4
transition: fade
---

# server 出題、client 作答

<Exchange :frame="$clicks" />

<!--
逐格講稿：
[click 0] HTTP 內建一套「server 出題、client 作答」的格式。
[click 1] 瀏覽器送出請求。
[click 2] server 回 401，加上 WWW-Authenticate，告訴你要用什麼方式證明身分。
[click 3] client 重送請求，帶上 Authorization，同一個方式加上資料。
[click 4] 答對了，回 200。<方式> 換成不同的字，會有不同的人來作答。（RFC 9110 §11）
-->

---
clicks: 7
transition: fade
---

# Basic：瀏覽器跳框幫你登入

<Exchange :frame="5 + $clicks" />

<!--
逐格講稿：
[click 0] 同一個格式，這次一條一條看。
[click 1] 瀏覽器送出請求。
[click 2] server 回 401，出題方式是 Basic。
[click 3] 瀏覽器自己跳出帳密框。這個框不是網頁畫的，是瀏覽器內建的。（可在這裡切到現場 demo）
[click 4] 輸入帳密。
[click 5] 瀏覽器自己把帳密組成 andy:P@ssw0rd、做 base64，放進 Authorization 送出（RFC 7617）。
[click 6] 答對了，200。
[click 7] server 只回了一個 header，跳框、送出、記住，全是瀏覽器自己做的。上週 demo 看到的那個框，就是瀏覽器在作答。

被問再講：base64 不是加密，解開就是明文帳密；同一個 realm 之後的請求，瀏覽器會自動帶上（RFC 9110 §11.5）。
-->

---
clicks: 5
transition: fade
---

# Bearer：你們每天在送的那一半

<Exchange :frame="13 + $clicks" />

<!--
逐格講稿：
[click 0] 這一行大家都很熟：Authorization: Bearer 加上 JWT。
[click 1] 平常我們的前端程式一開始就把它帶在請求上，server 直接回 200。所以我們從來沒看過 401，也沒看過 WWW-Authenticate。
[click 2] 但在 HTTP 的約定裡，這其實是一問一答：沒帶或帶錯的時候，server 會回 401，出題 WWW-Authenticate: Bearer（RFC 6750）。
[click 3] 我們每天送的那一行，就是作答的那一半。
[click 4] 答對了，200。
[click 5] 同一套一問一答，只是我們的前端程式一開始就先把答案帶著；作答的是我們的程式，不是瀏覽器。

補充：RFC 6750 §3 的出題還可以帶錯誤原因，例如 WWW-Authenticate: Bearer error="invalid_token"。
-->

---
clicks: 6
transition: fade
---

# Negotiate：瀏覽器去問 OS

<Exchange :frame="19 + $clicks" />

<!--
逐格講稿：
[click 0] 同一個格式，這次換成今天的主角。
[click 1] 瀏覽器送出請求。
[click 2] server 回 401，出題方式是 Negotiate（RFC 4559）。
[click 3] 這次瀏覽器不跳框，也不是前端程式自己帶答案：它去問自己電腦的 OS，幫我證明我是誰。
[click 4] 瀏覽器把 OS 給的答案放進 Authorization: Negotiate 送出。內容是什麼，下一章拆開。
[click 5] 答對了，200。
[click 6] 作答的還是瀏覽器，只是它去問 OS。
-->

---
layout: section
---

# Negotiate 跑了什麼流程

---
clicks: 2
transition: fade
---

# 瀏覽器把題目交給 OS

<World :frame="13 + $clicks" />

<!--
逐格講稿：
[click 0] 回到這張圖，這次電腦分成兩層：上面是瀏覽器，下面是 OS。
[click 1] server 回 401，出題 WWW-Authenticate: Negotiate。
[click 2] 瀏覽器用網址組出 SPN（上週學過的 HTTP/主機名），請 OS：幫我向這個網站證明我是誰。瀏覽器本身不碰票。
-->

---
clicks: 7
transition: fade
---

# OS 怎麼拿到 ST

<World :frame="16 + $clicks" />

<!--
逐格講稿（搭配現場 demo：klist purge → 重新整理 → klist）：
[click 0] OS 要拿到這個網站的 ST。看 klist，分三種情況。
[click 1] 情況一：klist 已經有這張 ST，直接用，完全不找 AD。
[click 2] 情況二：沒有 ST，但有 TGT。
[click 3] OS 拿 TGT 去 AD 的換票窗口換 ST，klist 多出一張 HTTP/…。
[click 4] 情況三：什麼都沒有。
[click 5] 瀏覽器跳出帳密框。
[click 6] 帳密交給 OS（不是交給 server），OS 拿去 AD 的驗密碼窗口換到 TGT。
[click 7] 再拿 TGT 換 ST。三種情況，最後 OS 手上都有一張 ST。

回收第一章 demo 的那個框：「上週那個框，就是情況三；你打的帳密沒有交給 server，是交給 OS 去換票。」
-->

---
clicks: 5
transition: fade
---

# 送出與驗證

<World :frame="24 + $clicks" />

<!--
逐格講稿：
[click 0] OS 手上有 ST 了。
[click 1] OS 把 ST 交回瀏覽器。
[click 2] 瀏覽器放進 Authorization: Negotiate 送給 server（RFC 4559）。
[click 3] server 用自己的金鑰解開，不必問 AD（RFC 4120 §3.2.3）。
[click 4] 對照第一章：那時 TGT 和密碼都跑到 server 手上；這裡 TGT 留在你的電腦，密碼沒有交給 server，越過網路邊界的只有 ST。
[click 5] 瀏覽器只是呼叫 OS，整套 Kerberos 都由 OS 完成。
-->

---
layout: center
clicks: 3
---

# 回顧

<div class="mt-8 text-left mx-auto flex flex-col gap-y-6" style="max-width: 760px">

<div v-click="1" class="flex gap-4 items-baseline">
<div class="text-2xl font-bold" style="color: #f9a8d4">1</div>
<div>

**由 server 完成 Kerberos 可行，但 AD 密碼沒必要流過 server**
<div class="text-sm opacity-60 mt-1">第一章</div>
</div>
</div>

<div v-click="2" class="flex gap-4 items-baseline">
<div class="text-2xl font-bold" style="color: #f9a8d4">2</div>
<div>

**瀏覽器本身就有幫 server 完成登入的機制：`WWW-Authenticate` ＋ `Authorization`**
<div class="text-sm opacity-60 mt-1">第二章</div>
</div>
</div>

<div v-click="3" class="flex gap-4 items-baseline">
<div class="text-2xl font-bold" style="color: #f9a8d4">3</div>
<div>

**scheme ＝ `Negotiate` 時，瀏覽器能幫你完成 Kerberos**
<div class="text-sm opacity-60 mt-1">第三章</div>
</div>
</div>

</div>

<!--
逐格講稿：
[click 0] 回顧今天的三件事。
[click 1] 第一：由 server 自己拿帳密去換票，Kerberos 一樣走得通；但 AD 的密碼沒必要流過 server，而且 TGT 也留不在使用者的電腦上。
[click 2] 第二：瀏覽器本身就有幫 server 完成登入的機制：server 出題 WWW-Authenticate，瀏覽器作答 Authorization。
[click 3] 第三：當 scheme 是 Negotiate，瀏覽器會去問 OS，由 OS 完成整套 Kerberos，送過網路的只有 ST。
-->

---

# 參考資料

<div class="text-xs leading-relaxed mt-2" style="columns: 2; column-gap: 2.5rem">

- [RFC 9110 — HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110)
- [RFC 7617 — The 'Basic' HTTP Authentication Scheme](https://www.rfc-editor.org/rfc/rfc7617)
- [RFC 6750 — The OAuth 2.0 Authorization Framework: Bearer Token Usage](https://www.rfc-editor.org/rfc/rfc6750)
- [RFC 4559 — SPNEGO-based Kerberos and NTLM HTTP Authentication in Microsoft Windows](https://www.rfc-editor.org/rfc/rfc4559)
- [RFC 4120 — The Kerberos Network Authentication Service (V5)](https://www.rfc-editor.org/rfc/rfc4120)
- [\[MS-NLMP\]: NT LAN Manager (NTLM) Authentication Protocol](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-nlmp/b38c36ed-2804-4868-a9ff-8dd3182128e4)
- [\[MS-NTHT\]: NTLM Over HTTP Protocol](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-ntht/f09cf6e1-529e-403b-a8a5-7368ee096a6a)
- [\[MS-APDS\]: Authentication Protocol Domain Support](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-apds/)
- [Microsoft Negotiate](https://learn.microsoft.com/en-us/windows/win32/secauthn/microsoft-negotiate)
- [Configuring Kerberos for IP Address](https://learn.microsoft.com/en-us/windows-server/security/kerberos/configuring-kerberos-over-ip)
- [Credentials Processes in Windows Authentication](https://learn.microsoft.com/en-us/windows-server/security/windows-authentication/credentials-processes-in-windows-authentication)
- [Protected Users Security Group in Windows Server](https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group)
- [Deprecated features in the Windows client](https://learn.microsoft.com/en-us/windows/whats-new/deprecated-features)
- [Features and functionality removed in Windows client](https://learn.microsoft.com/en-us/windows/whats-new/removed-features)
- [Kerberos Module for Apache](https://modauthkerb.sourceforge.net/configure.html)

</div>

---
layout: center
---

# 備用：可能被問的

<div class="mt-6 text-left mx-auto leading-relaxed text-sm" style="max-width: 760px">

- **跳過 Negotiate 時，瀏覽器會再去問 server 有沒有別的方式嗎？** 不會。只看同一個 401 回應裡的其他 `WWW-Authenticate`；只給 `Negotiate` 就直接顯示 401 頁面。
- **怎麼知道這次走的是 Kerberos 還是 NTLM？** `klist` 有沒有多出 `HTTP/…` 那張票；或看 DevTools 是一次 401 還是兩次。
- **NTLM 為什麼要兩次 401？** 回應要對 server 出的隨機數做運算，所以先表明要用 NTLM、server 再出題。實務上三則訊息要在同一條連線上完成，前面有不保持連線的 proxy／負載平衡器就會一直 401（規格未明寫，屬實務經驗）。
- **加入 Protected Users 群組會怎樣？** 不能用 NTLM 向 DC 驗證；Windows 也不再保存 NT hash 與長期金鑰，TGT 限 4 小時、不可續期。

</div>

---
layout: section
---

# 附錄：Kerberos 用不了時的備案 NTLM

---
clicks: 6
transition: fade
---

# 沒有 ST，也登入了

<World :frame="30 + $clicks" />

<!--
逐格講稿（搭配現場 demo）：
[click 0] OS 優先走 Kerberos；Kerberos 要靠正確的 SPN 換 ST。
[click 1] 同一個網站，網址改成 IP：10.0.0.5。SPN 變成 HTTP/10.0.0.5。
[click 2] OS 拿 TGT 去換 ST，AD 沒有這個 SPN，換不到（Microsoft〈Configuring Kerberos for IP Address〉：預設不對 IP 試 Kerberos，退回 NTLM）。
[click 3] 現場 demo：沒跳框，還是登入了。
[click 4] klist 沒有多出任何票；DevTools 這次出現兩次 401。
[click 5] 沒有 ST，那它拿什麼證明你是你？
[click 6] Kerberos 換不到時，OS 改用另一種方式：NTLM（Microsoft〈Microsoft Negotiate〉：條件不符時，Negotiate 改選 NTLM）。
-->

---
clicks: 5
transition: fade
---

# 挑戰與回應

<World :frame="37 + $clicks" />

<!--
逐格講稿：
[click 0] 你的電腦上有一個「由密碼算出的值」（紫色），先不管它叫什麼。
[click 1] 瀏覽器先表明：我要用 NTLM。
[click 2] server 回 401，附上一個隨機數。（所以 NTLM 會多一次 401：先表明、server 再出題。）
[click 3] 你的電腦用紫色的值，對這個隨機數做運算，算出回應。密碼本身不上網。
[click 4] 送出「我是 andy」加上回應。
[click 5] 問題來了：server 手上沒有那個值，驗不了。

（MS-NLMP §1.3.1.1；MS-NTHT §4.1）
-->

---
clicks: 4
transition: fade
---

# server 轉問 AD

<World :frame="43 + $clicks" />

<!--
逐格講稿：
[click 0] AD 手上有同一個值。
[click 1] server 把「andy、隨機數、回應」轉給 AD。
[click 2] AD 算一次，回答對不對。
[click 3] 對了，server 回 200，登入成功。
[click 4] 對照 Kerberos：server 用自己的金鑰就能解 ST，不必問 AD；NTLM 的 server 自己驗不了，每次登入都要問。（MS-APDS §1.4.1）
-->

---
clicks: 4
transition: fade
---

# 那個值是什麼

<World :frame="48 + $clicks" />

<!--
逐格講稿：
[click 0] 回到紫色的那個值。
[click 1] 它叫 NT hash：密碼做一次 MD4，不加鹽（MS-NLMP §3.3.1）。
[click 2] Windows 登入後把它留在記憶體裡，所以剛才不用打密碼，這就是 NTLM 的 SSO（Microsoft〈Credentials Processes in Windows Authentication〉）。
[click 3] 問題：算回應只需要它，不需要原本的密碼。拿到它就能登入。
[click 4] 這正是 PBKDF2 那場講過的：資料庫裡這個值，也能直接通過登入。
-->

---
clicks: 5
transition: fade
---

# server 不用證明自己

<Relay :frame="$clicks" />

<!--
逐格講稿：
[click 0] 最後一個差別：對面是不是真的 server。
[click 1] Kerberos 的 server 可以在 200 裡回一份資料，證明自己是真的（RFC 4559 §4.1）。
[click 2] NTLM 沒有這一份（MS-NTHT §5.1：NTLM 沒有 mutual authentication）。
[click 3] 於是站在中間的假 server，可以把真 server 的隨機數原封不動轉給你。
[click 4] 你算出回應，它再原封不動轉回真 server，就以 andy 的身分登入了。
[click 5] 你從來不知道對面是誰。

緩解措施（EPA、signing）這次沒有查證，被問再說會回頭確認。
-->

---
clicks: 3
---

# 能走 Kerberos 就走 Kerberos

<div v-click="1" class="text-sm opacity-85 mt-2">

Microsoft：NTLM 2024 年列為 deprecated（仍可使用，不再開發）；NTLMv1 已在 Windows 11 24H2／Server 2025 移除

</div>

<Overview :on="$clicks >= 2" />

<div class="text-center" style="height: 30px; line-height: 30px; font-size: 16px; color: #f9a8d4"
     :style="{ opacity: $clicks >= 3 ? 1 : 0, transition: 'opacity 400ms' }">

兩條路都不必把密碼交給 server；能走 Kerberos 就走 Kerberos

</div>

<!--
逐格講稿：
[click 0] 收尾。
[click 1] Microsoft 的現況：NTLM 已列為 deprecated，但還能用；NTLMv1 已經移除（〈Deprecated features in the Windows client〉、〈Features and functionality removed in Windows client〉）。
[click 2] 全貌：server 回 401 Negotiate，瀏覽器去問 OS；OS 換得到 ST 就走 Kerberos，server 自己驗；換不到就退回 NTLM，server 每次都問 AD。最後都放進 Authorization: Negotiate 送給 server。
[click 3] 兩條路都不必把密碼交給 server；能走 Kerberos 就走 Kerberos。
-->
