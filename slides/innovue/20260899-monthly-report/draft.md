2026 年 8 月月報 — andy.lin

本月概覽
    STD — EPSCore: 簽核 error 問題處理 — 已修正（從資料處理改為程式面根治）
    慧榮 — EPSNet: 滲透測試缺失修補 — 部分完成（三項缺失，一項完成、一項進行中、一項待客戶端驗證）
    力山 — EPSNet: 勒索軟體事件應變 — 已復原（DB 遭加密，靠客戶備份還原）
    本月主軸偏向「既有系統的體質與資安」，而非新功能開發。

一、STD — EPSCore: 簽核 error 問題處理

    問題本身
        老問題：flow db 中存有 XML 非法字元（例如 0x0b）
        SOAP response 序列化時直接 error，簽核流程中斷

    過去的處理方式
        每次發生就做一次資料處理，把 db 中的非法字元置換成空格
        屬於事後補救，問題會再發生

    這次的決定：改在程式面根治
        重新評估後決定修掉，不再只做資料清理
        理由：response 明知道下一關是 framework 的 XML，
              那就有義務在 return 前把 sanitize 做好
        責任歸屬的問題 — 誰產生輸出，誰負責讓輸出合法

    過程中的觀察：為什麼進來不會 error，出去才會
        SoapCore（專案內附的第三方 SOAP 中介層）讀、寫兩端用的不是同一個 XML 元件
        讀：走 WCF 的 XmlDictionaryReader，客戶端把 0x0B 寫成字元參照 &#xB; 送進來，它收得下去
        寫：走 XmlWriter，CheckCharacters 預設為 true，碰到 0x0B 直接 throw
        也就是同一個 &#xB;，reader 收得下去、writer 吐不出來
        而 CheckCharacters 並沒有開放設定 — SoapEncoderOptions 只給 MessageVersion / WriteEncoding / ReaderQuotas，
        encoder 也是 middleware 內部直接 new 出來的，沒有覆寫點，要關掉只能去改 SoapCore 原始碼
        何況就算關掉，也只是把不合法的 XML 推給客戶端的 parser，所以不採用

    結果
        已於 response 序列化前加上 sanitize，不再依賴事後資料處理

二、慧榮 — EPSNet: 滲透測試缺失修補

    背景
        客戶端滲透測試報告，本月處理其中三項缺失

    2-1 Session Fixation
        攻擊怎麼發生
            攻擊者先取得一個 session id，誘使受害者用這個 session id 進入登入頁
            受害者登入後，若 session id 沒有更換，攻擊者手上那組就變成已登入的 session
        理想解法
            進頁面時給一個 session
            登入完成當下立刻換發新 session
            登入資訊只寫進新 session，舊的作廢
        實際採用：OWASP 的 workaround
            （適用於 framework 不易更換 session 的情況）
            參考：https://owasp.org/www-community/controls/Session_Fixation_Protection
            1. 進頁面時給一個 session
            2. 登入資訊照樣寫進這個 session，但額外發一個 AntiFixationToken 到 cookies
            3. 之後每個請求都驗 AntiFixationToken，沒有就登出並導回登入頁
            4. 手動登出時刪掉 AntiFixationToken cookie
            關鍵：攻擊者能塞 session id，但塞不出登入後才發的 AntiFixationToken
        狀態：已完成

    2-2 使用有漏洞的元件
        缺失內容
            jquery 1.8.0、jquery 1.7.2、jquery-ui 1.7.2 被標記為有風險
        評估
            專案過舊，升級版本的成本與回歸風險不成比例，不考慮升級
            採用過去已決議的處理方式：直接改 jQuery 原始碼
        兩個部分
            1. 把版本相關資訊改成 customize，讓掃描工具不會憑版本號判定 — 已完成
            2. 把歷版中確實存在的風險逐一手動修正 — 待做
        必須講清楚的一句話
            第一部分只處理「被掃出來」，第二部分才是真的處理風險，兩者不能互相取代
        狀態：進行中

    2-3 LUCKY13（TLS CBC 系列造成的風險）
        處理方式
            至 Windows Server 設定機碼，移除 CBC 相關的 cipher suites
        遇到的問題
            移除後，server 主機自己用 Chrome、curl 都連不上 website
            原因不明 — 理論上 client 不會只支援 CBC suites
        我們家重現不出來
            我們家預設就走 TLS 1.3
            即使 curl 硬指定 TLS 1.2，也會正確選到 GCM 系列 suite
        目前處置
            與對方約一個雙方窗口都在的時間
            我們把 server 的 suites 移除後，請對方實際連線測試
            若對方連得上，就不再處理 server 自身連不上的問題
        狀態：待客戶端驗證

三、力山 — EPSNet: 勒索軟體事件應變

    事件發現
        排查時發現無法連線到 eps-db
        mdf 檔被改名為 LT_EPS_Rexon_Data.mdf.NBLock
        同目錄出現一個 README，內容要求付款
        判定為勒索軟體加密

    處置
        立即告知客戶
        客戶確認有備份
        還原 DB 後恢復正常
        同時提醒：附件檔案也需要一併還原，否則資料會對不起來

    狀態：已復原

    可以帶到的一點
        這次能快速恢復完全靠客戶端有備份
        備份的有效性（含附件等 DB 以外的資料）是這類事件唯一的保險

總結
    STD EPSCore — 把一個長年靠資料清理繞過的問題，改成在 response 端做 sanitize 根治
    慧榮 EPSNet — 滲透測試三項缺失，session fixation 完成、jQuery 風險修正進行中、LUCKY13 待客戶端驗證
    力山 EPSNet — 勒索軟體導致 DB 遭加密，靠備份還原完成復原
