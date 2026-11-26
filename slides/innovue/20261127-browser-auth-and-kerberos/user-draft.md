接續上週的 kerberos
應該在最終的 kerberos 開始
把細節封進黑箱子中
最終只要 user 能夠登入 ad 取得 tgt = 可以 sso 進系統

第一章 server 如何取得 tgt
這個問題分兩個層次:
server 怎麼從 ad 取得 tgt？ 和 server 怎麼從主機(klist)上面取得已有的 tgt？
這兩個不是在問廢話，而是雖然 user 持有 tgt 了也不代表 server 是取得到的

我們從一個連我們都想得到的，最直觀的方案開始: 以 server 為做認證的核心
user 輸入帳密 => server 拿帳密去 ad 換 user tgt => server 再拿 user tgt 去換 user st => server 解開 service ticket
這樣確實照著 kerberos 的流程認證完身份了，但至少產生了一下兩個問題
1. 帳密直接進到了 server
2. server 不容易將 tgt 存到 user 的電腦上 (klist) (這點是不容易還是做不到還是不該做待確認)，所以 sso 並沒有被滿足
3. 即使 user 的電腦上有 tgt, server 其實是沒有權限直接去電腦要 tgt 的 (這點我也不確定, 只是推論)

為了解決以上問題，其實這些事不需要由 server 來做，瀏覽器已經都幫我們做掉了，server 只需要吩咐瀏覽器即可

第二章 www-authenticate & authorization header: 這裡先以純 http header 的方式來介紹，直到 negotiate 的時候才轉到 spnego

簡單介紹一下這兩個 header 是什麼 怎麼搭配
實際用 www-authenticate: basic 說明瀏覽器會直接「幫你做事」
用 www-authenticate: bearer 說明有一些 scheme 是瀏覽器是不會做事的
最後用 www-authenticate: negotiate 說他是什麼 => spnego 今天的主角

第三章 spnego
實際上就是瀏覽器透過你的 os 環境決定你可以走哪一條認證機制，如何協商的方式去查 RFC 補足
    - kerberos
    - NTLM
但 spnego 只是選擇環境能用哪一個工具而已，實際上瀏覽器是會去 call 底層的 library 來完成流程，所以他才比較有權限取得 tgt

我們實際把 kerberos 這一條路走一遍
server response 401 negotiate
browser 開始協商決定出要使用 kerberos
klist 已有 st 時怎麼走
klist 沒 st 但有 tgt 時怎麼走
klist 兩個都沒有時怎麼走

整四章 spnego 的另一條路: NTLM
這邊我完全沒有研究了 由你來補充