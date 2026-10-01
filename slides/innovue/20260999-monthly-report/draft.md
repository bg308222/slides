2026 年 9 月月報 — andy.lin

本月概覽
    統一超商 — ETSNet: 證據批次核可功能 — 已完成（純前端實作，server 未改動）
    力山 — EPSNet: 資料庫無法連線排查 — 已解決（挖礦程式被防毒隔離導致 MSSQL 中止，客戶重裝 MSSQL）
    大同 — EPSNet + ECSNet: 更換系統 logo — 已完成（由 gif 改為 svg，並訂下系統圖一律 svg 的政策）
    特力 — EPSCore + ETSCore: 人資串接停止執行 — 已暫時恢復，長期方案待客戶回覆
    船舶 — EDUCore: 弱掃問題處理 — 已完成（兩項都在 lb 處理，未改主程式）
    本月多數項目的解法都落在主程式之外：前端 js、load balancer、OS 帳號設定、DB 主機環境；
    唯一動到程式的大同 logo，也是先確認了不會影響其他廠商才改。

一、統一超商 — ETSNet: 證據批次核可功能

    原始需求
        系統原本就有待簽核列表，能選一筆案件進到簽核頁，單筆進行簽核
        廠商希望在列表頁直接批次同意

    實現方式
        只寫一支 js，只在該列表頁生效
        畫出 checkbox 與「批次同意」button
        點擊後，對每個選取的 row 呼叫原本簽核頁選「同意」時的 API

    結果
        純前端完成，server 一行都不用改

    狀態：已完成

    可以帶到的一點
        批次只是把既有的單筆同意重複呼叫，簽核邏輯沿用原本的 API，沒有新增一條要另外驗證的路徑

二、力山 — EPSNet: 資料庫無法連線排查

    背景
        上個月也發生過一次無法連線，但那次是被勒索、mdf 被加密
        這次沒有被勒索，現象不同

    現象
        將 MSSQLSERVER 重新啟用後，可正常連線至 DB
        數秒後，防毒軟體（Athena EPP Agent）隔離了一個檔案
            Virus Name: CoinMiner.Win32.Agent.Vfxy
            Virus Type: Cryptomining
            File Path: c:\users\mssqlserver\appdata\local\temp\systemasap\<hash>\systemasap.dll
            Status: Quarantined
        隨後 MSSQLSERVER 被中止

    判斷
        經排查，該 dll 確實不是 MSSQL 原生的東西
        所以沒有貿然把它放進防毒白名單 —— 放行等於讓挖礦程式繼續跑

    處置
        客戶決定在本機重裝 MSSQL
        重裝後問題確實解決

    狀態：已解決

三、大同 — EPSNet + ECSNet: 更換系統 logo

    原本預期
        只是換一張圖，不用改程式

    遇到的問題
        ECS 的 logo 尺寸限制為 250×98，且使用 gif
        廠商提供的 logo 有圓形，無論怎麼試，都沒辦法在這個像素下讓圓形不出現鋸齒

    決定：改程式，讓原本 load gif 的地方改 load svg
        svg 可以直接用原圖，不用再轉檔
        為什麼可以直接改程式：dotnet 版未來的更新全都走獨立版，不會影響其他廠商

    同步訂下的政策
        所有系統圖統一改用 svg
        沒碰到的就不動；一旦碰到，就改成 svg
        美術之後也只交付 svg

    狀態：已完成

四、特力 — EPSCore + ETSCore: 人資串接停止執行

    檢查
        問題與 2025-04-08 那次相同
        觀察 log，2025-10-05 之後就沒有再執行
        原因：帳號密碼到期（Rocky Linux 預設 180 天到期）

    暫時處置
        更新密碼後即可正常執行

    提供給客戶的長期方案
        方案一：密碼設為永不到期
            180 天到期是 Rocky Linux 的預設值，我方並沒有這方面的安全性要求
            若客戶也沒有對應的安全政策，同意永不到期，即可採此方案
        方案二：我方定期更換密碼
            若客戶有相對應的安全要求，就只能定期更換
            到期時間不一定要 180 天，可以調整

    狀態：已暫時恢復，長期方案待客戶回覆

    可以帶到的一點
        同一個問題第二次發生，代表「到期 → 停擺 → 手動改密碼」會一直循環，
        要靠客戶在兩個方案中做決定才能真正結束

五、船舶 — EDUCore: 弱掃問題處理

    背景
        客戶端弱掃報告中的兩項，都在 lb（haproxy）完成，沒有改主程式

    5-1 Permissive HSTS Policy (98715)
        haproxy 原本就有設定 HSTS
            http-response set-header Strict-Transport-Security "max-age=31536000;"
        這次只是加上 includeSubDomains 選項
        狀態：已完成

    5-2 Host Header Injection (98623)
        掃描的攻擊方式
            發請求時帶上偽造的 X-Forwarded-Host，response 中竟然就會出現攻擊字串
        原因
            主程式設定為信任前一關 proxy 帶來的 header
                options.ForwardedHeaders = ForwardedHeaders.All;
                options.KnownNetworks.Clear();
                options.KnownProxies.Clear();
                app.UseForwardedHeaders();
            KnownNetworks / KnownProxies 被清空，代表不限定來源，任何人送來的 forwarded header 都會被採用
        決定：不改主程式，改由 lb 把關
            這段設定可能有歷史因素，不考慮拿掉
            既然主程式相信前一關 lb，lb 就應該把好關
        處理方式
            haproxy 一律覆寫三個 forwarded header，不採用 client 送來的值
                http-request set-header X-Forwarded-For %[src]
                http-request set-header X-Forwarded-Host %[req.hdr(host)]
                http-request set-header X-Forwarded-Proto http   （https template 對應設為 https）
            http、https 兩份 haproxy template 都已加上
        為什麼 X-Forwarded-Host 取自 Host 也安全
            haproxy 原本就有 Host 白名單，不在名單內的 Host 直接回 400
                acl valid_host hdr(host) -i ${validHost.join(" ")}
                http-request deny deny_status 400 unless valid_host
            所以能進到主程式的 Host 一定合法，由它填入的 X-Forwarded-Host 也一定合法
            兩段配起來才安全：白名單擋 Host，覆寫擋 X-Forwarded-Host
        狀態：已完成

    可以帶到的一點
        主程式選擇信任 proxy header，責任就落在 proxy：誰被信任，誰就要負責把關

總結
    統一超商 ETSNet — 以一支前端 js 呼叫既有同意 API 完成批次核可，server 未改動
    力山 EPSNet — 挖礦程式被防毒隔離導致 MSSQL 中止，未放行可疑 dll，客戶重裝 MSSQL 後解決
    大同 EPSNet + ECSNet — gif 無法呈現圓形 logo，改程式改用 svg，並訂下系統圖一律 svg 的政策
    特力 EPSCore + ETSCore — 密碼 180 天到期導致人資串接停擺，已更新密碼恢復，長期方案待客戶回覆
    船舶 EDUCore — 弱掃兩項皆在 haproxy 處理完成，未改主程式
