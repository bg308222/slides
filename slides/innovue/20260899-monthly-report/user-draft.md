STD EPSCore
    簽核 error 問題處理
        這是一個老問題，就是 flow db 中有 xml 非法字元，在 soap response 時序列化 error
        過去一直都是做資料處理，把 db 中 0x0b 這種非法字元改成空格
        這次就重新評估一下決定修掉，因為 response 明知道下一關是 framework 的 xml, 那就有義務在 return 前做好 sanitize
        不過有發現一個點是: request 進來不會 error, 但 response 出去會
慧榮 EPSNet: 滲透測試
    session fixation
        1. 先舉例攻擊怎麼發生
        2. 理想解法是進頁面時給一個 session，登入完馬上換一個 session, 登入資訊只寫進新 session
        3. owasp 也有提供一個如果 framework 不易做的時候的 workaround: https://owasp.org/www-community/controls/Session_Fixation_Protection
            進頁面時給一個 session
            登入資訊一樣被寫進這個 session，再多發一個新的 AntiFixationToken 進 cookies
            之後每個請求都要驗 AntiFixationToken, 沒有的話就導回登出導回登入頁
            手動登出時刪掉 AntiFixationToken cookie
    使用有漏洞的元件
        jquery 1.8.0, jquery 1.7.2, jquery-ui 1.7.2 被標為有危險
        但因為專案過舊，不考慮花成本去升級，故採過去已決議的處理方式: 直接改 jquery code, 分為兩部份
        1. 把版本有關資訊改成 customize, 讓掃描本身不會掃出來
        2. 把歷版中的風險手動修正 (待做)
    LUCKY13(tls CBC 系列造成的風險)
        至 windows server 設定機碼，把 cipher suites 移除 CBC 相關 suites
        刪掉後 server 主機自己用 chrome, curl 都連線不到 website (原因不明，理論上 client 不會完全只支援 cbc suites)
        我們家還原不出來，我們家預設就是走 tls1.3, 即使 curl 硬設 tls1.2 也會正確選到 gcm 系列 suite
        停在與對方約一個窗口人也在的時候，我們將 server 刪掉 suites 後請他們試試看能不能連線，能的話我們就也不處理 server 自己了
力山 EPSNet
    排查發現無法連線到 eps-db
    mdf 變成了 LT_EPS_Rexon_Data.mdf.NBLock
    同個目錄出現了一個 README 要求付款
    告知對方後，對方也確認是有備份的，把 db 還原回來後已經正常
    也有提醒附件也需要一起還原回來