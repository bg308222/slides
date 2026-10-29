2026 年 10 月月報 — andy.lin

本月概覽
    台大醫 — EDUCore: Passkey 在 iframe 中無法喚起 Bitwarden — 已實作（WebAuthn 改由 top frame 執行）
    遠東新 — EPSCore: clone 遠東 + 客製化人資 — 已完成（clone 流程整理成 skill）
    日月光 — EPSCore: Mac 無法 Kerberos SSO — 已提供 UI 取得票證方式，待廠商驗證

一、台大醫 — EDUCore: Passkey 在 iframe 中無法喚起 Bitwarden

    背景
        月中已經 demo 過在 eps 站台使用 passkey

    遇到的問題
        Bitwarden 攔截 WebAuthn、準備跳出 authenticator 時，會判斷目前所在的 frame 是否為 top
        eps 的主要頁面是在子 iframe 中，導致 Bitwarden 跳不出來

    決定
        會議上決定讓 WebAuthn 發生在 top

    實作方式
        top 自己在 window.passkeyRegistration 新增一組方法
        下層的 iframe 透過 window.top.passkeyRegistration 呼叫

    狀態：已實作

二、遠東新 — EPSCore: clone 遠東 + 客製化人資

    背景
        eps 本來就有遠東這個廠商，且已有各種客製化
        遠東新是一個全新的廠商，但要繼承目前遠東的所有功能

    2-1 clone 遠東
        做法：把 add / clone 一個廠商的方式整理成一個 skill
        理由：clone 廠商需要盤點各種客製點，並評估每個客製點要怎麼移植到新廠商，
              這不是複製設定就能完成的事，所以把流程整理下來
        狀態：skill 已完成，遠東新 clone 已完成

    2-2 客製化人資
        call API → 取得人員／部門資料 → map 進三表
        狀態：已完成

三、日月光 — EPSCore: Mac 無法 Kerberos SSO

    問題
        廠商說之前用 macOS 能正常透過 SSO 登入系統
            但我們無法確認他當時是進系統就直接 SSO 成功，還是有跳 401 帳密窗、輸入後才登入
        換新的 Mac 後，SSO 會把他導到 401 不支援頁面
            既沒有直接登入，也沒有要求輸入帳密，只能導回登入頁用 db 登入

    判斷
        這是預期的行為：ubuntu、mac 本來就不會跳 401 登入窗
        推測廠商先前能成功，是因為他在電腦上自己先取得了票證

    交付給廠商：Mac 取得票證的 UI 操作方式
        開啟 Ticket Viewer → Add Identity → 輸入網域帳號與密碼 → 重新進入系統
        只提供 UI 版，讓廠商好操作

    知識複習：Kerberos SSO 怎麼運作（給聽眾，未交付廠商；簡報中做成動畫）
        整體流程
            1. 取得 TGT：登入網域，取得 TGT
            2. 取得 Service Ticket：用 TGT 申請目標系統的 Service Ticket
            3. 完成 SSO：系統驗證 Service Ticket，取得使用者身分並登入
        從瀏覽器的角度
            已有 Service Ticket → 直接用票證完成驗證
            沒有 Service Ticket、但有 TGT → 向 KDC 申請 Service Ticket
            沒有 TGT → 要先取得 TGT；會不會出現登入提示，取決於瀏覽器與作業系統的設定
            取不到所需票證 → Kerberos SSO 失敗
            新 Mac 上沒有任何票證，就落在最後一種
        用 CLI 對照每一步（Ticket Viewer 背後做的事）
            klist                                   查看目前持有的票證（沒有時顯示 Cache not found）
            kinit andy.lin@dev.lan                  登入網域取得 TGT，klist 應看到 krbtgt/DEV.LAN@DEV.LAN
            kvno HTTP/eps.in.innovue.ltd@dev.lan    取得目標系統的 Service Ticket，klist 應看到對應票證
            重新進入系統，測試 Kerberos SSO
            kdestroy -a                             刪除所有票證

    狀態：已提供 UI 取得票證方式，待廠商驗證

    可以帶到的一點
        Kerberos SSO 中，系統只負責驗證 Service Ticket；票證要由用戶端電腦先取得

總結
    台大醫 EDUCore — Bitwarden 只在 top frame 喚起 authenticator，WebAuthn 改由 top 執行、iframe 透過 window.top 呼叫，已實作
    遠東新 EPSCore — 把 clone 廠商的流程整理成 skill 並完成遠東新 clone，客製化人資已完成
    日月光 EPSCore — 新 Mac 沒有票證所以 SSO 失敗，屬預期行為，已提供 Ticket Viewer 取得票證的 UI 操作方式，待廠商驗證

參考資料
    Kerberos SSO 實戰說明: ./Kerberos_SSO_實戰概念說明.md
