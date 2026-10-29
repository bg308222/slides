# Kerberos SSO 實戰說明

## 1. Kerberos SSO Overview

1. **取得 TGT**：登入網域，取得 TGT。
2. **取得 Service Ticket**：使用 TGT 申請目標系統的 Service Ticket。
3. **完成 SSO**：系統驗證 Service Ticket，取得使用者身分並登入。

## 2. Kerberos SSO Browser 視角

進入系統後，瀏覽器會嘗試透過 Kerberos 完成驗證：

- **已有 Service Ticket**：直接使用票證完成驗證。
- **沒有 Service Ticket，但有 TGT**：向 KDC 申請 Service Ticket。
- **沒有 TGT**：需要先取得 TGT；是否出現登入提示，取決於瀏覽器與作業系統的設定。
- **無法取得所需票證**：Kerberos SSO 失敗。

## 3. Mac 完成 Kerberos SSO

### 方式一：UI 操作

1. 開啟 `Ticket Viewer`。
2. 點選 `Add Identity`。
3. 輸入網域帳號與密碼。
4. 重新進入系統，即可嘗試使用 Kerberos SSO 登入。

### 方式二：CLI 操作

**1. 查看目前持有的票證**

```bash
klist
```

若尚無票證，可能顯示：

```text
klist: Cache not found: API:...
```

**2. 登入網域，取得 TGT**

```bash
kinit andy.lin@dev.lan
```

輸入密碼後，確認票證：

```bash
klist
```

此時應可看到 `krbtgt/DEV.LAN@DEV.LAN`。

**3. 取得目標系統的 Service Ticket**

```bash
kvno HTTP/eps.in.innovue.ltd@dev.lan
```

再次執行 `klist`，確認清單中出現目標服務的 Service Ticket。

**4. 重新進入系統**

確認票證取得成功後，重新進入系統，即可測試 Kerberos SSO。

> 可透過 `kdestroy -a` 刪除所有票