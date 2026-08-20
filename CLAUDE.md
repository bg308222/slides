1. 一律使用繁體中文回答
2. 思考過程不在前一點規範中，但回答時請永遠使用繁體中文

---

# 專案規則

這是一個放置**多份互不相干**的 Slidev 簡報的 repo。

## 核心原則

Slidev 只吃一個 Markdown 檔，其專案根目錄（`userRoot`）就是**該入口檔所在的資料夾**
（原始碼 `resolver.ts`：`const userRoot = dirname(entry)`）。

因此 `components/`、`layouts/`、`public/`、`styles/`、`vite.config.ts`、`index.html`
這些慣例資料夾，**跟著 `slides.md` 走，不是跟著執行指令的位置走**。

## 目錄結構

```
slides/                   # repo 根
├── package.json          # 只有 devDependencies，不放 scripts
├── bun.lock
├── node_modules/         # 唯一一份，靠 Node 向上解析共用
├── justfile              # 唯一的操作入口
└── slides/               # 所有簡報都在這下面
    └── <任意層級>/<簡報名>/
        ├── slides.md     # 入口，userRoot = 此資料夾
        ├── components/   # 選用，只有這場能用
        └── public/       # 選用，只有這場能用
```

## 硬性規則

1. **每份簡報的入口檔一律命名為 `slides.md`**，放在 `slides/` 下的葉節點資料夾。
   路徑層級不限（`slides/report/20260730/slides.md`、`slides/talks/vue-intro/slides.md` 皆可）。

2. **簡報之間不共用任何東西**（入口機制與 `node_modules` 除外）。
   需要元件、圖片、樣式，就放進該簡報自己的資料夾。
   不要為了共用而新增根層級的 `components/`、`layouts/`、addon 或 theme 專案。

3. **不在 `package.json` 加 `scripts`**。所有操作一律走 `justfile`。

4. **不在 repo 根放 `vite.config.ts`、`index.html`、`styles/`**。
   這些對 Slidev 而言只在 `userRoot`（即各簡報資料夾）內才有意義，放根目錄不會生效。

5. **runtime 使用 bun**。安裝套件用 `bun add`，不要用 npm/pnpm/yarn。

6. justfile 內呼叫 Slidev 一律用 `{{bin}}` 變數（絕對路徑指向
   `node_modules/@slidev/cli/bin/slidev.mjs`），**不要改用 `bunx slidev`**。
   Slidev 會拿 `process.argv[1]` 與 `userRoot` 做 `relative()` 判斷是否為全域安裝，
   走 bunx 的快取路徑會被誤判成 `(global)`。

## 常用指令

```bash
just                      # 列出所有 recipe
just list                 # 列出所有簡報
just dev samples          # 開發模式（可透傳 --port 等參數）
just new report/20260801  # 新建簡報骨架
```

## Skills

- `technical-report-draft`（`.claude/skills/`）：與已有初步切法的作者多輪推敲技術敘事、技術正確性與可視化的漸進推導，最後交付 `draft.md`。
- `draft-to-deck`（`.claude/skills/`）：把已定稿的條列式草稿編排成 Slidev 簡報。
  給定草稿路徑時使用——會先讀懂草稿、提問釐清，再重新編排成 `slides.md`，
  最後 run 起來用瀏覽器逐頁確認畫面（編譯過不代表畫面對）。

## 注意事項

- Slidev **不接受資料夾**當入口。`slidev slides/samples` 會被當成檔案而失敗，
  必須寫完整的 `slides/samples/slides.md`。
- Slidev 的 `--out`、`--output` 等路徑參數是**相對於 `userRoot`**，不是 cwd。
  若日後要加 build/export recipe，請用 `justfile_directory()` 組絕對路徑。
- `slides/samples/` 是說明本專案架構的範例簡報，同時也是語法參考，請保留。
