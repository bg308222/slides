# PKCE：為什麼它存在，以及該由誰產

## 這場分享要讓聽眾經驗什麼

### 目標觀眾與他們已知的起點

- 寫過或串過 OAuth 登入，跑得起來，但沒讀過規格。
- **腦中已經有 implicit flow 的知識**（這是關鍵起點，不是要清掉的舊資訊，是可以借用的直覺）。
- 已經知道「有 client_secret 的流程」長什麼樣，那是他們心中的預設 OAuth。
- 心中的角色詞彙是 `user / browser / server / google`，而不是規格的四個角色。

### 最後應能自行說出的結論

不是「PKCE 是什麼」，而是能**指著圖回答一個具體問題**：

> 「這次該誰產 code_verifier？」——並且知道**這個問題本身問錯了**，
> 該問的是「**你的 OAuth client 是誰**」。

以及能說出一句用 `client_secret` 解釋不了的事實：

> 「secret 從頭到尾都正確，但 token 給錯人了。」

### 這場的真正起因（不進簡報，僅供編排者理解動機）

作者過去講 PKCE 時卡住的三件事，本場要全部回答：

1. 有 server 的 app，PKCE 到底是 server 產還是 client 產？→ 討論不出結果，因為**用詞不對**。
2. PKCE 到底遇到什麼困難而出現？「防 code 被偷」講不出具體 threat model，聽眾不買單。
3. 有沒有 `client_secret` 對 PKCE 的影響是什麼？

### 刻意不講的邊界

- **不提 Resource Server**。第一段的「拿 token 問 user 資料」直接畫向 AS，刻意降低角色負擔。
- **不展開 XSS**。列為前提直接排除（頁面被完全操控時幾乎什麼都能偷）。
- **不展開 mix-up attack**。只在第二段的外流途徑清單中點名，不推導。
- **不談 refresh token、token 撤銷、sender-constrained token（DPoP / mTLS）**。
- **不談 OIDC 的 `nonce` 機制本身**。5.6 只講「例外的條件是什麼、為何很弱」。
- **不演 injection 的反向**（victim 誤入攻擊者帳號），只由講者口頭帶過一句。
- **不比較各家 SDK / IdP 實作差異**。

---

## 全場判讀尺

### 核心問題

> **這個機制回答的是「你是誰」，還是「這個 code 是不是你剛才要的那一個」？**

### 為何它能跨每一段檢查狀態

| 段 | 用尺量出來的結果 |
|---|---|
| 1 | `client_id` = 你**宣稱**你是誰 |
| 2 | 惡意 app 搶走 code —— 他什麼都不用證明 |
| 3 前半 | `client_secret` = 你**證明**你是誰 → 擋住第二段 |
| 3 後半 | injection —— 「你是誰」**全部答對**，攻擊照樣成立 |
| 4 | implicit —— public client 連第一根軸都答不了，於是乾脆放棄整條軸 |
| 5 | PKCE 回答的是**第二根軸** |

### 這把尺必須分兩次立起來（重要）

- **第一根軸在 3.3 由講者立起**：「原來 secret 回答的是『你是誰』。」此時聽眾以為一根軸就夠了。
- **第二根軸在 3.4 由聽眾自己立起**：injection 讓「你是誰」滿分卻仍失守，聽眾**自行意識到**還缺一根軸。

不要在開場就把兩根軸都給出來。第二根軸的價值全部來自聽眾自己發現它。

---

## 推導主線

### 第一段：座標確立（誰是 client）

- **已知／畫面起點**：他們自己寫過的那張圖 —— `user / browser → server → google`，並在 server 底下標著「client」。
- **痛點**：畫面上「**client**」這個標籤同時被用在**兩個位置**。所以「verifier 是 server 產還是 client 產」這個問題在這張圖上**問不出答案**——問的人講「client」時腦中是 browser，答的人講「client」時腦中是 server。
- **小步**：只做一件事——把每個位置換上規格的正式名稱，並且**把被混用的那個字拆開**。
- **新的可見狀態**：RO / Client / AS 三格 + browser（載具）。「client」這個字只剩一個位置。
- **留下的下一題**：這趟旅程，車上載過 code，那**有沒有哪一段車上的東西會被別人拿走**？

### 第二段：洞在哪（code 怎麼離開它該在的地方）

- **已知／畫面起點**：第一段那張跑完的流程圖。
- **痛點**：逐步檢查後發現**每一段都被 HTTPS 保護得好好的**——那洞在哪？（這個「咦？」是本段的引擎）
- **小步**：把「HTTPS 安全」這個前提講精確一格——**管線裡面偷不走，但 code 是寫在 URL 上的，而 URL 會離開管線**。
- **新的可見狀態**：手機 custom scheme 攔截；token endpoint 的檢查清單**四個綠勾全過**。
- **留下的下一題**：**這張清單上，沒有任何一格擋得住他。那要怎麼多一格？**

### 第三段：client_secret 的職責邊界

- **已知／畫面起點**：第二段那張四綠勾的檢查清單，以及「怎麼多一格」這個問句。
- **痛點（前半）**：同一張清單，加上 secret 那一格 → 三綠一紅。攻擊被擋住了。看起來 secret 解決了問題。
- **小步（前半）**：指出這是**副作用不是設計目的**——secret 回答的是「你是誰」，那個攻擊者剛好是在**冒充 client**，所以被擋住了。
- **痛點（後半）**：authorization code injection。攻擊者**不冒充 client**，他借用那個誠實的 client。secret 全程被正確使用，四個檢查全綠，token 仍然給錯人。
- **新的可見狀態**：attacker 的 session 裡掛著一個**顏色明顯屬於 victim** 的 token。
- **留下的下一題**：「你是誰」這根軸已經滿分了還是不夠——缺的是「**把 code 綁到這一次請求**」的能力。而 public client 呢？它連第一根軸都沒有。

### 第四段：public client 的第一次嘗試（implicit）

- **已知／畫面起點**：public client 沒有 secret。RFC 6749 §1.3.2 白紙黑字：implicit 流程裡 **AS 不認證 client**。
- **痛點**：那麼對 public client 而言，code exchange 那一趟往返**證明不了任何事**，只是多一趟。
- **小步**：早期的答案——**別發 code 了，直接發 token**。（借用聽眾既有的 implicit 知識，讓他們認同這個推理）
- **新的可見狀態**：現在 URL 上放的是**拿到就能用**的東西。第二段那個惡意 app 照樣接得到，而這次接到的**不用再換**。
- **留下的下一題**：方向錯了。**不該拿掉 code exchange，該給它一個 public client 也做得到的證明。** 那會是什麼樣的證明？

### 第五段：PKCE（一次收兩條線）

- **已知／畫面起點**：兩個缺口並排——第三段缺「綁到這一次請求」，第四段缺「不需要預先登記的證明」。
- **小步**：從這兩個條件**現場推導**出機制，而不是先給名字。
- **新的可見狀態**：回到 3.4 那張雙軌圖，**同一張圖，這次顏色錯位不會發生**。
- **收尾**：貼上正式名稱 → 回答開場那個問錯的問題 → 三份規格的立場。

---

## 逐頁／逐揭露設計

> 編號為 `段.頁`。標「**★**」者為全場不可壓縮的關鍵頁。

### 1.1 我們已經知道的 OAuth

- **畫面上有什麼**：橫排三格 `browser → server → google`。`browser` 上方標「user」，`server` 下方標「**client**」。
- **動畫（六個 click，同頁）**：
  1. user redirect to google
  2. user login google
  3. google callback to server
  4. server 帶 code + client_secret 去 google
  5. google 回 token
  6. 用 token access API
- **聽眾此刻應看出的事**：這張圖他們每天在用，沒有錯。
- **下一個痛點**：畫面上「client」這個字，跟他們口語講的「client 端」**不是同一個東西**。

### 1.2 ★ 翻譯成正式名詞（全場最重要的一次揭露）

- **初始畫面**：與 1.1 完全相同的三格，不重畫。
- **此頁的 click 順序（順序不可調換）**：
  1. `server` → **Client**
  2. `google` → **Authorization Server**
  3. **最大的一次變化**：`user`、`browser`、以及口語裡的「前端 client」這三個**一直被當成同義詞**的東西，一起塌縮成單一格 —— **Resource Owner**。
  4. `browser` 從 Resource Owner **下方長出來**，作為一個獨立的載具物件。
- **終態**：3 個角色（RO / Client / AS）+ 1 個載具（browser）。
- **必須講死的一句**：**中間這個 Client 是 OAuth 定義的 client，不是「應用的前端」。**
- **聽眾此刻應看出的事**：原本的歧義**全部發生在左邊那一格**——它一個字被拆成了「人」和「車」。
- **視覺注意**：第 3 步的塌縮是本場最劇烈的一次位移。三個物件的移動路徑必須清楚指向同一個目的地，不能只是淡出再淡入。第 4 步 browser 長出來時，**位置要預留**，不能推擠 Client / AS 兩格。

### 1.3 ★ 定住四者的關係

- **講者的定調**：整個 OAuth 都是**圍繞 Client 和 AS 在玩的**。RO 只在一個很小的節點參與（在 AS 完成登入與授權），其餘全是 Client 和 AS 在調度。**browser 是載具**——它載著 RO，受 Client 和 AS 調度到處跑。
- **動畫（七個 click，重跑一次流程）**：
  1. Client 向 AS 申請 `client_id` + `client_secret`，存進 Client
  2. RO 發起登入
  3. Client 叫 browser 載去 AS（**RO 是被載在車上送過去的**）
  4. RO 在 AS 登入
  5. AS 叫 browser 載回 Client（**車上多了一個 code**）
  6. **車從此不再動**。Client 自己去 AS 換 token
  7. Client 拿 token 向 AS 問 user 資料
- **本頁結論（必須是聽眾指著圖說出來的）**：
  > **有 `client_id`、做 code exchange 的那一個，就是 client。**
  > RO 就只是「我這個人」，不代表 browser，也不代表任何前端程式碼。
- **下一個痛點（轉入第二段的問句）**：指著這張圖——車上載過 code，code 落地在 Client 門口。**這一路上有沒有哪一段，車上的東西會被別人拿走？**

### 2.1 兩個前提

- **前提一**：假設瀏覽器**沒有被 XSS**。頁面被完全操控的話幾乎什麼都能偷，那不是本場要談的。
- **前提二（改寫過，關鍵）**：憑證有效時 HTTPS **管線裡面的內容偷不走**，這是事實，所以不要去想 request / response 半路被攔截。
  > **但是——code 不是躺在車廂裡的。它是寫在車身外面的牌子上。**
  > 車在管線裡跑時牌子當然安全；**車一到站，牌子還掛在那裡。**
- **視覺**：一條實心管線包住車。code 不畫成車廂內的貨物，畫成**車身外側的牌子**。這個語意在第 2、3 段都要沿用。
- **技術對照（不可被比喻取代，講者要講出來）**：code 出現在 **URL 的 query string** 裡。凡是會記錄或轉傳 URL 的地方，都在 HTTPS 的保護範圍之外。

### 2.2 逐步檢查，然後發現沒有洞

- **畫面**：還原 1.3 的完整流程圖，重跑一次，每一步旁邊標一個綠勾與理由：
  1. 申請 id / secret —— 人工操作，沒危險
  2. RO 發起登入 —— HTTPS
  3. redirect 到 AS —— HTTPS
  4. RO 在 AS 登入 —— HTTPS
  5. callback 回 Client —— HTTPS
  6. Client 換 token —— HTTPS
  7. Client 問 user 資料 —— HTTPS
- **聽眾此刻應看出的事**：**整段都被保護得好好的**。
- **講者的問句**：那洞在哪？
- **本頁的功能就是製造這個「咦？」**，不要提前洩底。

### 2.3 ★ 洞在第 5 步：callback 不是網址而是 app

- **一次揭露一件事**：只把第 5 步的終點從「一個 https 網址」換成「**一個 app**」（custom URI scheme）。其餘畫面不動。
- **接著的 click**：一個**第二台 app** 出現，它也註冊了同一個 scheme → 車開錯門 → 牌子（code）落在它手上。
- **必須補完的推理（不能只說「code 被偷 = token 被偷」）**：
  攻擊者拿著這個 code 去 token endpoint，AS 會檢查什麼？
  - `client_id` ✓ —— 它在 authorization request 的 URL 上，本來就是公開的，惡意 app 攔得到
  - `redirect_uri` 一致 ✓ —— 他就是註冊了同一個 scheme 才攔得到的，當然知道
  - code 有效、未使用過 ✓
  - **public client 的 token endpoint 不做 client authentication** ✓
  → **四個綠勾，全過。**
- **聽眾此刻應看出的事**：**沒有任何一格是紅的。** code 被偷，就等於 token 被偷。
- **下一個痛點（直接轉入第三段，不要插入其他內容）**：
  > 問題不在於他偷到了 code，而在於**這張清單上沒有一格擋得住他**。
  > **那要怎麼多一格？**
- **視覺語意（會在 3.2 與 3.4 回聲）**：這張「檢查清單 + 綠勾」是本場的固定視覺元件，之後兩次都要用**同一個版面**。它是第二、三段的**主軸線**：
  | 頁 | 清單狀態 | 聽眾的感受 |
  |---|---|---|
  | 2.3 | 四格，**全綠** | 沒有一格擋得住 |
  | 3.1 | ——（問：誰有能力多一格？） | |
  | 3.2 | 五格，**三綠一紅** | 多的那一格擋住了 |
  | 3.4 | 五格，**又全綠** | **清單變長了，但又沒有一格擋得住** |

### 3.1 怎麼多一格：confidential vs public

- **承接 2.3 的問句**：要在清單上多一格，那一格必須檢查「**只有真正的 client 才知道的東西**」。那就是 `client_secret`。
  > 但不是每個 client 都**有能力**持有它。
- **關鍵差異只有一件事**：**有沒有能力保護 secret。**
- **精確的判準（不要說成「有沒有 server」）**：
  > 分的不是「這個應用有沒有 server」，而是「**那個持有 `client_id`、做 code exchange 的東西，跑在誰控制的機器上**」。
  這與 1.3 的結論是同一句話，不是新規則。
- **兩個例子**：
  - 純前端應用：程式碼在使用者手上 → **沒有能力**
  - native app：binary 可被反編譯，而且裡面的 secret 對**所有安裝者是同一份** → **沒有能力**
    > RFC 8252 §8.5 原文：*"Secrets that are statically included as part of an app distributed to multiple users should not be treated as confidential secrets, as one user may inspect their copy and learn the shared secret."*
    > 同文並指出，對 public native app 要求 shared secret 認證 *"serves little value beyond client identification"*——**它只剩「宣稱你是誰」，沒有「證明」。**
  - 有 backend 且由 backend 做 code exchange → **有能力**
- **聽眾此刻應看出的事**：2.3 那個手機案例，屬於 public。

### 3.2 ★ 同一張清單，只差一格

- **畫面**：完全沿用 2.3 的檢查清單版面。
- **前提**：假設攻擊者用**剛才任一種途徑**拿到了 code（哪一種不重要）。
- **唯一的變化**：清單上**多出一格 `client_secret`**。
  - `client_id` ✓
  - `redirect_uri` ✓
  - code 有效 ✓
  - **`client_secret` ✗** ← 唯一的紅叉
- **聽眾此刻應看出的事**：三綠一紅，攻擊被擋住了。**看起來 secret 解決了問題。**
- **編排注意**：這頁刻意只讓焦點落在 secret 那一格，**不要同時討論 redirect_uri 在手機 / web 上的差異**，否則聽眾分不清是哪一格擋住的。

### 3.3 但這是副作用，不是設計目的

- **講者要立起第一根軸**：
  > `client_secret` 的職責是 **client authentication**——它回答「**來換 token 的，是不是我登記過的那個 client**」。
  > 它擋住剛才那個攻擊，是因為那個攻擊者**正在冒充 client**。
  > 它從來不回答「**這個 code，是不是你剛才那一次請求要來的那一個**」。
- **此刻聽眾的狀態**：以為一根軸就夠了。**這是刻意的。**
- **下一個痛點**：那如果攻擊者**根本不冒充 client** 呢？

### 3.4 ★★ authorization code injection（全場最需要被看見的一頁）

#### 3.4.0 前置：他手上的 code 哪來的？（一格，不要做成獨立長頁）

3.3 問完「如果他根本不冒充 client 呢」，要演這個攻擊，聽眾**當下就會問**的第一件事是：
confidential client 通常是 web app，**沒有 custom scheme 可以搶**，那攻擊者怎麼拿到 victim 的 code？

- **回到 2.1 那句前提**（此時它第二次被使用，份量才顯出來）：**只要 code 寫在 URL 上，就有路。**
  - browser history
  - Referer header
  - server / proxy 的 access log
  - **停錯站**：`redirect_uri` 驗證不夠嚴、或 client 自己網域上的 open redirector
  - 攻擊者假扮 AS（mix-up）—— 只點名，不展開
- **必須強調的兩句**：
  > **這些沒有任何一種需要破 HTTPS。**
  > **用哪一條不重要——重點是他手上有了。**
- **編排注意**：這是 3.4 的第一格，不是獨立一頁。它之所以能成立，是因為聽眾**已經在問這個問題了**。
  （早期版本曾把這份清單放在第二段末尾當獨立頁，那時聽眾還沒有需求，會不知道它想說什麼。）

#### 3.4.1 起 演出本體

- **版面**：上下兩條**完全相同**的軌道（同樣的 RO / Client / AS 三欄位置，垂直堆疊）。上軌 RO = **victim**，下軌 RO = **attacker**。
- **第一件必須先講死的事（最容易被誤解的地方）**：
  > 用一個垂直虛線框把上下兩軌的 **Client 欄和 AS 欄貫穿圈起來**，標「**同一個 client、同一個 AS**」。
  > 攻擊者**沒有**架假網站。他就是去用你的網站。
- **click 節奏**：
  1. 上軌跑到第 5 步，victim 的車載回 `code_V`，停在 Client 門口。
  2. **`code_V` 被拿走**（用 3.4.0 的任一途徑）。它從上軌**飛出畫面外**，落進一個標著「攻擊者手上」的格子。
     - 上軌**淡化但不消失**——victim 這一趟甚至可能成功登入了，**他毫無感覺**。
     - `code_V` 全程保留 victim 的顏色標記。
  3. 下軌開跑：attacker 自己去這個 client 點登入 → 用**自己的帳號**登入 AS → 車載著 `code_A` 回來。
  4. **★ 注入那一格。** 車還沒開進 Client 的門：`code_A` 灰掉、掉出畫面；`code_V` 從畫面外側**長距離飛回來**落上車。
     - **飛行路徑必須跨越整個畫面**，不能是原地變色。
     - 作者明確要求：**這一格要顯眼到不可能感覺不到**。建議配全屏紅標。
  5. **Client 是誠實的**——要用畫面講：Client 那格把 `client_secret` **明顯地舉起來用上**，不可以跳過這個動作。
  6. AS 的檢查清單（**再次沿用 2.3 / 3.2 的版面**）逐項打勾：
     `client_secret` ✓ ／ `client_id` ✓ ／ `redirect_uri` ✓ ／ code 有效未使用 ✓ → **全過**。
     - **這裡是清單軸線的收束點**：3.2 才剛因為多了 `client_secret` 那一格而變成三綠一紅；
       現在**清單一樣長，卻又全綠了**。連新加的那一格都是綠的。
  7. AS 發出**帶著 victim 顏色標記的 token**，交給 Client；Client 把它綁進**下軌 attacker 的 session**。
- **終態畫面**：**attacker 的欄位裡，掛著一個顏色明顯屬於 victim 的 token。**
- **三個顯眼點**（作者的硬性要求，缺一不可）：
  1. **跨畫面的長距離飛行**（動作）
  2. **四個綠勾**（沒有任何一步出錯）
  3. **顏色錯位**（結果）
- **聽眾此刻應自己說出的話**：
  > **「secret 從頭到尾都正確，但 token 給錯人了。」**
- **可壓在本頁的規格原文**（RFC 9700 §4.5.2）：
  > *"...do not stop this attack, as the legitimate client authenticates at the token endpoint."*
- **講者可口頭補一句、但不要做畫面的事**：這個攻擊**反過來也成立**——把**攻擊者的** code 注入 **victim 的** session，victim 就會在不知情下操作攻擊者的帳號。
  > OAuth 2.1 §7.5.1 原文：*"Authorization code injection can lead to both the attacker obtaining access to a victim's account, as well as a victim accidentally gaining access to the attacker's account."*
  > **不要為這個方向做動畫**，3.4 已經夠重了。
- **可在本頁結束後打出的規格原文**（OAuth 2.1 §7.5.1 Historic note，幾乎就是本場 3→5 段的主線摘要）：
  > *"Although PKCE was originally designed as a mechanism to protect native apps from authorization code **exfiltration** attacks, all kinds of OAuth clients, including web applications and other confidential clients, are susceptible to authorization code **injection** attacks, which are solved by the code_challenge and code_verifier mechanism."*
  > **規格自己把這兩個攻擊分成兩個詞**：第二段是 exfiltration，第三段是 injection。這正好對應本場的兩根軸。
- **留下的下一題**：「你是誰」這根軸已經滿分。缺的是**把 code 綁到這一次請求**——而且這個缺口，**confidential client 也有**。

### 4.1 回到 public client：它連第一根軸都沒有

- **畫面**：把焦點移回 public client。
- **規格原文（本段的支點）**，RFC 6749 §1.3.2：
  > *"When issuing an access token during the implicit grant flow, the authorization server does not authenticate the client."*
- **講者的問句**：那麼對 public client 來說，**code exchange 那一趟往返，到底證明了什麼？**
- **聽眾此刻應看出的事**：什麼都沒證明。它只是多一趟。

### 4.2 早期的答案：那就別發 code 了

- **小步**：既然那趟往返證明不了任何事——**直接在 authorization response 發 token**。
- **借用聽眾的既有知識**：這就是他們腦中的 implicit。**先讓他們認同這個推理**，不要急著否定。
- **規格原文**，RFC 6749 §1.3.2：
  > *"optimized for clients implemented in a browser using a scripting language such as JavaScript"*
  > *"reduces the number of round trips required to obtain an access token"*
- **視覺**：把 1.3 那張圖的第 5、6 步合併成一步——車回來時，**牌子上寫的不是 code，是 token**。

### 4.3 ★ 代價：牌子上現在放的是「拿到就能用」的東西

- **唯一的變化**：把 2.3 那個惡意 app **原封不動搬回來**。
- **聽眾此刻應看出的事**：它照樣接得到——而**這次接到的不用再換**。連 token endpoint 那張檢查清單都不用經過。
- **RFC 6749 §1.3.2 在 2012 年就寫下的警告**：
  > *"The access token may be exposed to the resource owner or other applications with access to the resource owner's user-agent."*
- **講者要點出的事**：**"other applications with access to the user-agent"**——這句話講的就是剛才那個惡意 app。規格自己警告過，只是當年沒人當回事。

### 4.4 方向錯了

- **本頁結論**：
  > code 這一層**間接**是有價值的——它讓「**拿到**」和「**能用**」分開。
  > 所以不該拿掉 code exchange，**該給 code exchange 一個 public client 也做得到的證明。**
- **規格立場**：RFC 9700 §2.1.2 —— *"Clients SHOULD NOT use the implicit grant..."*；OAuth 2.1 §10.1 直接移除 implicit。
- **必須講清楚的因果（作者原案在此處因果相反，已修正）**：
  implicit **不是**「因為不能做 PKCE 所以被廢」，而是「**因為它把拿到就能用的東西丟上前端通道**」。
- **留下的下一題**：什麼樣的證明，是**不需要預先登記**的？

### 5.1 兩個缺口並排

- **畫面**：左右兩欄，各自指回它的來源頁。
  - 左：**綁到這一次請求**（來自 3.4，confidential 也需要）
  - 右：**不需要預先登記的證明**（來自 4.4，public 才做得到）
- **聽眾此刻應看出的事**：這是兩個**不同**的需求，來自兩個**不同**的失敗。

### 5.2 ★ 現場推導出機制（先不給名字）

一次一個 click，每一步都由上一步的限制逼出來：

1. 「不需要預先登記」→ 那就 **當場產一個隨機值**。
2. 「綁到這一次請求」→ 那就在**發出 authorization request 的當下**把它交出去。
3. **但不能直接交**——因為 authorization request 走的是 URL，而我們在 2.1 就講過**URL 會離開管線**。直接交等於公開。
4. → 那就交一個**由它算出來、但反推不回去的值**。
5. 換 token 時才交出**原值**；AS 重算一次，比對。
- **這一步有規格明文背書，不是本 draft 自創的教學路徑**：
  > RFC 7636 §7.2：*"The 'S256' method protects against eavesdroppers observing or intercepting the 'code_challenge', because the challenge cannot be used without the verifier."*
  > OAuth 2.1 §7.5.2 講 `plain` 為何被禁：*"...offers no protection against authorization code interception by attackers who can read the authorization request..., as the code verifier is transmitted in plaintext in the authorization request."*
  > 換句話說，**第 3 步如果不做，得到的就是 `plain`，而 `plain` 已被 OAuth 2.1 明文禁止。**
- **聽眾此刻應看出的事**：整個機制是被前面四頁**逼出來的**，沒有一步是憑空的。
- **此時畫面上的兩個物件仍然沒有名字**，只有職責標籤：「當場產的那個原值」、「算出來、送得出去的那個」。

### 5.3 ★ 回到 3.4 那張圖，這次不一樣

- **畫面**：**原封不動重用 3.4 的雙軌圖**，只加上剛推導出來的兩個物件。
- **關鍵的一格**：
  - `code_V` 綁的是 **victim 那一趟**的挑戰值
  - Client 手上握的是 **attacker 那一趟**的原值
  - → 對不起來 → AS 拒絕（`invalid_grant`）
  - → **顏色錯位不會發生。**
- **同時檢查另一個缺口**：這整套不需要事先跟 AS 共享任何秘密 → **public client 也做得到**。
- **聽眾此刻應看出的事**：一個機制，**同時**補上了兩個來自不同段落的缺口。

### 5.4 現在才貼上名字

- **PKCE = Proof Key for Code Exchange**，四個字**對號入座**（讓聽眾自己對，不要直接念）：
  - **Proof** ← 我們需要一個證明（3.4 缺的）
  - **Key** ← 但不能是預先登記的 secret，要**臨時的**（4.4 缺的）
  - **for Code Exchange** ← 它保護的正是 code 換 token 那一步
- **物件對號入座**（貼回**沒有變過的圖**）：
  - 當場產的原值 → `code_verifier`
  - 算出來送出去的 → `code_challenge`
  - 算法 → `code_challenge_method`
- **規格細節（RFC 7636）**：
  - `code_verifier`：高熵亂數，43–128 字元，unreserved 字元集（§4.1）
  - `S256` = base64url(SHA256(verifier))；**"If the client is capable of using 'S256', it MUST use 'S256'"**（§4.2）
  - `plain`（直接把 verifier 當 challenge 送）在 RFC 7636 §7.2 是 **SHOULD NOT**，
    在 **OAuth 2.1 §7.5.2 已升級為明文禁止**：*"The `plain` code challenge method... is explicitly forbidden in OAuth 2.1."*
    理由：OAuth 2.1 要求 TLS 1.2+，而 TLS 1.2+ 本來就強制支援 SHA-256，
    所以「裝置算不動 hash」這個歷史藉口已不成立。

### 5.5 ★★ 回答開場那個問題（本場的著陸點）

- **把 1.1 的那個問句原樣搬回畫面**：「verifier 是 server 產還是 client 產？」
- **講者的回答**：
  > **這個問題問錯了。** 該問的是：**你的 OAuth client 是誰？**
- **唯一的規則（三者必須是同一個實體）**：
  > **誰發出 authorization request、誰保存 `code_verifier`、誰做 code exchange —— 必須是同一個。**
- **兩個對照案例**（用 1.2 的同一張角色圖，只換 Client 那格裡面裝的是誰）：
  - **BFF / 傳統 web app**：backend 持有 `client_id`、做 exchange → **backend 就是 Client** → **backend 產**
  - **SPA 或 native app 直接當 client**（backend 只提供自家 API，不參與 OAuth）→ **app 本身就是 Client** → **app 產**
- **必須打掉的錯誤直覺**：
  > **不是「有沒有 server」，是「誰做 code exchange」。**
  > 一個有 server 的應用，兩種都可能。
- **聽眾此刻應能自行完成的事**：說出自家專案屬於哪一種。

### 5.6 三份規格的立場（收尾）

| 文件 | 對 PKCE 的要求 |
|---|---|
| **RFC 7636**（2015） | 只談 public client。Abstract 第一句：*"OAuth 2.0 **public clients** ... are susceptible to the authorization code interception attack."* |
| **RFC 9700**（2025, Security BCP） | *"Public clients **MUST** use PKCE"*；*"For confidential clients, the use of PKCE is **RECOMMENDED**, as it provides strong protection against misuse and injection of authorization codes"*。例外：confidential 的 OIDC client **MAY** 改用 `nonce`。 |
| **OAuth 2.1 draft** | `code_challenge` **REQUIRED**，AS **MUST** 強制執行——**不再分 public / confidential**。 |

**OAuth 2.1 §7.5.1 的那個例外，逐字如下**（兩個條件必須**同時**成立）：

> *"...using `code_challenge` and `code_verifier` is REQUIRED for clients, and authorization servers MUST enforce their use, unless **both** of the following criteria are met:*
> - *The client is a confidential client.*
> - *In the specific deployment and the specific request, there is reasonable assurance by the authorization server that the client implements the OpenID Connect `nonce` mechanism properly."*
>
> *"**In this case, using and enforcing `code_challenge` and `code_verifier` is still RECOMMENDED.**"*

- **這個例外為什麼很弱（值得講一句）**：同節指出，靠 client 自己驗 `nonce`，**AS 無從確認它真的做了**；而且 nonce 是**事後**發現——token 已經發出去了，client 才在驗 ID token 時察覺不對。`code_challenge` 則是**事前**擋掉，AS 根本不會發出任何 token。
- **收尾的一句**：規格的態度已經從「public client 的補丁」走到「**authorization code flow 的預設**」。
- **這一頁同時把作者引言的問題 #3（有無 client_secret 對 PKCE 的影響）閉環**：有 secret 不代表不需要 PKCE，因為它們回答的是**不同的兩個問題**。

---

## 視覺語意與節奏

### 物件狀態如何一致標示

| 語意 | 表現 |
|---|---|
| **browser = 載具** | 一台車。它不是角色，它載著 RO 移動。第 6 步之後**車不再動**，這件事要看得出來。 |
| **code 的位置** | **車身外側的牌子**，不是車廂內的貨物。這是「URL 會離開管線」的視覺基礎，2.1 建立後全場沿用。 |
| **HTTPS** | 包住車的實心管線。管線裡安全，**到站後牌子還掛著**。 |
| **身份歸屬** | `code_V` / victim 的 token 用同一個顏色標記；attacker 的東西用另一個。**顏色錯位 = 攻擊成功**。 |
| **已發生 vs 淡化** | 淡化 = 已知但目前不在焦點（3.4 的上軌）。**淡化不等於消失**——victim 那一趟其實成功了。 |
| **檢查清單** | 固定版面的「項目 + 綠勾／紅叉」元件。出現在 **2.3（四綠）／3.2（三綠一紅）／3.4（四綠）**，版面必須一致，否則回聲無效。 |

### 哪些位置必須固定或預留

- **RO / Client / AS 三欄的水平位置，全場不得改變。** 3.4 的雙軌是同一組欄位垂直堆疊，5.3 直接重用。
- **1.2 第 4 步 browser 長出來時要預留空間**，不可推擠 Client / AS 兩格。
- **5.3 必須是 3.4 的同一張圖**，只加物件，不重新排版。同圖不同結果是這一頁全部的力量來源。

### 哪些資訊必須延後命名

| 東西 | 最早可出現的位置 |
|---|---|
| Resource Owner / Client / Authorization Server | 1.2（且必須在 1.1 的歧義痛點之後） |
| confidential / public client | 3.1 |
| authorization code injection（這個詞本身） | 3.4 **結束後**，先讓聽眾看完再命名 |
| exfiltration / injection 這組對照 | 3.4 結束後，隨 OAuth 2.1 Historic note 一起打出 |
| PKCE / `code_verifier` / `code_challenge` | **5.4**，機制已在 5.2 推導完、5.3 驗證完之後 |
| S256 / `code_challenge_method` | 5.4 |

### 哪裡才揭露完整全貌

**沒有開場架構圖。** 全貌是 5.3 那張「同一張雙軌圖，但這次守住了」，以及 5.5 那張「Client 那格可以裝不同的東西」。聽眾應該在 5.3 感覺到：**每一個物件都是被前面某一個具體失敗逼出來的。**

### 節奏警告

- **第四段必須短（3–4 頁）。** 3.4 結束時聽眾的懸念會拉到最高（「那到底怎麼修」），implicit 是趁這個懸念插進來的**一個錯誤答案**。膨脹就會變成拖延。
- **2.2 不要提前洩底。** 那個「咦，都被保護得好好的？」是第二段的引擎。
- **3.2 不要同時討論兩件事。** 只讓焦點落在 secret 那一格。
- **2.3 講完直接進 3.1，中間不要插入任何東西。** 「沒有一格擋得住 → 怎麼多一格」是第二、三段之間唯一的接縫，插入任何一頁都會讓它斷掉（這正是舊版 2.4 造成的問題）。
- **3.4.0 是一格，不是一頁。** 它只回答「他的 code 哪來的」，講完立刻進雙軌演出。

---

## 技術限定與查證結果

### 已確認的前提與來源

| 主張 | 來源 |
|---|---|
| PKCE 原始 scope 只針對 public client | RFC 7636 Abstract |
| 手機 custom scheme 可被惡意 app 註冊並攔截 code | RFC 7636 §1 |
| public client MUST 用 PKCE；confidential RECOMMENDED；OIDC 可用 nonce 例外 | RFC 9700 §2.1.1 |
| code 的取得途徑（redirect_uri、referer、history、mix-up、open redirector）**皆不需破 TLS** | RFC 9700 §4.1–4.5 |
| **client authentication 擋不住 code injection**，因為做認證的是那個誠實的 client | RFC 9700 §4.5.2：*"...do not stop this attack, as the legitimate client authenticates at the token endpoint."* |
| implicit 流程中 AS **不認證 client** | RFC 6749 §1.3.2 |
| implicit 的動機是「針對 browser app 最佳化」+「減少往返」 | RFC 6749 §1.3.2 |
| implicit 的 token **會曝露給其他能存取 user-agent 的應用** | RFC 6749 §1.3.2（原文警告） |
| implicit 應避免使用 / 已被移除 | RFC 9700 §2.1.2；OAuth 2.1 §10.1 |
| OAuth 2.1 的 `code_challenge` 為 REQUIRED，不分 client 類型 | draft-ietf-oauth-v2-1 §4.1.1 |
| verifier 43–128 字元、高熵亂數；capable 就 MUST 用 S256 | RFC 7636 §4.1 / §4.2 |
| **transform 的理由**：*"The 'S256' method protects against eavesdroppers observing or intercepting the 'code_challenge', because the challenge cannot be used without the verifier."* | RFC 7636 §7.2 |
| **`plain` 在 OAuth 2.1 已被明文禁止**（理由：verifier 以明文出現在 authorization request；且 TLS 1.2+ 本就強制 SHA-256，歷史藉口不成立） | OAuth 2.1 §7.5.2 |
| **native app 一律是 public client**；*"Secrets that are statically included as part of an app distributed to multiple users should not be treated as confidential secrets, as one user may inspect their copy and learn the shared secret."*；對 public native app 的 shared secret 認證 *"serves little value beyond client identification"* | RFC 8252 §8.4 / §8.5 |
| **public native app MUST 用 PKCE**；AS SHOULD 拒絕不帶 PKCE 的 native app 請求 | RFC 8252 §6 / §8.1 |
| **OAuth 2.1 §7.5.1 例外的逐字條件**：須**同時**滿足「client 是 confidential」與「AS 有合理保證該 client 正確實作 OIDC `nonce`」；即使如此 *"using and enforcing code_challenge and code_verifier is still RECOMMENDED"* | OAuth 2.1 §7.5.1 |
| **nonce 例外較弱**：AS 無從確認 client 真的驗了 nonce；nonce 是**事後**發現（token 已發出），code_challenge 是**事前**擋掉 | OAuth 2.1 §7.5.1 |
| **injection 雙向**：*"...can lead to both the attacker obtaining access to a victim's account, as well as a victim accidentally gaining access to the attacker's account."* | OAuth 2.1 §7.5.1 |
| **本場 3→5 段主線的規格背書（Historic note）**：*"Although PKCE... was originally designed as a mechanism to protect native apps from authorization code exfiltration attacks, all kinds of OAuth clients, including web applications and other confidential clients, are susceptible to authorization code injection attacks, which are solved by the code_challenge and code_verifier mechanism."* | OAuth 2.1 §7.5.1 |

### 為教學而合併／省略的細節

1. **不提 Resource Server**。第一段第 7 步「拿 token 問 user 資料」直接畫向 AS。
   —— 不影響此刻要理解的「誰有什麼」，因為本場所有攻防都發生在 code 與 token endpoint 之間。
2. **injection 只演 confidential 版本**。它在 public client 上同樣成立（而且更容易），但本段的敘事目的是「**連 confidential 都需要**」，演 public 會失焦。
3. **3.4.0 的外流途徑只列不推導**。mix-up attack 尤其被壓縮成一個名詞。
   —— 因為 3.4 只需要「攻擊者拿到了 code」這個前提，取得途徑用哪一種不影響推導。
4. **injection 的反向（victim 誤入攻擊者帳號）只由講者口頭帶過，不做畫面。**
   —— 規格有明文（OAuth 2.1 §7.5.1），但 3.4 已是全場最重的一頁，加第二個方向會失焦。
5. **`nonce` 作為 PKCE 替代方案**只在 5.6 講「例外條件是什麼、為何很弱」，不解釋 nonce 機制本身。
6. **1.1 那張圖不是錯的**，是**用詞**不夠精準。講者要明說這一點，不要讓聽眾覺得自己一直在寫錯的東西。

### 相對作者原案已修正的技術點（作者已確認接受編排）

1. **implicit 的因果反轉**：原案推論「public 必須 PKCE ⇒ implicit 廢棄」。實際是 implicit 因**自身**把 token 丟上前端通道而被廢；PKCE 是後來給 code flow 的補強。已改為第四段的「合理但走錯方向的嘗試」。
2. **`client_secret` 的設計目的**（原案第 87 行的自問）：它是 **client authentication**，不是為了防 code 被偷。在手機案例中擋住攻擊是**副作用**；injection 一出現，副作用即失效。
3. **「有 server 就 server 產」**（原案第 102 行）：在 SPA + API-only backend 的架構下會出錯。已改為「誰發出 authorization request、誰保存 verifier、誰做 exchange，必須是同一個實體」。
4. **「HTTPS 絕對安全」這個前提**：原樣保留會擋死第三段。已精確化為「管線裡偷不走，但 code 寫在 URL 上，URL 會離開管線」。
5. **「code 外流途徑」清單的位置**：曾短暫存在一頁 `2.4`，放在第二段末尾。**已移除。**
   問題不在內容，在**位置**——它服務的是一個當時還沒出現的需求（3.4 的 injection），
   聽眾在第二段末尾並不需要它，因此感覺不出它要說什麼；而且它**打斷了 2.3 → 3.1 的轉折**。
   現已改置於 **3.4.0**，此時聽眾自己會問「web app 的 code 哪來的」，它才是被逼出來的。
   附帶效益：2.1 的「URL 會離開管線」這個前提改為在 3.4.0 **第二次**被使用，份量比立刻消費掉更強。

### 查證結果（上一輪列為待確認的三項，已全部查完）

1. **OAuth 2.1 §7.5.1 的例外內容** —— **已查完，並發現例外比預期更窄**：須**同時**滿足「confidential client」與「AS 有合理保證 client 正確實作 OIDC nonce」，且即便如此仍 **RECOMMENDED** 使用 PKCE。已寫入 5.6，並補上「這個例外為什麼很弱」的規格理由。
2. **5.2 第 3 步的推導** —— **已查完，可升級為規格明文，不再是純教學路徑**。RFC 7636 §7.2 明說 S256 的作用就是防止 challenge 被觀察／攔截後被利用；OAuth 2.1 §7.5.2 更直接：不做這個 transform 得到的就是 `plain`，而 `plain` *"is explicitly forbidden in OAuth 2.1"*。講者**可以**說這是規格的設計理由。
3. **native app 的 secret 對所有安裝者是同一份** —— **已查完，RFC 8252 §8.5 有逐字依據**，並額外撿到一句更貼本場主線的話：對 public native app 要求 shared secret 認證 *"serves little value beyond client identification"*（只剩「宣稱」，沒有「證明」）。已寫入 3.1。

**目前 draft 內沒有未查證的技術主張。**

---

## 交接給 draft-to-deck

### 不可破壞的推導順序

```
1.1 歧義痛點（client 一個字兩個位置）
  └→ 1.2 塌縮成 RO ＋ browser 長出來        ← 沒有 1.1 的痛點，1.2 就只是名詞表
      └→ 1.3 「做 code exchange 的就是 client」
          └→ 2.1 前提改寫（URL 會離開管線）  ← 沒有這句，2.3 和 3.4 都失去基礎
              └→ 2.2 都很安全的「咦？」
                  └→ 2.3 手機 ＋ 四綠勾 → 「沒有一格擋得住，怎麼多一格？」
                      └→ 3.1 誰有能力多一格 → 3.2 五格三綠一紅
                          └→ 3.3 立起第一根軸（你是誰）
                              └→ 3.4.0 他的 code 哪來的  ← 沒有這格，3.4 的 code 憑空出現
                                  └→ 3.4 injection：五格**又全綠**（聽眾自己立起第二根軸）
                                      └→ 4.1–4.4 implicit 走錯方向
                                          └→ 5.1 兩個缺口並排
                                              └→ 5.2 現場推導（仍不命名）
                                                  └→ 5.3 重用 3.4 的圖
                                                      └→ 5.4 才命名
                                                          └→ 5.5 回答開場問題
                                                              └→ 5.6 三份規格的立場
```

**檢查清單是貫穿 2→3 段的視覺主軸**：`2.3 四格全綠` → `3.1 怎麼多一格` → `3.2 五格三綠一紅` → `3.4 五格又全綠`。這四步必須用**同一個版面**，否則 3.4 的震撼（清單變長了卻又全綠）會消失。

**特別注意**：4.x 整段排在 3.4 之後、5.x 之前，是刻意的。它借用聽眾既有的 implicit 知識，在懸念最高時插入一個錯誤答案。**不要為了「一條線走完」把它移到第三段之前**——那會讓 injection 變成 PKCE 的附加說明而不是逼出它的痛點。

### 每頁最重要的可見事件

| 頁 | 那一格 |
|---|---|
| 1.2 | 三個被當成同義詞的東西**塌縮成一格 RO**，然後 browser 從下方長出來 |
| 2.1 | code 被畫成**車身外側的牌子**，不是車廂裡的貨 |
| 2.3 | 檢查清單**四個綠勾全過** |
| 3.2 | 同一張清單**多出一格，紅叉** |
| 3.4 | `code_V` **跨畫面長距離飛回車上**；清單**變長了卻又全綠**；**顏色錯位** |
| 4.3 | 惡意 app 原封不動搬回來，這次接到的**不用再換** |
| 5.3 | **同一張雙軌圖，顏色錯位不再發生** |
| 5.5 | Client 那一格**換裝不同的東西**（backend／app），其餘不動 |

### 不能被濃縮成 bullet 的段落

- **1.2**：必須是動畫。塌縮這件事寫成條列就完全無效。
- **3.4**：必須是雙軌 + 逐格動畫。這是全場唯一無法用文字取代的一頁，也是作者明確要求「顯眼到不可能感覺不到」的地方。**預算不足時，其他頁都可以簡化，這頁不行。**
- **5.2**：必須一步一個 click。五個步驟一次出現，推導感就沒了。
- **5.3**：必須重用 3.4 的圖。做成新圖會失去「同一張圖、不同結果」的全部力量。

### 給實作者的提醒

- 檢查清單元件出現三次（2.3 / 3.2 / 3.4），**做成可重用的 component**，版面必須逐像素一致。
- RO / Client / AS 的欄位座標全場固定，建議抽成單一 layout 或共用常數。
- 3.4 的雙軌與 5.3 共用同一個 component，靠 props 控制「有沒有 PKCE」。
