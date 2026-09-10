---
theme: default
title: PBKDF2：一個密碼，可以變成什麼
info: |
  兩次撞見 PBKDF2，回頭把它看懂。
  整場只有兩個問題：猜一次要多少錢，還有算出來這串 bytes 放到哪一格。
class: text-center
transition: slide-left
colorSchema: dark
mdc: true
---

# PBKDF2

<div class="mt-3" style="font-size: 15px; letter-spacing: 0.5px">
<span class="text-teal-300 font-bold">P</span>assword-<span class="text-teal-300 font-bold">B</span>ased<span class="opacity-40 mx-2">·</span><span class="text-teal-300 font-bold">K</span>ey <span class="text-teal-300 font-bold">D</span>erivation <span class="text-teal-300 font-bold">F</span>unction<span class="opacity-40 mx-2">·</span><span class="text-teal-300 font-bold">2</span>
</div>

<div class="pt-16 text-xs opacity-35">andy.lin · 2026-09-11</div>

<!--
封面上這五個字先掛著就好，不要解釋。

「Key Derivation」這兩個字要到第 10 頁才會被聽眾真的讀懂 ——
在那之前他們會理所當然地以為這是一個「存密碼用的東西」，
而那個誤會本身就是第 10 頁的燃料。
-->

---
layout: center
---

# 今天怎麼走

<div class="grid grid-cols-2 gap-x-10 gap-y-7 mt-8 text-left mx-auto" style="max-width: 760px">

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第一段</div>

**兩次遇見**

<div class="text-sm opacity-60 mt-1 leading-relaxed">
不是什麼大哉問。就是兩件小事剛好指到同一個東西。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第二段</div>

**密碼要怎麼存**

<div class="text-sm opacity-60 mt-1 leading-relaxed">
從明文一路走到加了 salt 的 hash。然後問：<b class="opacity-100">存進 db 的那個值被偷走之後，攻擊者猜一次要多少錢？</b>
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第三段</div>

**把單價乘上去**

<div class="text-sm opacity-60 mt-1 leading-relaxed">
PBKDF2 只做這一件事。它做得到什麼、做不到什麼。
</div>
</div>

<div>
<div class="text-xs uppercase tracking-widest opacity-40 mb-1">第四段</div>

**回到那段 code**

<div class="text-sm opacity-60 mt-1 leading-relaxed">
它到底在做什麼，以及它為什麼被標成 obsolete。
</div>
</div>

</div>

<!--
四段是一條線，不是四個主題。

第二段結束時聽眾會想要第三段，第三段結束時會想要第四段 ——
如果沒有這個感覺，就是我哪一頁講壞了。
-->

---
clicks: 2
---

# 兩次遇見

<style>
.deck-met .slidev-code { font-size: 10px !important; line-height: 1.7 !important; }
</style>

<div class="deck-met grid grid-cols-2 gap-8 mt-6 mx-auto text-left" style="max-width: 920px">

<div v-click="1">
<div class="text-xs uppercase tracking-widest opacity-40 mb-2">其之一</div>

<div class="p-4 rounded border border-gray-500/30 bg-gray-500/5" style="min-height: 232px">

之前讀 **Bitwarden 的 whitepaper**，我把 password hashing 當成先備知識跳過了。

<div class="mt-3 font-mono text-xs leading-relaxed opacity-70 border-l-2 border-teal-400/50 pl-3">
… stretch the master password with <b class="text-teal-300">PBKDF2</b> …<br>
… <b class="text-teal-300">PBKDF2</b> SHA-256 with 600,000 iterations …<br>
… additional <b class="text-teal-300">PBKDF2</b> iterations on the server …
</div>

<div class="mt-3 text-sm opacity-60">結果它整份文件反覆出現。</div>

</div>
</div>

<div v-click="2">
<div class="text-xs uppercase tracking-widest opacity-40 mb-2">其之二</div>

<div class="p-4 rounded border border-gray-500/30 bg-gray-500/5" style="min-height: 232px">

最近把 **dotnet 8 升到 dotnet 10**，有段 code 被編譯器攔下來。

```csharp
var db  = new Rfc2898DeriveBytes(password, salt, iterations);
var key = db.GetBytes(alg.KeySize   / 8);
var iv  = db.GetBytes(alg.BlockSize / 8);
```

<div class="mt-2 text-xs px-2 py-1 rounded bg-amber-400/10 border-l-2 border-amber-400 font-mono opacity-80">
SYSLIB0060 · 'Rfc2898DeriveBytes' is obsolete
</div>

<div class="mt-3 text-sm opacity-60">查下去，發現它也是 PBKDF2。</div>

</div>
</div>

</div>

<!--
這頁不是謎題，不要問「你們知道它為什麼 obsolete 嗎」。

右邊那段 code 現在不解釋，只讓大家看一眼 —— 最後一頁會原封不動搬回來。
到那時候他們才有能力自己讀它。

停留不要超過一分鐘。
-->

---
clicks: 1
---

# 密碼要怎麼存

<div style="height: 38px" class="text-sm opacity-60">
使用者註冊時給你一個密碼，你得把它存下來 —— 之後他來登入，你要判斷得出「這次打的對不對」。
</div>

<Crack :step="$clicks" class="mt-2" />

<!--
這一頁的第一件事是把題目講出來，不是急著給做法。
在此之前聽眾只知道「有個東西叫 PBKDF2」，還不知道我們要解什麼。

題目講完，最直覺的答案自然就是「那就存起來啊」——
它合理，只是不夠。不要嘲笑這一頁。
-->

---
clicks: 3
---

# 那就別存明文

<div style="height: 38px"></div>

<Crack :step="$clicks + 1" class="mt-2" />

<!--
click 2 是這一頁的重點：andy 跟 bob 存進去的是一模一樣的東西。

click 3 要慢一點講，重點在「他算的次數跟 db 有幾列無關」：
「反推不回來是真的。但他從來就不需要反推 —— 他只要猜一個、算一次，
  然後拿這一個值去跟每一列比。比對是免費的。
  所以 andy 中的那一刻，bob 也一起中了 —— 他一次都沒多算。」

換句話說：破一個人的成本，跟破整個 db 的成本一樣。

不要講 rainbow table 這個詞。畫面上那條分岔的線比名詞有用。
-->

---
clicks: 2
---

# 那就讓每個人不一樣

<div style="height: 38px"></div>

<Crack :step="$clicks + 4" class="mt-2" />

<!--
salt 不是為了讓 hash 更難反推 —— 它反不反推得回來完全沒變。
它是為了讓「算一次」不再能算給全部人。

click 2 只要表達一件事，不要去數次數：
「同一個候選密碼，在這一列算完的結果，對下一列完全沒用。
  不管猜中沒有，每一列都得帶著自己的 salt 從頭再算一次。」

click 2 結束後停住，把問題丟出來：
「好，他被迫每一列重算了。那他算一次，到底要多久？」
-->

---
clicks: 3
---

# 那他算一次，要多久

<Cost :step="$clicks" :reserve-conclusions="false" class="mt-8" />

<div v-click="3" class="mx-auto mt-3 pl-3 text-sm opacity-70" style="max-width: 740px">
salt 逼他對每一列重算一次 —— 但他算一次只要 <b class="text-red-300">45 皮秒</b>。db 有一百萬列，也才 45 微秒。
</div>

<!--
第一列（單價）是這一頁的地基，一定要先唸出來：
「一張 4090，裸 SHA-256 一秒算 220 億次。」

後兩列再帶：「六碼純數字一百萬個組合，整個空間跑完 45 微秒 ——
  不是猜中一個要 45 微秒，是全部跑完。」

八碼英數三小時這個數字一定會被質疑，先講在前面：
  62^8 ≈ 2.2×10^14 ÷ 2.2×10^10 = 約一萬秒。算術就是這樣。
  而且這還是「完全隨機的八碼」；真人的密碼熵低得多，字典跑一跑更快。

這頁的結論不是「hash 不好」，是：
要動的不是他重算幾次，是他算一次的單價。

-->

---
clicks: 3
---

# 那就讓它慢

<div class="text-center mt-4" :class="$clicks >= 2 ? 'opacity-100' : ''">
  <Params :reveal="$clicks >= 1 ? 3 : 0" :hi="$clicks >= 1 ? 'it' : ''" />
</div>

<Chain :step="$clicks >= 3 ? 2 : $clicks >= 2 ? 1 : 0" class="mt-2" />

<!--
click 1：「光看名字大概就猜得到它想幹嘛了。」

click 2 的鏈只要傳達兩件事，不要多講：
  上一輪的結果是下一輪的輸入、password 每一輪都要用到。

click 3 之後一定要補這一句，否則下一頁的數字會變得莫名其妙：
「所以他只能一條一條算。
  但別忘了他手上那張卡有一萬多個核心 —— 他可以同時跑一萬條。
  所以我們真正要看的，還是那張表。」

（技術細節：每一輪其實是 HMAC，password 是它的 key；
  而且真正的 PBKDF2 是把每一輪的結果全部混起來，不是只取最後一輪。
  被問到再翻到附錄 A / C。）
-->

---
clicks: 3
---

# 同一張表，第二欄

<Cost :step="$clicks + 3" class="mt-8" />

<!--
這一頁講者一句標語都不要下。兩個結論都讓他們自己從表上讀。

click 2（橫著看）：亮的是「算一次」那一列 —— 45 皮秒 → 68 微秒，
  ×150 萬倍是他們自己從表上讀出來的，不是我宣稱的。
click 3（直著看）：停久一點。

「它是一個乘法，不是一個保護傘。
  你的密碼本來值多少，它就幫你放大多少倍。」

成本的線到這裡收乾。之後不再回來調 iterations、不再比較演算法。

若有人問「那為什麼不乾脆設一億輪？」：
600,000 輪在一般 CPU 上就是幾十毫秒的量級，而那是每個登入請求都要付的。
OWASP 的建議值就是照「約 0.1 秒」這個可用性預算校準出來的 ——
這句話口頭回答就好，不必回到表上。
-->

---
clicks: 4
---

# 可是這個參數表，還少一格

<div class="text-center mt-6">
  <Params :reveal="3" reserve :fourth="$clicks >= 1" :hi="$clicks >= 1 ? 'len' : ''" />
</div>

<div class="grid grid-cols-2 gap-8 mt-6 mx-auto" style="max-width: 720px">

<div v-click="2" class="p-3 rounded border border-gray-500/30 bg-gray-500/5 text-center" style="min-height: 92px">

<div class="font-mono text-sm text-amber-300/80">SHA-256( password )</div>
<div class="mt-1 font-mono text-lg">32 bytes</div>
<div class="mt-1 text-xs opacity-55">長度是演算法決定的，你沒得選</div>

</div>

<div v-click="2" class="p-3 rounded border border-teal-400/40 bg-teal-400/5 text-center" style="min-height: 92px">

<div class="font-mono text-sm text-teal-300/80">pbkdf2( …, <b>16</b> / <b>32</b> / <b>64</b> )</div>
<div class="mt-1 font-mono text-lg">要多長，你自己講</div>
<div class="mt-1 text-xs opacity-55" :class="$clicks >= 3 ? 'opacity-100 text-teal-300' : ''">
AES-256 的 key 剛好就是 32 bytes
</div>

</div>

</div>

<style>
.deck-rfc .slidev-code { font-size: 10.5px !important; line-height: 1.7 !important; }
</style>

<div v-click="4" class="deck-rfc mx-auto mt-4 grid grid-cols-5 gap-5 items-center" style="max-width: 820px">

<div class="col-span-3">

```text
PBKDF2 (P, S, c, dkLen)
  Input:   P      password, an octet string
           S      salt, an octet string
           c      iteration count, a positive integer
           dkLen  intended length in octets of the derived key
  Output:  DK     derived key, a dkLen-octet string
```

</div>

<div class="col-span-2" style="font-size: 12.5px">

前三個是<b class="text-teal-300">安全性</b>參數。第四個不是 —— 它只回答「我要幾個 byte」。

<div class="mt-2 opacity-60" style="font-size: 11px">
RFC 8018 §5.2：<i>“The length of the derived key is essentially unbounded.”</i>
</div>

<div class="mt-2 text-amber-300">而它吐出來的東西，規格書自己就叫它 <b>derived key</b>。</div>

</div>

</div>

<!--
這一頁是整場的轉軸。

存密碼根本用不到「指定長度」這個能力。它會存在，是因為
它的產物本來就不是要拿去比對的指紋，是要拿去當鑰匙的材料。

click 4 把規格書原文攤開，這一頁的立足點就有了：
  password / salt / iterations 是安全性參數，dkLen 不是 ——
  它是「intended length in octets of the derived key」，一個介面參數。
  而且輸出的名字，RFC 自己就寫 derived key。

然後回頭指封面：
「到這裡，封面那五個字才真的能讀了 —— Key Derivation。
  它從頭到尾都不是在做 password hashing，是在從密碼生出鑰匙。
  password hashing 只是它剛好也能做的事。」

（dkLen 不是完全免費：l = CEIL(dkLen / hLen)，每多一個 block 就要再跑完整的 c 輪。
  這件事第 13 頁會用到，這裡先不講。）
-->

---
clicks: 3
---

# 它其實什麼都不是，就是一串 bytes

<Fork :step="$clicks" class="mt-2" />

<!--
這一頁要把前一頁的「第四個參數」收成一個很鬆的結論：

click 1：「給它四個 input，它就穩定吐出那麼多 bytes。
  同一組 input 永遠同一串 —— 這是它能拿來驗證的原因。
  而算一次很貴 —— 這是它值錢的原因。就這兩件事。」

click 2：「那這串 bytes 要拿去幹嘛？隨你。
  送出去比對，它就是指紋；留著開資料，它就是鑰匙；
  抽 64 個切一半，一半加密一半算 MAC 也行。
  它自己不在乎。」

click 3 是這一頁真正的重點：
「規格書管到左邊那串 bytes 產出來為止。右邊這些，RFC 一個字都沒寫。
  所以不要記『PBKDF2 有哪幾種用法』—— 沒有哪幾種，是你自己決定的。」

（技術上的小補充，被問到再說：真的要從一次輸出切出好幾把 key，
  正統做法是再過一層 HKDF，或用不同 salt 各 derive 一次。
  這一頁不展開，不影響「用途由你決定」這個結論。）
-->

---
clicks: 2
---

# 那我們那段，抽了多少、拿去幹嘛

```csharp {all|2,3|5}
var db  = new Rfc2898DeriveBytes(password, salt, iterations);
var key = db.GetBytes(alg.KeySize   / 8);
var iv  = db.GetBytes(alg.BlockSize / 8);

return alg.CreateEncryptor(key, iv);
```

<div class="mt-6 grid grid-cols-2 gap-6" style="max-width: 900px">

<div v-click="1" class="p-3 rounded border-l-4 border-sky-400 bg-sky-400/5">

**抽了多少**

<div class="text-sm opacity-80 mt-1">
32 + 16 = <b class="text-sky-300">48 bytes</b>
</div>

</div>

<div v-click="2" class="p-3 rounded border-l-4 border-teal-400 bg-teal-400/5">

**拿去幹嘛**

<div class="text-sm opacity-80 mt-1">
自己切開：前 32 當 key、後 16 當 IV（AES 的 block 就是 16 bytes），餵給 AES
</div>

</div>

</div>

<div v-click="2" class="mt-5 text-sm opacity-70" style="max-width: 900px">
就是上一頁那張圖的其中一種用法而已 —— 抽一段 bytes，自己切，自己決定拿去幹嘛。
所以這個 class 叫 <code class="font-mono">Rfc2898DeriveBytes</code>，不叫 <code class="font-mono">PasswordHasher</code>。它就是照字面在做事。
</div>

<!--
這頁不用久。聽眾在第 10、11 頁已經拿到全部的工具了，這裡只是讓他們用一次。

但要把「48」這個數字唸出來，因為下一頁整頁都在問這個數字是誰決定的。

（被問到「為什麼引 8018 不引 2898」時：
  RFC 2898 = PKCS #5 v2.0（2000 年）；RFC 8018 = PKCS #5 v2.1（2017 年），
  它的檔頭第三行就寫著 "Obsoletes: 2898"，內文也說 "This document supersedes PKCS #5 version 2.0"。
  2898 已經被正式取代，所以引現行版本。
  PBKDF2 的演算法本身兩版一模一樣；v2.1 主要是加了 SHA-2 系列當 PRF、
  加了 AES-CBC 當 PBES2 的加密方案、補上 MD2/MD5/SHA-1 的 security considerations。
  諷刺的是這個 class 叫 Rfc2898DeriveBytes —— 名字凍在被取代的那一版上，為了相容性改不掉。）
-->

---
clicks: 3
---

# 那它為什麼被廢棄

<style>
.deck-obsolete .slidev-code { font-size: 11px !important; line-height: 1.6 !important; }
</style>

<div class="grid grid-cols-2 gap-6 mt-2 deck-obsolete" style="align-items: start">

<div>

```csharp {none|1}
var db  = new Rfc2898DeriveBytes(password, salt, iterations);
var key = db.GetBytes(alg.KeySize   / 8);
var iv  = db.GetBytes(alg.BlockSize / 8);
```

<div v-click="1" class="mt-3 text-sm">
這個建構子拿到了 <b class="text-teal-300">P</b>、<b class="text-sky-300">S</b>、<b class="text-teal-300">c</b> —— 然後就沒了。
<div class="mt-1 text-amber-300"><b>dkLen 呢？</b></div>
</div>

<div v-click="2" class="mt-4">

```csharp
byte[] material = Rfc2898DeriveBytes.Pbkdf2(
    password, salt, iterations,
    HashAlgorithmName.SHA256,
    keyLen + ivLen);          // ← 長度，在這裡
```

</div>

</div>

<div>

<div class="px-3 py-2 rounded bg-gray-500/10 border border-gray-500/25 font-mono" style="font-size: 12px; line-height: 1.7">
<span class="opacity-45">PBKDF2 ( P, S, c,</span> <b class="text-amber-300">dkLen</b> <span class="opacity-45">)</span>
<span class="opacity-35 ml-2" style="font-size: 10.5px">RFC 8018 §5.2</span>
</div>

<div v-click="1" class="mt-3 p-3 rounded border-l-4 border-red-400 bg-red-400/5">

**dkLen 被推遲到 GetBytes 了**

<div class="text-xs opacity-80 mt-1 leading-relaxed">
而且是一次一次地拿。所以這個物件<b class="text-red-300">不是一次 PBKDF2</b> ——
它是一條 stream，而 RFC 裡沒有這種東西。<br>
少了一個 input，它就不是規格書定義的那個函式了。
</div>

<div class="text-xs opacity-55 mt-2 italic">
“… offers a non-standard usage by streaming bytes back … the algorithm should be used as a one-shot.”
</div>

<div class="text-xs font-mono opacity-40 mt-2">SYSLIB0060 · .NET 10 · 全部建構子</div>

</div>

<div v-click="2" class="mt-3 p-3 rounded border-l-4 border-teal-400 bg-teal-400/5 text-xs opacity-85 leading-relaxed">
新的靜態方法把 input 補回來了。它沒有變聰明 —— 它只是<b class="text-teal-300">不讓你不講長度</b>。
</div>

</div>

</div>

<!--
這一頁只有一個論證，不要拆成兩件事講：

  RFC 的簽章是 PBKDF2 (P, S, c, dkLen) —— 四個 input。
  舊建構子只收三個。第四個被推遲到 GetBytes，還可以一直拿。
  所以它從一開始就不是「一次 PBKDF2」，是一條 stream。
  規格書裡沒有 stream 這種東西。

click 3 收回第 12 頁那個 48：
「48 不是誰算出來的，是兩次 GetBytes 掉出來的。
  新的 API 沒有變聰明，它只是逼你在寫下去之前，把長度講出來。」

不要在這裡開 SHA-1 / 1000 輪那條線 —— 那是 Options 那一行的事，
跟「少了一個 input」是不同的故事，講了會把這一頁的論證稀釋掉。
（SYSLIB0041 與預設值的細節在附錄 D，被問到再翻。
  而抽 48 bytes 實際跑了幾輪在附錄 B。）

被問到「那到底什麼時候開始算？」（dotnet/runtime 原始碼可查）：

  new 的時候一輪都沒跑。建構子只存下 password/salt/iterations、開好 HMAC、
  配一個 hLen 大小的 _buffer，然後 _block = 0。

  真正在算的是私有的 Func()，它裡面才是 for (int i = 2; i <= _iterations; i++)，
  一次算「一個 block」。而 GetBytes 的迴圈長這樣：
      while (offset < cb) { Func(); … }
  算不完的尾巴會留在 _buffer 裡（_startIndex / _endIndex），給下一次呼叫用。

  所以我們那段（SHA-1，hLen = 20）實際是：
      new(...)        → 0 輪
      GetBytes(32)    → block 1 + block 2 = 2000 輪，剩 8 bytes 留在 buffer
      GetBytes(16)    → 先吃掉那 8 bytes，再算 block 3 = 1000 輪
  第二次呼叫比第一次便宜，而且它有一半的 bytes 是上一次算出來的。

  但要講精確：那 3000 輪不是「被拆成兩次呼叫」造成的。
  分塊（l = ⌈dkLen/hLen⌉）是 RFC 本來就這樣定的，一次拿 48 bytes 也一樣跑 3000 輪。
  stream 的問題不是讓它變貴，是讓「48」這個數字從頭到尾沒有出現在任何人眼前。

  另外，因為 T_i 只跟 block index i 有關、block 之間沒有鏈，
  所以兩次拿跟一次拿產出的 bytes 完全一樣 —— 換成 one-shot 是 byte-compatible 的。
  ⚠️ 但只要順手把 SHA-1 換成 SHA-256，key 就變了，既有密文全解不開。
  這兩件事要分兩次做（見附錄 D）。

最後一句（時間夠再說）：
「PBKDF2 是個乘法，而且只乘 CPU 時間。
  後來的 Argon2 想乘的是記憶體 —— 那是另一場了。」
-->

---
layout: center
---

# 參考資料

<div class="text-sm leading-loose mx-auto text-left" style="max-width: 800px">

- [SYSLIB0060 warning - Rfc2898DeriveBytes constructors are obsolete](https://learn.microsoft.com/en-us/dotnet/fundamentals/syslib-diagnostics/syslib0060)
- [SYSLIB0041 warning - Rfc2898DeriveBytes constructors with default hash algorithm and iteration counts are obsolete](https://learn.microsoft.com/en-us/dotnet/fundamentals/syslib-diagnostics/syslib0041)
- [Rfc2898DeriveBytes.Pbkdf2 Method (System.Security.Cryptography)](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.rfc2898derivebytes.pbkdf2)
- [RFC 8018 — PKCS #5: Password-Based Cryptography Specification Version 2.1](https://www.rfc-editor.org/rfc/rfc8018)
- [OWASP Cheat Sheet Series — Password Storage](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [Hashcat v6.2.6 benchmark on the Nvidia RTX 4090](https://gist.github.com/Chick3nman/32e662a5bb63bc4f51b847bb422222fd)
- [Bitwarden — Encryption Key Derivation](https://bitwarden.com/help/kdf-algorithms/)
- [Bitwarden Security Whitepaper](https://bitwarden.com/help/bitwarden-security-white-paper/)

</div>

---
layout: center
class: text-center
---

<div class="opacity-40 text-sm tracking-widest uppercase">以下是附錄</div>

<div class="mt-4 text-lg opacity-70">簡報時不會走到，被問到才翻</div>

---

# 附錄 A · PBKDF2 的精確定義

<div class="text-sm opacity-70 mb-4">RFC 8018 §5.2。主線第 8 頁刻意省略了 XOR 與 block index。</div>

```text
DK = T₁ ‖ T₂ ‖ … ‖ T_l          截斷成 dkLen 個 byte

T_i = U₁ ⊕ U₂ ⊕ … ⊕ U_c          ← 每一輪的結果「全部」XOR 起來
                                    不是只取最後一輪

U₁  = PRF( P, S ‖ INT(i) )       P = password，S = salt
U_j = PRF( P, U_{j-1} )          PRF 預設是 HMAC-SHA-1，實務用 HMAC-SHA-256
```

<div class="grid grid-cols-2 gap-6 mt-6 text-sm">

<div class="p-3 rounded border-l-4 border-teal-400 bg-teal-400/5">

**password 是 HMAC 的 key，不是被 hash 的資料**

每一輪都要重新用到它，所以攻擊者不能預先算好前面幾輪再省略。
主線第 8 頁用「password 每輪都接進去」表達這件事。

</div>

<div class="p-3 rounded border-l-4 border-amber-400 bg-amber-400/5">

**dkLen 不是免費的**

`l = ⌈dkLen / hLen⌉`，而**每一個 block 都要跑完整的 c 輪**。
跟 PRF 要超過 hLen 的量，成本就是線性倍增 —— 但攻擊者否決一個錯的候選密碼，
往往算完第一個 block 就夠了。這個代價是**不對稱地落在你身上**。

</div>

</div>

---

# 附錄 B · dkLen 抽太多，多付的是你

<div class="text-sm opacity-70 mb-4">承附錄 A：<code class="font-mono">l = ⌈dkLen / hLen⌉</code>，而每一個 block 都要跑完整的 c 輪。</div>

<div class="p-4 rounded border-l-4 border-amber-400 bg-amber-400/5">

**套回我們那段 code**（假設 `alg` 是 AES-256）：沒指定 PRF，所以預設是 HMAC-SHA-1，`hLen = 20`；
兩次 `GetBytes` 一共抽 `32 + 16 = 48` bytes。

<div class="font-mono mt-3" style="font-size: 14px">
l = ⌈48 / 20⌉ = <b class="text-amber-300">3</b> 個 block　→　實際跑了 3 × 1000 = <b class="text-amber-300">3000</b> 輪，不是 1000 輪。
</div>

</div>

<div class="grid grid-cols-3 gap-4 mt-4 text-sm">

<div class="p-3 rounded border border-gray-500/30 bg-gray-500/5">

**多付的錢買不到安全**

<div class="text-xs opacity-80 mt-1 leading-relaxed">
多出來的兩個 block 不會讓密碼更難猜 —— 難猜程度由 <code class="font-mono">c</code> 和密碼本身決定。
它只是讓<b>你自己</b>多算兩遍。
</div>

</div>

<div class="p-3 rounded border-l-4 border-sky-400 bg-sky-400/5">

**block 之間互不相依**

<div class="text-xs opacity-80 mt-1 leading-relaxed">
<code class="font-mono">T_i = F(P, S, c, i)</code> 只跟 <code class="font-mono">i</code> 有關。
鏈是在<b>一個 block 之內</b>的 c 輪，block 與 block 之間<b class="text-sky-300">沒有鏈</b> ——
所以第 3 塊可以事後單獨算。
</div>

</div>

<div class="p-3 rounded border-l-4 border-amber-400 bg-amber-400/5">

**但這不是「拆」造成的**

<div class="text-xs opacity-80 mt-1 leading-relaxed">
一次拿 48 bytes 也一樣跑 3000 輪 —— 分塊是<b>演算法本來就這樣定的</b>。
水龍頭的問題不是讓它變貴，是讓<b class="text-amber-300">沒有人看見那個 48</b>。
</div>

</div>

</div>

<div class="mt-4 text-xs opacity-50">
⚠️ 待確認：<code class="font-mono">alg</code> 實際是不是 AES-256。若是 AES-128 則抽 32 bytes，<code class="font-mono">l = 2</code>、共 2000 輪。
</div>

---

# 附錄 C · 為什麼要 XOR 全部，不是只取最後一輪

<div class="space-y-4 text-sm mt-6" style="max-width: 820px">

<div class="p-4 rounded border border-gray-500/30 bg-gray-500/5">

如果 `T = U_c`（只取最後一輪），整條鏈就是一個函式反覆疊代自己。
疊代函式會**收斂到循環**：一旦某個 `U_j` 撞上前面出現過的值，
後面就永遠在那個圈裡打轉，再多輪也不會增加任何未知數。

</div>

<div class="p-4 rounded border-l-4 border-teal-400 bg-teal-400/5">

把每一輪的結果全部 XOR 起來，等於要求攻擊者**真的走完每一輪**才算得出答案 ——
中間就算提早進入循環，前面那些 `U_j` 仍然全部參與了最終結果。

</div>

<div class="p-3 rounded bg-gray-500/10 border border-gray-500/25 text-xs" style="line-height: 1.8">
RFC 8018 §5.2 的原註：<br>
<i class="opacity-85">“The construction of the function F follows a ‘belt-and-suspenders’ approach.
The iterates U_i are computed recursively <b>to remove a degree of parallelism from an opponent</b>;
they are exclusive-ored together <b>to reduce concerns about the recursion degenerating into a small set of values</b>.”</i>
</div>

<div class="text-xs opacity-55">
兩件事分得很清楚：<b>遞迴</b>是為了拿掉攻擊者的平行度（主線第 8 頁講的就是這個），
<b>XOR</b> 是為了防止那條遞迴退化。實務上 HMAC-SHA-256 撞上循環的機率極低 ——
這個設計是為了「不依賴那個機率」，不是為了修補一個看得到的漏洞。
</div>

</div>

---

# 附錄 D · 兩個 SYSLIB 的完整內容

<style>
.deck-syslib .slidev-code { font-size: 10px !important; line-height: 1.7 !important; }
</style>

<div class="deck-syslib grid grid-cols-2 gap-6 mt-4 text-sm">

<div>

**SYSLIB0041** · .NET 7 起

<div class="text-xs opacity-70 mt-2">這五個建構子會套用預設值（1000 輪 + SHA-1）：</div>

```csharp
Rfc2898DeriveBytes(String, Byte[])
Rfc2898DeriveBytes(String, Int32)
Rfc2898DeriveBytes(Byte[], Byte[], Int32)
Rfc2898DeriveBytes(String, Byte[], Int32)   // ← 我們用的是這個
Rfc2898DeriveBytes(String, Int32, Int32)
```

<div class="text-xs opacity-60 mt-3 leading-relaxed">
所以這個警告其實從 .NET 7 就掛在那裡了。<br>
<b class="text-amber-300">待確認：</b>我們在 .NET 8 時代的 build log 裡是不是已經有它。
</div>

</div>

<div>

**SYSLIB0060** · .NET 10 起

<div class="text-xs opacity-70 mt-2">全部建構子。官方給的搬移方式：</div>

```csharp
// 舊
var kdf = new Rfc2898DeriveBytes(
    password, salt, iterations, hashAlgorithm);
byte[] k = kdf.GetBytes(64);

// 新
byte[] k = Rfc2898DeriveBytes.Pbkdf2(
    password, salt, iterations, hashAlgorithm, 64);
```

<div class="text-xs opacity-60 mt-3 leading-relaxed">
若原本用的是「傳 saltSize 讓它自己生 salt」那組，
新的靜態方法沒有對應多載，要自己
<code class="font-mono">RandomNumberGenerator.GetBytes(saltSize)</code>。
</div>

</div>

</div>

<div class="mt-4 p-3 rounded border-l-4 border-red-400 bg-red-400/5 text-sm">

**升級時真正的地雷：不要順手把 PRF 也換掉**

<div class="text-xs opacity-85 mt-1 leading-relaxed">
因為 block 之間互不相依（附錄 B），<code class="font-mono">GetBytes(32)</code> + <code class="font-mono">GetBytes(16)</code>
跟一次 <code class="font-mono">Pbkdf2(…, 48)</code> 產出的 bytes <b class="text-teal-300">完全一樣</b> —— 純換寫法是安全的。
<b class="text-red-300">但只要把 SHA-1 換成 SHA-256，導出來的 key 就整個變了</b>，
既有密文全部解不開。這兩件事必須分開做：先無痛換成 one-shot，PRF 要不要動是另一次、要配資料搬遷的決定。
</div>

</div>

---

# 附錄 E · 那為什麼還會有 Argon2

<div class="text-sm mt-4" style="max-width: 860px">

主線第 9 頁那張表的「直著看」已經說了：PBKDF2 只是把每一格乘上同一個常數。
問題在於**它乘的是 CPU 時間，而 CPU 時間正好是攻擊者最便宜的東西**。

</div>

<div class="grid grid-cols-3 gap-4 mt-6 text-sm">

<div class="p-3 rounded border border-gray-500/30 bg-gray-500/5">

**PBKDF2**

<div class="text-xs opacity-70 mt-2 leading-relaxed">
只吃 CPU。一張 GPU 有上萬個核心，每個核心跑一條鏈，
所以攻擊者的平行度幾乎不受限。
</div>

</div>

<div class="p-3 rounded border border-gray-500/30 bg-gray-500/5">

**bcrypt / scrypt**

<div class="text-xs opacity-70 mt-2 leading-relaxed">
開始吃記憶體。GPU 的核心多，但每個核心分到的記憶體很少，
於是平行度被記憶體卡住。
</div>

</div>

<div class="p-3 rounded border-l-4 border-teal-400 bg-teal-400/5">

**Argon2id**

<div class="text-xs opacity-70 mt-2 leading-relaxed">
記憶體用量是可調參數。OWASP 目前對新專案的首選；
PBKDF2 主要留給需要 FIPS-140 的場景。
</div>

</div>

</div>

<div class="mt-6 text-xs opacity-55">
Bitwarden 也已經可以把 KDF 換成 Argon2id，PBKDF2 是預設值而不是唯一選項。
</div>

---

# 附錄 F · IV 是什麼，為什麼不該從密碼導出

<div class="p-3 rounded border border-gray-500/30 bg-gray-500/5 text-sm mb-4">

**AES 是 block cipher** —— 一次只處理固定大小的一塊，AES 的 block 永遠是 **16 bytes**（key 才有 128/192/256 之分）。
同一把 key、同一塊明文，出來永遠是同一塊密文；所以直接一塊一塊加密（ECB），明文的圖樣會透出來。
**CBC 這類模式**讓每一塊先跟前一塊混合再加密 —— 但第一塊沒有「前一塊」，
所以需要一個外來的起點，那就是 **IV**。

<div class="mt-2 text-xs opacity-70">
所以 <code class="font-mono">key</code> 是 cipher（AES）的東西，<code class="font-mono">IV</code> 是<b>模式</b>（CBC…）的東西。
IV <b class="text-teal-300">不必保密</b>，但必須<b class="text-teal-300">每次都不一樣</b>；長度等於 <b>block size</b> 而非 key size ——
這就是 code 裡 <code class="font-mono">alg.BlockSize / 8 = 16</code> 的由來。
</div>

</div>

<div class="grid grid-cols-2 gap-6">

<div class="p-3 rounded border-l-4 border-red-400 bg-red-400/5">

**我們那段做了什麼**

```csharp
var key = db.GetBytes(alg.KeySize   / 8);
var iv  = db.GetBytes(alg.BlockSize / 8);
```

<div class="text-xs opacity-80 mt-2 leading-relaxed">
同一組 <code class="font-mono">password + salt + iterations</code>，永遠得到<b>同一個 key，也永遠得到同一個 IV</b>。
IV 的整個用途就是「讓同樣的明文每次加出來不一樣」——
它一旦變成密碼的函式，這個用途就<b class="text-red-300">整個消失</b>了。
</div>

</div>

<div class="p-3 rounded border-l-4 border-teal-400 bg-teal-400/5">

**該怎麼做**

```csharp
byte[] key = Rfc2898DeriveBytes.Pbkdf2(
    password, salt, iterations,
    HashAlgorithmName.SHA256, alg.KeySize / 8);

byte[] iv = RandomNumberGenerator.GetBytes(
    alg.BlockSize / 8);      // 隨密文一起存
```

<div class="text-xs opacity-70 mt-2">
只抽 key 不抽 IV，也讓 dkLen 從 48 降回 32（見附錄 B）。
</div>

</div>

</div>

<div class="mt-3 text-xs opacity-55">
跟「水龍頭」是同一個原因：那個 API 讓人覺得可以一直跟它要，於是沒人問過這段 bytes 該不該從密碼來。
</div>

---

# 附錄 G · 真實產品裡的那兩條分岔

<div class="text-sm opacity-70 mb-4">主線第 11 頁刻意不寫名字。這裡是 Bitwarden 的實際做法。</div>

<div class="grid grid-cols-2 gap-6 text-sm">

<div class="p-4 rounded border-l-4 border-teal-400 bg-teal-400/5">

**留在本機那條**

```text
Master Key = PBKDF2-SHA256(
    password = master password,
    salt     = 帳號 email,
    iter     = 600,000 )
```

<div class="text-xs opacity-70 mt-2">
永遠不離開裝置。它負責解開真正鎖著資料的那把鑰匙。
</div>

</div>

<div class="p-4 rounded border-l-4 border-amber-400 bg-amber-400/5">

**送出去那條**

```text
Master Password Hash = PBKDF2-SHA256(
    password = Master Key,
    salt     = master password,
    iter     = 極少數輪 )
```

<div class="text-xs opacity-70 mt-2">
server 收到後會再自己 hash 一次才存。
</div>

</div>

</div>

<div class="mt-5 p-3 rounded border border-gray-500/30 bg-gray-500/5 text-sm">

**為什麼第二次只跑幾輪？** 因為它的輸入已經是高熵的 Master Key，不是人類密碼 ——
沒有東西可以暴力猜，iterations 這個乘數也就沒有意義了。
iterations 是拿來對抗**低熵輸入**的。

</div>

<div class="mt-4 text-xs opacity-55">
⚠️ 待查證：client 端第二次的實際輪數（1 或 2），以及官方說的「總共 700,000 輪」怎麼拆帳，
兩份來源說法不一致。上台前要再對一次 whitepaper 與 clients 原始碼。
</div>
