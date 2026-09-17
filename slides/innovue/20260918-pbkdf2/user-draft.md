0. 封面
PBKDF2 大標
用小標把五個字展開 首字用特別顏色標出來讓人知道是什麼的縮寫
演講者

1. Outline
為什麼會講 PBKDF2
傳統的 password hashing
PBKDF2 如何運作
實際程式分析

2. 為什麼會講 PBKDF2
    1. 先前在介紹 bitwarden 時，我把 password hashing 當作是一個先備知識，完全沒展開講，但 bitwarden whitepaper 中其實反覆出現 PBKDF2
    2. 近期在將 dotnet8 升級至 dotnet10 時，發現有一個 class Rfc2898DeriveBytes 的用法被標記為 obsolete，查一下發現欸他也是 PBKDF2
    基於以上兩點，就好奇了研究了一下
    (這邊完全不要拋出任何問題，純粹只是提到這兩次遇見)

3. 傳統的 password hashing
    1. 實際跑一次 (password) => hashed_password 存在 db 中 => db 被偷走 => attacker 開始試: 同密碼會同結果
    2. 實際跑一次 (password + salt) => hashed_password + salt 存在 db 中 => db 被偷走 => attacker 開始試: 同密碼不同結果
    3. 但 hash 成本太低，端一些數字讓人有感覺: 比如說一秒可後試幾次，6 碼數字在多久內會被試完 之類的，總之要讓人有感覺

4. PBKDF2 如何運作
    1. 把參數演化列下來 (password) => (password, salt) => (password, salt, iterations): 光從名字可能就有人猜得到他在做什麼了
    2. PBKDF2 的最簡理解模型，不用去說到什麼 xor, index，但是也不要傳達到錯誤的內容
    2.5 技術細節全部放在這，可以有 n 頁，但簡報時是被隱藏的，我自己會看或有人問到時會看
    3. 結論: 跑一次可能要數秒，暴力破解難度變很高

5. 實際程式分析
    1. 我們原本怎麼用 Rfc2898DeriveBytes，他又用 pbkdf2 做了什麼
    2. 為什麼會 obsolete？新寫法的哲學是什麼

6. 答疑 (一樣不顯示 我自己看或是被問到的時候才會看)
    1. password base 能理解但 key derivation 在這是什麼意思