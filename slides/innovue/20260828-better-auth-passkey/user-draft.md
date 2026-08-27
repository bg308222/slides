1. 今天的簡報路線:
    - 為了能理解第二段，最少量地知道 better auth 是甚麼
    - better auth passkey 怎麼與 app 串起來

第一段
2. better auth 是甚麼
    官方定義: Better Auth is a framework-agnostic authentication (and authorization) framework for TypeScript.
    實際上他本身不是 server, 只是一個 library, 分為 server lib 和 client lib

3. server lib 分為兩部份
db migration: 與程式無關，反正就是一個工具把 better auth 所需要的 schema 建好
instance: 只要 createBetterAuth({...}) 他就會建好 better auth instance, 但建出來也完全沒用

這裡要用動畫去把 db, instance 畫出來

4. auth server
最後官方有提供工具可以把 instance 掛到各個 web framework, 掛上去之後就會在你的 server 長出一組 endpoint

動畫上現在多了一個框去把 instance + db 框住，並且這個框本身叫 auth server(後面都會用這個名字稱他)

以上就能明白為什麼說他不是 server, 而不是一個 library

5.
server 已經 ready, 先前有提到 better auth 還有 client lib 他的用法就很單純: create 的時候給網址．然後就可以
client.adduser...: 動畫讓 db user 的 table 多一個人
client.login...: 動畫跑一下資料流登入成功
client.addpasskey...: 動畫讓 db 中 user 和 passkey 關聯起來
client.loginpasskey...: 動畫跑一下資料流登入成功
所以實際上 better auth 本身已經是一個完整的使用者管理系統

但問題是: 我們的 app 沒有要大費周章把使用者移到 better auth 中

6. 原本 auth server 占了整個畫面，讓他縮小鄉側出現一個一樣大的 app server 空間
app server 也有一個 db, db 裡面也有 user, 然後把原本在 auth server 中的 user 移到 app server 中，表示現在 「使用者」 其實是在 app server

7. 註冊
首先要求 user 一定要登入 app
app 自己會簽一個 jwt 在 cookies 裡
接著 user 要在 app 點註冊 passkey (實際上是呼叫 client.addpasskey)
passkey 會隨 cookies 一起被帶到 auth server
這時候 auth server 會同時做兩件事: 1. 解出 app_user_id 2. 建立 auth_user 並與 app_user 關聯

8. 登入
user 用 client.loginpasskey: 動畫跑一下 auth server 登入成功
但沒用，因為我們不是要 auth server 登入而是要 app server 登入
所以這時候再提到 auth server 作為一個 idp 提到 oidc
app server 登入時不是透過 client.loginpasskey, 而是透過標準 oidc 拿到 id_token 後自己在 app 登入一次

9. 最後用一個動畫來展示目前實際實作的是怎麼拆分
app server 只多了一組 oidc endpoint + handler，並在頁面上多兩個 button 導到 auth server 的 enroll + sign-in 頁，將 app 異動壓到最小
auth server client: 讓 app server 只要負責導頁，其他負責的 ui + 依賴全由 auth server 提供
auth server api: 前面提過
---

client.adduser... 這些請用去找官方正式的方法名，我只是 pseudo code