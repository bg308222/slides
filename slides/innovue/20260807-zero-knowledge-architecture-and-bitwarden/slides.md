---
theme: default
title: Zero-knowledge Architecture and Bitwarden
info: |
  從「登入」一路推導到 Bitwarden 的零知識架構。
  每一步都是上一步的痛點逼出來的。
class: text-center
transition: slide-left
mdc: true
---

# Zero-knowledge<br>Architecture

從「登入」推導到 Bitwarden

<div class="pt-10 text-sm opacity-50">
  全場只問一個問題 —— <span class="text-amber-300">現在 server 手上有什麼？</span>
</div>

---
layout: center
---

# 今天怎麼走

<div class="grid grid-cols-2 gap-8 mt-8 text-left">

<div>

<div class="text-xs uppercase tracking-widest opacity-40 mb-3">上半場</div>

**用「登入」感受零知識**

<div class="text-sm opacity-70 mt-3 leading-relaxed">

四步演進，每一步都在問同一件事：<br>
為了讓你登入，server 到底得知道多少？

</div>

</div>

<div>

<div class="text-xs uppercase tracking-widest opacity-40 mb-3">下半場</div>

**Bitwarden 怎麼保護「資料」**

<div class="text-sm opacity-70 mt-3 leading-relaxed">

密碼可以用「回不去」保護，<br>
但資料**必須回得去** —— 那怎麼辦？

</div>

</div>

</div>

<div class="mt-12 text-sm opacity-45">
不會出現任何演算法名稱與參數。今天只講「東西在誰手上」。
</div>

---
layout: section
---

# 上半場

以達成「登入」來感受零知識

---
clicks: 4
---

# ① 直接存密碼

<Stage>
  <template #client>
    <Token label="使用者輸入" value="hunter2" variant="plain" :dim="$clicks < 1" />
  </template>
  <template #wire>
    <Token value="hunter2" variant="plain" :dim="$clicks < 2" />
  </template>
  <template #server>
    <Db :cols="['帳號', '密碼']" :rows="[['andy', 'hunter2']]" :dim="$clicks < 3" />
  </template>
</Stage>

<div v-click="4" class="mt-4">
<ServerHolds
  :items="[{ text: '完整的明文密碼 <code>hunter2</code>', safe: false }]"
  verdict="資料庫被偷 → 所有人的密碼直接攤開。而且因為大家會重複使用密碼，<b>災情會擴散到他其他站的帳號</b>。"
/>
</div>

---
clicks: 4
---

# ② server 端 hash

<Stage>
  <template #client>
    <Token label="使用者輸入" value="hunter2" variant="plain" :dim="$clicks < 1" />
  </template>
  <template #wire>
    <Token value="hunter2" variant="plain" :dim="$clicks < 2"
           note="明文還是原封不動送過去了" />
  </template>
  <template #server>
    <Db :cols="['帳號', 'salt', 'hash']" :rows="[['andy', 'x7Kq…', '9f2a…']]" :dim="$clicks < 3" />
  </template>
</Stage>

<div v-click="4" class="mt-4">
<ServerHolds
  :items="[
    { text: '存在資料庫裡的是 hash，反推不回密碼', safe: true },
    { text: '但在<b>收到的那一瞬間</b>，server 看得到 <code>hunter2</code> 本人', safe: false },
  ]"
  verdict="風險換了位置 —— 從「資料庫」搬到「那一刻」。加一行 log、一個 error tracking、一次記憶體 dump，密碼就外流了。"
/>
</div>

---
clicks: 4
---

# ③ client 端 hash

<Stage>
  <template #client>
    <div class="flex items-center gap-3">
      <Token label="使用者輸入" value="hunter2" variant="plain" :dim="$clicks < 1" />
      <span class="opacity-40 text-lg" v-show="$clicks >= 2">→</span>
      <Token label="本機算完" value="9f2a…" variant="hash" :dim="$clicks < 2" />
    </div>
  </template>
  <template #wire>
    <Token value="9f2a…" variant="hash" :dim="$clicks < 3"
           note="明文從此不離開裝置" />
  </template>
  <template #server>
    <Db :cols="['帳號', 'hash']" :rows="[['andy', '9f2a…']]" :dim="$clicks < 4" />
  </template>
</Stage>

<div v-click="4" class="mt-6 text-center text-lg">
server 從頭到尾<b class="text-teal-300">沒看過</b> <code>hunter2</code>
</div>

---
layout: center
---

# 但這其實是 ① 的變形

<div class="max-w-3xl mx-auto">

<v-clicks>

<div class="text-base opacity-80">

server 存的是 `9f2a…`，client 送去比對的也是 `9f2a…`

</div>

<div class="p-4 my-4 rounded border-l-4 border-red-400 bg-red-400/5">

**`9f2a…` 本身就變成了新的密碼**

資料庫再被偷一次，攻擊者拿著它直接送去登入 API 就進去了。
他還原不出 `hunter2`，但他**根本不需要**還原。

</div>

<div class="grid grid-cols-2 gap-4 mt-6">
<div class="p-3 rounded border border-teal-400/40 bg-teal-400/5">
<div class="text-teal-300 font-bold text-sm mb-1">保護了「這個人」</div>
<div class="text-sm opacity-75">真密碼沒外流，不會波及他其他站的帳號</div>
</div>
<div class="p-3 rounded border border-red-400/40 bg-red-400/5">
<div class="text-red-300 font-bold text-sm mb-1">沒保護「這個帳號」</div>
<div class="text-sm opacity-75">這站還是照樣被登入</div>
</div>
</div>

<div class="mt-6 text-center text-lg">
而 ① 的這個毛病，我們在 ② 已經解決過了 ——
</div>

</v-clicks>

</div>

---
clicks: 5
---

# ④ 兩邊各做一次

<Stage>
  <template #client>
    <div class="flex items-center gap-3">
      <Token value="hunter2" variant="plain" :dim="$clicks < 1" />
      <span class="opacity-40 text-lg" v-show="$clicks >= 2">→</span>
      <Token label="本機 hash" value="9f2a…" variant="hash" :dim="$clicks < 2" />
    </div>
  </template>
  <template #wire>
    <Token value="9f2a…" variant="hash" :dim="$clicks < 3" />
  </template>
  <template #server>
    <div class="flex flex-col items-center gap-2 w-full">
      <Token label="server 再加 salt hash 一次" value="c41d…" variant="locked" :dim="$clicks < 4" />
      <Db :cols="['帳號', 'salt', 'hash']" :rows="[['andy', 's4Lm…', 'c41d…']]" :dim="$clicks < 4" />
    </div>
  </template>
</Stage>

<div v-click="5" class="mt-3">
<ServerHolds
  :items="[
    { text: 'client 那層 → 真密碼不離開裝置，<b>保護這個人</b>', safe: true },
    { text: 'server 那層 → 資料庫外洩也拿不到能登入的東西，<b>保護這個帳號</b>', safe: true },
  ]"
  verdict="server 從頭到尾沒有在任何時刻、以任何形式持有過密碼，而它仍然驗證得了「你是你」。"
/>
</div>

---
layout: center
class: text-center
---

# 上半場結束

<div class="text-xl opacity-80 mt-6">秘密永遠只在你的裝置上</div>

<div class="mt-8 text-base opacity-60 max-w-2xl mx-auto leading-relaxed">
資料庫被偷也沒事、有人多 log 了一行也沒事 ——<br>
因為那些地方<b class="opacity-100">從來就沒有真正的秘密</b>
</div>

---
clicks: 3
---

# 但我們真正要存的，其實是這個

<Stage>
  <template #client>
    <Token value="hunter2" variant="plain" note="前四步都只是為了進得來" />
  </template>
  <template #server>
    <div class="w-full flex flex-col items-center gap-2">
      <Db :cols="['帳號', 'salt', 'hash']" :rows="[['andy', 's4Lm…', 'c41d…']]" />
      <div class="w-full transition-all duration-700"
           :class="$clicks >= 1 ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'">
        <Db title="vault —— 使用者真正的資料"
            :cols="['名稱', '帳號', '密碼']"
            :rows="[['GitHub', 'andy', '???'], ['銀行', 'andy', '???']]" />
      </div>
    </div>
  </template>
</Stage>

<div v-click="2" class="mt-4 text-center text-lg">
這一定要是<b class="text-sky-300">密文</b> —— 不然前面四步都白做了
</div>

<div v-click="3" class="mt-2 text-center text-sm opacity-55">
等於門鎖得很緊，但東西堆在門外
</div>

---
layout: center
class: text-center
---

<div class="text-sm uppercase tracking-widest opacity-40 mb-6">而這裡有一個根本差異</div>

<div class="text-3xl leading-relaxed">

hash 是因為 <b class="text-amber-300">回不去</b> 才安全

<div class="my-6 opacity-30 text-xl">但</div>

資料<b class="text-sky-300">必須回得去</b>

</div>

<div class="mt-10 text-base opacity-55">
不然存了等於沒存 —— 前半場的所有招式，在這裡<b class="opacity-100">全部用不了</b>
</div>

---
layout: section
---

# 下半場

那這個密文，是怎麼來的？

---
clicks: 3
---

# 先試最直覺的做法

資料要可逆，就一定要有一把開得回來的鑰匙。那就拿前半場已經有的東西來用 ——

<Stage>
  <template #client>
    <Token label="拿它當加密鑰匙" value="9f2a…" variant="hash" :dim="$clicks < 1" />
  </template>
  <template #wire>
    <Token value="9f2a…" variant="hash" :dim="$clicks < 1" />
  </template>
  <template #server>
    <div class="flex flex-col items-center gap-2">
      <Token label="server 手上也有" value="9f2a…" variant="hash" :dim="$clicks < 2" />
      <div v-show="$clicks >= 2" class="text-red-400 text-2xl">↓</div>
      <div v-show="$clicks >= 2" class="text-red-300 text-sm">它解得開你的 vault</div>
    </div>
  </template>
</Stage>

<div v-click="3" class="mt-4 p-4 rounded border-l-4 border-amber-400 bg-amber-400/5">

問題不是這把鑰匙不夠強 ——
**是它被要求同時做兩件事**：證明我是我，而且開我的資料。

</div>

---
layout: center
class: text-center
---

<div class="text-4xl font-bold leading-tight">
一把鑰匙<br>不能同時做兩件事
</div>

<div class="mt-10 text-base opacity-55 max-w-xl mx-auto leading-relaxed">
接下來的每一次分裂，都是因為有人叫一把鑰匙做兩件事，然後壞掉了
</div>

<div class="mt-8 flex justify-center gap-3 text-xs opacity-40">
<span class="px-3 py-1 rounded-full border border-white/20">第一次：認證 / 解密</span>
<span class="px-3 py-1 rounded-full border border-white/20">第二次：鎖資料 / 綁密碼</span>
<span class="px-3 py-1 rounded-full border border-white/20">第三次：長期 / 臨時</span>
</div>

---
clicks: 3
---

# 第一次分裂：證明我是我 / 開我的資料

<div class="mt-6">
<Split
  :step="$clicks"
  root-label="從 master password 長出一個根"
  root="Master Key"
  left-label="送去 server"
  left="Master Password Hash"
  left-note="只負責 <b>證明我是我</b>"
  right-label="留在本機，永不送出"
  right="Stretched Master Key"
  right-note="只負責 <b>開我的資料</b>"
  :root-at="1"
  :split-at="2"
/>
</div>

<div v-click="3" class="mt-6 text-center">

兩條互相**推不回去** —— 就是前半場那個「回不去」，再用一次

</div>

---
layout: center
---

<ServerHolds
  :items="[
    { text: '一個驗證得了、但反推不回密碼的值', safe: true },
    { text: '解開資料的那把鑰匙 —— <b>它根本沒有</b>', safe: true },
  ]"
  verdict="所以 server 能驗證你是你，卻<b>沒有能力</b>解開你的資料。<br>不是它保證不看，是它手上根本沒有那把。"
/>

---
clicks: 3
---

# 那就用留下來那把直接鎖 vault

<Stage no-wire client-title="CLIENT" server-title="SERVER">
  <template #client>
    <Token label="留在本機那把" value="Stretched Master Key" variant="key" />
    <div class="text-2xl opacity-40">↓</div>
    <div class="text-xs opacity-55">直接加密整個 vault</div>
  </template>
  <template #server>
    <Db title="加密後的 vault"
        :cols="['名稱', '內容']"
        :rows="[['a8f…', 'e91c…'], ['3b2…', '7d4a…']]" />
  </template>
</Stage>

<div v-click="1" class="mt-4 text-center text-base opacity-70">
可以動，沒問題。但問一句 ——
</div>

<div v-click="2" class="mt-3 text-center text-2xl">
改 master password 會發生什麼事？
</div>

<div v-click="3" class="mt-5 p-4 rounded border-l-4 border-red-400 bg-red-400/5">

鑰匙一換，**整個 vault 要全部重新加密一遍**。
資料越多越痛，而且重加密的當下，所有明文都得攤開。

</div>

---
clicks: 3
---

# 第二次分裂：鎖資料的 / 綁密碼的

<div class="flex items-center justify-center gap-6 mt-8">

<Token label="① 隨機產生一把" value="Symmetric Key" variant="key" :dim="$clicks < 1"
       note="真正鎖著 vault 的就是它" />

<div class="text-2xl opacity-30" v-show="$clicks >= 2">被鎖進</div>

<Token label="② 再被密碼衍生物鎖起來" value="Protected Symmetric Key" variant="locked" :dim="$clicks < 2"
       note="存在 server 上" />

</div>

<div class="text-center mt-6 text-sm opacity-50" v-show="$clicks >= 2">
vault ← 被 Symmetric Key 鎖　｜　Symmetric Key ← 被 Stretched Master Key 鎖
</div>

<div v-click="3" class="mt-8 p-4 rounded border-l-4 border-teal-400 bg-teal-400/5">

改密碼只要**重包那一小把**，vault 一個字都不用動。

<div class="mt-2 text-sm opacity-70">換鎖頭，不用換保險箱裡的東西。</div>

</div>

---
layout: center
---

<ServerHolds
  :items="[
    { text: '一個驗證得了、但反推不回密碼的值', safe: true },
    { text: '一把被鎖起來的鑰匙（Protected Symmetric Key）', safe: true },
    { text: '一整包加密的 vault', safe: true },
  ]"
  verdict="三樣東西，<b>沒有一樣打得開</b>。<br>而解開它們需要的那把，從頭到尾沒離開過你的裝置。"
/>

---
clicks: 4
---

# 第三次分裂：長期的 / 臨時的

每次要用都重打一次 master password 太煩，但解開的鑰匙一直留著又等於沒鎖。

<div class="grid grid-cols-2 gap-5 mt-8">

<div class="p-4 rounded-lg border-2 border-amber-400/40 bg-amber-400/5 transition-opacity duration-500"
     :class="$clicks >= 1 ? 'opacity-100' : 'opacity-20'">

### lock

<div class="mt-3 space-y-2 text-sm">
<div class="text-red-300">✗ 鑰匙 —— 丟掉</div>
<div class="text-teal-300">✓ 鎖著的東西 —— 留在本機</div>
</div>

<div class="mt-4 text-xs opacity-60" v-show="$clicks >= 3">
unlock 只是把鑰匙<b>重算一次</b><br>
→ <b class="text-teal-300">完全不需要連網</b>
</div>

</div>

<div class="p-4 rounded-lg border-2 border-red-400/40 bg-red-400/5 transition-opacity duration-500"
     :class="$clicks >= 2 ? 'opacity-100' : 'opacity-20'">

### logout

<div class="mt-3 space-y-2 text-sm">
<div class="text-red-300">✗ 鑰匙 —— 丟掉</div>
<div class="text-red-300">✗ 鎖著的東西 —— 也一起丟掉</div>
</div>

<div class="mt-4 text-xs opacity-60" v-show="$clicks >= 3">
東西都不在了，只能跟 server 重拿<br>
→ <b class="text-red-300">必須連網</b>
</div>

</div>

</div>

<div v-click="4" class="mt-6 text-center text-base">
差別講白了就是：<b>加密後的 vault 有沒有留在裝置上</b>
</div>

---
clicks: 4
layout: default
---

# 現在才把完整的圖攤開

<FullMap :step="$clicks" />

---
layout: center
class: text-center
---

<div class="text-sm uppercase tracking-widest opacity-40 mb-8">最後一次問</div>

<div class="text-3xl text-amber-300 mb-10">現在 server 手上有什麼？</div>

<div class="text-4xl font-bold">
一包它<span class="text-teal-300">永遠打不開</span>的東西
</div>

<div class="mt-12 text-base opacity-55 max-w-xl mx-auto leading-relaxed">
它不是承諾不看 —— 是<b class="opacity-100">沒有能力看</b>
</div>

---
layout: center
---

# 附錄：CLI 上的 session key

<div class="max-w-3xl">

<div class="text-sm opacity-70 mb-4">
<code>bw unlock</code> 會吐一串 <code>BW_SESSION</code>，之後帶著它就不用再打 master password。
</div>

<div class="p-4 rounded border-l-4 border-teal-400 bg-teal-400/5 mb-4">

它叫 session，但**不是通行證，是一把鑰匙**。

<div class="text-sm opacity-70 mt-2">

CLI 每跑一次指令都是新的 process，記憶體不共享。
所以 unlock 把算好的 Symmetric Key 用一把隨機鑰匙鎖起來存在本機 —— 那把隨機鑰匙就是 `BW_SESSION`。

</div>

</div>

<div class="p-4 rounded border-l-4 border-amber-400 bg-amber-400/5">

**再 unlock 一次，前一把為什麼就不能用了？**

<div class="text-sm opacity-70 mt-2">

因為本機存放那份加密結果的地方只有一格，新的 unlock 會覆寫掉它。
舊鑰匙沒有被撤銷、server 也完全不知情 —— 它只是**再也沒有東西可以開了**。

</div>

<div class="text-sm mt-3 opacity-85">不是「作廢」，是「換鎖」。</div>

</div>

<div class="mt-4 text-xs opacity-45">
延伸：<code>bw login</code> 拿到的是跟 server 講話的憑證（認證），<code>bw unlock</code> 拿到的是解本機資料的鑰匙（解密）——
同一個分裂，在日常指令裡又出現一次。
</div>

</div>
