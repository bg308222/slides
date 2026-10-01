---
theme: neversink
title: 2026 年 9 月月報
info: |
  innovue 月報 — 2026 年 9 月
neversink_slug: 2026 年 9 月月報
layout: cover
color: cyan
transition: slide-left
mdc: true
---

# 2026 年 9 月月報

<div class="pt-4">andy.lin</div>

---
layout: default
---

# 本月概覽

| 客戶 — 系統 | 項目 | 狀態 |
|---|---|---|
| 統一超商 — ETSNet | 證據批次核可功能 | <span class="text-teal-600">已完成</span> |
| 力山 — EPSNet | 資料庫無法連線排查 | <span class="text-teal-600">已解決</span> |
| 大同 — EPSNet + ECSNet | 更換系統 logo | <span class="text-teal-600">已完成</span> |
| 特力 — EPSCore + ETSCore | 人資串接停止執行 | <span class="text-amber-600">已暫時恢復，待客戶回覆</span> |
| 船舶 — EDUCore | 弱掃問題處理 | <span class="text-teal-600">已完成</span> |

<div class="mt-4 px-4 py-1 bg-gray-500/10 rounded">

本月多數項目的解法都落在**主程式之外**：前端 js、load balancer、OS 帳號設定、DB 主機環境。唯一動到程式的大同 logo，也是先確認不會影響其他廠商才改。

</div>

---
layout: section
color: cyan-light
---

# 統一超商 — ETSNet

證據批次核可功能

---

# 從單筆簽核到批次同意

<div class="grid grid-cols-2 gap-4 mt-6">

<div v-click class="p-4 border-l-4 border-gray-400 bg-gray-500/5">

**原本**

待簽核列表 → 選一筆案件 → 進簽核頁 → 單筆同意

</div>

<div v-click class="p-4 border-l-4 border-amber-500 bg-amber-400/5">

**廠商需求**

在列表頁直接勾選多筆，**批次同意**

</div>

</div>

<div v-click class="mt-6 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**實現方式** — 只寫一支 js，只在該列表頁生效

1. 在列表上畫出 checkbox 與「批次同意」button
2. 點擊後，對每個選取的 row 呼叫**原本簽核頁「同意」時的 API**

</div>

<div v-click class="mt-6 p-4 bg-gray-500/10 rounded">

純前端完成，**server 一行都不用改**。批次只是重複呼叫既有的單筆同意，簽核邏輯沒有多出一條要另外驗證的路徑。

</div>

---
layout: section
color: cyan-light
---

# 力山 — EPSNet

資料庫無法連線排查

---

# 和上個月不同的原因

<div class="text-sm opacity-70">
上個月也無法連線，但那次是勒索軟體把 mdf 加密；這次沒有被勒索。
</div>

<v-clicks>

<div class="mt-5 p-3 border-l-4 border-teal-500 bg-teal-400/5">

**① 重新啟用 MSSQLSERVER** — 可以正常連線至 DB

</div>

<div class="mt-3 p-3 border-l-4 border-amber-500 bg-amber-400/5">

**② 數秒後，防毒軟體（Athena EPP Agent）隔離了一個檔案**

<div class="text-xs mt-1 font-mono opacity-80">

Virus Name: CoinMiner.Win32.Agent.Vfxy　·　Type: Cryptomining<br>
c:\users\mssqlserver\appdata\local\temp\systemasap\…\systemasap.dll

</div>

</div>

<div class="mt-3 p-3 border-l-4 border-red-500 bg-red-400/5">

**③ MSSQLSERVER 隨即被中止** — 又連不上了

</div>

</v-clicks>

---

# 判斷與處置

<v-clicks>

- 經排查，那個 dll **確實不是 MSSQL 原生的東西**
- 所以沒有貿然把它放進防毒白名單 —— 放行等於讓挖礦程式繼續跑

</v-clicks>

<div v-click class="mt-8 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**處置** — 客戶決定在本機重裝 MSSQL，重裝後問題確實解決。

</div>

---
layout: section
color: cyan-light
---

# 大同 — EPSNet + ECSNet

更換系統 logo

---

# 預期只是換一張圖

<v-clicks>

<div class="p-4 mb-3 border-l-4 border-gray-400 bg-gray-500/5">

**原本預期** — 換一張圖就好，不用改程式。

</div>

<div class="p-4 mb-3 border-l-4 border-amber-500 bg-amber-400/5">

**遇到的問題** — ECS 的 logo 限制為 **250×98**，且使用 **gif**。廠商的 logo 有圓形，無論怎麼試，都沒辦法在這個像素下讓圓形不出現鋸齒。

</div>

<div class="p-4 mb-3 border-l-4 border-teal-500 bg-teal-400/5">

**決定** — 改程式，讓原本 load gif 的地方改 load **svg**，直接用原圖、不用轉檔。

</div>

</v-clicks>

<div v-click class="mt-4 p-4 bg-gray-500/10 rounded">

**為什麼可以直接改程式**：dotnet 版未來的更新全都走獨立版，不會影響其他廠商。

</div>

---

# 同步訂下的政策

<div class="mt-2 text-sm opacity-70">
這次的問題不會只發生一次，所以順帶定下往後的做法
</div>

<v-clicks>

<div class="mt-6 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**所有系統圖統一改用 svg**

</div>

<div class="mt-3 p-4 border-l-4 border-gray-400 bg-gray-500/5">

**沒碰到的就不動**；一旦碰到，就改成 svg

</div>

<div class="mt-3 p-4 border-l-4 border-gray-400 bg-gray-500/5">

**美術之後也只交付 svg**

</div>

</v-clicks>

---
layout: section
color: cyan-light
---

# 特力 — EPSCore + ETSCore

人資串接停止執行

---

# 同一個問題，第二次發生

<v-clicks>

- 問題與 **2025-04-08** 那次相同
- 觀察 log，**2025-10-05** 之後就沒有再執行
- 原因：帳號密碼到期 —— Rocky Linux 預設 **180 天**到期

</v-clicks>

<div v-click class="mt-6 flex items-center gap-3 text-sm">
  <div class="px-3 py-2 rounded border border-gray-400">2025-04-08<br><span class="opacity-60">上次處理</span></div>
  <div class="opacity-60">— 180 天 →</div>
  <div class="px-3 py-2 rounded border border-red-500 bg-red-400/5">2025-10-05<br><span class="opacity-60">密碼到期，停止執行</span></div>
</div>

<div v-click class="mt-6 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**暫時處置** — 更新密碼後即可正常執行。

</div>

---

# 提供給客戶的長期方案

<div class="grid grid-cols-2 gap-4 mt-6">

<div v-click class="p-4 border-l-4 border-teal-500 bg-teal-400/5">

**方案一：密碼設為永不到期**

180 天是 Rocky Linux 的預設值，我方沒有這方面的安全性要求。

<div class="mt-2 text-sm opacity-70">
適用：客戶也沒有對應的安全政策
</div>

</div>

<div v-click class="p-4 border-l-4 border-gray-400 bg-gray-500/5">

**方案二：我方定期更換密碼**

到期時間不一定要 180 天，可以調整。

<div class="mt-2 text-sm opacity-70">
適用：客戶有相對應的安全要求
</div>

</div>

</div>

<div v-click class="mt-6 p-4 border-l-4 border-amber-500 bg-amber-400/5">

**目前狀態：等待客戶回覆。** 不做決定的話，「到期 → 停擺 → 手動改密碼」會一直循環下去。

</div>

---
layout: section
color: cyan-light
---

# 船舶 — EDUCore

弱掃問題處理

---

# 本月處理的兩項

| 弱掃項目 | 處理方式 | 狀態 |
|---|---|---|
| Permissive HSTS Policy (98715) | 原本就有 `max-age=31536000`，加上 `includeSubDomains` | <span class="text-teal-600">已完成</span> |
| Host Header Injection (98623) | haproxy 覆寫 forwarded headers | <span class="text-teal-600">已完成</span> |

<div class="mt-8 p-4 bg-gray-500/10 rounded">

兩項都在 **lb（haproxy）** 完成，**沒有改主程式**。

</div>

---

# Host Header Injection — 為什麼會被打中

<div v-click class="p-3 border-l-4 border-red-500 bg-red-400/5">

**掃描的攻擊方式** — 請求帶上偽造的 `X-Forwarded-Host`，response 中竟然就出現攻擊字串

</div>

<div v-click class="mt-4">

**原因** — 主程式設定為信任前一關 proxy 帶來的 header：

```csharp
options.ForwardedHeaders = ForwardedHeaders.All;
options.KnownNetworks.Clear();
options.KnownProxies.Clear();
```

</div>

<div v-click class="mt-2 p-3 bg-gray-500/10 rounded text-sm">

`KnownNetworks` / `KnownProxies` 預設只信任 loopback；被清空後**不再限定來源**，任何人送來的 forwarded header 都會被採用。

</div>

---

# 處理方式：主程式不動，lb 把關

<style>
.slidev-code { font-size: 0.6rem !important; line-height: 1.5 !important; padding: 0.5rem 0.6rem !important; }
</style>

<div class="text-sm opacity-70">
這段設定可能有歷史因素，不考慮拿掉。既然主程式相信前一關 lb，lb 就應該把好關。
</div>

<div class="grid grid-cols-2 gap-4 mt-4">

<div v-click class="p-3 border-l-4 border-gray-400 bg-gray-500/5">

**原本就有：Host 白名單**

```text
acl valid_host hdr(host) -i ${validHost.join(" ")}
http-request deny deny_status 400 unless valid_host
```

<div class="text-sm opacity-70">不在名單內的 Host 直接回 400</div>

</div>

<div v-click class="p-3 border-l-4 border-teal-500 bg-teal-400/5">

**這次加上：一律覆寫 forwarded headers**

```text
http-request set-header X-Forwarded-For %[src]
http-request set-header X-Forwarded-Host %[req.hdr(host)]
http-request set-header X-Forwarded-Proto http
```

<div class="text-sm opacity-70">http、https 兩份 template 都已加上</div>

</div>

</div>

<div v-click class="mt-4 p-3 border-l-4 border-teal-500 bg-teal-400/5">

**兩段配起來才安全**：白名單擋 Host，覆寫擋 X-Forwarded-Host —— 能進到主程式的 Host 一定合法，由它填入的 X-Forwarded-Host 也一定合法。

</div>

---
layout: center
class: text-center
---

# 總結

<div class="mt-6 text-left inline-block">

- **統一超商 ETSNet** — 一支前端 js 呼叫既有同意 API 完成批次核可，server 未改動
- **力山 EPSNet** — 挖礦程式被防毒隔離導致 MSSQL 中止，未放行可疑 dll，重裝後解決
- **大同 EPSNet + ECSNet** — gif 無法呈現圓形 logo，改用 svg，並訂下系統圖一律 svg
- **特力 EPSCore + ETSCore** — 密碼 180 天到期導致停擺，已暫時恢復，長期方案待客戶回覆
- **船舶 EDUCore** — 弱掃兩項皆在 haproxy 處理完成，未改主程式

</div>

---
layout: default
---

# 參考資料

- [Configure ASP.NET Core to work with proxy servers and load balancers | Microsoft Learn](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer)
- [Strict-Transport-Security header | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Strict-Transport-Security)
