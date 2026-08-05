---
theme: default
title: 2026 年 7 月月報
info: |
  innovue 月報 — 2026 年 7 月
class: text-center
transition: slide-left
mdc: true
---

# 2026 年 7 月月報

<div class="pt-4 opacity-60">andy.lin</div>

---
layout: default
---

# 本月概覽

| 項目 | 內容 | 狀態 |
|---|---|---|
| 統一超商 — EPSNet | 商標資料批次匯入 | <span class="text-amber-400">驗收中</span> |
| STD — ECSTen | 人資三表 API | <span class="text-teal-400">已交付</span> |
| Azure DevOps plugin | AI 協助填寫 task | <span class="text-teal-400">已完成</span> |

<div class="mt-8 text-sm opacity-70">
兩項完成交付，一項因客戶端資料問題仍在驗收循環中。
</div>

---
layout: section
---

# 統一超商 — EPSNet

商標資料匯入

---

# 需求與交付

## 原始需求

以一份 Excel 匯入**預檢案**與**申請案**的商標資料，
包含附件與分類資料，且皆為必填欄位。

## 交付工具

<v-clicks>

| 工具 | 負責範圍 |
|---|---|
| SQL | 主資料處理，結構最單純 |
| exe | 搬移附件 |
| exe | 匯入分類資料 |

</v-clicks>

<div v-click class="mt-6 text-sm opacity-70">
主資料以 SQL 直接處理；附件與分類因涉及檔案搬移與格式轉換，另外寫成執行檔。
</div>

---

# 驗收歷程

三輪驗收，前兩輪皆整批 rollback

<v-clicks>

<div class="mt-6 p-4 border-l-4 border-red-400 bg-red-400/5">

**第一輪** — 部分案件指定的人員不存在，匯入失敗
→ 整批 rollback，等客戶確認人員資料

</div>

<div class="p-4 border-l-4 border-red-400 bg-red-400/5">

**第二輪** — 案件的從屬關係有誤
→ 整批 rollback，等客戶確認關聯資料

</div>

<div class="p-4 border-l-4 border-amber-400 bg-amber-400/5">

**第三輪** — 列表有特殊顯示邏輯：商標有效起訖日**同時有值**才會顯示，
但實際上只有起日為必填
→ 回頭在 Excel 增加一個欄位

</div>

</v-clicks>

---
layout: default
---

# 觀察

<v-clicks>

- 前兩輪的失敗都**不在程式面**，而是來源資料本身不完整或關聯錯誤
- 採整批 rollback 而非部分匯入，確保資料一致性，但每輪都需等客戶確認才能再跑
- 第三輪才浮現的顯示邏輯，屬於既有系統的隱性規則，
  單看需求文件無法預先得知

</v-clicks>

<div v-click class="mt-8 p-4 bg-gray-500/10 rounded">
目前仍在驗收循環中，待客戶確認後可再次匯入。
</div>

---
layout: section
---

# STD — ECSTen

人資三表 API

---

# 背景與評估

## 原始需求

暫時性讓 ECSTen 站台能透過 API 完成人資串接。

## 評估結果

<v-clicks>

- ecscore 原本「三表進系統」的邏輯相當複雜，短時間內無法完整梳理
- 若強行重寫，風險與工時都不可控

</v-clicks>

<div v-click class="mt-6 p-4 border-l-4 border-teal-400 bg-teal-400/5">

**採取策略**：不動原本的系統邏輯，改以 API 將資料寫入三表，
再呼叫原有程序把三表資料帶進系統。

</div>

---

# 交付內容

共四支 API

<v-clicks>

| API | 用途 |
|---|---|
| 進三表 — 部門表 | 寫入部門資料 |
| 進三表 — 人員表 | 寫入人員資料 |
| 進三表 — 人員部門表 | 寫入人員與部門的對應關係 |
| 觸發原程序 | 呼叫既有邏輯，將三表資料帶進系統 |

</v-clicks>

<div v-click class="mt-8 text-sm opacity-70">
前三支負責資料落地，第四支負責銜接既有流程。
外部只需依序呼叫，不必理解 ecscore 內部的處理細節。
</div>

---
layout: section
---

# Azure DevOps plugin

AI 協助填寫 task

---

# 目標與設計

## 目標

在**不影響正常開發體驗**的前提下，讓 AI 協助填寫 task 的時數與內容。

## 設計

<v-clicks>

分成兩層：**五個 skill** 負責與 ADO 溝通的原子操作，
**一個 command** 負責主動觸發與流程編排。

</v-clicks>

---

# 五個 skill

<v-clicks>

| Skill | 職責 |
|---|---|
| `ado-query-classification` | 查詢分類資訊 |
| `ado-query-workitem` | 查詢 work item |
| `ado-create-feature` | 建立 feature |
| `ado-create-pbi` | 建立 PBI |
| `ado-create-task` | 建立 task |

</v-clicks>

<div v-click class="mt-8 text-sm opacity-70">
拆成細粒度的 skill，讓 AI 依情境自行組合，
而不是寫死成單一流程。
</div>

---

# log-commits command

<div class="mt-4">

主動呼叫，執行流程：

</div>

<v-clicks>

1. 掃描當前 branch 的所有 commit
2. 依 commit 內容規劃成 task 清單
3. 呼叫 skill，實際在 ADO 建立 task

</v-clicks>

<div v-click class="mt-8 p-4 border-l-4 border-teal-400 bg-teal-400/5">

開發者照常寫 code、照常 commit，
需要回填 ADO 時再主動觸發，開發節奏不被打斷。

</div>

---
layout: center
class: text-center
---

# 總結

<div class="mt-6 text-left inline-block">

- **EPSNet 商標匯入** — 工具已交付，因來源資料問題仍在驗收中
- **ECSTen 人資三表 API** — 四支 API 交付完成，繞開既有複雜邏輯
- **ADO plugin** — 五個 skill 加一個 command，已可實際使用

</div>
