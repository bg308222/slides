# slides

一個 repo 管理多份互不相干的 [Slidev](https://sli.dev) 簡報。
共用一份 `node_modules`，但每份簡報的資源完全隔離。

## 需求

- [bun](https://bun.sh)
- [just](https://github.com/casey/just)

## 安裝

```bash
bun install
```

## 使用

```bash
just                      # 列出所有可用指令
just list                 # 列出所有簡報
just dev samples          # 開啟 samples 這份簡報
just new report/20260801  # 新建一份簡報
```

`just dev` 會啟動 dev server 並自動開啟瀏覽器（預設 <http://localhost:3030>）。
額外參數會直接透傳給 Slidev：

```bash
just dev samples --port 8080          # 換 port
just dev samples --remote             # 開啟遠端控制
just dev samples --remote mypassword  # 遠端控制加密碼
```

## 目錄結構

```
.
├── package.json
├── bun.lock
├── justfile
└── slides/
    └── samples/              # 一份簡報 = 一個資料夾
        ├── slides.md         # 入口檔，固定叫這個名字
        └── components/       # 選用，只有這份簡報能用
```

簡報的路徑層級不限，`just list` 會自動掃出所有 `slides/**/slides.md`：

```
slides/
├── samples/slides.md                → just dev samples
├── report/20260730/slides.md        → just dev report/20260730
└── talks/2026/vue-intro/slides.md   → just dev talks/2026/vue-intro
```

## 新增一份簡報

```bash
just new report/20260801
```

會建立：

```
slides/report/20260801/
├── slides.md
└── public/
```

然後直接開：

```bash
just dev report/20260801
```

## 每份簡報可以放什麼

在簡報自己的資料夾內，以下 Slidev 慣例目錄都會自動生效，**且只對該份簡報生效**：

| 路徑 | 用途 |
|---|---|
| `slides.md` | 入口檔 |
| `components/*.vue` | 自訂 Vue 元件，在 md 內直接 `<MyComponent />` |
| `layouts/*.vue` | 自訂版面，在 frontmatter 用 `layout: my-layout` |
| `public/*` | 靜態資源，以 `/` 為根引用（如 `![](/logo.png)`） |
| `styles/index.ts` | 自訂樣式 |
| `snippets/*` | 程式碼片段，用 `<<< @/snippets/foo.ts` 引入 |
| `vite.config.ts` | 擴充 Vite 設定 |
| `index.html` | 注入 meta / script |

原因是 Slidev 的專案根目錄就是入口檔所在的資料夾，所以每個簡報資料夾天生就是
一個獨立的 Slidev 專案。詳細說明見 `slides/samples`——那份簡報本身就在講這件事。

## 設計取捨

**共用**：`node_modules`、Slidev CLI 版本、theme 套件、Vite 快取。
靠 Node 的向上模組解析，只需要根目錄一份。

**不共用**：`components/`、`layouts/`、`public/`、`styles/`、`vite.config.ts`。
每份簡報各自獨立，刪掉整個資料夾就是乾淨移除，不會影響其他簡報。

如果日後真的需要跨簡報共用元件，正確做法是做一個 local addon
（在簡報的 headmatter 加 `addons: [../../shared]`），而不是在根目錄放共用資料夾——
後者不會生效。

## 授權

Private.
