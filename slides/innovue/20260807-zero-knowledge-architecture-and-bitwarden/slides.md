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

<div class="grid grid-cols-2 gap-x-10 gap-y-5 mt-8 text-left max-w-3xl mx-auto">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-2">第一段</div>

**用「登入」感受零知識**

<div class="text-sm opacity-65 mt-2 leading-relaxed">
四步演進。為了讓你登入，server 到底得知道多少？
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-2">第二段</div>

**零知識怎麼保護「資料」**

<div class="text-sm opacity-65 mt-2 leading-relaxed">
密碼可以靠「回不去」保護，但資料<b>必須回得去</b>。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-2">第三段</div>

**Bitwarden 還多做了什麼？**

<div class="text-sm opacity-65 mt-2 leading-relaxed">
第二段那套已經能動了。但一天要用幾十次呢？
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-2">第四段</div>

**完整走一遍**

<div class="text-sm opacity-65 mt-2 leading-relaxed">
register / login / unlock / lock / logout，一步一步走完。
</div>
</div>

</div>

<div class="mt-10 text-sm opacity-45">
不會出現任何演算法名稱與參數。今天只講「東西在誰手上」。
</div>

---
layout: section
---

# 第一段

用「登入」感受零知識 —— 保護密碼

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
      <span class="text-lg transition-opacity duration-500"
            :style="{ opacity: $clicks >= 2 ? 0.4 : 0 }">→</span>
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
      <span class="text-lg transition-opacity duration-500"
            :style="{ opacity: $clicks >= 2 ? 0.4 : 0 }">→</span>
      <Token label="本機 hash" value="9f2a…" variant="hash" :dim="$clicks < 2" />
    </div>
  </template>
  <template #wire>
    <Token value="9f2a…" variant="hash" :dim="$clicks < 3" />
  </template>
  <template #server>
    <div class="flex flex-col items-center gap-2 w-full">
      <Token label="server 再加 salt hash 一次" value="c41d…" variant="muted" :dim="$clicks < 4" />
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

# 第一段結束

<div class="text-xl opacity-80 mt-6">秘密永遠只在你的裝置上</div>

<div class="mt-8 text-base opacity-60 max-w-2xl mx-auto leading-relaxed">
資料庫被偷也沒事、有人多 log 了一行也沒事 ——<br>
因為那些地方<b class="opacity-100">從來就沒有真正的秘密</b>
</div>

---
layout: section
---

# 第二段

零知識怎麼保護「資料」

---
clicks: 3
---

# 但我們真正要存的，其實是這個

<Stage>
  <template #client>
    <div class="flex items-center gap-3">
      <Token label="使用者輸入" value="hunter2" variant="plain" />
      <span class="opacity-40 text-lg">→</span>
      <Token label="本機 hash" value="9f2a…" variant="hash" />
    </div>
    <div class="opacity-45 mt-1" style="font-size: 11px">前五步都只是為了進得來</div>
  </template>
  <template #wire>
    <Token value="9f2a…" variant="hash" />
  </template>
  <template #server>
    <div class="w-full flex flex-col items-center gap-2">
      <Db :cols="['帳號', 'salt', 'hash']" :rows="[['andy', 's4Lm…', 'c41d…']]" />
      <div class="w-full transition-opacity duration-700"
           :style="{ opacity: $clicks >= 1 ? 1 : 0 }">
        <Db title="vault —— 使用者真正的資料"
            :cols="['名稱', '帳號', '密碼']"
            :rows="[['GitHub', 'andy', '???'], ['銀行', 'andy', '???']]" />
      </div>
    </div>
  </template>
</Stage>

<div v-click="2" class="mt-4 text-center text-lg">
這一定要是<b class="text-sky-300">密文</b> —— 不然前面五步都白做了
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
不然存了等於沒存 —— 第一段的所有招式，在這裡<b class="opacity-100">全部用不了</b>
</div>

---
clicks: 3
---

# 先試最直覺的做法

資料要可逆，就一定要有一把開得回來的鑰匙。手上唯一現成的東西就是它 ——

<Stage>
  <template #client>
    <div class="flex items-center gap-3">
      <Token label="使用者輸入" value="hunter2" variant="plain" />
      <span class="opacity-40 text-lg">→</span>
      <div class="flex flex-col items-center gap-1">
        <div class="leading-none transition-opacity duration-500"
             :style="{ fontSize: '11px', opacity: $clicks >= 1 ? 0.85 : 0 }">拿它當加密鑰匙</div>
        <Token value="9f2a…" variant="hash" />
      </div>
    </div>
  </template>
  <template #wire>
    <Token value="9f2a…" variant="hash" />
  </template>
  <template #server>
    <div class="w-full flex flex-col items-center gap-1.5">
      <Token label="server 手上也有" value="9f2a…" variant="hash" :dim="$clicks < 2" />
      <div class="text-red-400 text-xl leading-none transition-opacity duration-500"
           :style="{ opacity: $clicks >= 2 ? 1 : 0 }">↓</div>
      <div class="text-red-300 leading-none mb-1 transition-opacity duration-500"
           :style="{ fontSize: '12px', opacity: $clicks >= 2 ? 1 : 0 }">它解得開這一包</div>
      <Db title="vault —— 用 9f2a… 鎖起來的" locked
          :cols="['名稱', '內容']"
          :rows="[['a8f…', 'e91c…'], ['3b2…', '7d4a…']]" />
    </div>
  </template>
</Stage>

<div v-click="3" class="mt-4 p-4 rounded border-l-4 border-amber-400 bg-amber-400/5">

只要拿 **server 也有的東西**來加密，就一定行不通。
所以那把鑰匙，只能從 **server 沒有的地方**生出來。

</div>

---
clicks: 3
---

# 那就退回 client，盤點一次

<Wiring :step="$clicks" />

<div class="relative mt-2" style="height: 46px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks === 1 ? 1 : 0 }">
    <div class="text-base">同一個密碼，還能再算出<b class="text-teal-300">一把只有這台裝置知道的鑰匙</b></div>
    <div class="text-sm opacity-55 mt-1">它跟 hash 互相推不回去，而且從頭到尾不送出去</div>
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks === 2 ? 1 : 0 }">
    <div class="text-base">加密只能發生在<b class="text-teal-300">有鑰匙的那一邊</b></div>
    <div class="text-sm opacity-55 mt-1">所以資料得先回到自己手上</div>
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks >= 3 ? 1 : 0 }">
    <div class="text-base">鎖起來，再送回去 —— server 收到的是<b class="text-sky-300">一包它打不開的東西</b></div>
    <div class="text-sm opacity-55 mt-1">client 留著：hunter2、hash、key、明文 vault</div>
  </div>
</div>

---
layout: center
---

<ServerHolds
  title="現在 server 知道什麼？"
  :items="[
    { text: '一個驗證得了、但推不回密碼的值', safe: true },
    { text: '一包加密的 vault', safe: true },
    { text: '解得開它的那把鑰匙 —— <b>它根本沒有</b>', safe: true },
  ]"
  verdict="它能確認你是你，也能替你保管東西，卻<b>沒有能力</b>知道那是什麼。"
/>

---
layout: center
class: text-center
---

# 第二段結束

<div class="text-xl opacity-80 mt-4">同一個密碼，長出兩樣東西</div>

<div class="mt-7 grid grid-cols-2 gap-6 max-w-3xl mx-auto text-left">

<div class="p-5 rounded-lg border-2 border-amber-400/45 bg-amber-400/5">
<div class="font-mono text-amber-300">送出去那個 <span class="text-lg">hash</span></div>
<div class="mt-3 text-base">只負責<b>證明我是我</b></div>
<div class="mt-2 text-sm opacity-60 leading-relaxed">
它離開了裝置，但 server 拿著它推不回密碼，也開不了任何東西
</div>
</div>

<div class="p-5 rounded-lg border-2 border-teal-400/45 bg-teal-400/5">
<div class="font-mono text-teal-300">留在本機那把 <span class="text-lg">key</span></div>
<div class="mt-3 text-base">只負責<b>開我的 vault</b></div>
<div class="mt-2 text-sm opacity-60 leading-relaxed">
它從頭到尾沒有離開過這台裝置，所以沒有第二個人有
</div>
</div>

</div>

<div class="mt-8 text-base opacity-60 max-w-2xl mx-auto leading-relaxed">
到這裡，零知識保護資料的最小版本<b class="opacity-100">已經成立了</b>
</div>

---
layout: section
---

# 第三段

Bitwarden 還多做了什麼？

---
clicks: 3
---

# 先講痛

<div class="flex items-center justify-center gap-4 mt-1">
  <Token label="你打的密碼" value="hunter2" variant="plain" />
  <div class="flex flex-col items-center opacity-45 leading-none gap-0.5" style="font-size: 11px">
    <span>算出</span><span class="text-lg">→</span>
  </div>
  <Token label="只有本機有" value="key" variant="key" />
  <div class="flex flex-col items-center opacity-45 leading-none gap-0.5" style="font-size: 11px">
    <span>才解得開</span><span class="text-lg">→</span>
  </div>
  <Token label="從 server 拿回本機" value="vault" variant="data" locked />
</div>

<div class="text-center text-lg mt-4 mb-5">
反過來讀 ——「想開右邊那個」就等於「手上要有左邊那個」，兩件事被<b class="text-amber-300">綁死了</b>
</div>

<div class="grid grid-cols-2 gap-5">

<div class="p-4 rounded-lg border-2 border-white/15 transition-opacity duration-500"
     :style="{ opacity: $clicks >= 1 ? 1 : 0 }">

### 方案 A

<div class="text-sm opacity-75 mt-2">每次要用，就重打一次密碼</div>

<div class="mt-4 space-y-1.5 text-sm">
<div class="text-teal-300">✓ 安全上完全沒問題</div>
<div class="text-red-300">✗ 一天幾十次，沒有人受得了</div>
</div>

</div>

<div class="p-4 rounded-lg border-2 border-white/15 transition-opacity duration-500"
     :style="{ opacity: $clicks >= 2 ? 1 : 0 }">

### 方案 B

<div class="text-sm opacity-75 mt-2">第一次解開後，把明文 vault 存在本機</div>

<div class="mt-4 space-y-1.5 text-sm">
<div class="text-teal-300">✓ 方便</div>
<div class="text-red-300">✗ 明文從此永遠躺在這台裝置上</div>
</div>

</div>

</div>

<div class="mt-5 text-center text-xl transition-opacity duration-500"
     :style="{ opacity: $clicks >= 3 ? 1 : 0 }">
有沒有折衷？<b class="text-teal-300">不用一直打密碼，也不要在本機留明文</b>
</div>

---
clicks: 2
---

# 要回答這題，得先把圖看清楚

<Wiring :step="3 + $clicks" />

<div class="relative mt-2" style="height: 46px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks === 1 ? 1 : 0 }">
    <div class="text-base">圖一點都沒變，只是<b>貼上名字</b></div>
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks >= 2 ? 1 : 0 }">
    <div class="text-base">Master Key <b class="text-amber-300">直接對 vault 做事</b>，而它只能從 master password 算出來</div>
  </div>
</div>

---
clicks: 2
---

# 在這條線的中間，插一把新的鑰匙

<Wiring :step="$clicks >= 1 ? 6 : 5" />

<div class="relative mt-2" style="height: 46px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks === 1 ? 1 : 0 }">
    <div class="text-base">Master Key 從此<b>不再碰 vault</b>，它只負責開那一小把</div>
    <div class="text-sm opacity-55 mt-1">真正鎖著 vault 的，是一把隨機產生的鑰匙</div>
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks >= 2 ? 1 : 0 }">
    <div class="text-base text-amber-300">可是這樣到底解決了什麼？這把新的鑰匙自己又放哪？</div>
    <div class="text-sm opacity-55 mt-1">要看懂，得把鏡頭拉到只剩幾樣東西的地方</div>
  </div>
</div>

---
clicks: 7
---

# 鏡頭拉近：這把新鑰匙怎麼解套

<div class="text-sm opacity-50 -mt-2 mb-1">全場最繞的一張，我們慢慢走。台上只有三個角色。</div>

<Zoom :step="$clicks" />

<div class="relative mt-1" style="height: 44px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 0 ? 0.75 : 0 }">
    Master Key、Symmetric Key、vault —— 先看清楚誰是誰
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 1 ? 0.85 : 0 }">
    真正鎖住 vault 的是 <b>Symmetric Key</b>，它是隨機生的，跟你的密碼沒有任何關係
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 2 ? 0.85 : 0 }">
    而 Symmetric Key 自己，再被 <b>Master Key</b> 鎖起來
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 3 ? 0.85 : 0 }">
    這兩包鎖著的東西送去 server；要用資料時，也是這兩包一起被拉回本機
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 4 ? 1 : 0 }">
    轉折在這 —— 打密碼算出 Master Key 之後，<b class="text-amber-300">解開的不是 vault，是 Symmetric Key</b>
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 5 ? 0.9 : 0 }">
    這時候才隨機生一把 <b class="text-violet-300">session key</b> —— 它跟你的密碼一點關係都沒有
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 6 ? 0.9 : 0 }">
    用它把 Symmetric Key 再鎖一次，得到<b class="text-violet-300">第二把鎖著的副本</b>，放在本機
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks >= 7 ? 1 : 0 }">
    原本那把也鎖回去 —— 明文只存在剛剛那一瞬間，而
    <b class="text-teal-300">vault 從頭到尾一個字都沒動過</b>
  </div>
</div>

---
clicks: 1
---

# 回到大圖 —— 那被鎖起來的一份，放在哪？

<Wiring :step="6 + $clicks" />

<div class="relative mt-2" style="height: 46px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center"
       :style="{ opacity: $clicks >= 1 ? 1 : 0 }">
    <div class="text-base">被 Master Key 鎖起來的那一份，<b>存在 server</b></div>
    <div class="text-sm opacity-55 mt-1">所以換一台裝置，只要打對密碼就能把它拿回來解開 —— server 全程沒看過裡面</div>
  </div>
</div>

---
layout: center
---

<ServerHolds
  :items="[
    { text: 'Master Password Hash —— 驗證得了，但推不回密碼', safe: true },
    { text: 'Protected Symmetric Key —— 鎖著的', safe: true },
    { text: '加密的 vault —— 也是鎖著的', safe: true },
  ]"
  verdict="三樣東西，<b>沒有一樣打得開</b>。<br>而解開它們需要的那把，從頭到尾沒離開過你的裝置。"
/>

<div class="max-w-3xl mx-auto mt-5 text-sm opacity-55 text-center">
順帶一提：改 master password 時，只要重包那一小把 —— vault 一個字都不用動。
</div>

---
layout: section
---

# 第四段

完整走一遍

---
clicks: 9
---

<Phases now="register" />

<Flow phase="register" :step="$clicks" />

<div class="relative -mt-1" style="height: 40px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 0 ? 0.7 : 0 }">一台全新的裝置 —— 兩邊都還是空的</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 1 ? 0.85 : 0 }">一切從你打進去的那串字開始</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 2 ? 0.85 : 0 }">先算出 <b>Master Key</b>，它永遠不會離開這台裝置</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 3 ? 0.85 : 0 }">再從它算出 <b>Master Password Hash</b> —— 這個才是要送出去的</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 4 ? 0.85 : 0 }">另外隨機生一把 <b>Symmetric Key</b>，它跟你的密碼一點關係都沒有</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 5 ? 0.85 : 0 }">你的 vault 現在還是明文，躺在記憶體裡</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 6 ? 0.85 : 0 }">鎖住 vault —— 鎖起來的那包才准落到硬碟</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 7 ? 0.85 : 0 }">再鎖住 Symmetric Key —— 硬碟上這兩包，一樣都打不開</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 8 ? 1 : 0 }">把這三樣送上去 —— <b>注意送的全是鎖著的或推不回去的</b></div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks >= 9 ? 1 : 0 }">關掉之後本機清空，<b class="text-teal-300">server 手上這三樣，沒有一樣打得開</b></div>
</div>

---
clicks: 6
---

<Phases now="login" />

<Flow phase="login" :step="$clicks" />

<div class="relative -mt-1" style="height: 40px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 0 ? 0.7 : 0 }">本機是空的，東西全在 server 那邊</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 1 ? 0.85 : 0 }">一樣從打密碼開始</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 2 ? 0.85 : 0 }">算出 Master Key</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 3 ? 0.85 : 0 }">算出 Master Password Hash</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 4 ? 0.9 : 0 }">送去比對 —— server 只認得這個，<b>推不回你的密碼</b></div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 5 ? 0.9 : 0 }">驗過了，server 把<b>鎖著的那兩包</b>丟回來，落在硬碟</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks >= 6 ? 1 : 0 }">
    <b>login 到這裡就結束了</b> —— 東西拿回來了，但還是鎖著的。<br>
    <span class="text-xs opacity-70">你平常感覺不到，是因為 login 完會<b class="opacity-100">順手幫你做一次 unlock</b> —— 下一頁把那一段拆開來看</span>
  </div>
</div>

---
clicks: 4
---

<Phases now="unlock" />

<Flow phase="unlock" :step="$clicks" />

<div class="relative -mt-1" style="height: 40px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 0 ? 0.7 : 0 }">這就是 login 停下來的地方 —— 東西在手上，但打不開</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 1 ? 0.85 : 0 }">Master Key 解開其中一包，Symmetric Key 回到記憶體</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 2 ? 0.9 : 0 }">
    隨機生一把 <b class="text-violet-300">session key</b> —— 它<b>不留在裝置上</b>，是直接交到你手上
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 3 ? 0.9 : 0 }">用它把 Symmetric Key <b>再鎖一次</b>，這一份落到硬碟</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks >= 4 ? 1 : 0 }">
    <b>記憶體整個清空</b> —— 能打開硬碟那一份的，只剩你手上那把 session key。
    <b class="text-teal-300">整段沒跟 server 講過一句話</b>
  </div>
</div>

---
clicks: 2
---

<Phases now="lock" />

<Flow phase="lock" :step="$clicks" />

<div class="relative -mt-1" style="height: 40px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 0 ? 0.7 : 0 }">這是 unlock 完的樣子 —— 記憶體是空的，能開的那把在你手上</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 1 ? 0.9 : 0 }">
    lock 做的事只有一件：<b>把硬碟上「被 session key 鎖的那一份」刪掉</b> ——
    另外兩包<b class="text-teal-300">一個 byte 都沒動</b>
  </div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks >= 2 ? 1 : 0 }">
    你手上那把 <b class="text-violet-300">session key</b> 就這樣作廢了 ——
    <b>不是被撤銷，是它能開的東西不見了</b>。重打一次密碼就能再 unlock，<b class="text-teal-300">不用連網</b>
  </div>
</div>

---
clicks: 2
---

<Phases now="logout" />

<Flow phase="logout" :step="$clicks" />

<div class="relative -mt-1" style="height: 40px">
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 0 ? 0.7 : 0 }">從 lock 完的樣子開始</div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks === 1 ? 0.9 : 0 }">logout 再往下一步：<b>連硬碟上鎖著的那兩包也刪掉</b></div>
  <div class="absolute inset-0 transition-opacity duration-500 text-center text-sm"
       :style="{ opacity: $clicks >= 2 ? 1 : 0 }">本機什麼都不剩，要再用只能重新 login，而且<b class="text-red-300">一定要連網</b></div>
</div>

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

# 附錄：CLI 上的 BW_SESSION

<div class="max-w-3xl">

<div class="text-sm opacity-70 mb-4">
剛才那把 session key，在 CLI 上是看得見摸得到的 —— <code>bw unlock</code> 會直接把它印出來。
</div>

<div class="p-4 rounded border-l-4 border-teal-400 bg-teal-400/5 mb-4">

**為什麼 CLI 一定要把它交給你？**

<div class="text-sm opacity-70 mt-2">

因為 CLI 每跑一次指令都是新的 process ——
記分板上那欄「本機 memory」，在 CLI 上<b>根本不存在</b>。
鎖著的 Symmetric Key 只能放硬碟，鑰匙只好交給使用者自己拿著。

</div>

</div>

<div class="p-4 rounded border-l-4 border-amber-400 bg-amber-400/5">

**再 unlock 一次，前一把為什麼就不能用了？**

<div class="text-sm opacity-70 mt-2">

因為硬碟上那一格只有一個位置，新的 unlock 會直接覆寫掉它。
舊鑰匙沒有被撤銷、server 也完全不知情 —— 它只是**再也沒有東西可以開了**。

</div>

<div class="text-sm mt-3 opacity-85">不是「作廢」，是「換鎖」。</div>

</div>

<div class="mt-4 text-xs opacity-45">
<code>bw login</code> 拿的是跟 server 講話的憑證，<code>bw unlock</code> 拿的是解本機資料的鑰匙 ——
第二段長出來的那兩條線，在日常指令裡又出現一次。
</div>

</div>
