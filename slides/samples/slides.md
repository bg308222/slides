---
theme: default
title: 專案架構說明
info: |
  這個 repo 的架構說明，同時也是一份可運作的範例簡報。
class: text-center
transition: slide-left
mdc: true
---

# 專案架構說明

一個 repo，任意多個互不相干的 Slidev 簡報

<div class="pt-8 text-sm opacity-60">
  這份簡報本身就放在 <code>slides/samples/</code>，是結構的活範例
</div>

---
layout: center
class: text-center
---

# 核心原則

Slidev 只吃**一個 Markdown 檔**

其他一切都從那個檔案的**所在位置**反推出來

---

# 為什麼是「所在位置」

Slidev 原始碼 `resolver.ts` 裡的一行決定了整個架構：

```ts
const userRoot = dirname(entry)
```

<v-clicks>

- `components/`、`layouts/`、`public/`、`styles/`、`vite.config.ts`
- 這些慣例資料夾**跟著 `slides.md` 走**
- **不是**跟著你執行 `just` 的位置走

</v-clicks>

<div v-click class="mt-6 p-4 bg-teal-500/10 rounded border-l-4 border-teal-500">
所以每個簡報資料夾天生就是一個獨立的 Slidev 專案根目錄，
不需要任何設定就能各自擁有完整資源。
</div>

---

# 目錄結構

```plain {all|2-5|6-14|8-11}
slides/
├── package.json          # 只有 2 個 devDeps，無 scripts
├── bun.lock
├── node_modules/         # 唯一一份，靠 Node 向上解析共用
├── justfile              # 唯一的操作入口
└── slides/               # 所有簡報都在這下面
    ├── samples/          # ← 這份簡報
    │   ├── slides.md         # 入口，userRoot = 此資料夾
    │   ├── components/       # 只有這場能用
    │   └── public/           # 只有這場能用
    └── report/20260730/  # 任意層級都可以
        └── slides.md
```

---
layout: two-cols
class: gap-4
---

# 共用什麼

<v-clicks>

- `node_modules`
- Slidev CLI 版本
- theme 套件
- Vite 依賴快取

</v-clicks>

<div v-click class="mt-4 text-sm opacity-70">
靠 Node 的向上模組解析，放在根目錄就夠了
</div>

::right::

# 不共用什麼

<v-clicks>

- `components/`
- `layouts/`
- `public/`
- `styles/`
- `vite.config.ts`
- `index.html`

</v-clicks>

<div v-click class="mt-4 text-sm opacity-70">
每場簡報各自獨立，刪掉整個資料夾就乾淨移除
</div>

---

# justfile

只有三個 recipe，因為只需要三個

| 指令 | 行為 |
|---|---|
| `just` | 列出所有 recipe |
| `just list` | 掃 `slides/**/slides.md`，印出相對路徑 |
| `just dev samples` | 開 dev server 並開瀏覽器 |
| `just new report/20260801` | 產生骨架（`slides.md` + `public/`） |

<div class="mt-6">

`dev` 吃 `*ARGS`，所以參數可以直接透傳：

```bash
just dev samples --port 8080 --remote
```

</div>

---

# 一個關鍵細節

justfile 裡指定 binary 的方式：

```just
bin := "bun " + justfile_directory() / "node_modules/@slidev/cli/bin/slidev.mjs"
```

<v-clicks>

- 用**絕對路徑**指向 `node_modules` 內的 `.mjs`
- 而不是 `bunx --bun slidev`

</v-clicks>

<div v-click class="mt-6">

原因：Slidev 會拿 `process.argv[1]` 跟 `userRoot` 做 `relative()`
來判斷自己是否為全域安裝。走 bunx 的快取路徑會讓它誤判成 `(global)`。

</div>

---

# 新增一個簡報

```bash
just new report/20260801
```

產生：

```plain
slides/report/20260801/
├── slides.md
└── public/
```

<div class="mt-6">

然後就能開：

```bash
just dev report/20260801
```

層級隨你，`just list` 會自動掃出來。

</div>

---

# 本地元件示範

下面這行來自 `slides/samples/components/Hello.vue`——
一個只有這場簡報看得到的元件：

<div class="mt-8 p-6 bg-gray-500/10 rounded">
  <Hello />
</div>

<div class="mt-8 text-sm opacity-60">
證明 <code>userRoot</code> 慣例在任意深度都生效，無需任何設定。
</div>

---
layout: center
class: text-center
---

# 常見誤解

| 誤解 | 實際 |
|---|---|
| slidev 吃資料夾 | 不吃，只吃 md 檔 |
| 共用資源放 repo 根就好 | 不行，以 `dirname(entry)` 為準 |
| 相對路徑相對於 cwd | 相對於 `userRoot` |

---
layout: center
class: text-center
---

# 就這樣

一個 `package.json`、一個 `node_modules`、一個 `justfile`

其餘完全隔離

<div class="mt-8 text-sm opacity-60">
  按 <kbd>o</kbd> 看總覽，<kbd>d</kbd> 切換深色模式
</div>
