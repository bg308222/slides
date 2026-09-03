---
theme: default
title: 2026 年 8 月月報
info: |
  innovue 月報 — 2026 年 8 月
class: text-center
transition: slide-left
mdc: true
---

# 2026 年 8 月月報

<div class="pt-4 opacity-60">andy.lin</div>

---
layout: default
---

# 本月概覽

| 客戶 — 系統 | 項目 | 狀態 |
|---|---|---|
| STD — EPSCore | 簽核 error 問題處理 | <span class="text-teal-600">已修正</span> |
| 慧榮 — EPSNet | 滲透測試缺失修補 | <span class="text-amber-600">部分完成</span> |
| 力山 — EPSNet | 勒索軟體事件應變 | <span class="text-teal-600">已復原</span> |

<div class="mt-8 p-4 bg-gray-500/10 rounded">

本月的三件事都不是新功能，而是**既有系統的體質與資安**：
一個長年繞過的老問題、一份滲透測試報告、一次資安事件。

</div>

---
layout: section
---

# STD — EPSCore

簽核 error 問題處理

---

# 一個反覆出現的老問題

<v-clicks>

- flow db 中存有 XML 非法字元（例如 `0x0B`）
- SOAP response 序列化時直接 error，**簽核流程當場中斷**
- 過去的處理方式：每次發生就做一次資料處理，把 db 中的非法字元置換成空格

</v-clicks>

<div v-click class="mt-8 p-4 border-l-4 border-amber-500 bg-amber-400/5">

這是事後補救 —— 資料只要再髒一次，同樣的 error 就再來一次。
這次重新評估後決定不再清資料，改從程式面修掉。

</div>

---

# 這次的處理

<v-clicks>

- 在 SOAP response 序列化之前，先把非法字元置換掉
- 由 service 自己在 return 前處理，不再依賴事後的資料清理

</v-clicks>

<div v-click class="mt-6 p-4 border-l-4 border-teal-500 bg-teal-400/5">

往後資料端就算再出現非法字元，簽核流程也不會再因此中斷。

</div>

---

# 順帶查清楚的一件事

同樣的非法字元，request 進來不會 error，response 出去才會

<div class="grid grid-cols-2 gap-4 mt-6">

<div v-click class="p-4 border-l-4 border-teal-500 bg-teal-400/5">

**進來** — 走 WCF 的 `XmlDictionaryReader`

客戶端把 `0x0B` 寫成字元參照 `&#xB;` 送進來，
這個 reader 收得下去，還原成真正的 `0x0B` 進到字串裡。

</div>

<div v-click class="p-4 border-l-4 border-red-500 bg-red-400/5">

**出去** — 走 `XmlWriter`

`CheckCharacters` 預設為 `true`，
碰到 `0x0B` 直接 throw。

</div>

</div>

<div v-click class="mt-6 p-4 bg-gray-500/10 rounded">

也就是同一個 `&#xB;`，SoapCore 的 reader 收得下去、writer 吐不出來。
讀寬鬆、寫嚴格，兩端用的根本不是同一個 XML 元件。

</div>

---
layout: section
---

# 慧榮 — EPSNet

滲透測試缺失修補

---

# 本月處理的三項缺失

| 缺失 | 處理方式 | 狀態 |
|---|---|---|
| Session Fixation | 採 OWASP 的 AntiFixationToken 做法 | <span class="text-teal-600">已完成</span> |
| 使用有漏洞的元件 | 不升版，直接改 jQuery 原始碼 | <span class="text-amber-600">進行中</span> |
| LUCKY13（TLS CBC） | 移除 CBC 相關 cipher suites | <span class="text-amber-600">待客戶端驗證</span> |

<div class="mt-8 text-sm opacity-70">
三項都來自客戶端的滲透測試報告。
</div>

---
clicks: 4
---

# Session Fixation — 攻擊怎麼發生

<div style="height: 348px" class="mt-2">
  <SessionFixation :step="$clicks" />
</div>

<div v-click="4" class="mt-2 text-sm opacity-70">
關鍵在第 ③ 步：登入前後如果是同一組 session id，那組 id 就從「匿名」升級成「已登入」。
</div>

---

# Session Fixation — 採用的解法

<div class="grid grid-cols-2 gap-4 mt-4">

<div v-click class="p-4 border-l-4 border-gray-400 bg-gray-500/5">

**理想解法**

登入完成的當下立刻換發新 session，
登入資訊只寫進新的，舊的作廢。

<div class="mt-2 text-sm opacity-60">
需要 framework 支援換發 session。
</div>

</div>

<div v-click class="p-4 border-l-4 border-teal-500 bg-teal-400/5">

**實際採用** — OWASP 提供的 workaround

1. 登入資訊照樣寫進原本的 session
2. 額外發一個 `AntiFixationToken` 到 cookies
3. 之後每個請求都驗這個 token，沒有就登出並導回登入頁
4. 手動登出時一併刪掉這個 cookie

</div>

</div>

<div v-click class="mt-6 p-4 bg-gray-500/10 rounded">

**為什麼有效**：攻擊者塞得了 session id，但塞不出登入完成後才發的 `AntiFixationToken`。

</div>

---

# 使用有漏洞的元件

<v-clicks>

- 掃描結果：`jquery 1.8.0`、`jquery 1.7.2`、`jquery-ui 1.7.2` 被標為有風險
- 專案過舊，升級版本的成本與回歸風險不成比例，**不考慮升級**
- 採用過去已決議的處理方式：直接改 jQuery 原始碼，分成兩個部分

</v-clicks>

<div class="grid grid-cols-2 gap-4 mt-6">

<div v-click class="p-4 border-l-4 border-teal-500 bg-teal-400/5">

**一、版本資訊改成 customize** — 已完成

讓掃描工具不會單憑版本號就判定有風險。

</div>

<div v-click class="p-4 border-l-4 border-amber-500 bg-amber-400/5">

**二、歷版風險手動修正** — 待做

把各版本中確實存在的問題逐一補掉。

</div>

</div>

<div v-click class="mt-6 p-4 border-l-4 border-red-500 bg-red-400/5">

第一部分只處理「被掃出來」，第二部分才是真的處理風險 —— **兩者不能互相取代**。

</div>

---

# LUCKY13（TLS CBC 系列造成的風險）

<v-clicks>

- 處理方式：至 Windows Server 設定機碼，移除 CBC 相關的 cipher suites
- 移除後出現預期外的狀況：**server 主機自己用 Chrome、curl 都連不上 website**
- 原因不明 —— 理論上 client 不會只支援 CBC suites

</v-clicks>

<div v-click class="mt-6 p-4 border-l-4 border-gray-400 bg-gray-500/5">

**我們家重現不出來**：預設就走 TLS 1.3，
即使 curl 硬指定 TLS 1.2，也會正確選到 GCM 系列的 suite。

</div>

<div v-click class="mt-4 p-4 border-l-4 border-amber-500 bg-amber-400/5">

**目前處置**：與對方約一個雙方窗口都在的時間，我們移除 suites 後請對方實際連線。
對方連得上，就不再追究 server 自己連不上的問題。

</div>

---
layout: section
---

# 力山 — EPSNet

勒索軟體事件應變

---

# 事件與處置

<v-clicks>

<div class="p-4 mb-3 border-l-4 border-red-500 bg-red-400/5">

**發現** — 排查時無法連線到 eps-db；
mdf 檔被改名為 `LT_EPS_Rexon_Data.mdf.NBLock`，同目錄多出一個要求付款的 README。

</div>

<div class="p-4 mb-3 border-l-4 border-amber-500 bg-amber-400/5">

**判定** — 勒索軟體加密，立即告知客戶。

</div>

<div class="p-4 mb-3 border-l-4 border-teal-500 bg-teal-400/5">

**復原** — 客戶確認有備份，還原 DB 後恢復正常。
同時提醒：**附件檔案也必須一併還原**，否則資料會對不起來。

</div>

</v-clicks>

---
layout: center
class: text-center
---

# 總結

<div class="mt-6 text-left inline-block">

- **STD EPSCore** — 把長年靠清資料繞過的問題，改成在 response 端 sanitize 根治
- **慧榮 EPSNet** — 三項缺失：session fixation 完成、jQuery 風險修正進行中、LUCKY13 待客戶端驗證
- **力山 EPSNet** — 勒索軟體加密 DB，靠客戶備份完成還原

</div>

---
layout: default
---

# 參考資料

- [Session Fixation Protection | OWASP Foundation](https://owasp.org/www-community/controls/Session_Fixation_Protection)
- [XmlWriterSettings.CheckCharacters Property (System.Xml) | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/api/system.xml.xmlwritersettings.checkcharacters)
- [Extensible Markup Language (XML) 1.0 — 2.2 Characters](https://www.w3.org/TR/REC-xml/#charsets)
- [DigDes/SoapCore — SOAP protocol middleware for ASP.NET Core](https://github.com/DigDes/SoapCore)
- [Lucky Thirteen: Breaking the TLS and DTLS Record Protocols](https://www.isg.rhul.ac.uk/tls/Lucky13.html)
