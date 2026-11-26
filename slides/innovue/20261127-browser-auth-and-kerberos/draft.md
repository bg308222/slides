# Browser authentication & Kerberos

> 主線：瀏覽器透過 `Negotiate`，呼叫 OS 完成整套 Kerberos。NTLM 移到附錄；不講 SPNEGO 的協商機制。

## 這場分享要讓聽眾經驗什麼

- **目標觀眾與他們已知的起點**：
  - 聽過上週〈AD and Kerberos SSO〉：知道 TGT、service ticket（ST）、SPN、keytab，知道「有 TGT 就能換到 app 解得開的 ST」，也看過 `klist`。
  - 上週第一章 demo 看過瀏覽器跳出 401 帳密框，但沒解釋它從哪來。
  - 日常寫 API，天天在送 `Authorization: Bearer <jwt>`，但多半不知道它屬於 HTTP 的一套驗證格式。
  - 聽過 PBKDF2 分享，知道「資料庫裡的 hash 如果能直接拿來登入，就等於密碼」。
- **最後應能自行說出的結論**：
  - 「server 只回一個 `401` 加 `WWW-Authenticate: Negotiate`；瀏覽器就會請電腦的 OS 證明你是誰，OS 用電腦上的票換到 server 解得開的 ST，整個過程不用把密碼交給 server。」
  - （附錄）Kerberos 用不了的時候，OS 會改用 NTLM：server 自己驗不了、每次都要問 AD，而且它用的那個值拿到就能登入。
- **刻意不講的邊界**：
  - Kerberos 內部細節：上週已講。AD 欄只留兩個窗口（驗密碼、發 TGT；拿 TGT 換 ST），不再展開。
  - 瀏覽器何時自動送身分（信任範圍、允許清單）、各平台差異：不提。第三章只展示「瀏覽器透過 OS 取票」。
  - token 的實際內容與編碼（base64 值、開頭字元、訊息欄位、OID）。第三章只講流程的邏輯，不比對 Kerberos 與 NTLM 的 token。
  - GSS-API 介面名稱（SSPI／GSSAPI／LSASS 只出現在講者備註）。
  - NTLM 的 v1／v2 差異、HMAC-MD5 計算細節、session security。
  - NTLM relay 的緩解措施（EPA、signing）：未查證，不講。
  - delegation、跨網域信任。
  - Firefox、Safari 的行為：只查證了 Chrome／Edge。

## 推導主線

### 開場：先回顧上週的 Kerberos

- **畫面**：只有 user、AD、app 三個角色。AD 欄是上週的兩個窗口：「驗密碼，發 TGT」「拿 TGT 換 ST」，之後每一頁都保留。
- **小步**：登入 Windows → 拿到 TGT → 拿 TGT 換 ST → ST 交給 app。
- **留下的下一題（痛點）**：Kerberos 的流程懂了，但我們自己寫的 app（網站）要怎麼接上？我們的 app 有辦法直接碰到整個 Kerberos 流程嗎？→ 接到第一章最直觀的做法：全部交給 server 自己做。

### 第一章：最直觀的做法——server 自己拿帳密去換票

- **已知**：server 需要一張它自己解得開的 ST。
- **小步（直觀做法）**：網頁放一個登入表單。使用者輸入帳密 → server 拿去向 AD 換 TGT → 再用 TGT 換一張給自己的 ST → 用自己的金鑰解開，確認身分。這是照著 Kerberos 走的，真的有人這樣做（Apache mod_auth_kerb 的密碼模式）。
- **痛點 1**：密碼進到 server 了。上週 Kerberos 的出發點，就是不讓每個 app 看到密碼。
- **痛點 2**：TGT 留在 server 手上，沒有留在你的電腦（OS）；下次、或換一個網站，又要重新登入，SSO 不成立。
- **兩個痛點在同一格一起寫出來。**這裡不假設你的電腦上已經有 TGT。
- **留下的下一題**：那能不能不經過 server 登入？→ 答案是有：瀏覽器本來就支援（第二章）。

### 第二章：瀏覽器本來就會幫忙登入——401 與 WWW-Authenticate

這一章的目的不是教 HTTP 驗證的知識，而是用兩個簡單、熟悉的例子，讓聽眾相信「server 回一個 header，瀏覽器就會幫忙」這件事存在，再帶到複雜的 Negotiate。

- **已知**：server 想請瀏覽器幫忙證明身分。
- **小步**：HTTP 內建一套「server 出題、client 作答」的格式：server 回 `401` 加 `WWW-Authenticate: <方式>`；client 重送請求，帶上 `Authorization: <方式> <資料>`。
- **例一 `Basic`：瀏覽器直接跳框幫你登入**。server 只回了一個 header，瀏覽器就自己跳出帳密框、送出、之後自動帶上。上週 demo 看到的那個框就是這樣來的（框的來源見 3-3）。
- **例二 `Bearer`：你們每天都在用的那一半**。`Authorization: Bearer <jwt>` 不是隨便取的 header，它就是這套格式的作答那一半；對應的出題是 `WWW-Authenticate: Bearer`。差別在於這一半一直是你們的前端程式自己在送，瀏覽器不插手。
- **新的可見狀態**：同一套「出題→作答」格式，`<方式>` 寫什麼，決定由誰、用什麼作答。
- **例三 `Negotiate`（帶到第三章）**：server 出題 `WWW-Authenticate: Negotiate`，瀏覽器會作答——而且它作答的方式是**去問自己電腦的 OS**。
- **留下的下一題**：瀏覽器收到 Negotiate 之後，到底跑了什麼流程？

### 第三章：Negotiate 跑了什麼流程

這一章最重要的是展示：**瀏覽器透過呼叫 OS 取票，就完成了整套 Kerberos。**不提信任範圍，不看 token 內容，不比對 Kerberos 與 NTLM。

- **小步 1（瀏覽器把題目交給 OS）**：server 回 `401 Negotiate`；瀏覽器用網址組出 SPN `HTTP/<主機名>`，請 OS「幫我向這個網站證明我是誰」。瀏覽器本身不碰票。
- **小步 2（OS 怎麼拿到 ST，三種情況）**：
  - OS 已有 ST → 直接用，不找 AD；
  - 沒有 ST，但有 TGT → 拿 TGT 去 AD 換 ST；
  - 都沒有 → 瀏覽器跳框，帳密交給 OS，OS 向 AD 換到 TGT，再換 ST。
- **小步 3（送出與驗證）**：OS 把 ST 交回瀏覽器，放進 `Authorization: Negotiate …` 送出；server 用自己的金鑰解開，不必問 AD。
- **新的可見狀態**：對照第一章：TGT 留在你的電腦，密碼沒有交給 server，越過網路的只有 ST。瀏覽器只是呼叫 OS，整套 Kerberos 都由 OS 完成。
- **留下的下一題**：Kerberos 換不到 ST 的時候呢？

### 附錄：Kerberos 用不了時的備案——NTLM（放在備用問答之後、參考資料之前）

- **已知**：OS 優先走 Kerberos；Kerberos 要靠正確的 SPN 換 ST。
- **觸發（demo）**：同一個網站改用 **IP** 連線。SPN 變成 `HTTP/10.0.0.5`，AD 沒有這張 ST 可換——但**還是沒跳框就登入了**。`klist` 沒有多出任何票；DevTools 裡這次出現兩次 401。
- **痛點**：沒有 ST，那它拿什麼證明你是你？
- **小步 0**：Kerberos 換不到時，OS 改用另一種方式：NTLM。（不講 SPNEGO 的協商機制。）
- **小步 1（挑戰與回應）**：server 出一個隨機數；你的電腦用「由密碼算出的值」對它做運算，把結果回傳。密碼本身不上網。（所以要多一次 401：先說要用 NTLM、server 再出題。）
- **痛點**：server 手上沒有那個值，驗不了。
- **小步 2（server 轉問 AD）**：server 把「誰、隨機數、回應」轉給 AD；AD 算一次、回答對不對。對照 Kerberos：server 用自己的金鑰就能解 ST，不必問 AD；NTLM 則每次登入都要問。
- **小步 3（那個值是什麼）**：那個值叫 **NT hash**＝密碼做一次 MD4，不加鹽。Windows 登入後把它留在記憶體裡，所以不用再打密碼（這就是 NTLM 的 SSO）。**痛點**：算回應只需要這個值，不需要原本的密碼——拿到它就能登入。這正是 PBKDF2 那場講過的「hash 等於密碼」。
- **小步 4（server 不用證明自己）**：Kerberos 的 server 可以回一份資料證明自己是真的；NTLM 沒有這一步。站在中間的人可以把你的回應轉給另一台 server，用你的身分登入。
- **收尾**：Microsoft 2024 年宣布 NTLM 進入 deprecated（仍可使用，但不再開發），NTLMv1 已在 Windows 11 24H2／Server 2025 移除。Negotiate 的設計就是「先試 Kerberos，必要時才退回 NTLM」。
- **全貌**：一張圖收齊：server 回 `401 Negotiate` → 瀏覽器 → OS → 換得到 ST 走 Kerberos（server 自己驗）／換不到走 NTLM（server 問 AD）→ `Authorization: Negotiate …` → server。

## 逐頁／逐揭露設計

### 0-1 先回顧上週的 Kerberos

- **畫面**：user｜AD｜app 三欄，user 欄不分瀏覽器／OS 兩層。AD 欄是兩個窗口：「驗密碼，發 TGT」「拿 TGT 換 ST」（全場固定）。第一章起 user 欄才改名「你的電腦」並分出兩層。
- **click 序列**：
  1. 用 AD 帳號登入 Windows。
  2. 向「驗密碼」窗口證明身分，拿到 TGT。
  3. 拿 TGT 去「換票」窗口換 ST。
  4. ST 交給 app → ✓。
  5. 痛點：「Kerberos 懂了，但我們的 app 碰得到這整個流程嗎？」app 欄出現「我們的 app 怎麼接上？」

### 1-1 server 自己拿帳密去換票

- **畫面**：你的電腦（上層瀏覽器、下層 OS）｜AD｜app。瀏覽器層是網頁的登入表單；OS 層一開始沒有 TGT。
- **click 序列**：
  1. 使用者在表單輸入帳密。
  2. 帳密（紅色、沒有鎖頭＝明文）從 user 欄送到 app 欄。
  3. app 拿帳密去 AD，換回一張 TGT，出現在 **app 欄**。
  4. app 用這張 TGT 換到自己的 ST，用自己的金鑰解開 → ✓。
  5. 圖不動，兩個痛點一起寫出來：「密碼進到 server 了；TGT 也沒留在你的電腦，下次又要重登」（紅色帳密與 server 的 TGT 加粗，你的電腦 OS 層出現虛線的「沒有 TGT」）。
  6. 問題：「那能不能不經過 server 登入？」
- **講者備註**（被問「最後換 ST 那步是不是多餘」時）：只換到 TGT 就算登入成功的話，攻擊者可以假冒 AD 回應（mod_auth_kerb 稱為 KDC spoofing）；假 AD 不知道 server 的金鑰，做不出 server 解得開的 ST。server 驗身分靠的永遠是「我解得開這張 ST」。

### 2-1 server 出題、client 作答

- **畫面**：user（瀏覽器）與 app 兩欄，中間是時間往下走的請求序列。AD 欄保留位置、淡化。
- **click 序列**：
  1. 瀏覽器 `GET /`。
  2. app 回 `401` ＋ `WWW-Authenticate: <方式>`。
  3. 瀏覽器重送，帶 `Authorization: <方式> <資料>`。
  4. app 回 `200`。
- **講者要說的話**：「server 出題，client 作答。`<方式>` 換成不同的字，會有不同的人來作答。」

### 2-2 Basic：瀏覽器跳框幫你登入

- **click 序列**（箭頭一條一條出現）：
  1. `GET /report`。
  2. 401 箭頭出現時就直接是 `WWW-Authenticate: Basic`（不是從 `<方式>` 換字）。
  3. 頁面上方跳出仿瀏覽器原生樣式的帳密 dialog（白底、藍色「登入」按鈕，刻意和投影片深色風格不同）。
  4. dialog 裡填上帳密。
  5. dialog 關掉，`Authorization: Basic base64(andy:P@ssw0rd)` 的箭頭才出現。
  6. `200 OK`。
  7. 點明：「跳框、送出、記住，全是瀏覽器自己做的。」
- **講者要說的話**：「上週 demo 那個框，就是瀏覽器在作答。」
- **講者備註**：base64 不是加密；同一個 realm 之後會自動帶上（RFC 7617、RFC 9110 §11.5）。被問再講。

### 2-3 Bearer：你們每天在送的那一半

- **初始畫面**：只有大家熟悉的那一行 `Authorization: Bearer eyJhbGciOi…`，沒有任何箭頭。
- **click 序列**：
  1. 平常的樣子：前端程式一開始就帶著它，`GET /report ＋ Authorization: Bearer …` → `200 OK`。點明：「所以從來沒看過 401」。左欄改名「你的前端程式」。
  2. 箭頭換成 HTTP 的約定：`GET /report` → `401 WWW-Authenticate: Bearer`。
  3. `Authorization: Bearer eyJhbGciOi…`：「你們送的那一行，其實是作答」。
  4. `200 OK`。
  5. 點明：「同一套一問一答，只是你們的前端程式一開始就先帶著答案。」
- **講者備註**：RFC 6750 §3 的出題可以帶錯誤原因，例如 `WWW-Authenticate: Bearer error="invalid_token"`。

### 2-4 Negotiate：瀏覽器去問 OS

- **click 序列**（箭頭一條一條出現，和 2-2、2-3 同一種表達方式）：
  1. `GET /report`。
  2. 401 箭頭出現時就直接是 `WWW-Authenticate: Negotiate`。
  3. 瀏覽器往下問 OS：「幫我證明我是誰」。
  4. `Authorization: Negotiate …`：「瀏覽器把 OS 給的答案送出」。
  5. `200 OK`。
  6. 點明：「作答的還是瀏覽器，只是它去問 OS。」

### 3-1 瀏覽器把題目交給 OS

- **click 序列**：
  1. 收到 `401 WWW-Authenticate: Negotiate`。
  2. 瀏覽器組出 SPN `HTTP/app.corp.local`，往下請 OS：「幫我向這個網站證明我是誰」。

### 3-2 OS 怎麼拿到 ST（demo 為主）

- **畫面**：OS 層旁邊放一個 `klist` 視窗。
- **click 序列**：
  1. 情況一：`klist` 已有 `HTTP/app.corp.local` → 直接用，AD 欄不動。
  2. 換一種情況：`klist` 只有 `krbtgt/…`。
  3. OS 拿 TGT 去「換票」窗口換 ST → `klist` 多出 `HTTP/…`。
  4. 再換一種情況：`klist` 全空。
  5. 瀏覽器跳出帳密框。
  6. 帳密往下交給 OS，OS 向「驗密碼」窗口換到 TGT。
  7. 再拿 TGT 換 ST。
- **demo**：`klist purge` → 重新整理 → `klist` 同時出現 `krbtgt/…` 與 `HTTP/…`。
- **講者要說的話**（回收上週 demo 的框）：「上週那個框，就是情況三；你打的帳密沒有交給 server，是交給 OS 去換票。」

### 3-3 送出與驗證

- **click 序列**：
  1. OS 把 ST 交回瀏覽器。
  2. `Authorization: Negotiate …` 送給 server。
  3. server 用自己的金鑰解開 → ✓，AD 欄標「不必問 AD」。
  4. 重點：「越過網路邊界的，只有 ST。」
  5. 重點：「瀏覽器只是呼叫 OS，整套 Kerberos 都由 OS 完成。」

### 4-1 沒有 ST，也登入了

- **click 序列**：
  1. 網址換成 `http://10.0.0.5/`；SPN 變成 `HTTP/10.0.0.5`。
  2. OS 拿 TGT 去換 ST → 「換票」窗口打 ✕：AD 沒有這個 SPN。
  3. 現場 demo：沒跳框，仍然登入成功。
  4. `klist` 沒有新票；DevTools 出現兩次 401。
  5. 痛點：「沒有 ST，那它拿什麼證明你是你？」
  6. 重點：「Kerberos 換不到時，OS 改用另一種方式：NTLM」。

### 4-2 挑戰與回應

- **畫面**：user｜AD｜app 三欄；user 欄 OS 層多一個紫色的「由密碼算出的值」（先不命名）。
- **click 序列**：
  1. 瀏覽器：「我要用 NTLM」（第一個 `Authorization`）。
  2. app 回 `401` ＋ 一個隨機數（白色）。
  3. OS 用紫色的值對隨機數做運算，得出回應。
  4. 瀏覽器送出「我是 andy」＋回應（第二個 `Authorization`）。
  5. app 那一格：手上沒有紫色的值 →「？」。點明痛點：「server 驗不了。」

### 4-3 server 轉問 AD

- **click 序列**：
  1. app → AD：「andy、這個隨機數、這個回應」。
  2. AD（有紫色的值）算一次 → 回 ✓。
  3. app → 瀏覽器 `200`。
  4. 與 3-3 並排：Kerberos 的 app 與 AD 之間沒有線；NTLM 每次登入都有一條。
- **聽眾此刻應看出的事**：「server 自己驗不了，每次都要問 AD。」

### 4-4 那個值是什麼

- **click 序列**：
  1. 紫色的值貼上名字：**NT hash**＝MD4(密碼)，不加鹽。
  2. 它住在 OS 層的記憶體裡：「所以 4-1 不用打密碼」。
  3. 點明痛點：「算回應只需要它，不需要原本的密碼——拿到它就能登入。」
  4. 帶回 PBKDF2 那場的一句話：「資料庫裡這個值也能直接通過登入。」

### 4-5 server 不用證明自己

- **click 序列**：
  1. Kerberos：app 可以在 `200` 裡回一份「我是真的」。
  2. NTLM：沒有這一份。
  3. 中間插入一個假 server：把你的回應原封不動轉給另一台真的 server → 以 andy 的身分登入。
  4. 點明：「你從來不知道對面是誰。」

### 4-6 收尾與全貌

- **click 序列**：
  1. Microsoft 現況：NTLM 2024 年 deprecated（仍可用）；NTLMv1 已移除。
  2. 全貌圖：`401 Negotiate` → 瀏覽器 → OS → 分岔：換得到 ST（Kerberos，server 自己驗）／換不到（NTLM，server 問 AD）→ `Authorization: Negotiate …` → server。
  3. 結論句：「兩條路都不必把密碼交給 server；能走 Kerberos 就走 Kerberos。」

### 回顧（第三章之後）

- **畫面**：三點，各佔一個 click 依序出現：
  1. 由 server 完成 Kerberos 可行，但 AD 密碼沒必要流過 server。（第一章）
  2. 瀏覽器本身就有幫 server 完成登入的機制：`WWW-Authenticate` ＋ `Authorization`。（第二章）
  3. scheme ＝ `Negotiate` 時，瀏覽器能幫你完成 Kerberos。（第三章）
- **之後的頁序**：回顧 → 參考資料 → 備用：可能被問的 → 附錄 NTLM。報告時預期停在參考資料。

## 視覺語意與節奏

- **物件狀態如何一致標示**（沿用上週，新增的標 ★）：
  - 金 ＝ TGT；藍 ＝ app 的 ST 與 app 的金鑰；鎖頭顏色 ＝ 能解開它的金鑰。
  - ★ 紅色、無鎖頭 ＝ 明文密碼。出現在哪一欄 ＝ 誰看到了密碼。
  - ★ 紫色 ＝ NT hash（第四章才出現，4-4 前不命名）。
  - ★ 白色 ＝ server 出的隨機數。
  - ★ user 欄分兩層：上層瀏覽器、下層 OS。票與 NT hash 永遠只放在 OS 層。
  - ★ user 欄與右側之間的虛線 ＝ 網路邊界。物件越過它的那一刻，就是「送上網路了」。
  - ★ AD 欄固定兩個窗口：「驗密碼，發 TGT」「拿 TGT 換 ST」；TGT 從前者出來，ST 從後者出來。NTLM 的「由密碼算出的值」放在兩個窗口下方。
  - ★ `Authorization: Negotiate …` 的資料一律畫成「…」，全場不展開 token 內容。
  - 淡化 ＝ 存在但不在討論焦點（1-1 的 TGT、2-1 的 AD 欄）。
- **哪些位置必須固定或預留**：
  - user｜AD｜app 三欄位置與上週相同，全場固定。
  - 2-4 起 user 欄分兩層；1-1 就預留上下兩層的高度，避免 2-4 推動既有物件。
  - 第二章的 `<方式>` 是同一個位置，2-2／2-3／2-4 只換字。
- **哪些資訊必須延後命名**：
  - SPNEGO：全場不講協商機制，也不貼這個名字。
  - NTLM：3-2 的清單上出現這個詞但不解釋；4-1 才展開。
  - NT hash：4-4。
  - SSPI、GSSAPI、LSASS：只放講者備註。
- **哪裡才揭露完整全貌**：4-6。在那之前，Kerberos 與 NTLM 的分岔不同時出現在同一張圖上。

## 技術限定與待查證事項

完整原文引用見同資料夾 `knowledge.md`（✅／🟡／⚠️ 標記與該檔一致）。

- **已確認的前提與來源**：
  - 401 ＋ `WWW-Authenticate`／`Authorization` 框架、可同時給多個 challenge、client 挑最安全的：RFC 9110 §11.3、§11.4、§11.6.1。
  - Basic 是 base64 帳密、同 realm 自動重送：RFC 7617 §2、§2.2；RFC 9110 §11.5。
  - `Authorization: Bearer` 與 `WWW-Authenticate: Bearer` 是同一個 scheme 的一問一答：RFC 6750 §2.1、§3（「All challenges defined by this specification MUST use the auth-scheme value "Bearer"」）。
  - Negotiate：第一次 401 不帶資料、client 送 GSS token、成功回應可帶最後一段資料：RFC 4559 §4.1、§4.2。
  - server 收到的是 ST＋authenticator，用自己的金鑰解：RFC 4120 §3.2.2、§3.2.3。
  - 用 IP 連線時 Windows 不試 Kerberos、退回 NTLM：Microsoft Learn〈Kerberos over IP〉。
  - Negotiate 除非條件不符，否則選 Kerberos：Microsoft Learn〈Microsoft Negotiate〉。
  - LSASS 保存 TGT、service ticket、NT hash，讓使用者不必重打帳密：Microsoft Learn〈Credentials processes in Windows authentication〉。
  - NT hash ＝ MD4(UNICODE(密碼))；三則訊息：MS-NLMP §3.3.1、§2.2.1；NTLM over HTTP 的兩次 401：MS-NTHT §4.1。
  - NTLM server 透過 Netlogon 請 DC 驗證：MS-NLMP §1.3.1.1、MS-APDS §1.4.1。
  - NTLM 沒有 mutual authentication：MS-NTHT §5.1。
  - KDC spoofing 與「再換一張自己的 ST」：RFC 4120 §3.1.5、§10；mod_auth_kerb 文件。
  - NTLM deprecated（2024-06）、NTLMv1 移除：Microsoft Learn〈Deprecated features〉、〈Removed features〉。
- **為教學而合併／省略的細節**：
  - Kerberos 細節只保留兩個窗口；server 收到的 ST 實際上還附一份 authenticator，不提。
  - 瀏覽器何時自動送身分（信任範圍、允許清單、mac／Linux 不跳框）全部不提；查證內容留在 `knowledge.md` §2.5、§3.5，被問再答。
  - 不講 SPNEGO 的協商機制：`Negotiate` 底下實際是 SPNEGO（RFC 4178）在協商 Kerberos 或 NTLM；查證內容留在 `knowledge.md` §3，被問再答。
  - token 一律畫成「…」：不講 base64 內容、開頭字元，也不講 Windows 在某些情況下會直接送不帶 SPNEGO 外層的 NTLM token。
  - 4-2 的「運算」不展開 NTLMv2 公式（HMAC-MD5、client challenge、時間戳）。
  - 4-5 的 relay 只畫概念，不談緩解措施。
- **尚待作者確認或查證的主張**：
  - ⚠️ 4-1 的 IP demo 在你的環境是否真的不跳框、出現兩次 401：demo 實測。
  - 🟡 3-3 情況 C「跳框拿到的帳密用來向 AD 換 TGT」：由 Microsoft 文件推得；非網域 Windows 能否找到 AD 未查到原文。
  - ⚠️ Intranet 區域的自動判定規則、`AuthServerAllowlist` 的萬用字元規則：demo 前實測。
- **demo 準備清單**：
  1. 2-2：一個回 `WWW-Authenticate: Basic` 的小 server。
  2. 3-3：網域 Windows ＋ Edge 連 IIS（Windows 驗證），網址需在近端內部網路區域或允許清單；`klist purge` 後重新整理。
  3. 4-1：同一台改用 IP 連線，開 DevTools 看兩次 401。

## Q&A 備用

- **跳過 Negotiate 時，瀏覽器會再去問 server 有沒有別的方式嗎？** 不會。只看同一個 401 回應裡的其他 `WWW-Authenticate`；server 只給 `Negotiate` 就直接顯示 401 頁面。
- **怎麼知道這次走的是 Kerberos 還是 NTLM？** `klist` 有沒有多出 `HTTP/…` 那張票；或看 DevTools 是一次 401 還是兩次。
- **NTLM 為什麼要兩次 401？** 回應要對 server 出的隨機數做運算，所以 client 先表明要用 NTLM、server 再出題，多一來一回。實務上三則訊息要在同一條連線上完成，前面有不保持連線的 proxy／負載平衡器就會一直 401（規格未明寫，屬實務經驗）。
- **加入 Protected Users 群組會怎樣？** 該帳號不能用 NTLM 向 DC 驗證；Windows 也不再保存 NT hash 與長期金鑰，TGT 限 4 小時、不可續期。

## 交接給 draft-to-deck

- **不可破壞的推導順序**：
  - 第一章的兩個痛點（密碼進 server、電腦上的 TGT 用不到）必須先發生，第二章才有理由請瀏覽器代勞。
  - 第二章 Basic → Bearer → Negotiate：兩個簡單熟悉的例子先建立「瀏覽器會幫忙」，再帶到複雜的 Negotiate。第二章不講各方式的優缺點。
  - 第三章依流程順序：瀏覽器把題目交給 OS → OS 拿 ST（三種情況）→ 送出與驗證。不提信任範圍，不展開 token 內容，不比對 Kerberos 與 NTLM。不講 SPNEGO 的協商機制。
  - 4-1 必須先讓「沒跳框也登入了」發生，才問「拿什麼證明你」。
- **每頁最重要的可見事件**：
  - 0-1：上週的流程走一遍，停在「我們的 app 怎麼接上？」
  - 1-1：紅色密碼越過網路邊界進到 app 欄；TGT 出現在 app 欄。
  - 1-1 最後：你的電腦 OS 層是虛線的「沒有 TGT」，接著問「能不能不經過 server 登入？」
  - 2-2：瀏覽器自己跳框。
  - 2-3：`Authorization: Bearer` 落進「作答」那一格，配上 `WWW-Authenticate: Bearer`。
  - 2-4：瀏覽器往下問 OS。
  - 3-2：OS 列清單、server 挑。
  - 3-3：`klist` 的三種狀態。
  - 3-3：越過網路邊界的只有 ST；整套 Kerberos 都由 OS 完成。
  - 4-1：沒有 ST 也登入了。
  - 4-3：app 與 AD 之間每次都有一條線。
  - 4-4：紫色的值貼上 NT hash，並接回 PBKDF2。
- **不能被濃縮成 bullet 的段落**：1-1、3-1 到 3-3、4-1 到 4-4。
