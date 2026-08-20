先前講 pkce 的時候遇到了幾個問題
1. 有 server 的 app, PKCE 到底是 server 產還是 client 產 => 結果討論不出結果，實際上是用詞不對
2. PKCE 到底遇到了什麼困難而出現的？說防止 code 被 hacker 偷走的狀況確實不會被買單，那個 threat model 沒有明確被指出來
3. 有 client_secret 或 沒 client_secret 對 pkce 的影響
這些沒有要進簡報，只是本草稿的一個引言
---
第一段: oauth 概念確立
1. 有關 oauth，我們已經知道的事
把 oauth with client_secret & code exchange 跑一遍

user
browser => server => google
client

    同頁動畫方式呈現
    1. user redirect to google
    2. user login google
    3. google callback to server
    4. server bring code + client_secret to google
    5. google return token
    6. access API...

這流程本身其實，但用詞不精準會導致後續知識擴展時遇到障礙

2. 翻譯成正式 oauth 標準的名詞

初始畫面仍是前一張圖的三個角色
用動畫的方式把 server 變成 Client, google 變成 Authorization Server (後兩 part 先完成)
然後一樣透過動畫的方式把 user, browser, client 原本三個視為同義直接變成一個 Resource Owner (這是最大的變化，原本歧義都發生在這)
最後再把 browser 給長出來在 Resource Owner 下方
最終畫面上有 3(ro, client, as) + 1 個物件 (browser)

這邊要特別強調 現在中間位置的這個 client 是 Oauth 裡的定義: 指得是作為 Oauth 的 client 而不是應用的 client

3. 重新「定住」四者的關係
可以說: 整個 oauth 都是圍繞著 Client 和 AS 在玩的
Resource Owner 只有在一個很小的節點參與 完成 as 登入和授權，但主要都是 client 和 as 在調度的
而 browser 在這裡要意象成一個載具，他就是載著 ro 受 client, as 調度到處跑

實際用動畫跑一次 oauth 流程
    1. client 向 as 申請 id, secret 存到 client
    2. ro 發起登入
    3. client 叫 browser 載去 as (ro 是被載在 browser 上送過去的)
    4. ro 登入 as
    5. as 叫 browser 載回 client (車上多一個 code)
    6. 之後車都不會再動了，但 client 去 as 換 token
    7. client 拿 token 向 as 問 user 資料 (這整個簡報會不提到 Resource Server，是刻意降低負擔)

這邊要再次灌輸一個概念: ro 就只是我這個人 不代表 browser 或任何前端程式碼, 不論是 app client 或 app server 都屬於現在 client 的那一個位置，有 client_id, 做 code exchange 的那一個人就是 client
把這四個人的本質完理確立完，後續的擴展才不會一直發散

第二段: pkce threat model (code 到底怎麼被偷走的)

1. 維持前一張圖，我們要去框出整趟旅程中到底哪一段有危險，但有兩個前提
   (1) 我們假設瀏覽器沒被 xss: 頁面被完全操控的話，什麼東西幾乎都能被偷走了
   (2) 我們必須相信憑證有效時 https 絕對安全: 事實就是如此，所以不能去想什麼 request, response 中間被偷走

前提列完後就把圖還原，因為我們要重跑一次流程
    1. 申請是人工操作沒危險
    2. 發起登入是 https 沒危險
    3. redirect 到 as 是 https 沒危險
    4. ro 登入 as 是 https 沒危險
    5. callback 回來也是 https 沒危險
    6. client 換 token https 沒危險
    7. client 拿 token 問 user https 沒危險

奇怪了看起來整段都被 https 保護的好好的？

2. 最經驗的例子: 手機應用
就是說只要在 browser 上面目前都被 https 保護的好好的，但是那個洞其實是在第 5 步的 callback
如果他 callback 的不是網址而是 app 時
這時候就直接跳到另一個體系了
只要 app 被接走，code 就被偷走了
code 被偷走 = token 被偷走

第三段: confidential vs public client
我們必須知道這兩個的概念，才能更好的理解 client_secret

1. 兩者關鍵差異在於有沒有能力保護 secret
純前端應用沒能力
有 server 的 app 就有能力
應該挺直觀的

2. 現在聽眾應該就有能力分辨前一章的手機應用就是屬 public
那麼 confidential 又是怎樣？
用跟剛一樣的流程直到 code 被偷走，但因為 hacker 沒有 client_secret 所以 code 被偷走不等於 token 被偷走
所以雖然 client_secret 本質不是為了防 code 被偷走 (!!!!!還是其實是？他設計出來的目的是這個嗎？) 但確實防住了
然後 public client 沒有 client_secret, 所以必須使用 PKCE
搬出 rfc: 明確指出了 public client 必須 PKCE 而 confidential 不一定

3. 基於 public client 必須 PKCE 這條規則基本上可以推定 oauth 的 implicit 流程是廢棄的(這是我的推論)
因為 implicit 沒有 code exchange 就更不用說 pkce 了

4. ???? 這章我不確定，要由你幫我 survey 一下
rfc 對 confidential 的 pkce 的態度是有不有都沒差，還是最還好是要有？
如果是後者，那一定也有某一種 threat model 可以繞過 https?

第四段: pkce
這邊就比較簡單了由你設計
我想要讓 user 明白
1. pkce 全名和流程
2. 不論是 app client 或 app server 都屬於現在 client 的那一個位置，有 client_id, 做 code exchange 的那一個人就是 client (第一段第3章的結論)，所以
    - 有 server 的, challenge + verifier 就是在 server 產
    - 反之 client 產