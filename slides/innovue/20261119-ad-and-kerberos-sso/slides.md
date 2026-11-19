---
theme: default
title: AD and Kerberos SSO
info: |
  登入 Windows 之後，為什麼能直接進系統。
  從上次的 OIDC 出發，一步一步推出 Kerberos。
class: text-center
transition: slide-left
colorSchema: dark
mdc: true
fonts:
  sans: LXGW WenKai TC
  mono: JetBrains Mono
---

# AD and Kerberos SSO

登入 Windows 之後，為什麼能直接進系統

<div class="pt-16 text-xs opacity-35">andy.lin · 2026-11-19</div>

---
layout: center
---

# 今天要講的

<div class="grid grid-cols-2 gap-x-10 gap-y-6 mt-8 text-left mx-auto" style="max-width: 720px">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第一章</div>

**拆開 AD、Kerberos、SSO 三個詞**
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第二章</div>

**一步一步推出 Kerberos 的做法**
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第三章</div>

**對上 Kerberos 的正式名詞**
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第四章</div>

**為什麼登入 Windows 就能直接進系統**
</div>

</div>

---
layout: section
---

# 拆開 AD、Kerberos、SSO 三個詞

---
clicks: 2
transition: fade
---

# 點「用 Google 登入」

<GoogleFlow :step="$clicks" />

<!--
大家一定都有這個經驗：在某個 app 點「用 Google 登入」，到 Google 登入，回到 app。

[click] 第一次：導去 Google、輸入帳密、帶著 id_token 回來。這是上次 OIDC 講過的流程，今天不重講。

[click] 第二次再點，Google 沒有再問帳密，直接回來了。
為什麼？Google 在一段時間內記住了你——靠的是放在你瀏覽器裡的登入 cookie。
所以第二次「看起來」直接登入，其實 OIDC 流程還是完整跑了一次，只是不用再輸入帳密。

-->

---
clicks: 4
transition: fade
---

# 同一張圖，三塊

<GoogleFlow :step="$clicks + 2" />

<!--
[click] 登入一次 Google，之後就能直接進 app：這是 SSO。

[click] 整個流程：OIDC。

[click] 擁有你身分的那一方：Google。

[click] 今天的三個概念剛好一一對應：SSO 還是 SSO；OIDC 換成 Kerberos；Google 換成 AD。
-->

---
layout: center
---

# 現場 demo

<div class="mt-4 opacity-70">跳 401 → 輸入帳密 → 進系統 → 登出 → 再進去</div>

<!--
只展示體驗和 Google 一樣：第一次跳 401 輸入帳密，登出後再進去就直接登入了。
這裡不跑 klist，klist 留到第四章揭曉。

收尾的一句話：體驗一樣——那背後發生了什麼？
-->

---
layout: section
---

# 一步一步推出 Kerberos 的做法

---
clicks: 4
transition: fade
---

# app 拿不到你登入的證據

<KeyWorld :frame="$clicks" />

<!--
逐格講稿（畫面上每格只有一句短的動作描述，以下由講者口頭說）：
[click 0] 你在 AD 登入了。照 OIDC 的做法，接下來要靠瀏覽器跳轉，把結果帶回 app。
[click 1] 可是檔案分享、SQL Server、遠端桌面這些連線，沒有跳轉可用；Kerberos 也設計成 app 不必回頭問 AD。你確實登入了 AD，但 app 拿不到你已登入的證據。
[click 2] 不靠跳轉：AD 在你登入時，發一張票。
[click 3] 由你自己帶著，夾在連線裡交給 app。
[click 4] app 沒理由相信一張來歷不明的票：誰都寫得出「我是 andy」。

這一章要讓大家感受到的第一個重點：你確實登入了 AD，但 app 拿不到證據。

講者可說：「很多連線沒有跳轉可用，Kerberos 也設計成 app 不必回頭問 AD，那證據要怎麼送到 app？」
-->

---
clicks: 5
transition: fade
---

# 共用一把對稱金鑰

<KeyWorld :frame="5 + $clicks" />

<!--
逐格講稿（畫面上每格只有一句短的動作描述，以下由講者口頭說）：
[click 0] 事前準備：app 先向 AD 註冊。這時還沒有任何人登入。
[click 1] AD 產生一把對稱金鑰，自己留一份——
[click 2] ——另一份交給 app。從此 AD 和 app 共用這把金鑰。
[click 3] 準備好之後，你才登入：AD 產出一張票。
[click 4] AD 用這把金鑰把票加密，交給你。你拿著一張自己解不開的票。
[click 5] app 解得開，而且內容沒被動過。這把金鑰只有 AD 和 app 有，不是 app 自己加密的——那就只能是 AD。

前三格是事前準備：app 先向 AD 註冊、拿到金鑰，這時還沒有人登入。第四格開始才是使用者的流程。

Kerberos 的加密會偵測竄改：內容被動過就解不開（RFC 4120 §3.2.3）。

最後一格要讓觀眾自己推出：這把金鑰只有 AD 和 app 有，app 知道不是自己加密的，那就只能是 AD。
-->

---
clicks: 3
transition: fade
---

# 加入 app2

<KeyWorld :frame="11 + $clicks" />

<!--
逐格講稿（畫面上每格只有一句短的動作描述，以下由講者口頭說）：
[click 0] 加入 app2，它也向 AD 註冊。最省事的做法：交給它同一把金鑰。
[click 1] 同一張票走遍所有 app——SSO 成立。
[click 2] 可是對稱金鑰能解密，也能加密：app2 用手上這把灰色金鑰，自己做了一張「我是 andy」。
[click 3] app 解開一看，完全分不出這不是 AD 做的。這張票誰做得出來？每一個拿到灰色金鑰的人。

最後一格才問「這張票誰做得出來？」——此時畫面已經讓它答得出來：每一個拿到灰色金鑰的人。
指著 app2 那一格：它手上有同一把對稱金鑰，所以它做得出來。

預備被問「寫 audience 不就好了？」：
寫「給誰」沒用，因為假票就是 app2 自己寫的，吊牌愛寫什麼就寫什麼。

若有人問「為什麼不用簽名」：這頁的前提就是 Kerberos 用對稱金鑰；和 OIDC 的對照見備用頁。

若有人問「app 手上的金鑰真的能拿來做票嗎？」——RFC 的依據：

1. 票的加密區只用「AD 與該服務共用的那把金鑰」加密，沒有別的祕密：
   RFC 4120 §5.3 (enc-part)："It is encrypted in the key shared by Kerberos and the end server
   (the server's secret key), using a key usage value of 2."
   RFC 4120 §1.7 (Ticket)："... all sealed using the server's secret key."
2. 實際加密與驗完整性用的子金鑰，是由這把金鑰加上公開常數推導出來的，拿到這把金鑰就推得出全部：
   RFC 3961 §5.3："Ke = DK(base-key, usage | 0xAA); Ki = DK(base-key, usage | 0x55);"
   （usage 是公開的 key usage 編號，票的加密區固定是 2。）
3. 所以持有這把金鑰的人，能自己產生一份「用同一把金鑰加密、完整性也驗得過」的加密區。
   RFC 沒有直接寫「可以偽造」這幾個字；這是從 1、2 推出來的結論。
   實務佐證：MITRE ATT&CK T1558.002 Silver Ticket："Adversaries who have the password hash of a target
   service account ... may forge Kerberos ticket granting service (TGS) tickets"。

若再追問「AD 不是在票裡有簽章嗎？」：
AD 放進票裡的 PAC 附有兩個簽章（MS-PAC §2.8 PAC_SIGNATURE_DATA）：
server signature 用服務自己的金鑰（持有者做得出來）；KDC signature 用 AD 自己的金鑰（app 沒有，要回頭請 DC 驗）。
在「app 不回頭問 AD」的前提下，app 只能驗前者，擋不住。
Microsoft："Services that are running as part of the Windows OS do not perform PAC validation."
（2022 年後的 PAC 簽章強化是否也在服務端強制，未找到官方明文，別講太滿。）
-->

---
clicks: 1
transition: fade
---

# 每個 app 一把金鑰

<KeyWorld :frame="15 + $clicks" />

<!--
逐格講稿（畫面上每格只有一句短的動作描述，以下由講者口頭說）：
[click 0] 每個 app 和 AD 各自共用一把專屬的對稱金鑰。
[click 1] app2 做不出、也解不開給 app 的票。app 解開藍票時，「是 AD 做的」重新成立。

分開金鑰不是為了切權限，而是為了讓票的內容可信。

若被問「那權限在哪設？」：Kerberos 只證明你是誰，並附上 AD 的群組資訊；能不能用，預設由 app 解開票之後看身分和群組自己決定。就像用個人 Google 帳號登入某個網站，Google 不替那個網站決定你能不能用。AD 也有在發票時就擋人的進階設定（Authentication Policy／Silo），本場不談。

講者備註：實務上一把金鑰屬於一個 AD 帳號，不是一個 app；
同一台 IIS 上的網站預設共用電腦帳號那把。不影響推導。
-->

---
clicks: 11
transition: fade
---

# 要進第二個 app

<KeyWorld :frame="17 + $clicks" />

<!--
逐格講稿（畫面上每格只有一句短的動作描述，以下由講者口頭說）：
[click 0] 你登入，AD 發給你一張給 app 的藍票。
[click 1] 藍票交給 app，app 解得開，登入成功。
[click 2] 現在想登入 app2：手上只有藍票，app2 的綠色金鑰解不開。
[click 3] 只好再向 AD 要一張：AD 要發票，得先確認你還是你，只能再問一次密碼。
[click 4] 拿到綠票。
[click 5] 痛點：每多一個 app，就要多輸一次密碼——SSO 消失。圖不動，讓這句話停一下。
[click 6] 於是 AD 在你登入時，多發一張給 AD 自己的票，用只有 AD 有的那把金鑰（金色）加密。吊牌寫「給 AD」：它就是 AD 把自己當成一個 app 的專用票。
[click 7] 要進 app 時，帶著金票去換票。
[click 8] AD 用自己的金鑰解開金票：你在有效期限內登入過。不用再問密碼，發出藍票。
[click 9] 藍票交給 app。
[click 10] 要進 app2 時，同一張金票再換一張綠票，一樣不用輸密碼。
[click 11] 綠票交給 app2。一張金票換出多張專用票 → SSO；每張專用票仍只有自己的 app 解得開 → 隔離。

痛點在 [click 3]（再輸一次密碼）發生，[click 5] 才用文字點明；換票要等痛點點明後才登場。

頓悟點：金票沒有引入新的機制，只是多一把金鑰，它就是「AD 把自己當成一個 app」的專用票。

若被問：RFC 的設計理由是不讓電腦長期持有由密碼推導的金鑰（RFC 4120 §2.3）。
但 Windows 實務上會在 LSASS 保留這把金鑰，好在 TGT 過期後自動重新取得；
這是便利換風險的取捨，Protected Users 群組就是把它關掉。
-->

---
layout: section
---

# 對上 Kerberos 的正式名詞

---
clicks: 9
transition: fade
---

# 同一張圖

<KeyWorld :frame="29 + $clicks" />

<!--
逐格講稿（畫面上每格只有一句短的動作描述，以下由講者口頭說）：
[click 0] 圖不動，只把名字貼上去。
[click 1] AD 那一整欄：KDC（Key Distribution Center）
[click 2] 輸入密碼、拿金票的那一關：AS（Authentication Server）
[click 3] 拿金票換專用票的那一關：TGS（Ticket-Granting Server）
[click 4] 金票：TGT（Ticket-Granting Ticket）
[click 5] 藍票、綠票：service ticket
[click 6] app、app2：Application Server
[click 7] 吊牌上的「給 app」：SPN（service principal name）
[click 8] app 手上的那把對稱金鑰：服務帳號的 secret key（Linux / Java 服務會把它存成 keytab 檔）
[click 9] 最後把兩個窗口和它發的票連起來：AS 發 TGT，TGS 拿 TGT 換出 service ticket。

圖和上一章最後一格完全一樣，每個 click 只換一個名字。

瀏覽器用 DNS 解析後的正式主機名稱組 SPN（會跟隨 CNAME）。
-->

---
layout: section
---

# 為什麼登入 Windows 就能直接進系統

<!--
這裡切到現場 demo：klist 沒有票 → 登入 → klist 出現票。
demo 前先 klist purge。加入網域的電腦通常不只兩張票，講「其中這兩張」。

指著 krbtgt/... 那張：這是金票（TGT）。krbtgt 出現時只說一句：krbtgt 就是 AD 自己。
指著 HTTP/... 那張：這是藍票（service ticket）。

第一章輸入帳密，是讓電腦用它向 AD 證明身分、換到 TGT（密碼本身不上網），而 TGT 會在電腦上存一段時間。

還是得在 401 視窗輸入一次帳密——連這一步都不要呢？
-->

---
clicks: 4
---

# 連 401 都不用

<div class="mt-10">
<Logon :step="$clicks" />
</div>

<!--
[click] 電腦加入網域後，用 AD 帳號登入 Windows。

[click] 登入 Windows 的同時，就拿到金票。

[click] 所以 401 那一步不會出現。

[click] 其餘照舊：拿金票換藍票，進 app。

講者備註：瀏覽器只對被信任為內部網路的網站自動送票（Windows 的「近端內部網路」區域，
或 Chrome／Edge 的 AuthServerAllowlist 原則）。帶點的主機名稱預設不在內部網路區域。
-->

---
layout: center
---

# 總結

<div class="mt-8 text-left mx-auto leading-loose" style="max-width: 680px">

<v-clicks>

- 登入 Windows 時，電腦拿到一張能換票的票（TGT）
- 之後要進哪個 app，都拿它去 AD 換一張只有那個 app 解得開的票
- 所以不用再輸入密碼——這就是 AD and Kerberos SSO

</v-clicks>

</div>

---
layout: center
---

# 備用：為什麼 OIDC 不用每個 app 一把金鑰？

<div class="mt-6 text-left mx-auto leading-relaxed text-sm" style="max-width: 720px">

- OIDC 通常用非對稱簽章（預設 RS256）：驗章用的公鑰不能拿來蓋章，所有 app 共用同一組公鑰也做不出假票；「給誰」另外靠 `aud` 檢查，擋住別的 app 把真票轉送過來。
- 反過來說，OIDC 若改用 HS256（對稱），金鑰就是每個 app 自己的 client_secret——同樣是一個 app 一把，正好印證第二章。
- Kerberos 是以對稱加密設計的；後來的 PKINIT 只把初次登入換成公鑰，票本身仍用對稱金鑰加密。

</div>

<!--
「當年公鑰運算昂貴」屬史實說法，只口頭講，不上畫面。
-->

---
layout: center
---

# 備用：偷到金鑰會怎樣？

<div class="mt-6 text-left mx-auto leading-relaxed text-sm" style="max-width: 720px">

- 偷到某個服務帳號的金鑰：能偽造進這個服務的票，身分與群組任你寫（Silver Ticket；Windows 內建服務不向 DC 做 PAC 驗證）。
- 服務帳號密碼若是人設且偏弱：任何持票者都能拿票離線破解出這把金鑰（Kerberoasting）；RFC 4120 建議服務金鑰隨機產生。
- 偷到 AD 加密金票的那把金鑰：能偽造金票，再拿去換任何服務的票（Golden Ticket）。

</div>

<!--
這三題正好驗證「誰手上有哪把金鑰」的推導。
-->

---

# 參考資料

<div class="text-sm leading-loose">

- [RFC 4120 — The Kerberos Network Authentication Service (V5)](https://www.rfc-editor.org/rfc/rfc4120)
- [RFC 3961 — Encryption and Checksum Specifications for Kerberos 5](https://www.rfc-editor.org/rfc/rfc3961)
- [RFC 4556 — Public Key Cryptography for Initial Authentication in Kerberos (PKINIT)](https://www.rfc-editor.org/rfc/rfc4556)
- [OpenID Connect Core 1.0 incorporating errata set 2](https://openid.net/specs/openid-connect-core-1_0.html)
- [Kerberos authentication overview in Windows Server](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview)
- [Protected Users Security Group in Windows Server](https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group)
- [\[MS-PAC\]: PAC_SIGNATURE_DATA](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-pac/6e95edd3-af93-41d4-8303-6c7955297315)
- [Steal or Forge Kerberos Tickets: Silver Ticket, Sub-technique T1558.002](https://attack.mitre.org/techniques/T1558/002/)
- [Understanding Microsoft Kerberos PAC Validation](https://learn.microsoft.com/en-us/archive/blogs/openspecification/understanding-microsoft-kerberos-pac-validation)
- [HTTP authentication](https://www.chromium.org/developers/design-documents/http-authentication/)

</div>
