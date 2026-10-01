統一超商 - ETSNet
    使用證據批次核可功能
        系統原本就有待簽核列表可簽核，能選一筆案件進到簽核頁單筆進行簽核
        廠商想要在列表頁直接可以批次同意
        最後的實現方式是: 只寫一隻 js，只在該列表頁生效並且畫出 checkbox + 批次同意 button, 點擊後會將每個選取的 row 去 call 原本簽核頁選同意時的 api，就這樣在純前端完成, server 一行都不用改
力山 - EPSNet
    確認資料庫無法連線原因
        上個月發生過一次但上次是被勒索導致 mdf 壞掉
        這一次沒有被勒索而是有以下現象
        ```
        將 MSSQLSERVER 重新啟用後，已可正常連線至 DB
        數秒後，防毒軟體將某個檔案隔離 (Athena EPP Agent)
        Virus Name: CoinMiner.Win32.Agent.Vfxy
        Virus Type: Cryptomining
        File Path: c:\users\mssqlserver\appdata\local\temp\systemasap\1eb7f80d943dfb9d5229f04c6ae82866110bca75e3567262754c4ba015ac38ac\systemasap.dll
        Status: Quarantined
        MSSQLSERVER 就被中止了
        ```
        經排查那個 dll 確實不是 mssql 原生的東西，所以沒有冒然放進防毒白名單
        最後對方決定本機重裝 mssql, 最後也確實解決了

大同 - EPSNet + ECSNet
    更換系統 logo
        預期就是換一張圖而已，不用改程式，簡單完成
        因為 ECS 的 logo 只能是 250*98，但圖卻是使用 gif, 又因為廠商提供的 logo 是有圓型的，我們無論怎麼試都沒有辦法在這樣的像素中不讓圓型變鋸齒
        最後討論改程式，讓 load gif 的改 load svg 就可以直接用原圖不用轉了
            為什麼可以直接改程式？因為 dotnet 版未來更新全都是走獨立版了，所以不會影響到其他廠商
        也同步了一個未來政策: 所有系統圖統一改 svg，沒碰到的就不動，一旦碰到的就改 svg，美術也只會交付 svg

特力 - EPSCore + ETSCore
    人資串接不如預期: 描述如下
    ```
    檢查
        問題同 2025-04-08
        觀察 log 確實到 10-05 後就沒有再執行了
    解法
        更新密碼後即可正常執行
        改善方式有以下選項
        將密碼設成永不到期
        180 天到期是 rocky linux 的預設選項，我方並沒有這方面的安全性要求
        如果對方也沒有對應的安全政策，同意永不到期的話，可以採這個方案
        根據 特殊記錄 第 3 點的時間，我方定期改密碼
        同理，我方並沒有這方面的安全性要求，如果對方有相對應的安全要求那就只能定期改密碼
        過期時間不一定要 180 天，可以調整
        每次改都應要收費
    ```
    還沒得到回應

船舶 - EDUCore
    弱掃問題處理: 以下兩個都在 lb 完成，沒有改主程式
        Permissive HSTS Policy (98715): 調整 Server/Middleware 標頭設定，加上 includeSubDomains
        Host Header Injection (98623):
            廠商掃出來的攻擊方式是透過給 x-forwarded-host 發請求進系統，竟然就能讓 response 中含有攻擊字串
            原因是因為主程式有以下設定，會相信前一關的 proxy header
            ```
            builder.Services.Configure<ForwardedHeadersOptions>(options =>
                    {
                        options.ForwardedHeaders = ForwardedHeaders.All;
                        options.ForwardLimit = 5;
                        options.KnownNetworks.Clear();
                        options.KnownProxies.Clear();
                    });
            app.UseForwardedHeaders();
            ```
            可能有歷史因素，所以我不考慮把這段拿掉，但竟然主程式相信前一關 lb，那 lb 就應該要把好關
            最終讓 haproxy 把三個 forwarded header 的把關好
            ```
            # Forwarded headers
            http-request set-header X-Forwarded-For %[src]
            http-request set-header X-Forwarded-Host %[req.hdr(host)]
            http-request set-header X-Forwarded-Proto http
            ```
