台大醫
    Passkey: 月中時已經 demo 過在 eps 站台使用 passkey, 但那時有一個問題: bitwarden 在攔截 webauth 準備跳 authenticator 時，會去判斷現在所在的 frame 要在 top，但 eps 的主要頁面是在子 iframe 中，導致 bitwarden 出不來，會議上已決定要讓 webauth 發生在 top，目前實作方式就是 top 自己在 window.passkeyRegistration 新增一組方法，讓下面的 iframe 透過 window.top.passkeyRegistration 去調用

遠東新
    clone 遠東: eps 本來就有遠東這個廠商，且已有各種客製化，遠東新是一個全新廠商，但要繼承目前遠東的所有功能，所以本次把 add / clone 一個廠商的方式整理成一個 skill，因為他需要去盤點各種客製點，評估要怎麼移植至新廠商
    客製化人資: call API => 取得人員 / 部門資料 => map 進三表

日月光
    Kerberos SSO:
        廠商說他之前用 MacOS 能正常透過 SSO 登入系統 (但我們不知道他到底是進系統就直接 sso 成功，還是有跳 401 帳密窗打完後才行)
        但他換新的 Mac 電腦後，SSO 會把他導到 401 不支援頁面，也就是既沒有直接登入，也沒有要打輸入帳密，只能導回登入頁 db 登入
        這是我們預期的沒錯，我們自己都知道 ubuntu, mac 本來就不會跳 401 登入窗
        所以我們推測先前廠商能成功應該是有在電腦上自己先取得票了
        我這次把整個故事整理好 參考 @slides/innovue/20261099-monthly-report/Kerberos_SSO_實戰概念說明.md 動畫化進簡報
        結論就是這設定方式給廠商