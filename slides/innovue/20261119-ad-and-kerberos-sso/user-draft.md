# AD and Kerberos SSO

標題在描述 user 登入 windows 後可以自然登入系統的一件事
但實際上含蓋了三個概念 ad / kerberos / sso

##
我想在第一章先把三個概念直接拆開來定位好
剛好可以用之前的已經分享過的 oidc 來擴展知識

先舉一個具體的例子:
大家一定都有一個經驗
在一個其他 app 點擊 google 登入
就可以在 google 完成登入後登入 app
然後會發現 之後登入再次點擊 google 登入
你可能就不用再登入 google 而直接進到 app 了

這背後發生了什麼？(本次沒有要展開 直接把之前的 oidc 搬過來用)
app => authz server => login = (id_token) > app
為什麼第二次會直接登入？
因為 google 登入後，短時間內記住了登入狀態
所以第二次 oidc 流程「看似」直接登入，但其實還是完整跑完取得了 oidc
這其實就是 Single Sign-on 的概念: 只要登入一次 google, 之後就能透過這一個登入來直接登入其他 app 的登入

這時圖上面應該要能剛好畫出三個區塊
一是後面直接登入其他 app 的區塊是 sso
二是整個流程是 oidc
三是身份擁有者 google

而我們這次要說的三個概念其實就跟他們對應
sso 一樣是 sso
oidc 抽換成 kerberos
google 抽換成 ad

我會實際 demo 一下 kerberos sso, 實際上的體驗是與前面 google 的例子是一樣的
第一次登入時 browser 會跳 401 打一次帳密後進入系統(實際上登入的是 ad)
登出後再次進系統會直接登入(因為 ad 已登入)

那背後到底發生什麼？

##
接下來是第二章 kerberos

想像一下把 oidc callback 回 app 的那一段切掉, id 要怎麼傳回給 app?
你確實登入了 google
但是 app 沒有辦法取得已登入的證據 (這邊是重點 要讓大家感受到)

(換回 ad)
直觀的單票解:
那就在登入時發一個票給 user
然後 user 拿著票去找 app，這樣能證明票是 ad 發的嗎？
不能，app 沒理由相信一個來歷不明的票
所以就要利用到一個網路常用的技術 「簽名」
如果 app 一開始 ad 申請拿到了一個可以驗簽名的工具
那 ad 只要在 user 的票上簽名, 然後 app 就可以驗出確實是 ad 簽名完成登入
同時，如果 app2 也要驗簽名的工具，那 user 也可以直接拿這個票登入 app2 (sso 剛好被達成)

但如果想細微去控制這個票就是只能登入 app 而不能登入 app2 呢？
app 一開始向 ad 註冊, ad 給 app 一個 「app 專用的驗簽名工具」
user 登入時說我想使用 app, 所以 ad 就會簽一個 app 專用的名
這時候這個票就只有 app 可以驗了, app2 不承認 user 已登入 (需求達成)

如果 app 要能登入 app, app3, 但不能登入 app2 呢？
user 沒得選擇只能向 app 和 app3 各自登入一次取得他們的專用票 (sso 消失)
有沒有辦法既能隔離 app, 又能達到 sso?

雙票解:
user 登入 ad 拿到 「能換票的票 (ticket granting ticket)」 這個票不能登入任何 app
user 在 tgt 有效期間內隨時可以拿去向 ad 再換含 app 專用簽名的票，如果你有權限的話, ad 就會把票給你 (service ticket)
此時兩個需求都達到了:
tgt 換票時會再驗一次你有什麼權限 => 隔離 app
一個 tgt 換多個 app 的票 => sso

##
第三章 總圖
接下來只剩下收尾
把所有故事都用正確的詞來說
然後畫成對的流程動畫讓人明白即可

kerberos:
    kdc: 只是一個名字，下面有兩個主要元件, AD 實作並扮演了這整個部份
        as: user 登入, 發 tgt
        tgs: 透過 tgt, 發 st
    ss: 服務本身
        spn: 服務名稱 app app1 app2
        keytab: 向 ad 申請到的驗簽名工具

##
四章 AD & Kerberos SSO

至此大家應該都知道，只要想辦法拿到 tgt 就等於可以自動登入 app 了
第一章最後有 demo 過透過跳 401 登入後就開始 sso 了
實際上那邊帳密打上去就是送去 ad 拿 tgt
且 tgt 會被存在你的電腦上一陣子

但還有另一種連 401 都不用的方式:
當 windows 加入 domain 時
用 ad 登入 windows 的同時就會把 tgt 給取到電腦上了
等於達到登入 windows 即可直接登入 app 的效果



references
https://zh.wikipedia.org/zh-tw/Kerberos