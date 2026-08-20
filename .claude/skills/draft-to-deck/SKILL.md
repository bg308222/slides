---
name: draft-to-deck
description: 把條列式草稿編排成 Slidev 簡報。使用者提供草稿路徑（通常是某個簡報資料夾下的 draft.md、outline.md 或純文字筆記）並要求「編排」、「重寫」、「做成簡報」時使用。流程為：先讀懂草稿、提出釐清問題、再以自己的話重新編排成 slides.md，最後 run 起來用瀏覽器實際逐頁確認畫面。適用於月報、週報、專案回顧、技術分享等由條列筆記出發的簡報。
---

# 草稿 → Slidev 簡報

把條列式、縮排式的草稿，重新編排成結構清楚的 Slidev 簡報。

**核心心法**：不是把草稿逐行搬進 slides.md，而是先讀懂內容的因果與輕重，
再決定哪些該獨立成頁、哪些該合併、哪些需要補上草稿沒寫但觀眾會問的東西。

## 流程

### 1. 讀草稿，建立理解

讀取使用者給的草稿路徑。同時確認該簡報資料夾的位置——
草稿通常已經在目標位置（如 `slides/innovue/monthly-report/202607/draft.md`），
輸出的 `slides.md` 就放在同一層。

讀完後，**先用兩三句話摘要每個項目**，讓使用者確認你理解正確。
這一步不要跳過：草稿常有縮寫、內部代號、省略的因果關係，
把理解攤開來比事後改稿便宜。

### 2. 提問（用 AskUserQuestion）

一次問完，不要來回擠牙膏。以下四類問題最常需要問，
依草稿實際情況調整，不必硬湊四題：

| 類型 | 為什麼要問 |
|---|---|
| **項目狀態** | 草稿常只描述做了什麼，沒說完成度。用 multiSelect 讓使用者勾選「已完成」的項目 |
| **專有名詞處理** | 內部代號要照原樣用，還是首次出現處補註解？取決於觀眾 |
| **觀眾與場合** | 主管月報／團隊分享／對客戶簡報，決定要放多少技術細節與踩雷過程 |
| **是否加延伸章節** | 如「下月計畫」、「待處理事項」。給「加但留空白待填」／「不用加」／「由我推論」三選項 |

其他視情況要問的：簡報的封面副標要放什麼（人名、部門、日期）、
是否有不想寫進簡報的敏感內容、頁數上限。

**不要問的**：「這樣可以嗎」、「要開始了嗎」——直接做。

### 3. 編排

這是這個 skill 的重點。編排原則：

#### 找出最有訊息量的部分，給它獨立一頁

草稿裡平鋪的幾行，往往是整個項目最值得講的地方。
例如「三輪驗收都 rollback」在草稿裡是三行，但它比「交付了三個工具」更有訊息量，
應該獨立成頁並用視覺區分（不同顏色邊框標示性質不同的失敗）。

#### 拆開被壓縮的因果

草稿常把「發現問題 → 所以採取某方案」壓成一句。
拆成兩頁或兩段：先講為什麼不能用直覺的做法，再講實際採取的策略。
讀者需要先接受「原方案不可行」，才會覺得繞道方案合理。

#### 補上草稿沒寫但觀眾會問的

草稿只陳述「發生什麼」，簡報要回答「所以呢」。
常見的補充是一頁「觀察」或「檢討」：
把失敗歸因（是程式問題還是資料問題）、說明取捨的代價、
指出哪些是事前無法預知的。

**這些補充是推論，必須明確告知使用者**，讓他們核對是否符合事實。

#### 為設計決策補上意圖

草稿列出「5 個 skill」只有名稱，簡報要說明為什麼拆這麼細。
每個看起來像清單的東西，問自己：讀者看完會不會想問「為什麼這樣切」。

#### 段落節奏

- 用 `layout: section` 分隔頁區隔各大項目，讓觀眾知道換題目了
- 開頭放一頁「本月概覽」／「總覽」表格，含狀態色標，先給全貌
- 結尾一頁「回顧」／「總結」，每個重點一行收束
- 每個大項目控制在 2–4 頁

#### 最後一頁一定是「參考資料」（每份簡報都要，不要漏）

把簡報過程中**實際引用過**的東西，用 `[標題](網址)` 條列出來，一行一筆。
規格文件寫全名（例如 `[RFC 7636 — Proof Key for Code Exchange by OAuth Public Clients](https://www.rfc-editor.org/rfc/rfc7636)`），
文章寫原標題。**這一頁不要有任何自己發揮的內容** —— 沒有導讀、沒有評論、沒有分類標題，就是一份清單。

兩個容易出錯的地方：

- **清單要跟內文對得起來。** 編排過程中刪掉的段落，它引用的來源也要跟著移除；
  收尾前用 `grep -o 'RFC [0-9]*' slides.md | sort -u` 之類的方式對一次，
  確認「引用過的都列了、列了的都還在引用」。
- **標題與網址要查證過**，不要憑印象寫。RFC 直接抓 `https://www.rfc-editor.org/rfc/rfcXXXX.txt`
  看標題行；文章就打開原頁面確認。

### 4. 常用的 Slidev 排版手法

```md
---
theme: default
title: <簡報標題>
info: |
  <一句話說明>
class: text-center
transition: slide-left
mdc: true
---
```

狀態色標（放在總覽表格裡）：

```md
| 項目 | 內容 | 狀態 |
|---|---|---|
| A | ... | <span class="text-teal-400">已完成</span> |
| B | ... | <span class="text-amber-400">進行中</span> |
| C | ... | <span class="text-red-400">受阻</span> |
```

逐點揭露：

```md
<v-clicks>

- 第一點
- 第二點

</v-clicks>

<div v-click class="mt-6 text-sm opacity-70">
補充說明，最後才出現
</div>
```

帶色邊框強調區塊（區分性質）：

```md
<div class="p-4 border-l-4 border-red-400 bg-red-400/5">

**失敗** — 說明
→ 處理方式

</div>
```

顏色語意慣例：`teal` 成功／策略、`amber` 警告／進行中、`red` 失敗／阻礙、
`gray-500/10` 中性補充。

**注意**：`<div>` 內要寫 Markdown 語法（`**粗體**`、清單）時，
div 標籤與內容之間必須留空行，否則不會被解析。

### 5. 驗證：編譯 + 視覺，兩關都要過

**最重要的一件事：編譯通過不等於畫面是對的。**

實測案例：一份 31 頁的簡報 `build` 回傳 exit=0、零錯誤、所有元件都進了 bundle，
但實際打開來看，**兩張 SVG 圖整個爆掉**（渲染成一堆飽和模糊色塊，完全看不出是什麼）、
一頁的內容掉出畫面底部、配色因為底色判斷錯誤而幾乎讀不出來。
這些沒有任何一個會讓 build 失敗。

所以流程是：先確認編譯過，**然後一定要真的看**。

#### 5.1 編譯驗證

```bash
# 確認新簡報被掃到
just list

# 用 build 驗證整份編譯（比 dev server 可靠：任何一頁有問題都會讓 build 失敗）
OUT=<scratchpad>/build-check
bun node_modules/@slidev/cli/bin/slidev.mjs build <path>/slides.md --out "$OUT"
echo "exit=$?"
ls "$OUT/assets" | grep -c '^md-'   # md chunk 數 ≈ 頁數
```

> **不要用「逐頁 curl 看 HTTP 狀態」當驗證。**
> Slidev 是 SPA，`/1` 到 `/999` 全都回 200 和同一份 shell，
> 這個檢查永遠會過，是假訊號。

#### 5.2 視覺驗證（必做）

啟動 dev server，用 playwright MCP 實際看。
這些工具是 deferred 的，先用 ToolSearch 載入：

```
ToolSearch("select:mcp__playwright__browser_navigate,mcp__playwright__browser_take_screenshot,mcp__playwright__browser_resize,mcp__playwright__browser_evaluate")
```

若回報瀏覽器沒安裝，先跑 `npx -y @playwright/mcp install-browser chrome-for-testing`。

```bash
nohup bun node_modules/@slidev/cli/bin/slidev.mjs <path>/slides.md --port 3095 > /tmp/deck.log 2>&1 & disown
for i in $(seq 1 60); do c=$(curl -s -m 3 -o /dev/null -w '%{http_code}' http://localhost:3095/); [ "$c" = "200" ] && { echo ready; break; }; sleep 1; done
```

**關鍵操作細節**（踩過才知道的）：

- **路由是 `/{頁碼}?clicks={第幾個click}`**，不是 `/{頁碼}/{clicks}`——後者會回 404 頁。
- **`browser_resize` 設 1440×810**，比例接近 Slidev 的 980×552.5 canvas。
- **截圖不要指定 `filename`**。指定了只會存檔並回傳路徑，模型看不到內容；
  不指定才會把圖片內容回傳，你才真的「看到」畫面。
- 導航後若要看動畫終態，先 `browser_evaluate` 睡個 2 秒再截圖。

**用程式化檢測掃全部狀態，用截圖看關鍵頁。**
逐頁截圖很耗 context（30 頁 × 每頁數個 click ≈ 上百個狀態），不要硬掃。

> **不要用 `/print` 當「所有 click 都展開」的最壞情況。** 實測過：`/print` 只讓
> `v-click` 指令的元素顯示，但 `$clicks` 這個值在 print 模式下仍是 0 ——
> 所以任何 `<MyComp :step="$clicks" />` 這種元件，在 print 頁上量到的都只是初始狀態。

正確做法是驅動 Slidev 自己的 nav，一路 `next()` 走完全部狀態：

```js
// browser_evaluate，在正常的 /1 頁面上執行
async () => {
  const nav = window.__slidev__.nav;   // 屬性已 unwrap：nav.clicks / nav.currentPage 直接是值
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const out = [], seen = [], pagesSeen = new Set();
  const measure = (tag, no) => {
    const pg = document.querySelector('.slidev-page-' + no);   // 見下方警告
    const pb = pg.getBoundingClientRect();
    let wb = 0, wr = 0, culprit = '';
    pg.querySelectorAll('*').forEach(el => {
      const b = el.getBoundingClientRect();
      if (!b.width || !b.height) return;
      if (b.bottom - pb.bottom > wb) { wb = b.bottom - pb.bottom; culprit = el.tagName + '.' + (el.className || '').toString().slice(0, 26); }
      if (b.right - pb.right > wr) wr = b.right - pb.right;
    });
    // SVG 圖元用「螢幕座標 vs svg 螢幕座標」比對。
    // 不要用 getBBox 去比 viewBox：getBBox 不含祖先 <g transform>，
    // 任何放在 translate(...) 裡的東西都會被誤報成超界。
    const svgBad = [];
    pg.querySelectorAll('svg').forEach(svg => {
      const sb = svg.getBoundingClientRect();
      svg.querySelectorAll('text,rect,line,polygon').forEach(el => {
        const b = el.getBoundingClientRect();
        if (!b.width || !b.height) return;
        if (b.right > sb.right + 2 || b.bottom > sb.bottom + 2 || b.left < sb.left - 2 || b.top < sb.top - 2)
          svgBad.push((el.textContent || el.tagName).trim().slice(0, 20));
      });
    });
    if (wb > 3 || wr > 3 || svgBad.length) out.push({ at: tag, bottom: Math.round(wb), right: Math.round(wr), svgBad, culprit });
  };
  await nav.goFirst(); await sleep(220);
  let guard = 0;
  while (guard++ < 500) {
    const no = nav.currentPage;
    const tag = `p${no}c${nav.clicks}`;
    seen.push(tag); measure(tag, no); pagesSeen.add(no);
    if (!nav.hasNext) break;
    await nav.next(); await sleep(75);
  }
  return JSON.stringify({
    visited: seen.length, distinct: new Set(seen).size,
    pagesMeasured: pagesSeen.size, problems: out,
  }, null, 1);
}
```

**這個腳本有三個地方會靜默地讓你得到假的「零問題」，全部踩過：**

| 陷阱 | 症狀 | 自我檢查 |
|---|---|---|
| `nav.clicks = c` | 唯讀，賦值靜靜失敗，每頁只量到同一個 click | `distinct` 必須等於 `visited` |
| `querySelector('.slidev-page')` | 抓到 DOM 裡**第一個** slide（通常是封面），整份掃描其實都在量封面 | `pagesMeasured` 必須等於總頁數 |
| `getBBox()` 比 viewBox | 不含祖先 `<g transform>`，任何被 translate 的圖元都誤報超界 | 改用上面的螢幕座標比對 |

**每次都要把 `distinct` 和 `pagesMeasured` 一起回報**，數字對不上就代表這次掃描沒有意義。
真實案例：修好第二個陷阱後，同一份簡報從「零問題」變成抓出 17 筆，其中一頁底部整塊內容被切掉。

這三個陷阱都只在 console 留痕（例如
`Set operation on key "clicks" failed: target is readonly`），
所以掃完**順手看一次 `browser_console_messages`**。

另外兩件關於 DOM 的事：

- 用 `opacity: 0` 藏起來的元素**仍然在 DOM 裡**。如果某頁「不該有」某個東西，
  除了看截圖，還要驗 `pg.innerText`；真的不該存在的就用 `v-if`，不要只調 opacity。
- 反過來，**`innerText` 不能拿來判斷 `v-click` 元素此刻可不可見**——還沒輪到的 v-click
  元素照樣在 DOM 裡、文字照樣抓得到。要確認「第幾個 click 才出現」，用截圖，
  不要用文字比對（試過用 computed style 探針，抓到的往往是祖先容器，也不準）。

然後**用截圖親眼看這些頁**（檢測抓不到「醜」和「語意錯」）：

- 每一張自訂 Vue／SVG 元件所在的頁 —— 這是最容易整個爆掉的地方
- 有多欄、表格、或元件並排的頁
- 動畫頁的**關鍵那一格**（不只看終態；中間那格才是重點所在）
- 第一頁和最後一頁

看的時候要問：字有沒有溢出容器、框有沒有對齊、留白是不是大到不自然、
箭頭指的方向對不對、顏色在這個底色上讀不讀得出來。

#### 5.3 已知地雷（都是實際踩過的）

| 症狀 | 原因與修法 |
|---|---|
| SVG 渲染成飽和模糊色塊，圖完全看不出是什麼 | SVG **attribute** 裡不能用 `fill="rgb(45 212 191 / 0.06)"` 這種 CSS Color 4 語法。陷阱在於 `getComputedStyle` 查出來是**正確的** `rgba(...)`，會讓你以為沒問題，但光柵化是錯的。**一律用 8 位 hex**（`fill="#2dd4bf0f"`），或 hex + 獨立的 `fill-opacity`。 |
| SVG 高度失控，把後面內容擠出畫面 | `style="max-height: 230px"` 對 SVG **不生效**（實測設 230 實際 311）。用外層 `<div :style="{height: N+'px'}">` 包住，SVG 給 `class="w-full h-full"`。 |
| 文字很淡、幾乎讀不出來 | Slidev default theme **預設是淺色底**。若配色用了 `text-*-300` + `bg-*-400/10` 這類深色底設計，要在 frontmatter 加 `colorSchema: dark`。動手前先截一張圖確認底色。 |
| SVG 內文字被切掉 | 文字超出 viewBox 右界。用 `text-anchor="end"` 靠右對齊，或縮短文字。 |
| SVG 文字大小不對 | 用 inline `style="font-size: 12px"`，不要用 `font-size` presentation attribute（會被 theme 蓋掉）。 |
| 某個 click 什麼也沒發生 | frontmatter 的 `clicks: N` 開多了，最後幾個是空轉。實際對照元件的 step 上限。 |

#### 5.4 收尾

```bash
pgrep -f 'slidev.mjs' | grep -v $$ | xargs -r kill
rm -rf .playwright-mcp   # 截圖產生的暫存目錄，不要留進 repo
git status --short        # 確認沒有多餘檔案
```

### 6. 回報

告訴使用者：

- 頁數與段落結構（用表格列出各段落佔幾頁）
- **主要的編排判斷**：哪些內容被獨立成頁、哪些被拆開、為什麼——這是使用者最需要 review 的部分
- **哪些是你推論補上的**，明確標示以便核對
- 驗證結果：頁數、編譯狀態、**視覺檢查的涵蓋範圍**
- **誠實說明你實際看了哪些頁、哪些只靠程式化檢測**。
  上百個 click 狀態不可能全看，但要講清楚界線在哪，
  不要讓「驗證過了」聽起來像「每一格都確認過了」。
- 若視覺檢查時修了東西，**列出修了什麼**——這是使用者最想知道的部分
- **確認最後一頁是「參考資料」，並列出你放了哪幾筆**（漏掉這頁是最常見的疏忽）
- 開啟指令：`just dev <deck-path>`

草稿檔（`draft.md`）保留不刪——Slidev 只吃 `slides.md`，草稿放著不影響任何事，
留著方便日後對照。順帶說明這點，使用者才知道可以自行決定去留。

## 反面示例

以下都是「搬字」而非「編排」，要避免：

- 草稿一行 → 簡報一個 bullet，順序照抄
- 所有內容擠在少數幾頁，沒有 section 分隔
- 只有清單沒有因果，讀者不知道為什麼這樣做
- 把內部代號直接丟出來卻沒問過觀眾是誰
- 推論的內容混在事實裡不加說明
- **沒有參考資料頁**，或那一頁還夾雜自己的導讀與評論
- **只驗證編譯就回報「做好了」**——build 過了畫面照樣可能整個爆掉，沒看過就不算做完
