---
theme: frankfurt
title: 2026 年 10 月月報
author: andy.lin
date: 2026 年 10 月
info: |
  innovue 月報 — 2026 年 10 月
colorSchema: light
layout: cover
transition: slide-left
mdc: true
---

# 2026 年 10 月月報

<div class="pt-6 text-lg">andy.lin</div>

---
section: 概覽
---

# 本月概覽

| 客戶 — 系統 | 項目 | 狀態 |
|---|---|---|
| 台大醫 — EDUCore | Passkey 在 iframe 中無法喚起 Bitwarden | <span class="text-teal-600">已實作</span> |
| 遠東新 — EPSCore | clone 遠東 | <span class="text-teal-600">已完成</span> |
| 遠東新 — EPSCore | 客製化人資 | <span class="text-teal-600">已完成</span> |
| 日月光 — EPSCore | Mac 無法 Kerberos SSO | <span class="text-amber-600">已提供 UI 取得票證方式，待廠商驗證</span> |

---
layout: center
section: 台大醫
---

# 台大醫 — EDUCore

Passkey 在 iframe 中無法喚起 Bitwarden

---

# 月中 demo 時遇到的問題

<div class="p-4 bg-gray-500/10 rounded">

月中已經 demo 過在 eps 站台使用 passkey

</div>

<v-clicks>

<div class="mt-5 p-4 border-l-4 border-gray-500 bg-gray-500/5">

**Bitwarden 的行為** — 攔截 WebAuthn、準備跳出 authenticator 時，會判斷目前所在的 frame 是不是 **top**

</div>

<div class="mt-4 p-4 border-l-4 border-red-500 bg-red-400/5">

**EPS 的頁面結構** — 主要頁面在**子 iframe** 中，WebAuthn 在 iframe 裡發生，Bitwarden 就跳不出來

</div>

<div class="mt-4 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**會議決定** — 讓 WebAuthn 發生在 **top**

</div>

</v-clicks>

---
clicks: 4
---

# 讓 WebAuthn 改在 top 發生

<div :style="{ height: '300px' }">
  <PasskeyFrames :step="$clicks" class="w-full h-full" />
</div>

<div v-click="4" class="mt-2 text-sm">

top 自己在 `window.passkeyRegistration` 新增一組方法，下層 iframe 透過 `window.top.passkeyRegistration` 呼叫　·　狀態：<span class="text-teal-600 font-bold">已實作</span>

</div>

---
layout: center
section: 遠東新
---

# 遠東新 — EPSCore

clone 遠東 + 客製化人資

---

# clone 遠東：整理成 skill

<v-clicks>

<div class="p-4 border-l-4 border-gray-500 bg-gray-500/5">

**背景** — eps 本來就有「遠東」這個廠商，且已有各種客製化；遠東新是一個**全新的廠商**，但要繼承遠東的**所有功能**

</div>

<div class="mt-4 p-4 border-l-4 border-amber-500 bg-amber-400/5">

**clone 廠商要做的事** — 盤點各種客製點，並評估每個客製點要怎麼移植到新廠商

</div>

<div class="mt-4 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**做法** — 把 add / clone 一個廠商的方式整理成一個 **skill**

</div>

</v-clicks>

<div v-click class="mt-6 text-sm">

狀態：skill <span class="text-teal-600 font-bold">已完成</span>　·　遠東新 clone <span class="text-teal-600 font-bold">已完成</span>

</div>

---
clicks: 2
---

# 客製化人資

<div class="mt-10" :style="{ height: '80px' }">
  <HrFlow :step="$clicks" class="w-full h-full" />
</div>

<div class="mt-10 text-sm">

狀態：<span class="text-teal-600 font-bold">已完成</span>

</div>

---
layout: center
section: 日月光
---

# 日月光 — EPSCore

Mac 無法 Kerberos SSO

---

# 換了新 Mac 之後

<div class="grid grid-cols-2 gap-4">

<div v-click class="p-4 border-l-4 border-gray-500 bg-gray-500/5">

**廠商說：之前的 Mac 可以**

能正常透過 SSO 登入系統

<div class="text-sm mt-2 opacity-75">

但我們無法確認當時是**進系統就直接 SSO 成功**，還是**有跳 401 帳密窗、輸入後才登入**

</div>

</div>

<div v-click class="p-4 border-l-4 border-red-500 bg-red-400/5">

**換新 Mac 後**

SSO 導到 **401 不支援頁面**

<div class="text-sm mt-2 opacity-75">

既沒有直接登入，也沒有要求輸入帳密，只能導回登入頁用 db 登入

</div>

</div>

</div>

<div v-click class="mt-5 p-4 border-l-4 border-teal-500 bg-teal-400/5">

**判斷：這是預期的行為** — ubuntu、mac 本來就不會跳 401 登入窗

推測廠商先前能成功，是因為他在電腦上**自己先取得了票證**

</div>

---
clicks: 4
---

# 知識複習：瀏覽器到底要什麼

<div :style="{ height: '322px' }">
  <KerberosDecision :step="$clicks" class="w-full h-full" />
</div>

---

# Ticket Viewer 與 kinit：本質都是在拿 TGT

<div class="grid grid-cols-2 gap-4">

<div v-click class="p-4 border-l-4 border-teal-500 bg-teal-400/5">

**交付給廠商：Ticket Viewer（UI）**

1. 開啟 `Ticket Viewer`
2. 點選 `Add Identity`
3. 輸入網域帳號與密碼
4. 重新進入系統

<div class="text-sm mt-3 opacity-75">只提供 UI 版，讓廠商好操作</div>

<div class="text-sm mt-2">狀態：<span class="text-amber-600 font-bold">待廠商驗證</span></div>

</div>

<div v-click class="p-4 border-l-4 border-gray-500 bg-gray-500/5">

**知識複習：用 CLI 對照每一步**<span class="text-xs opacity-60">（未交付廠商）</span>

```bash
klist          # 目前持有的票證
kinit andy.lin@dev.lan
               # 取得 TGT → krbtgt/DEV.LAN@DEV.LAN
kvno HTTP/eps.in.innovue.ltd@dev.lan
               # 取得 EPS 的 Service Ticket
kdestroy -a    # 刪除所有票證
```

</div>

</div>

<div v-click class="mt-5 p-3 bg-gray-500/10 rounded text-sm">

Kerberos SSO 中，系統只負責驗證 Service Ticket；票證要由用戶端電腦先取得

</div>

---
section: 總結
---

# 總結

| 客戶 — 系統 | 本月 | 狀態 |
|---|---|---|
| <span class="whitespace-nowrap">台大醫 — EDUCore</span> | Bitwarden 只在 top frame 喚起 authenticator，WebAuthn 改由 top 執行、iframe 透過 `window.top` 呼叫 | <span class="text-teal-600">已實作</span> |
| <span class="whitespace-nowrap">遠東新 — EPSCore</span> | 把 clone 廠商的流程整理成 skill 並完成遠東新 clone；客製化人資完成 | <span class="text-teal-600">已完成</span> |
| <span class="whitespace-nowrap">日月光 — EPSCore</span> | 新 Mac 沒有票證所以 SSO 失敗，屬預期行為；已提供 Ticket Viewer 取得票證的 UI 操作方式 | <span class="text-amber-600 whitespace-nowrap">待廠商驗證</span> |

---

# 參考資料

- Kerberos SSO 實戰說明（`Kerberos_SSO_實戰概念說明.md`，本簡報資料夾）
