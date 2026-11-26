# 知識檔：SPNEGO 與 NTLM（給作者備課用，不是草稿）

> 整理 `user-draft.md` 裡標了「待確認」「不確定」「沒研究」的地方，以及讀稿時發現會影響主線的技術前提。
>
> **這一版每條主張都回到原文查證過**（2026-11-25 讀取）。標記：
>
> - ✅ 已在原文找到依據，附章節與原句（英文原句保留，方便你上台被問時直接引用）
> - 🟡 原文沒有直接寫，但可由已查證的事實推得；或只有部分被證實
> - ⚠️ 官方文件裡**查不到**，只是實務觀察或常見說法 → 不要當成事實講，要講就先實測
> - ❌ 上一版寫錯或寫得不精確，這一版已修正
>
> 用詞沿用上週：金票 = TGT、藍票 = service ticket（ST）、app 的金鑰 = 服務帳號的 secret key／keytab。

---

## 查證後的修正摘要

| 上一版的說法 | 查證結果 |
|---|---|
| Kerberos 機制 OID 出自 RFC 4121 | ❌ 出自 **RFC 2743 §1.1.4**（RFC 4121 正文沒列這個 OID） |
| Microsoft 另有一個「舊版」Kerberos OID | ❌ 不是「舊版」，是 **Windows 2000 的編碼錯誤**（數值被截斷成 16 bits），後來為了相容保留下來（MS-SPNG 附註 <10>） |
| 瀏覽器收到 Basic 會跳出「原生」帳密框 | 🟡 MDN 只說 client 會 prompt 使用者，沒有說「原生」 |
| 瀏覽器不處理 Bearer | ⚠️ RFC 6750 與 MDN 都沒寫，是實際行為觀察 |
| Negotiate 失敗時瀏覽器會改走 Basic | ⚠️ 查不到。Chromium 文件只寫「挑最安全的 scheme、不理 server 的偏好」 |
| 瀏覽器不會跳框問 Kerberos 密碼 | ❌ 要分平台。Linux／macOS 的 Chrome ✅ 不會（原始碼）；**Windows 會跳框，而且手打的帳密仍可能走 Kerberos**（§3.5） |
| 非網域 Windows → 退回 NTLM（引用 MS-NLMP「server is not joined to a domain」） | ❌ 引用錯了：那句講的是 server，不是 client。已改寫（§3.5） |
| NTLM 的 3 則訊息必須在同一條 TCP 連線上 | 🟡 RFC 4559、MS-NTHT 都沒明寫；只有 RFC 4559 §6 提醒 proxy 不可共用「已驗證的連線」，MS-NLMP 也把 HTTP 這類用法歸在 connection-oriented 變體。實務上的確如此，但不是規格原文 |
| Windows 預設不讓程式拿 TGT 的 session key（AllowTgtSessionKey） | ⚠️ 這次在 Microsoft Learn 找不到可引用的頁面 → 建議**從講稿拿掉**，改用已查證的「LSA 保存票與 NT hash」講法 |
| server 驗票不需聯絡 AD | 🟡 RFC 4120 沒有一句話這樣寫，但 §3.2.3 列出的驗證步驟只用到 server 的金鑰、時間與 authenticator，沒有聯絡 KDC 這一步 |
| `krb5_verify_init_creds` 是用來防 KDC spoofing | 🟡 MIT 頁面只說「驗證票來自知道 keytab 金鑰的 KDC」，沒寫 spoofing；**「KDC spoofing」這個詞出自 mod_auth_kerb 文件與 RFC 4120 §3.1.5／§10 的精神** |
| MIT ccache 類型 | 🟡 不只 5 種，共 7 種：FILE、DIR、KEYRING、KCM、MEMORY、API、MSLSA |
| Spring Security Kerberos 支援 SPNEGO | ⚠️ 官方文件網址失效，未查證 → 移除 |

---

## 0. 先講最會影響主線的一件事：server 從頭到尾都不需要 TGT

```text
目前說法：第一章「server 如何取得 tgt」、第三章「瀏覽器比較有權限取得 tgt」
問題類型：概念錯置（會讓整條主線的目標設錯）
為什麼：app 需要的是 service ticket ＋ authenticator（合稱 AP-REQ），不是 TGT。
       RFC 4559 §4.2：Authorization: Negotiate 後面放的是「the base64 encoding of an InitialContextToken」，
       也就是 GSS-API 的 token；用 Kerberos 時裡面裝的是 AP-REQ。
       RFC 4120 §3.2.2：「The Authenticator is encrypted in the session key and combined with the ticket
       to form the KRB_AP_REQ message」——裡面是藍票，不是金票。
       （例外：delegation。RFC 4121 §4.1.1：「a ticket-granting ticket will be transferred in a KRB_CRED
        message」，也就是 client 刻意把 TGT 轉送給 server，讓 server 代替使用者存取後端。本場可不談。）
建議：把第一章的問題改成「server 怎麼拿到一張『這個使用者』的藍票？」
```

- ✅ RFC 4559 §4.2、RFC 4120 §3.2.2、RFC 4121 §4.1.1（原句如上）

---

## 1. 第一章：「以 server 為核心」的直觀方案

### 1.1 這個方案真的存在，而且最後兩步不是多餘的

「使用者在網頁輸入帳密 → server 拿去 AD 換 TGT → 再換一張給自己的藍票 → 自己解開」是真實存在的做法。

- ✅ **mod_auth_kerb**（Apache 模組）的 `KrbMethodK5Passwd`：「To enable or disable the use of password based authentication for Kerberos v5.」
  （文件沒有明寫「透過 Basic」，但這個模式就是 server 自己拿密碼去換票。）

**為什麼要多換一張自己的藍票？** 因為 server 只換到 TGT 的話，攻擊者可以假冒 AD 回應：

- ✅ mod_auth_kerb 文件：「the module must also verify that KDC hasn't been deliberately faked and the ticket just received can be trusted.」
  `KrbVerifyKDC`：「verification tickets against local keytab to prevent KDC spoofing atacks」（原文拼錯 atacks）
- ✅ RFC 4120 §10：「the credentials obtained in the AS exchange may first be used in a TGS exchange to obtain credentials for a local server」「Those credentials must then be verified by a local server through successful completion of the Client/Server exchange.」
- ✅ RFC 4120 §3.1.5：「If the host wishes to verify the identity of the user, it MUST require the user to present application credentials」
- ✅ MIT `krb5_verify_init_creds`：「attempts to verify that creds were obtained from a KDC with knowledge of a key in keytab」

台上可以這樣講：假 AD 不知道 server 的金鑰，做不出 server 解得開的藍票。**server 驗身分靠的永遠是「我解得開這張藍票」**——和後面 SPNEGO 的 server 端是同一件事。

### 1.2 你列的三個問題

| 你的說法 | 判定 | 依據 |
|---|---|---|
| 1. 帳密直接進到 server | ✅ 正確 | RFC 7617 §4（講 Basic，同理）：「Because Basic authentication involves the cleartext transmission of passwords」。上週 Kerberos 的出發點就是密碼不要給每個 app。 |
| 2. server 不容易把 TGT 存到使用者電腦（klist） | 🟡 **做不到，也不該做**——但「做不到」沒有單一原文 | klist 讀的是**使用者電腦本地**的票快取：MIT `klist`「will display the credentials in the default credentials cache」✅；Windows 的票由 LSASS 保存 ✅（見 §3.3）。HTTP 驗證框架（RFC 9110 §11）只有 server 出題、client 作答，**沒有任何讓 server 把票寫進 client 的機制**——這是從規格內容推得，沒有一句話直接寫「做不到」。「不該做」：TGT 是 server 換出來的，代表 server 也握有一份能冒充使用者的金票。 |
| 3. server 沒權限去使用者電腦拿 TGT | 🟡 結論對，原因要改 | 不是「權限不足」，而是 server 在網路另一端，**沒有通道**讀使用者電腦的記憶體。上一版提的 `AllowTgtSessionKey` 查不到可引用的官方頁，**建議不講**。 |

### 1.3 第一章收尾

畫面上的痛點：**使用者電腦上明明已經有金票（klist 看得到），server 卻用不到它。**
能用到它的，只有在同一台電腦上、以使用者身分執行的程式 → 瀏覽器剛好就是。

---

## 2. 第二章：`WWW-Authenticate` 與 `Authorization`

### 2.1 這兩個 header 是怎麼搭配的

- ✅ RFC 9110 §11.3：「A 401 (Unauthorized) response message is used by an origin server to challenge the authorization of a user agent」
- ✅ RFC 9110 §11.6.1：server「MUST send a WWW-Authenticate header field containing at least one challenge」
- ✅ RFC 9110 §11.3：client 回應時「can do so by including an Authorization header field with the request」，而且是「usually, but not necessarily, after receiving a 401」
- ✅ **多個 challenge**，RFC 9110 §11.6.1：「it might contain more than one challenge」「the header field itself can occur multiple times」
- ✅ **client 怎麼挑**，RFC 9110 §11.4：「selecting the challenge with what it considers to be the most secure auth-scheme that it understands」
- ✅ **proxy 版本**，RFC 9110 §11.3、§11.7：`407` + `Proxy-Authenticate` / `Proxy-Authorization`
- ✅ RFC 9110 取代 RFC 7235（Abstract：「obsoletes RFCs … 7235」）
- ✅ scheme 名稱登記在 IANA「HTTP Authentication Scheme Registry」（RFC 9110 §11.1）
- ✅ MDN 列出的 scheme：Basic、Bearer、Digest、HOBA、Mutual、**Negotiate / NTLM**（合併成一項，連到 RFC 4559）、VAPID、SCRAM、AWS4-HMAC-SHA256

```text
client → GET /report
server ← 401 Unauthorized
         WWW-Authenticate: <scheme> [參數]
client → GET /report
         Authorization: <scheme> <credentials>
server ← 200 OK（或再一次 401，繼續下一輪）
```

### 2.2 `Basic`：瀏覽器會幫你做事

- ✅ RFC 7617 §2：「constructs the user-pass by concatenating the user-id, a single colon (":") character, and the password」，再 base64。
- ✅ RFC 7617 §2：「The authentication parameter 'realm' is REQUIRED」
- ✅ **明文**：RFC 7617 §1「passed over the network as cleartext」；MDN：「base64 is a reversible encoding」「Basic authentication offers no cryptographic security」
- ✅ **之後自動帶上**：RFC 9110 §11.5「the user agent MAY reuse the same credentials for all other requests within that protection space」；RFC 7617 §2.2「A client MAY preemptively send the corresponding Authorization header field」
- 🟡 **跳框**：MDN「Usually a client will present a password prompt to the user」。是否為「原生」對話框，文件沒寫——台上說「瀏覽器自己跳出帳密框」即可，DevTools 現場看得到。

對主線的用途：server 只回一個 header，瀏覽器就自己跳框、自己記住、之後每次自己送。但 Basic 送的是密碼，**就是第一章「帳密進到 server」的那個方案**。

### 2.3 `Bearer`：有些 scheme 瀏覽器不會理

- ✅ RFC 6750 §3 範例：`WWW-Authenticate: Bearer realm="example", error="invalid_token", error_description="The access token expired"`
- ✅ 錯誤碼（§3.1）：`invalid_request`（400）、`invalid_token`（401）、`insufficient_scope`（403）
- ⚠️ 「瀏覽器收到 Bearer challenge 不會做任何事」**RFC 6750 與 MDN 都沒寫**。這是實際行為，上台前在瀏覽器實測一次，以畫面為證，不要說成「規格規定」。
  可以講的推論：token 要從 OAuth 流程拿，瀏覽器沒有內建這個流程，所以只能顯示 401 頁面，由前端程式自己處理。

### 2.4 `Negotiate`：今天的主角

- ✅ RFC 4559：「auth-scheme of "negotiate" is defined here」；類別 **Informational**，作者來自 Microsoft。
- ✅ RFC 4559 §4.1：「The initial WWW-Authenticate header will not carry any gssapi-data.」——第一次 401 只寫 `Negotiate`，不帶參數。
- ✅ RFC 4559 §4.2：client 送的是「the base64 encoding of an InitialContextToken」
- ✅ RFC 4559 §4.1：成功的回應「can also carry a "WWW-Authenticate" response header containing the final leg of an authentication」（mutual auth 時 server 用它證明自己）
- ✅ 可以多輪，RFC 4559 §5：「This cycle can continue until the security context is complete.」
- ✅ RFC 4559 §6：「It provides no facilities for protecting the HTTP headers or data」——只驗身分，不保護內容，要搭 TLS。

### 2.5 瀏覽器「什麼時候」才會自動走 Negotiate

依據：Chromium 設計文件〈HTTP authentication〉（文件仍使用舊名稱 `AuthServerWhitelist`，可能有點舊）、Microsoft Edge policy 文件、Mozilla policy-templates。

| 項目 | 結果 |
|---|---|
| Windows，沒設允許清單 | ✅ Chromium：「By default, this includes servers in the Local Machine or Local Intranet security zones.」Edge：「If you don't configure this policy, Microsoft Edge tries to detect if a server is on the intranet」 |
| macOS／Linux，沒設允許清單 | ✅ Chromium：「Integrated Authentication is only enabled when Chrome receives an authentication challenge from a proxy」→ **網站一律不會自動送**，要設 `AuthServerAllowlist` |
| Firefox | ✅ policy `Authentication` → `SPNEGO`，對應 `network.negotiate-auth.trusted-uris`（policy-templates 頁標示「NOT current」，建議以 firefox-admin-docs 為準） |
| Intranet 區域怎麼自動判定 | ⚠️ 未查證，demo 前實測 |

**SPN 怎麼組**：

- ✅ Chromium：「The default SPN is: HTTP/<host name>, where <host name> is the canonical DNS name of the server.」——**HTTPS 也一樣用 `HTTP/`**（RFC 4559 §4.1 也寫「a principal name of the form of "HTTP/hostname"」，但沒提 HTTPS）
- ✅ CNAME：Chromium「If left unset or set to false, Chrome uses the canonical name.」（`DisableAuthNegotiateCnameLookup`）
- ✅ port：Chromium「If set to true, the port is appended. Otherwise (or if left unset) the port is not used.」（`EnableAuthNegotiatePort`）
- ✅ **用 IP 連線**：Microsoft Learn〈Kerberos over IP〉「By default Windows will not attempt Kerberos authentication for a host if the hostname is an IP address.」「It will fall back to other enabled authentication protocols like NTLM.」
  Windows 10 1507／Server 2016 起可用登錄值 `TryIPSPN` 開啟，「This entry does not exist in the registry by default.」

**多個 scheme 時 Chrome 挑哪個**：

- ✅ Chromium：「we choose the most secure scheme, and we ignore the server or proxy's preference.」排序 Negotiate(4) > NTLM(3) > Digest(2) > Basic(1)。
- ⚠️ Negotiate **失敗後**是否改走 Basic，文件沒寫。

---

## 3. 第三章：SPNEGO

### 3.1 名字拆開

- ✅ RFC 4178 §1：SPNEGO「is a pseudo security mechanism that enables GSS-API peers」決定要用哪個真正的機制。
- ✅ RFC 4178 取代 RFC 2478（Abstract：「replaces RFC 2478 in order to fix defects」）。
- ✅ SPNEGO 自己的 OID 是 `1.3.6.1.5.5.2`（RFC 4178 §4.2）。
- ✅ Windows：MS-SPNG 附註 <3>「By default, the Kerberos protocol and NTLM are available in Windows.」

### 3.2 怎麼協商（修正「瀏覽器透過 OS 環境決定」）

```text
目前說法：瀏覽器透過 OS 環境決定可以走哪一條認證機制
問題類型：過度簡化
為什麼：協商是 client 和 server 兩邊的事：
       - client 列出清單：RFC 4178 §3.1「in decreasing preference order (favorite mechanism first)」
         清單依 client 手上的憑證而定：§3.2「a list of one or more security mechanisms that are available
         based on the credentials used」
       - server 挑：§3.1「the target SHALL choose the first mechanism in the initiator proposed list for
         which it has valid credentials.」
建議：講成「client 依自己手上有的憑證列出清單，server 從頭挑第一個自己也能接的」。
```

訊息結構（✅ RFC 4178 §3.1、§4.2.1、§4.2.2）：

```text
client → NegTokenInit
           mechTypes: [Kerberos, NTLM]          ← 依偏好排序
           mechToken: <第一志願的 token>         ← RFC 稱為 "optimistic mechanism token"
server → NegTokenResp
           negState: accept-completed(0) / accept-incomplete(1) / reject(2) / request-mic(3)
           supportedMech
           responseToken
           mechListMIC                          ← 確保清單沒被竄改
```

- ✅ Windows 預設把 Kerberos 當第一志願：MS-SPNG 附註 <5>「Windows implementations use Microsoft Kerberos as the preferred optimistic mechanism by default.」
- ✅ mechListMIC 的作用：RFC 4178 §1「the negotiation is protected to ensure that the mechanism list has not been modified.」
  ❗ 限定條件：§7「When the selected mechanism does not support integrity protection, the negotiation is vulnerable」——不是無條件防降級。

**機制的 OID**：

| 機制 | OID | 依據 |
|---|---|---|
| Kerberos v5 | `1.2.840.113554.1.2.2` | ✅ RFC 2743 §1.1.4 |
| Kerberos（Microsoft 版） | `1.2.840.48018.1.2.2` | ✅ MS-SPNG 附註 <10>：Windows 2000 實作錯誤，「truncated the values at 16 bits」；之後 Windows 兩種都接受 |
| NTLM | `1.3.6.1.4.1.311.2.2.10` | ✅ MS-SPNG §4 範例 `…Microsoft(311).security(2).mechanisms(2).ntlm(10)` |

### 3.3 「瀏覽器比較有權限」要怎麼講才對

```text
目前說法：瀏覽器去 call 底層 library，所以比較有權限取得 TGT
問題類型：概念與實作混淆
為什麼：瀏覽器沒有特權，也不碰 TGT。它在使用者電腦上、以登入使用者的身分執行，
       呼叫 OS 的 API 請 OS 產生 token；票由 OS 保存、由 OS 拿去換。
建議：講成「瀏覽器不碰票，它請 OS 幫忙產生一個 token」。
```

- ✅ 瀏覽器呼叫的介面，Chromium：「On Windows, Negotiate is implemented using the SSPI libraries and depends on code in secur32.dll.」Linux 載入 `libgssapi_krb5.so.2`（找不到再試 `libgssapi.so.4/.2/.1`）。
- ✅ 票由 OS 保存，Microsoft Learn〈Credentials processes in Windows authentication〉列出 LSASS 保存的東西：「Kerberos tickets (ticket-granting tickets (TGTs), service tickets)」「NT hash」；用途：「The stored credentials let users seamlessly access network resources … without reentering their credentials for each remote service.」
- ✅ Linux 的票快取，MIT 文件：7 種類型（FILE、DIR、KEYRING、KCM、MEMORY、API、MSLSA），預設 FILE；`klist` 讀預設快取。

### 3.4 Kerberos 這條路完整走一遍

共同前段：

1. 瀏覽器 `GET https://app.corp.example/`
2. server 回 `401` + `WWW-Authenticate: Negotiate`（✅ RFC 4559 §4.1）
3. 瀏覽器檢查網址在不在允許範圍（§2.5）→ 組 SPN `HTTP/app.corp.example` → 呼叫 SSPI／GSS-API
4. OS 依票快取的狀態走以下三種情況之一

**情況 A：klist 已有 `HTTP/app.corp.example` 的藍票**
- 不聯絡 AD，直接用藍票 ＋ 新的 authenticator 組成 AP-REQ（✅ RFC 4120 §3.2.2）。

**情況 B：沒有藍票，但有有效 TGT**
- 用 TGT 向 AD 換藍票（TGS exchange）：✅ RFC 4120 §3.3「The KRB_TGS_REQ message includes information authenticating the client plus a request for credentials.」
- 換到的票放進快取（`klist` 會多一張）→ 接情況 A。
- SPN 不存在時 AD 回錯：✅ RFC 4120 §7.5.9 `KDC_ERR_S_PRINCIPAL_UNKNOWN`（7）「Server not found in Kerberos database」。
- Kerberos 失敗時退回 NTLM：✅ Microsoft Learn〈Microsoft Negotiate〉「Negotiate selects Kerberos unless one of the following conditions applies」「Otherwise, Negotiate always selects the NTLM security provider.」〈Deprecated features〉「tries to authenticate with Kerberos and only falls back to NTLM when necessary.」

**情況 C：連 TGT 都沒有（或過期）**

| 環境 | 會發生什麼 | 查證 |
|---|---|---|
| 加入網域的 Windows、用網域帳號登入 | LSASS 保存了登入時的憑證，TGT 過期後能自動重拿，使用者無感 | 🟡 Protected Users 文件反過來證實這件事：加入該群組後「Kerberos also doesn't cache the user's plaintext credentials, or long-term keys after acquiring the initial」TGT，且 TGT 不能續期超過 4 小時——代表**一般帳號預設會保存** |
| TGT 快到期但可續期 | 續期 | ✅ RFC 4120 §2.3 renewable ticket；AD 預設：使用者票 **10 小時**、續期上限 **7 天**、服務票 **600 分鐘**（Microsoft Learn 各 policy 頁「Default Domain Policy」欄） |
| Linux／macOS（Chrome）沒先 `kinit` | Negotiate 在 client 端就產生不出 token → 停用 Negotiate，改用 server 給的下一個 scheme；沒有就顯示 401 頁面。**不會為了 Kerberos 跳框問密碼** | ✅ Chromium 原始碼，流程見 §3.5 |
| Windows，跳框讓使用者輸入帳密 | **不一定是 NTLM**，見 §3.5 | ✅ 見 §3.5 |

`klist purge` 後重新整理網頁，看 TGT 和藍票一起重新出現——仍然是很好的 demo，但這屬於實測，上台前跑一次。

共同後段（server 端）：

5. server 用自己的金鑰解藍票：✅ RFC 4120 §3.2.3「The ticket is decrypted using the version of the server's key specified by the ticket.」
6. 檢查 authenticator 的時間與重放：✅ RFC 4120 §3.2.3「allowable clock skew (e.g., 5 minutes)」；「the server MUST utilize a replay cache」。AD 預設容許 **5 分鐘**（✅ Microsoft Learn policy 頁）。
7. 🟡 **server 不聯絡 AD**：RFC 4120 沒有一句話直接寫；但 §3.2.3 的驗證步驟沒有聯絡 KDC 這一步。上週草稿已用同樣講法。（AD 的 PAC 驗證例外：MS-APDS §1.4.2，server 可透過 Netlogon 請 DC 驗 PAC。）
8. mutual auth：✅ RFC 4120 §3.2.4 KRB_AP_REP；放在 `200` 回應的 `WWW-Authenticate: Negotiate <token>`（✅ RFC 4559 §4.1）。
9. ⚠️ 「驗完後 server 通常發自己的 session cookie」是常見實作，不是規格內容，講的時候說「通常」。

### 3.5 收到 `401 Negotiate` 時跳出帳密框，一定是 NTLM 嗎？

**不一定。在 Windows 上，輸入的帳密交給 Negotiate 後，仍然優先走 Kerberos。**

1. ✅ **框是瀏覽器跳的，帳密會交給 OS 的 Negotiate**：Chromium `http_auth_sspi_win.cc`：`AllowsExplicitCredentials()` 回傳 `true`；`// Pass the username/password to get the credentials handle.` 接著呼叫 `AcquireCredentialsHandleW`，把帳密當作 `pAuthData` 傳進去。
2. ✅ **SSPI 本來就接受「不是目前登入者」的帳密**：〈AcquireCredentialsHandle (Negotiate)〉「or the caller can provide alternative credentials.」；不傳時（`NULL`）才是「the default credentials for that security package」。
3. ✅ **拿到帳密後，Negotiate 怎麼選**：〈Microsoft Negotiate〉「Negotiate selects Kerberos unless one of the following conditions applies」：
   - 「It can't be used by one of the systems involved in the authentication.」
   - 「The calling app didn't provide sufficient information to use Kerberos.」
   → 這兩條都跟「帳密是自動帶的還是手打的」無關。
4. 🟡 **手打的密碼怎麼變成 Kerberos**：Kerberos 一定要先有這個使用者的 TGT，而從密碼拿到 TGT 的唯一途徑就是向 AD 做 AS exchange（RFC 4120 §3.1）——也就是上週「輸入帳密 → 換到 TGT」那一步，只是現在由 OS 在背景做。Microsoft 文件**沒有逐字寫**「手打的帳密會拿去做 AS exchange」，這是由 1～3 推得的。
5. ⚠️ **實務條件**：要走 Kerberos，client 還得找得到、連得到該網域的 AD，SPN 也必須正確。非網域電腦能不能找到 AD 這次沒有查到原文。

**所以「跳框」只告訴你「瀏覽器沒有自動帶身分」**（例如網址不在 Intranet／允許清單：Chromium「If a challenge comes from a server outside of the permitted list, the user will need to enter the username and password.」），**不告訴你最後走哪一條**。要知道走哪一條，還是看 token 開頭（§4.6）。

| 平台 | 跳框後打帳密 | 依據 |
|---|---|---|
| Windows（Edge／Chrome） | 交給 Negotiate，Kerberos 能用就走 Kerberos，不能才 NTLM | ✅ 1～3；🟡 4 |
| Linux／macOS（Chrome） | Negotiate 不接受手打的帳密 | ✅ Chromium 原始碼（見下方） |
| Firefox | 未查證 | ⚠️ |

#### 先跳框，還是先協商？——「協商」其實有兩層

依據：Chromium 原始碼 `net/http/`（main 分支，2026-11-26 讀取）的 `http_auth.cc`、`http_auth_controller.cc`、`http_auth_handler_negotiate.cc`、`http_auth_gssapi_posix.cc`。

| 層次 | 誰決定 | 什麼時候 |
|---|---|---|
| **第一層：用哪個 HTTP scheme**（Negotiate／NTLM／Basic…） | 瀏覽器自己挑，**不問 server** | 收到 401 時，**跳框之前** |
| **第二層：SPNEGO 裡用 Kerberos 還是 NTLM** | OS 產生 token 時決定（Windows SSPI／Linux GSSAPI），再由 server 從清單中挑 | 產生 token 的當下，**拿到帳密之後** |

Chrome 收到 401 後的順序（`HttpAuthController::HandleAuthChallenge`）：

1. **挑 scheme**：`HttpAuth::ChooseBestChallenge`「Choose the challenge whose authentication handler gives the maximum score.」建立失敗的 handler 直接 `continue` 跳過。
2. **挑身分來源**（`SelectNextAuthIdentityToTry`），依序：
   1. 網址裡的帳密：「Try to use the username:password encoded into the URL first.」
   2. 這次瀏覽期間存下的帳密：「Check the auth cache for a realm entry.」
   3. 登入電腦時的身分（SSO），只試一次：`if (!default_credentials_used_ && handler_->AllowsDefaultCredentials())`；註解「Use default credentials (single sign-on) if they're allowed and this is the first attempt」
3. **都沒有時**：
   ```cpp
   if (!handler_->AllowsExplicitCredentials()) {
     // If the handler doesn't accept explicit credentials, then we need to
     // choose a different auth scheme.
     InvalidateCurrentHandler(INVALIDATE_HANDLER_AND_DISABLE_SCHEME);
   } else {
     // Pass the challenge information back to the client.
     PopulateAuthChallenge();   // ← 這就是「跳框」
   }
   ```
4. **產生 token**：帳密（或 SSO 身分）交給 SSPI／GSSAPI，`auth_system_->GenerateAuthToken(credentials, spn_, …)`。**第二層的 Kerberos／NTLM 選擇在這裡才發生。**

**結論（Windows）**：先決定用 Negotiate → 不能自動帶身分（網址不在允許範圍），或自動帶的身分被 server 拒絕（`default_credentials_used_` 已用過）→ 跳框拿帳密 → 帳密交給 SSPI → 這時才選 Kerberos 或 NTLM。
也就是說，**跳框發生在 Kerberos／NTLM 協商之前**。框跳出來時，連第一個 SPNEGO token 都還沒產生。

#### 為什麼 mac／Ubuntu 的 Chrome 連框都不跳

你提的兩個選項都不完全對：
- 不是「瀏覽器沒法跳框」：同一台電腦收到 `Basic` 照樣會跳。
- 也不是「Kerberos 和 NTLM 都協商失敗」：根本沒有協商，**一個 SPNEGO token 都沒有送出去**。

真正的原因：**Linux／macOS 上的 Negotiate 不接受手打的帳密，所以 Chrome 不會為它跳框。**

- ✅ `http_auth_gssapi_posix.cc`：`AllowsExplicitCredentials()` 在非 ChromeOS 回傳 `false`。
- ✅ `http_auth_handler_negotiate.cc` 的 `Init`：「GSSAPI does not provide a way to enter username/password to obtain a TGT」「If the default credentials are not allowed for a particular site (based on allowlist), fall back to a different scheme.」→ `if (!AllowsDefaultCredentials()) return false;`

分兩種情況：

| 情況 | Chrome 做了什麼 | 結果 |
|---|---|---|
| 網址**不在**允許清單（mac／Linux 預設就是不在，見 §2.5） | 建立 Negotiate handler 時就失敗，第一步挑 scheme 時直接跳過 Negotiate | server 若有給其他 scheme（如 Basic）→ 改用它（Basic 會跳框）；**只給 Negotiate → 沒有可用的 scheme** → `// We found no supported challenge -- let the transaction continue so we end up displaying the error page.` → 顯示 401 頁面 |
| 網址**在**允許清單，但沒有 Kerberos 票（沒 `kinit`、或 `kdestroy` 過） | GSSAPI 產生第一個 token 時就失敗（`GSS_S_NO_CRED` → `ERR_INVALID_AUTH_CREDENTIALS`；沒有 ccache → `ERR_MISSING_AUTH_CREDENTIALS`，註解「Occurs with GSSAPI, if the user has not already logged in.」） | 因為不能改問帳密，Negotiate 被停用（`INVALIDATE_HANDLER_AND_DISABLE_SCHEME`）→ 同上，改用下一個 scheme 或顯示 401 頁面 |

兩種情況的失敗都發生在 **client 本機**，server 從頭到尾不會收到任何 `Authorization` header。

**「跳過 Negotiate、改看下一個 scheme」不會額外去問 server**：✅ `HttpAuth::ChooseBestChallenge` 只列舉**同一個 401 回應**裡的 `WWW-Authenticate` header（`response_headers.EnumerateHeader(&iter, header_name)`），跳過被停用的 scheme（`!disabled_schemes.contains(...)`）。server 只給 `Negotiate` 時就找不到可用的 handler，直接把那個 401 的內容顯示出來。

兩種情況送出的請求數不同：

| 情況 | 實際送出的請求 |
|---|---|
| 不在允許清單 | **1 次**：GET → 401 Negotiate → 當場找不到可用的 handler → 顯示 401 頁面 |
| 在允許清單、沒有票 | **2 次**：GET → 401 Negotiate → Chrome 準備重送，在組 header 時呼叫 GSSAPI 產生 token → 失敗 → 停用 Negotiate，但 ✅ 這次重送照樣發出，只是沒帶 header（`AddAuthorizationHeader` 註解：「auth_token_ can be empty if we encountered a permanent error with the auth scheme and want to retry.」）→ server 再回 401 Negotiate → Negotiate 已停用 → 顯示 401 頁面 |

🟡 第二種情況的「重送照樣發出」是讀 `HttpNetworkTransaction`（`DoGenerateServerAuthToken` → `BuildRequestHeaders`）推得的流程，DevTools 實測時應該會看到兩個 401。

🟡 Linux 上 GSSAPI 用的是 SPNEGO 機制（原始碼 `CHROME_GSS_SPNEGO_MECH_OID_DESC`，OID 1.3.6.1.5.5.2），但系統的 GSSAPI 函式庫裡有沒有 NTLM 機制，要看安裝了什麼套件，這次未查證。一般只有 Kerberos，所以在 mac／Linux 上，Negotiate 實務上幾乎等於 Kerberos。

#### 寫死的範圍：只有「Negotiate 不跳框」

- ✅ **寫死在編譯時**：`AllowsExplicitCredentials()` 用 `#if BUILDFLAG(IS_CHROMEOS)` 決定，非 ChromeOS 的版本直接 `return false`，沒有任何 policy 能改。`AuthServerAllowlist` 只影響「能不能自動帶 Kerberos 票」（`AllowsDefaultCredentials`），不影響跳框。
- ✅ **但 mac 上的頁面仍可能跳框**，取決於 server 還給了哪些 scheme：
  - Chrome 在 mac／Linux 上的 **NTLM scheme**（`WWW-Authenticate: NTLM`）是 Chrome 自己實作的，`http_auth_handler_ntlm_portable.cc`：「Default credentials are not supported in the portable implementation of NTLM」→ 不能 SSO；而 `AllowsExplicitCredentials()` 沿用基底類別的 `return true` → **會跳框**，手打的帳密直接算 NTLM 回應。
  - `Basic` 同樣會跳框。
- 🟡 所以在 mac 上看到帳密框，如果 server 同時給了 `Negotiate` 和 `NTLM`，那個框是 **NTLM scheme 的**，不是 Negotiate 的。⚠️ IIS 的 Windows 驗證是否預設同時送出這兩個 header，這次未查證，請實測（DevTools 看 401 的 response header）。

⚠️ 以上只適用 Chrome／Chromium 系。Firefox、Safari 未查證。

**對上一版的修正**：上一版 §3.4 情況 C 寫「非網域 Windows → Kerberos 用不了 → 退回 NTLM」，並引用 MS-NLMP「The server is not joined to a domain.」。這句講的是 **server** 沒加入網域，不是 client，引用錯了，已改寫。

### 3.6 server 端要先準備什麼

- ✅ `setspn -S`：「Adds the specified SPN for the computer, after verifying that no duplicates exist.」
- ✅ `ktpass`：讓「non-Windows services that support Kerberos authentication」使用 AD，並「generates a .keytab file that contains the shared secret key of the service.」
- ✅ keytab，MIT：「A keytab (short for "key table") stores long-term keys for one or more principals.」
- ✅ Apache `mod_auth_gssapi` README：「relies on Microsoft's IANA registered www-authenticate: Negotiate auth scheme to provide Kerberos and NTLM authentication to web browsers」，範例設定 `GssapiCredStore keytab:/etc/httpd.keytab`。（它取代了 mod_auth_kerb）

---

## 4. 第四章：SPNEGO 的另一條路——NTLM

主要依據：**[MS-NLMP]** v20261110、**[MS-NTHT]** v20240423、**[MS-APDS]** v20250113（都從 Microsoft Open Specifications 的 PDF 原文查證）。

### 4.1 它是什麼、什麼時候會用到

- ✅ MS-NLMP §1.3：「NTLM is a challenge-response style authentication protocol.」
- ✅ MS-NLMP §1：「Kerberos authentication [MS-KILE] replaces NTLM as the preferred authentication protocol. However, NTLM can be used when the Kerberos Protocol Extensions (KILE) do not work」，列出的情境：
  - 「One of the machines is not Kerberos-capable.」
  - 「The server is not joined to a domain.」
  - 「The KILE configuration is not set up correctly.」（例如 SPN 沒註冊）
  - 「The implementation chooses to directly use NLMP.」
- ✅ 用 IP 連線也會退回 NTLM（§2.5）。
- ⚠️ 「client 連不到 DC 的 port 88 就會退回 NTLM」**這次沒有找到原文**，實務上常見，要講請標「常見情況」。

### 4.2 最核心的一件事：NT hash

- ✅ MS-NLMP §3.3.1：`Define NTOWFv1(Passwd, User, UserDom) as MD4(UNICODE(Passwd))`——這就是 NT hash，**沒有加鹽**。
- ✅ NTLMv2 的金鑰也從它推出，MS-NLMP §3.3.2：
  `NTOWFv2 = HMAC_MD5( MD4(UNICODE(Passwd)), UNICODE(Uppercase(User) + UserDom) )`
- 🟡 **Pass-the-Hash**：上面的公式顯示，算回應只需要 `MD4(UNICODE(Passwd))`，不需要原始密碼 → 拿到 NT hash 就能登入。這是從公式推得的結論；MS-NLMP 本身沒用「pass-the-hash」這個詞。
  可以接回你們 PBKDF2 系列的講法：「資料庫裡這個值也能直接通過登入；拿到它的人不需要還原密碼。」
- ✅ LSASS 會保存 NT hash（§3.3 引用的 Credentials processes 頁）→ 這就是 NTLM 也能 SSO 的原因（§4.5）。

### 4.3 流程：三則訊息、兩次 401

✅ MS-NLMP §1.3.1.1（connection-oriented 流程）＋ MS-NTHT §4.1（HTTP 範例）：

```text
C: GET /dir/index.html
S: 401  WWW-Authenticate: NTLM                         ← 不帶資料（MS-NTHT §2.2.1「MUST NOT carry any auth-data」）
C: Authorization: NTLM <NEGOTIATE_MESSAGE>             ← 「我要用 NTLM，我支援這些選項」
S: 401  WWW-Authenticate: NTLM <CHALLENGE_MESSAGE>     ← 含 server 產生的隨機值
C: Authorization: NTLM <AUTHENTICATE_MESSAGE>          ← 使用者名稱 + 回應
S: 200
```

- ✅ 每則訊息開頭 8 bytes 是 ASCII `NTLMSSP\0`（MS-NLMP §2.2.1）。
- ✅ 挑戰值 8 bytes，MS-NLMP §2.2.1.2：「ServerChallenge (8 bytes): A 64-bit value that contains the NTLM challenge.」
- ✅ 回應的計算，MS-NLMP §3.3.2：
  ```text
  temp        = 版本 + Time + ClientChallenge + ServerName(目標資訊)
  NTProofStr  = HMAC_MD5(ResponseKeyNT, ServerChallenge + temp)
  回應        = NTProofStr + temp
  ```
  → 密碼與 NT hash 都不在網路上傳。
- ✅ MS-NLMP §1.3.1.1：AUTHENTICATE_MESSAGE「contains the name of a user and a response that proves that the client has the user's password.」
- ✅ **HTTP header 名稱**：MS-NTHT 定義的 scheme 是 `NTLM`；MS-NTHT §1.3「the NTLM over HTTP Protocol authentication variant only works with NTLM. The Kerberos protocol is not supported.」§1.6：用在「SPNEGO-based Kerberos and NTLM HTTP authentication … are not available」的環境。
  → 實務上兩種都會看到：`WWW-Authenticate: Negotiate`（SPNEGO 協商後走 NTLM）或 `WWW-Authenticate: NTLM`（直接 NTLM）。

### 4.4 server 怎麼驗——和 Kerberos 最關鍵的差別

✅ MS-NLMP §1.3.1.1：「If the user name is for a domain account, it can validate the response by sending the user authentication information (the user name, the challenge sent to the client, and the response received from the client) to a」DC。
✅ MS-APDS §1.4.1：「NTLM authentication ([MS-NLMP]) uses the Netlogon pass-through authentication ([MS-NRPC] section 3.2) to authenticate the user in the domain with the domain controller」
✅ MS-APDS §3.1.5：「The NTLM server SHOULD invoke the NetrLogonSamLogonEx method」

```text
web server ──(Netlogon)──▶ DC：「alice 對這個挑戰回了這個，對嗎？」
           ◀───────────── DC：「對，她是 alice」
```

| | Kerberos | NTLM | 查證 |
|---|---|---|---|
| server 驗證時要不要聯絡 AD | 不用（PAC 驗證例外） | **每次都要** | 🟡 Kerberos 側見 §3.4 第 7 點；✅ NTLM 側見上方 MS-APDS |
| server 有沒有證明自己是真的 | 有（AP-REP） | **沒有** | ✅ MS-NTHT §5.1「does not provide any facilities for mutual authentication; therefore, server identities cannot be verified.」 |
| HTTP 來回 | 通常 1 次 | 2 次 | ✅ RFC 4559 §4、MS-NTHT §4.1 |
| 依賴 SPN／主機名 | 是 | 否 | ✅ Kerberos over IP 頁（用 IP 就退回 NTLM） |
| 連線要求 | 無特別要求 | 實務上 3 則訊息要在同一條連線 | 🟡 MS-NLMP 把這類用法歸為「connection-oriented」變體；RFC 4559 §6 要求 proxy「must take care to not share authenticated connections between different authenticated clients」。**「一定要 keep-alive」沒有原文明寫**，要講就說「實務上」 |

### 4.5 NTLM 為什麼也能 SSO

✅ LSASS 保存 NT hash（Credentials processes 頁），OS 直接用它算回應，使用者不用再打密碼。
所以「沒跳框」不代表走的是 Kerberos——要看 token 開頭或 `klist`。

### 4.6 從 token 開頭看走哪一條（demo 用）

| 開頭 | 意義 | 查證 |
|---|---|---|
| `YII…`／`YIG…` | 第一個 byte 是 `0x60`＝GSS-API 初始 token（SPNEGO 包裝，通常裡面是 Kerberos） | ✅ RFC 2743 §3.1「0x60 -- Tag for [APPLICATION 0] SEQUENCE」；本機驗證：`60 82 …` → `YII`，`60 81 …` → `YIG`（長度 ≥256 bytes 時是 `YII`，Kerberos token 通常屬於這種） |
| `TlRMTVNTUA…` | 解碼是 `NTLMSSP\0` → **走的是 NTLM，而且沒有 SPNEGO 外層** | ✅ 本機驗證 base64(`NTLMSSP\0`) = `TlRMTVNTUA`；✅ MS-SPNG 附註 <8>：特定條件下「Windows clients in this case send an NTLM token instead of an SPNEGO token.」 |

🟡 「Windows 在 Kerberos 不可用時，`Negotiate` header 裡直接放 NTLM token」：MS-SPNG 只在 NTLM 是雙方最優先機制的條件下寫到這件事；一般「Kerberos 失敗就退回」的情境沒有逐字寫明。**demo 時以畫面為準**。

### 4.7 NTLM 的弱點

- 🟡 **Pass-the-Hash**：由 §4.2 的公式推得。
- ✅ **server 不證明自己**（MS-NTHT §5.1）→ 🟡 **NTLM Relay**：攻擊者在中間把 client 的回應轉給另一台 server。這是由「沒有 mutual auth」推得的攻擊類型；EPA／channel binding、SMB／LDAP signing 等緩解措施這次**未查證官方頁**，要講請先查。
- ✅ **DC 負擔**：每次驗證都要找 DC（MS-APDS）。

### 4.8 Microsoft 的現況

- ✅ **NTLM 已 deprecated**（Microsoft Learn〈Deprecated features〉，宣布時間 **2024 年 6 月**）：「All versions of NTLM, including LANMAN, NTLMv1, and NTLMv2, are no longer under active feature development」；但「Use of NTLM will continue to work in the next release of Windows Server and the next annual release of Windows.」——**deprecated 不等於移除**。
- ✅ **NTLMv1 已移除**（〈Removed features〉）：「NTLMv1 is removed starting in Windows 11, version 24H2 and Windows Server 2025.」
- ✅ **IAKerb／Local KDC**（Windows IT Pro Blog〈The evolution of Windows authentication〉，2023-10-11）：「Our team is building new features for Windows 11, Initial and Pass Through Authentication Using Kerberos (IAKerb)」；「NTLM will continue to be available as a fallback to maintain existing compatibility.」
- ✅ **補充**：MS-SPNG 附註 <9>：Windows 11 24H2／Server 2025 起支援 SPNEGO 的「Late Fallback」，**預設關閉**。
- ✅ **Protected Users 群組**：成員「Authenticate with NTLM authentication」會被拒（針對向 DC 驗證的情況）；client 端「NTLM stops caching the user's plaintext credentials or NT one-way function (NTOWF).」

---

## 5. 建議上台前實測的項目

以下都是 ⚠️／🟡 的項目，只能靠實測確認：

1. 網域 Windows + Edge 連 IIS：DevTools 看 `Negotiate YII…`；`klist` 前後比對；`klist purge` 後重新整理。
2. 同一台改用 **IP** 連：看是否變成 `TlRMTVNTUA…`、出現兩次 401（Kerberos over IP 頁已證實會退回 NTLM，header 長相要實測）。
3. 網址不在 Intranet／允許清單：看瀏覽器是跳框還是直接 401。
4. 回 `WWW-Authenticate: Bearer`：確認瀏覽器只顯示 401 頁面。
5. （選用）Linux + Firefox：沒 `kinit` 時的行為、`kinit` 後成功。

---

## 6. 來源索引

| 主題 | 來源 | 狀態 |
|---|---|---|
| HTTP 驗證框架 | RFC 9110 §11 | ✅ 已讀 |
| Basic | RFC 7617；MDN〈HTTP authentication〉、〈Authorization〉、〈WWW-Authenticate〉 | ✅ 已讀 |
| Bearer | RFC 6750 §3 | ✅ 已讀 |
| HTTP Negotiate | RFC 4559 | ✅ 已讀 |
| SPNEGO | RFC 4178；[MS-SPNG] v20261026 | ✅ 已讀 |
| GSS-API token 格式、Kerberos OID | RFC 2743 §1.1.4、§3.1 | ✅ 已讀 |
| Kerberos | RFC 4120；RFC 4121 §4.1.1 | ✅ 已讀 |
| NTLM | [MS-NLMP] v20261110；[MS-NTHT] v20240423 | ✅ 已讀（PDF） |
| NTLM 找 DC 驗證 | [MS-APDS] v20250113 | ✅ 已讀（PDF） |
| 瀏覽器 | Chromium〈HTTP authentication〉；Edge policy：AuthServerAllowlist、DisableAuthNegotiateCnameLookup、EnableAuthNegotiatePort、AuthSchemes；Mozilla policy-templates `Authentication` | ✅ 已讀（Chrome Enterprise policy 頁無法讀取，以 Edge 對應頁替代） |
| Windows 行為 | Microsoft Learn：Microsoft Negotiate、Kerberos over IP、Credentials processes in Windows authentication、Protected Users、Kerberos policy 預設值 4 頁、setspn、ktpass | ✅ 已讀 |
| NTLM 淘汰 | Microsoft Learn〈Deprecated features〉、〈Removed features〉；Windows IT Pro Blog 2023-10-11 | ✅ 已讀 |
| Server 端模組 | mod_auth_kerb 設定頁、mod_auth_gssapi README、MIT krb5 文件（krb5_verify_init_creds、ccache、keytab、klist） | ✅ 已讀 |
| AllowTgtSessionKey、Spring Security Kerberos、IIS Kerberos 疑難排解 | — | ⚠️ 頁面 404 或查無結果，未使用 |
