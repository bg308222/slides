# Part 2 — Bitwarden 怎麼從「保護密碼」走到「保護資料」

## 承上：p1 只做完了一半

p1 走到最後，server 從頭到尾沒看過使用者的密碼。

但把場景換成密碼管理器，馬上就會發現不夠：
**server 就算完全不知道你的 master password，它照樣看得到你存在裡面的每一筆帳號密碼。**

密碼藏好了，資料還裸著。

=> p1 的思想（只交出剛好夠用的東西）要繼續往下推，
   從「server 不需要知道密碼」推到「**server 也不需要知道資料**」

## 一切的起點：只有兩個輸入

使用者身上只有兩樣東西：

- **email**
- **master password**

其他所有東西都是從這兩個推導出來的。這點很重要 ——
它代表 Bitwarden **不需要幫你保管任何東西**，你的裝置隨時可以自己重算一次。

```
email + master password
        │
        ▼
   Master Key          ← 一切的根
```

## 關鍵設計：從同一個根長出兩條路

Master Key 沒有直接拿去用，而是分岔成兩條**互相到不了對方**的路：

```
                    Master Key
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
  Master Password Hash            Stretched Master Key
  「證明我是我」                    「打開我的資料」
        │                               │
   送給 server                     留在本機，永不送出
```

- **左邊**這條送去 server，功能只有一個：讓 server 確認「你是你」
- **右邊**這條完全不離開裝置，功能只有一個：解開你的資料

兩條路算出來的東西**無法互相反推**。

=> 這就是整個設計的核心：
   **「認證」和「解密」被徹底切開。**
   server 手上握著的那條，跟解開資料的那條，是不同的東西。

所以 server 能驗證你的身分，卻**沒有能力**解開你的資料 ——
不是「它保證不看」，是它手上根本沒有那把鑰匙。

## Vault 不是直接用 Stretched Key 鎖的

直覺會以為 Stretched Master Key 直接拿去加密 vault，但 Bitwarden 多繞了一層：

```
建立帳號時，隨機產生一把全新的鑰匙 ── Symmetric Key
                                        │
                    ┌───────────────────┴──────────────────┐
                    │                                      │
        用它加密所有 vault 內容              被 Stretched Master Key 加密
                    │                                      │
                    ▼                                      ▼
            加密後的 vault                        Protected Symmetric Key
            （存在 server）                        （也存在 server）
```

**為什麼要多這一層？**

因為 vault 是被那把隨機鑰匙鎖的，而不是被密碼衍生物鎖的。
所以你**改 master password 的時候，不用把整個 vault 重新加密一遍** ——
只要用新的 Stretched Master Key 把那把隨機鑰匙重新包一次就好。

vault 裡的內容一個字都不用動。

=> 換鎖頭，不用換保險箱裡的東西

## 五個動作，其實只是在問三個問題

`register` / `login` / `unlock` / `lock` / `logout` 這五個動作，
差別只在三件事：

1. **本機記憶體裡，那幾把鑰匙在不在？**
2. **本機硬碟上，加密的 vault 在不在？**
3. **需不需要連上 server？**

### register

1. 輸入 email + master password
2. 本機算出 Master Key，再分岔出 Master Password Hash 和 Stretched Master Key
3. 本機隨機產生一把 Symmetric Key
4. 用 Stretched Master Key 把它包成 Protected Symmetric Key
5. 只把「email + Master Password Hash + Protected Symmetric Key」送去 server

=> server 從頭到尾只收到它打不開的東西

### login

1. 輸入 email + master password
2. 本機重算 Master Key → Master Password Hash，送去 server
3. server 比對通過，回傳「加密後的 vault + Protected Symmetric Key」
4. 本機用 Stretched Master Key 打開 Protected Symmetric Key，拿到 Symmetric Key
5. 用 Symmetric Key 解開 vault

=> 解密的每一步都發生在裝置上，server 全程只是個保管加密檔案的倉庫

### lock

把記憶體裡的 Master Key、Stretched Master Key、Symmetric Key **全部丟掉**。
但**加密後的 vault 留在裝置上**。

=> 鑰匙丟了，保險箱還在

### unlock

重新輸入 master password（email 本機已經有了）
→ 重算出 Master Key → Stretched Master Key
→ 打開留在本機的 Protected Symmetric Key
→ 解開留在本機的 vault

=> **完全不需要連網**。因為解密從來就不是 server 的工作，
   而該算的東西，用 email + master password 隨時可以重算出來

### logout

鑰匙丟掉，**加密後的 vault 也一併清掉**。

=> 保險箱都搬走了，下次要重新 login 才能跟 server 拿回來
   （所以 logout 之後必須連網，unlock 不用）

### 對照表

| | 記憶體裡的鑰匙 | 本機的加密 vault | 要連網嗎 |
|---|---|---|---|
| 已解鎖 | ✅ 有 | ✅ 有 | 否 |
| **lock** | ❌ 丟掉 | ✅ 留著 | 否 |
| **logout** | ❌ 丟掉 | ❌ 清掉 | 是 |

=> lock 和 logout 的差別，講白了就是「**加密後的 vault 有沒有留在裝置上**」。
   這也直接解釋了為什麼 unlock 可以離線、login 不行。

## 落地：同一個設計，在 CLI 上原封不動又出現一次

前面講的都還在架構層。但如果你用過 Bitwarden 的 CLI，會發現兩件怪事：

**怪事一：明明已經 `bw login` 了，`bw list items` 還是失敗。**

因為那是兩件不同的事：

- `bw login` → 拿到跟 server 講話的憑證 → **認證**
- `bw unlock` → 拿到解開本機資料的鑰匙 → **解密**

登入了不代表解得開 —— 這正是前面那個分岔，只是換了個場景又出現一次。

**怪事二：`bw unlock` 會吐一串 `BW_SESSION` 給你，之後帶著它就不用再打 master password。**

它的名字叫 session，但它**不是通行證，是一把鑰匙**。

原因是 CLI 每跑一次指令都是一個全新的 process，記憶體不共享。
unlock 辛苦推導出來的 Symmetric Key，如果不寫到硬碟上，下一個指令就沒了。
但明文寫下去等於 vault 永遠開著。所以做法是：

1. unlock 時用 master password 一路推到 Symmetric Key
2. 隨機產生一把新鑰匙（就是 `BW_SESSION`）
3. 用它把 Symmetric Key 加密後存在本機
4. 把這把鑰匙交給你

```
unlock 前：master password ──► Master Key ──► Stretched Master Key ──┐
                                                                     ├──► Symmetric Key ──► vault
unlock 後：BW_SESSION ───────────────────────────────────────────────┘
```

兩條路通往同一扇門。master password 的意義本來就只是「抵達 Symmetric Key」，
而 unlock 已經抵達過一次、把結果就地封存了。

=> 不用再打 master password，不是因為系統「記得你驗證過」，
   而是因為**該算的東西已經算完並鎖在本機了**

**那為什麼再 unlock 一次，前一把就不能用了？**

因為本機存放那份加密結果的地方**只有一格**。再 unlock 一次，就會產生一把全新的鑰匙、
把 Symmetric Key 重新鎖一遍、**覆寫掉原本那份**。

舊的那把沒有被撤銷、沒有被列入黑名單、也沒有任何人通知 server ——
它只是**再也沒有東西可以開了**。

> 不是「作廢」，是「換鎖」。舊鑰匙還在你手上，但那個鎖頭已經不存在了。

跟一般網頁的 session 對照就很清楚：

| | 網頁 session token | Bitwarden session key |
|---|---|---|
| 誰發的 | server | 本機自己隨機產生 |
| server 知道它嗎 | 知道，存在 session table | **完全不知道** |
| 怎麼撤銷 | server 刪掉那筆記錄 | 沒有撤銷，覆寫掉它能開的東西 |
| 本質 | 通行證（證明身分） | 鑰匙（解開資料） |

=> 連 session 管理都不需要 server 參與

順帶一提的安全意涵：**握有 `BW_SESSION` 等同於 vault 是開著的**，
不需要 master password、也不需要通過兩步驟驗證。
所以別把它寫進 shell history、`.bashrc` 或 CI log。

## 小結

回頭看 p1 那條線：

| | server 手上有什麼 |
|---|---|
| p1 第 1 步 | 你的密碼本人 |
| p1 第 4 步 | 一個驗證得了、但用不了的衍生值 |
| **Bitwarden** | 一個驗證得了、但用不了的衍生值 **+ 一整包它打不開的資料** |

同一個思想推到底：**只交出剛好夠用的東西。**

server 需要「確認你是你」，就只給它確認得了的那一份；
server 需要「幫你存資料」，那就只給它存得了、但打不開的那一包。

=> 它不是承諾不看，是**沒有能力看**。

而「認證」和「解密」徹底切開這件事，不是白板上的理論 ——
它在架構層出現一次，在你每天打的 `bw login` / `bw unlock` 裡又原封不動出現一次。

## 參考資料

- [Bitwarden Security Whitepaper](https://bitwarden.com/help/bitwarden-security-white-paper/)
  官方權威來源。Master Key 分岔成兩條路、Symmetric Key 被 Stretched Master Key 包成
  Protected Symmetric Key，這整條鏈的正式描述都在這。
  想深入的人看這篇，但它比較硬，簡報上不用照著念。

- [What encryption is used? — Bitwarden](https://bitwarden.com/help/what-encryption-is-used/)
  上面那篇的科普版，短很多。重點一句：所有加密都在你的裝置上完成，
  server 只負責存加密後的東西。

- [Vault timeout options — Bitwarden](https://bitwarden.com/help/vault-timeout/)
  對應 lock / logout 那段。官方明講 lock 會把 vault 資料留在裝置上、所以可以離線解鎖，
  而 logout 會把資料完全清除、必須連網重新驗證（含兩步驟驗證）。

- [Password Manager CLI — Bitwarden](https://bitwarden.com/help/cli/)
  對應最後的 CLI 段落。官方原話就是 *"a session key which acts as a **decryption key**"* ——
  直接證明它是鑰匙而不是通行證。也說明了 login 和 unlock 是兩件分開的事。

- [Decrypting Bitwarden Secrets — attie.co.uk](https://attie.co.uk/bitwarden/decrypt/)
  對社群對本機 `data.json` 的逆向分析，說明 `BW_SESSION` 實際上解開的是哪一格。
  「再 unlock 一次會覆寫掉原本那份」的機制來自這裡 ——
  官方文件只寫「session key 在 lock / logout 前都有效」，沒有正面講這件事。
  所以簡報上建議講「新的 unlock 會讓舊的開不了東西」，
  而不是「官方會撤銷舊 session」。
