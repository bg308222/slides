# Better Auth Passkey：把 Passkey 接到既有 App，而不搬走使用者

## 這場分享要讓聽眾經驗什麼

- **目標觀眾與他們已知的起點**：寫過 web app、知道 session / cookie / JWT 大致怎麼運作的工程師。8/21 已聽過 OAuth2 + PKCE 那場，因此「提到 OIDC」時，他們知道那條流程的產出是一個 `id_token`，不需要重講。對 Better Auth 本身可以假設**完全沒接觸過**。
  **關鍵起點**：他們也已經看過公司內 webpatx 與 ecsten 的 passkey 實作（一個用 Better Auth，一個不是；但兩者都把整個 passkey 實作放在 app 身體裡）。P9 因此只需要**一句話**提到它們，聽眾自己就有畫面，不需要任何佐證或動畫。
- **最後應能自行說出的結論**：
  - 使用者資料留在 app、passkey 留在 auth server，兩邊靠**註冊時建立的那一列 mapping** 連起來。
  - 登入時 auth server 只負責「認人」，認完的結果要走 OIDC 這條標準管道送回 app，**app 自己再簽一次 session**。
  - 這樣拆的價值是：app 新增的東西裡沒有一樣是 Better Auth 專屬的；下一個產品要接 passkey 時，不必在那個產品裡再長一整套。
- **刻意不講的邊界**：
  - OAuth2 / OIDC / PKCE 的流程細節（上一場已講）。
  - WebAuthn 的 RP ID / origin 規則。導頁的理由只講「app 不必引入 auth 依賴」。
  - consent 頁（demo client 設 `skipConsent: true`，一般 `openid` 登入不會出現）。
  - path prefix、reverse proxy 契約、多副本與 secret 輪替。
  - Better Auth 的其他 plugin（social provider、2FA、organization 等）。

## 全場判讀尺

- **核心問題**：**「此刻，『這是誰』這個判斷握在哪一格手上？」**
- **為何它能跨每一段檢查狀態**：這條線上每一段都在換答案，且每次都換得看得見——
  - P4：只有 auth server（它就是全部）
  - P5：使用者的真身搬到 app，auth server 還不認識他
  - P6：auth server **借** app 的簽章，第一次認得這個人
  - P7：auth server 已經能自己認人了，但這個判斷**卡在它那一格出不去**
  - P8：OIDC 把這個判斷送過邊界，app 收下後自己發 session

---

## 推導主線

### 第一段（P1–P3）：Better Auth 不是 server
- **已知／畫面起點**：聽眾看過各種 auth library / auth 服務。
- **痛點**：官方自稱是 framework，但你 `bun add` 之後手上什麼都跑不起來——它連一個能被打到的 endpoint 都沒有。
- **小步**：拆成 server lib / client lib；server lib 再拆成 db migration 與 instance；最後用官方 adapter 把 instance 掛到 web framework 上。
- **新的可見狀態**：一個由**你自己的 server** 框住的 db + instance + endpoints，此刻才把它命名為 auth server。
- **留下的下一題**：server 好了，那 client lib 拿它能做到什麼程度？

### 第二段（P4）：它自己就是一套完整的使用者管理系統
- **已知／畫面起點**：auth server 已就緒，右邊接上 client。
- **痛點**：（這一段刻意不製造痛點，它是後面所有取捨的**對照組**。）
- **小步**：四個官方動作各跑一次，每次都在 db 留下可見痕跡。
- **新的可見狀態**：一格之內同時有 user、session、passkey，且 passkey 那條登入路徑**完全不需要密碼**。
- **留下的下一題**：可是我的 app 早就有自己的使用者了，我不打算把他們搬過來。

### 第三段（P5）：把使用者搬回 app，auth server 的能力就懸空了
- **已知／畫面起點**：滿版的 auth server，裡面有 Alice。
- **痛點**：真實情境裡「使用者」的定義權在 app，不在 auth server。
- **小步**：畫面一分為二；Alice 移到 app server；把剛演過的帳密那條路當場關掉。
- **新的可見狀態**：auth server 仍握有 passkey 的全部能力，但 passkey 那條關聯線**懸空、連不到任何人**。
- **留下的下一題**：auth server 要怎麼認得「app 的 Alice」？

### 第四段（P6）：借 app 的簽章，建立第一條關聯
- **已知／畫面起點**：兩格並列，能力在左、使用者在右。
- **痛點**：auth server 沒有任何辦法自己認得 Alice——它已經沒有帳密了。
- **小步**：讓 app 用私鑰簽一個 JWT 放進 cookie；使用者導頁到 auth server 的 enroll 頁，cookie 隨之送達；auth server 用**設定給它的公鑰**驗簽，取出 `app_user_id`，建一個沒有密碼的 auth_user，寫下 mapping，再把 passkey 綁上去。
- **新的可見狀態**：mapping 表第一次出現一列；懸空的 passkey 關聯接上了。
- **留下的下一題**：她有 passkey 了，那登入會怎樣？

### 第五段（P7）：認人成功了，但結果出不了那一格
- **已知／畫面起點**：兩格都有東西，關聯已建立。
- **痛點**：`signIn.passkey()` 成功後，唯一多出來的是**左邊那格的一個 session**；右邊的 app server 完全沒有任何變化，它不知道剛才發生過任何事。而且那個 session 只活 60 秒、不 refresh——它根本不打算當登入狀態。
- **小步**：（這一頁不解決問題，它只是把痛點釘死。）
- **新的可見狀態**：一條明確的邊界，判斷在左邊，需要它的人在右邊。
- **留下的下一題**：怎麼把「auth server 已確認這是誰」安全地送過這條邊界？

### 第六段（P8）：OIDC 把判斷送過邊界，mapping 在這裡兌現
- **已知／畫面起點**：邊界兩側的落差。
- **痛點**：需要一條標準、雙方都認的管道。
- **小步**：auth server 換帽子，它同時是 OIDC Provider；走一次標準 OIDC，app 拿回 `id_token`。
- **新的可見狀態**：`id_token` 的 payload 裡有自訂 claim `app_user_id`，一條線指回 P6 建的那一列 mapping；app 據此找回自己的 Alice，簽**自己的** session。右邊那格終於變了。
- **留下的下一題**：所以整體到底怎麼拆的？app 到底多做了什麼？

### 第七段（P9）：app server 異動最小化
- **已知／畫面起點**：完整的兩格架構。
- **痛點**：公司內 webpatx 與 ecsten 之前都把**整個 passkey 實作放在 app 身體裡**（一個用 Better Auth、一個不是，但落點相同）。那是可行的、也已經在跑；代價是每多接一個產品，就要在那個產品裡再長一整套。
  **這一段只用一句話帶過，不進動畫**——聽眾本來就熟悉這兩個產品，講出來就有畫面。P9 的動畫全部留給「我們這一側」。
- **小步**：把框留在外面，清點 app 這一格實際新增了什麼。
- **新的可見狀態**：一組**純標準**的 OIDC client，加上兩個導頁入口——而導頁甚至不必寫進 app，任何入口或外掛都能長出來。
- **結論**：app 新增的東西裡，沒有一樣是 Better Auth 專屬的。

---

## 逐頁／逐揭露設計

### P0 今天的路線
- **畫面上有什麼**：先一句話定錨——這件事公司內已經做過兩次，今天講的是站在那個基礎上的**第三種做法**，差別在**對 app 的影響**。（此處不點名，名字留到 P9 出現一次即可。）接著兩行路線：①最少量地知道 Better Auth 是什麼 ②它的 passkey 怎麼跟既有 app 串起來。
- **此 click 唯一發生的事**：給這場分享一個存在理由，並宣告第一段是為了讓第二段成立。
- **聽眾此刻應看出的事**：這不是 passkey 入門，是同一件事的第三種拆法；第一段不是背景介紹，是第二段的前置。
- **注意**：這裡只承諾「差別在對 app 的影響」，**不要**預告任何架構、元件或結論。全部的比較留到 P9 才兌現。

### P1 Better Auth 是什麼
- **畫面上有什麼**：GitHub README 的第一句話（已逐字查證，見「技術限定」）。
- **click 1**：定義出現。
- **click 2**：底下補一句「但它不是一個 server」；同時把它拆成 `server lib` / `client lib` 兩個盒子。
- **聽眾此刻應看出的事**：接下來要看的是這兩個盒子各給了什麼。
- **下一個痛點**：那 server lib 給的是什麼？

### P2 server lib 的兩部分
- **畫面上有什麼、分別在哪裡**：左側 `db migration` 工具，中間 `db` 方塊（列出 user / session / passkey 等空表頭），右側 `instance` 方塊。
- **click 1**：db migration 跑過 → db 方塊長出來，表都是空的。講者可帶過：這一步跟你的程式無關，就是個把 schema 建好的工具。
- **click 2**：`betterAuth({ ... })` → instance 方塊長出來，一條線連到 db。
- **click 3**：把 instance 的**對外方向刻意留白**（或畫一圈虛線缺口）。
- **聽眾此刻應看出的事**：東西都建好了，但外面沒有任何人打得到它。
- **下一個痛點**：怎麼讓它被打到？

### P3 掛上去，auth server 才誕生
- **click 1**：`toNodeHandler(auth)` 掛進 express → instance 右側長出一排 `/api/auth/*` endpoint，P2 的缺口補上。
- **click 2**：掃過官方 adapter 清單：`node` / `next-js` / `svelte-kit` / `solid-start` / `tanstack-start`。
- **click 3**：一個外框把 db + instance + endpoints 框住，貼上名字 **auth server**。
- **聽眾此刻應看出的事**：這排 adapter 本身就是「framework-agnostic」的證據；而 server 是**你的** server，Better Auth 只是長在裡面的 library。
- **講者要說的話**：所以說它是 library，不是 server。
- **下一個痛點**：server 好了，client 拿它能做什麼？

### P4 client lib：它自己就是完整的使用者管理系統
- **畫面上有什麼**：左邊 auth server（滿版佔據畫面），右邊一個 client 方塊。
- **click 0**：`createAuthClient({ baseURL })` → client 連到 endpoints。
- **click 1**：`authClient.signUp.email({ email, password, name })` → db.user 多一列 `Alice`。
- **click 2**：`authClient.signIn.email({ email, password })` → db.session 多一列，client 那側出現 cookie。
- **click 3**：`authClient.passkey.addPasskey({ name })` → db.passkey 多一列，一條線連到 Alice。
- **click 4**：`authClient.signIn.passkey()` → session 再次出現；**標註：這一次沒有密碼參與**。
- **聽眾此刻應看出的事**：這一格自己就能跑完註冊、登入、passkey 註冊、passkey 登入，是一套完整的系統。
- **下一個痛點**：但我的 app 已經有自己的使用者了。

### P5 搬家（三個獨立 click，不可合併）
- **click 1**：auth server 從滿版**縮到左半**，右半同時長出等大的 app server（自帶 db.user，裡面已經有 Alice）。左右兩格從此位置固定，不再移動。
- **click 2**：auth server db.user 裡的 Alice **沿著箭頭移到右邊那格**——保留同一個物件的身份，只改變位置，不要換成新方塊。
- **click 3**：把 P4 演過的 `signUp.email` / `signIn.email` 兩條線當場打上紅叉（對應 `emailAndPassword: { enabled: false }`）。
- **新的可見狀態**：auth server 的 passkey table 還在，但它的關聯線變成**懸空的虛線**，連不到任何人。
- **聽眾此刻應看出的事**：能力還在左邊，對象卻在右邊。
- **下一個痛點**：auth server 要怎麼認得 app 的 Alice？

### P6 註冊：借 app 的簽章
- **畫面上有什麼、分別在哪裡**：左 auth server（passkey 能力、空的 mapping 表、一把**空心鑰匙**＝公鑰），右 app server（db.user 有 Alice、一把**實心鑰匙**＝私鑰）。
- **click 1**：Alice 在 app 用帳密登入 → app 用私鑰簽一個 JWT（`sub = app_user_id`），放進 cookie。畫面上 cookie 掛在瀏覽器那側。
- **click 2**：app 頁面上的「新增 Passkey」按鈕 → **導頁**箭頭飛到 auth server 的 enroll 頁；強調使用者**離開了 app 的頁面**，cookie 隨請求一起送達。
- **click 3**：⚠ 一行紅字：**前提：app 與 auth server 必須在同一個網域（`example.com`）底下，這個 cookie 才送得到**。全場只出現這一次紅字。
- **click 4**：auth server 用公鑰驗簽 → 取出 `app_user_id` → 建一個**沒有密碼的** auth_user → **mapping 表第一次出現一列**（`auth_user_id ↔ app_user_id`）。
- **click 5**：`addPasskey` 完成 → P5 那條懸空的虛線接到新的 auth_user 上，變成實線。
- **聽眾此刻應看出的事**：auth server 不認識 Alice，它只是**相信 app 說她是誰**；信任的全部來源就是畫面上那對鑰匙。
- **下一個痛點**：她有 passkey 了，那登入呢？

### P7 登入：認人成功了，但結果出不去（全場的關鍵痛點頁）
- **click 1**：`authClient.signIn.passkey()` → 驗證成功 → **左邊那格**多一個 session。
- **click 2**：鏡頭／highlight 掃到右邊 app server → **什麼都沒有變**。app 不知道剛才發生過任何事。
- **click 3**：補刀標註：那個 session 只活 60 秒、且 `disableSessionRefresh: true`——它根本不打算當登入狀態。
- **聽眾此刻應看出的事**：「這是誰」的判斷已經做出來了，但它卡在左邊那一格，右邊拿不到。
- **講者要說的話**：我們要的不是在 auth server 登入，是在 app 登入。
- **下一個痛點**：怎麼把這個判斷送過邊界？

### P8 OIDC：把判斷送過邊界，mapping 在這裡兌現
- **click 1**：auth server 換帽子——它同時是 OIDC Provider（IdP），app 是 OIDC client。
- **click 2**：一次標準 OIDC，**只用一組來回箭頭帶過，不展開流程**；app 拿到 `id_token`。
- **click 3**：`id_token` 攤開 payload：`iss` / `aud` / `sub` / `nonce` / **`app_user_id`**（只 highlight 最後這個）。
- **click 4**：一條線從 `app_user_id` **指回 P6 建的那一列 mapping**。這是全場最重要的一次回收。
- **click 5**：app 用 `app_user_id` 找回自己 db 裡的 Alice → 簽**自己的** session cookie → 右邊那格終於變了。
- **聽眾此刻應看出的事**：auth server 從頭到尾沒有發過 app 的 session；它只交出「這是誰」這個判斷，session 永遠是 app 自己的。
- **下一個痛點**：所以整體是怎麼拆的？

### P9 收束：app server 異動最小化
- **click 1（一句話，不進動畫）**：webpatx 與 ecsten 之前都是把**整個 passkey 實作放在 app 身體裡**。畫面上最多一行字，沒有任何圖形變化。
  - **講者定調很重要**：這不是反例，是已經在跑、而且是對的版本；今天講的是站在它上面的下一步，不是否定它。
  - **不要**把 P3 的框搬進 app server 那格。兩個產品裡有一個沒用 Better Auth，畫成 Better Auth 的框會失真；而且動畫一給，這段的篇幅就壓不住了。
- **click 2**：我們的做法——auth 那一整套留在左邊，右邊只留一個介面。畫面**留在 P8 結束時的那張圖**，不新增元件，只把 app 那格圈起來。
- **click 3**：清點 app 這一格實際新增了什麼：
  - 一組**純標準**的 OIDC client（endpoint + handler）
  - 兩個導頁入口（enroll / sign-in）——**而且這兩個甚至不必寫在 app 裡**，任何入口或外掛都能長出來
- **click 4（決定性的一句）**：app 新增的東西裡，**沒有一樣是 Better Auth 專屬的**。把 auth server 換成別的 IdP，app 一行都不用改。
- **click 5（換算成公司的成本）**：所以下一個產品要接 passkey 時，不需要在那個產品裡再長一整套 Better Auth，只需要接一個標準 OIDC client。
- **聽眾此刻應看出的事**：「異動最小化」不是省了幾行，是 app 沒有被綁定到任何特定的 auth 實作，而這件事在第 N 個產品上才真正兌現。

---

## 視覺語意與節奏

- **兩格位置**：P5 之後左 = auth server、右 = app server，位置永遠固定。P4 的滿版 → P5 的左半，是全場**唯一一次**空間重排，且必須是「主動縮小、預留右半」，不能讓右邊的新物件把左邊擠開。
- **資料表欄位固定**：`user` / `session` / `passkey` / `mapping` 在各自那格的位置從頭到尾不變，方便聽眾掃一眼比對。
- **身份保留**：Alice 從左搬到右是**同一個物件改變位置**，不是消失後在別處出現一個新方塊。
- **鑰匙**：實心 = 私鑰（只有 app 有）；空心 = 公鑰（auth server 有，由設定給它）。這對鑰匙在 P6 出現後就留在畫面上，是 P6 全部信任的來源。
- **線**：實線 = 已發生的資料流；懸空虛線 = 失去對象的關聯（P5 的 passkey）；紅叉 = 被關掉的能力（P5 的帳密）。
- **淡化** = 已講過、此刻不在焦點的東西。
- **紅字全場只出現一次**（P6 的網域前提），維持它的重量。
- **延後命名**：
  - 「auth server」到 P3 click 3 才貼名字。
  - 「OIDC / IdP」到 P8 click 1 才出現；P7 結尾只說「送過邊界」，不預告解法名稱。
  - `app_user_id` 這個欄位名在 P6 就出現（它就是 JWT `sub` 解出來的東西），但它**為什麼要存在**要到 P8 click 4 才揭曉。
- **全貌何時出現**：沒有開場架構圖。完整的兩格架構在 P9 才第一次以「全貌」的姿態被看待，而此時每個元件都已經有各自被逼出來的理由。

---

## 技術限定與待查證事項

### 已確認的前提與來源
以下皆已對照 `better-auth-server` 原始碼與 `node_modules/better-auth@1.7.0`：

- 正式方法名（P4 用）：
  - `authClient.signUp.email({ email, password, name })` → `POST /sign-up/email`
  - `authClient.signIn.email({ email, password })` → `POST /sign-in/email`
  - `authClient.passkey.addPasskey({ name })` → `/passkey/generate-register-options` → `/passkey/verify-registration`
  - `authClient.signIn.passkey()` → `/passkey/generate-authenticate-options` → `/passkey/verify-authentication`
- 建立 instance 是 `betterAuth({...})`（`createBetterAuth` 是本 repo 自己的 wrapper，簡報請用官方名）。
- 掛載是 `toNodeHandler(auth)`（`better-auth/node`）；官方同層 adapter：`next-js`、`svelte-kit`、`solid-start`、`tanstack-start`。
- migration 在本 repo 是啟動時跑 `getMigrations(auth.options).runMigrations()`（`src/better-auth/db-migrator.ts`）。
- P5 的「關掉帳密」對應 `emailAndPassword: { enabled: false }`（`src/better-auth/instance.ts`）。
- P6 的「借 app 的 session」對應 passkey plugin 的 `registration.requireSession: false` + `resolveUser`。**這是官方 plugin 明確留的擴充點**：`requireSession` 預設為 `true`，設成 `false` 時 `resolveUser` 為必填（否則丟 `RESOLVE_USER_REQUIRED`）。如果講者想加一句技術背書，這是最好的一句。
- P7 的 60 秒：`session.expiresIn = AUTH_SESSION_EXPIRES_IN_SECONDS`（預設 60）且 `disableSessionRefresh: true`。
- P8 的 `app_user_id`：`oauthProvider({ customIdTokenClaims })` 從 mapping 表查出來後注入（`appUserIdClaim()`）。
- P6 的公鑰來自設定 `APP_JWT_PUBLIC_KEY_PATH`，RS256；本服務只驗簽章與 `sub`。

### 為教學而合併／省略的細節
- **導頁的真正理由不只一個**。簡報只講「app 不必引入 auth 依賴」。實際上還有 WebAuthn 的 RP ID／origin 規則（RP ID 由 `AUTH_SERVER_PUBLIC_URL` 的 hostname 推導，兄弟子網域部署下 app 頁面根本無法直接呼叫）與跨 origin cookie 型 API 的 trusted origin 成本。**這是刻意的取捨；若 Q&A 被問到，這是完整答案。**
- **P6 的紅字是簡化版**。精確的規則是：cookie 能否送達取決於 `Domain` / `Path` / `Secure` / `SameSite`，且 **cookie 不隔離 port**。因此同 host 不同 port（`localhost:3000` vs `localhost:3001`）可行；兄弟子網域可行但 app 必須設 `Domain=example.com`；跨可註冊網域則不可行。紅字寫「同一個網域底下」是為了避免聽眾記成過嚴的「同一個 host」。
- **P6 建的 auth_user 是佔位身份**：實作填的是 `email: app-user-<id>@invalid`、`emailVerified: true`、沒有密碼。簡報只需說「一個沒有密碼的 auth_user」，不必秀這個 email。
- **P8 的 OIDC 不展開**（依作者決定，8/21 已講過 PKCE）。實際實作是 Authorization Code + PKCE(S256)，app 端會驗 `iss` / `aud` / `nonce` 與 JWKS 簽章後才建立 session。
- **consent 頁不講**：demo client 設 `skipConsent: true`，一般 `openid` 登入流程不會出現。
- **不講**：path prefix 與 reverse proxy 契約、OAuth client 的 startup bootstrap 與一致性檢查、多副本共用 `BETTER_AUTH_SECRET`。

### 已與作者確認
- **P1 的引用已查證**：「Better Auth is a framework-agnostic authentication (and authorization) framework for TypeScript.」逐字出自 GitHub README `## Better Auth` 段落的第一句，該 README 也隨 npm 套件發佈（`node_modules/better-auth/README.md`）。它與 `package.json` 的 description（"The most comprehensive authentication framework for TypeScript."）不同屬正常，兩者是不同欄位。
- **P9 的對照組是公司內部事實，不是業界推論**：webpatx 與 ecsten 近期都實作了 passkey，兩者都把整套實作放在 app 身體裡（一個用 Better Auth、一個不是）。作者是站在這兩次已完成的實作上，做出對 app 影響最小的第三種拆法。因此對照組是**聽眾已經看過的東西**，一句話就夠，不需要外部佐證，也不需要講成普遍現象。

- **webpatx / ecsten 的 library 已確認**：一個用 Better Auth、一個不是。因此 P9 的對照點**不是「用了哪個 library」，而是「整套實作放在哪」**——兩者都放在 app 身體裡。措辭要停在這一層，不要說成「他們都用 Better Auth」。

### 尚待確認
- 目前沒有阻擋定稿的未決項。

---

## 交接給 draft-to-deck

### 不可破壞的推導順序
1. **P4 必須在 P5 之前**。P4 是對照組；沒有它，P5 的「搬家」就沒有代價可言。
2. **P6 的 mapping 必須在 P8 的 `id_token` 之前**，且 P8 click 4 必須明確地把線指回 P6 那一列。這是全場最重要的一次回收。
3. **P7 必須獨立成一頁，不能與 P8 合併**。P7 的全部價值就是「passkey 登入成功了，但 app 那格沒有任何變化」這個空白。
4. **P3 的「library 長在你的 server 裡」在 P9 是軟回收**：它解釋了為什麼把整套實作放進 app 身體裡是自然的選擇（所以那兩個產品不是做錯）。但因為其中一個產品沒用 Better Auth，這個回收只能是口頭的一句，不可做成畫面上的對照動作。
5. 名稱出現的時機不可提前：`auth server`（P3）、`OIDC / IdP`（P8）。
6. **P0 的定錨與 P9 的對照組是同一對**：P0 只能承諾「差別在對 app 的影響」且**不點名**，P9 才點名並兌現差別是什麼。P0 不可提前畫出任何架構。
7. **webpatx / ecsten 全場只出現一次、只有文字**（P9 click 1）。它們是聽眾已知的參照點，不是這場要展開的對象。

### 每頁最重要的可見事件
| 頁 | 唯一要記住的可見事件 |
| --- | --- |
| P2 | instance 建好了，但對外沒有任何連線 |
| P3 | 掛上去之後長出 endpoint，外框被命名為 auth server |
| P4 | passkey 那次登入，db 裡沒有密碼參與 |
| P5 | Alice 移到右邊之後，passkey 的關聯線懸空 |
| P6 | mapping 表第一次出現一列，懸空的線接上了 |
| P7 | 左邊多一個 session，右邊完全沒動 |
| P8 | `app_user_id` 拉出一條線指回 P6 那一列 |
| P9 | app 那格新增的東西，沒有一樣是 Better Auth 專屬的 |

### 不能被濃縮成 bullet 的段落
- **P5 的三個 click**：縮小、搬人、劃掉帳密。合成一頁靜態圖就失去「能力與對象被拆開」的過程。
- **P6 的 click 3→4→5**：驗簽 → 建 mapping → 接回 passkey。這三步是這場的技術核心，必須是動畫。
- **P7 的「沒有變化」**：這是用空白製造的痛點，寫成文字（「但這樣不行」）就完全失效。
- **P8 的 click 4**：mapping 的回收線。
- **P9 的 click 3–4**：清點 app 新增了什麼，以及「沒有一樣是 Better Auth 專屬的」這一句。這是整場的落點。

### 削減候選（若時間不足）
1. P4 click 3–4（passkey 兩個動作）可壓縮成一個 click——但**不可整段刪除**，P7 需要「你剛才看過它成功」的對照。
2. P9 click 5（換算成公司成本）可併進 click 4 一句講完。
3. P1 click 1 的官方定義引用可省，直接從「它不是一個 server」開場。
