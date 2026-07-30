統一超商 - EPSNet: 匯入商標資料
    原始需求: 一份 excel 匯入預檢案 申請案 商標資料，含附件和分類資料 (都是必填欄位)
    交付工具:
        sql 主資料處理 (最單純)
        exe 搬附件
        exe 匯入分類
    第一輪驗收發現部分案件所指定的人員不存在，匯入失敗，所以整批 rollback 等對方確認
    第二輪驗收發現案件的從屬關係有誤，所以 rollback 等對方確認
    第三輪驗收列表有特殊顯示邏輯 商標有效起訖日同時有值才會顯示 但實際上只有起日是必填 所以回頭在 excel 多加一個欄位

STD - ECSTen: 人資三表 API
    原始需求: 暫時性讓 ECSTen 站台能透過 API 完成人資串接
    評估發現 ecscore 原三表進系統的邏輯很複雜短時間整理不出來，所以採取 API 進三表然後 call 原本的程序三表進系統
    共交付四個 API
        進三表部門表
        進三表人員表
        進三表人員部門表
        觸發原程序

Azure Devops plugin
    目標: 在不影響正常開發體驗的情況下，讓 ai 協助填寫 task 的時數和內容
    設計:
        5 個 skill:
            ado-query-classification
            ado-query-workitem
            ado-create-feature
            ado-create-pbi
            ado-create-task
        1 個 command:
            log-commits: 主動呼叫，掃描當前 branch 的所有 commit 規劃成 task 清單，call skill 實際在 ado 建立 task