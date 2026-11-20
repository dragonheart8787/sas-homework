/*****************************************************************
 * 作業標題：SAS 課程作業 Day 3 — DATA Step 資料清理與新增欄位
 * 日期    ：2026-11-20
 * 學號    ：B1528003
 * 環境    ：SAS OnDemand for Academics (SAS Studio, session encoding = UTF-8)
 * 說明    ：輸出 WORK.CLEAN_CARS_HW，不覆蓋 sashelp。
 *           任務 1~3 合在同一個 DATA step；之後接 4 段驗證程式。
 *           標「SAS 實際輸出 (2026-11-20)」者為 2026-11-20 於 SAS OnDemand 實際執行的結果，
 *           與 shadow/expected.md 的 Python 影子驗證全部一致；所有 LOG：0 ERROR、0 WARNING。
 *****************************************************************/

/* ===== Day 3 任務 1 ~ 3（同一個 DATA step，依講義原文改寫） ===== */
DATA work.clean_cars_hw;

    /* --- 長度宣告：必須寫在任何 IF / 指定敘述之前 ---
       SAS 會用「第一次出現」決定字元變數長度。若不先宣告，
       Power_Tier 第一次被指定為 "高性能"（UTF-8 = 9 bytes）就會定為 $9，
       之後的 "一般動力" 會被截成 "一般動"。
       UTF-8 下一個中文字佔 3 bytes：
         高節能 = 9、一般 = 6、高耗能 = 9、高性能 = 9、一般動力 = 4×3 = 12 bytes
       所以寫 $10 也不夠（"一般動力" 會被截斷），必須 $12。 */
    LENGTH Eco_Level  $12;   /* 講義原本是 $10：Eco_Level 三個類別最長 9 bytes，$10 夠用；
                                改成 $12 是為了與 Power_Tier 統一長度，
                                之後若改成 4 個中文字的類別（12 bytes）也不會被截斷。 */
    LENGTH Power_Tier $12;   /* 任務 3：一般動力 = 12 bytes */

    SET sashelp.cars;

    /* --- 任務 1：只保留亞洲車且 MSRP <= 50000（取代原本的 MSRP <= 100000） --- */
    WHERE Origin = 'Asia' AND MSRP <= 50000;

    /* --- 講義原有邏輯：平均油耗與節能等級（門檻依講義：>=28 / >=20） ---
       必須用 MEAN() 函數，不可寫成 (MPG_City + MPG_Highway) / 2：
         MEAN() 會略過缺值，只要有一個非缺值就算得出平均；
         (a+b)/2 只要任一個是缺值，結果就是缺值，並在 LOG 產生
         "Missing values were generated" 的 NOTE。 */
    Avg_MPG = MEAN(MPG_City, MPG_Highway);

    /* 防呆：缺值小於任何數字，若不先擋，Avg_MPG 缺值會落入 "高耗能"，
       所以比照 Power_Tier，缺值時設為空白。 */
    IF MISSING(Avg_MPG) THEN Eco_Level = " ";
    ELSE IF Avg_MPG >= 28 THEN Eco_Level = "高節能";
    ELSE IF Avg_MPG >= 20 THEN Eco_Level = "一般";
    ELSE Eco_Level = "高耗能";

    /* --- 任務 2：每萬元可買到的馬力 ---
       防呆：MSRP 為 0、負數或缺值時不做除法，直接給缺值，避免 LOG 出現
             "Division by zero" 或 "Missing values were generated" 的 NOTE。 */
    IF MSRP > 0 THEN HP_Per_10k = Horsepower / (MSRP / 10000);
    ELSE HP_Per_10k = .;

    /* --- 任務 3：動力等級 ---
       SAS 中缺值小於任何數字，若直接寫 IF Horsepower >= 250 ... ELSE ...，
       缺值會掉進 ELSE 變成 "一般動力"，所以先判斷缺值並設為空白。 */
    IF MISSING(Horsepower) THEN Power_Tier = " ";
    ELSE IF Horsepower >= 250 THEN Power_Tier = "高性能";
    ELSE Power_Tier = "一般動力";

    /* --- KEEP：講義的 8 個變數 + 新欄位 HP_Per_10k、Power_Tier = 10 個 ---
       一定要加入 HP_Per_10k 與 Power_Tier，否則新欄位會被丟掉（本題最容易出錯的地方）。 */
    KEEP Make Model Type Origin MSRP Horsepower Avg_MPG Eco_Level
         HP_Per_10k Power_Tier;
RUN;
/* LOG 預期：
   NOTE: There were 152 observations read from the data set SASHELP.CARS.
         WHERE (Origin='Asia') and (MSRP<=50000);   （LOG 中 WHERE 的括號寫法可能略有不同）
   NOTE: The data set WORK.CLEAN_CARS_HW has 152 observations and 10 variables.
   SAS 實際輸出 (2026-11-20)：WORK.CLEAN_CARS_HW 152 筆、10 個變數（10 = KEEP 清單變數數）。 */


/* ===== Day 3 驗證 1：PROC CONTENTS ===== */
/* 目的：確認欄位存在且長度正確。
   預期：10 個變數；HP_Per_10k（Num 8）、Power_Tier（Char 12）、Eco_Level（Char 12）都存在。
   SAS 實際輸出 (2026-11-20)：10 個變數；Eco_Level 與 Power_Tier 長度皆為 12。 */
PROC CONTENTS DATA=work.clean_cars_hw;
RUN;


/* ===== Day 3 驗證 2：PROC FREQ ===== */
/* 目的：確認 Origin 只剩 Asia，且中文類別沒有被截斷（應看到完整的「一般動力」）。
   預期：Origin 只有 Asia 一類；Power_Tier 只有「一般動力」「高性能」兩類、無缺值；
         Eco_Level 為「高節能」「一般」「高耗能」。
         SAS 實際輸出 (2026-11-20)：Origin 只有 Asia；Power_Tier 一般動力 133 / 高性能 19（中文完整，未截斷）；
                                    Eco_Level 一般 86 / 高節能 46 / 高耗能 20。 */
PROC FREQ DATA=work.clean_cars_hw;
    TABLES Origin Power_Tier Eco_Level / MISSING;
RUN;


/* ===== Day 3 驗證 3：PROC MEANS ===== */
/* 目的：確認 MSRP 最大值 <= 50000，並看 HP_Per_10k 的分布。
   預期：MSRP 的 Max <= 50000；N 與 DATA step 輸出筆數相同。
         SAS 實際輸出 (2026-11-20)：MSRP 最高 48450（<= 50000）；HP_Per_10k 平均 82.72、最高 120.30。 */
PROC MEANS DATA=work.clean_cars_hw;
    VAR MSRP HP_Per_10k;
RUN;


/* ===== Day 3 驗證 4：HP_Per_10k 前 10 名 ===== */
/* 目的：先排序到另一個 WORK 表（不動 clean_cars_hw 本身），依 HP_Per_10k 降冪，再印前 10 筆。
   預期：10 列，HP_Per_10k 由大到小。
         SAS 實際輸出 (2026-11-20)：第 1 名 Suzuki Aeno S 4dr，HP_Per_10k = 120.30。
         （第 2~10 名：未逐項回報，請以截圖為準；Python 影子值見 shadow/expected.md 4.2）
   LOG 預期：PROC SORT -> NOTE: The data set WORK.CLEAN_CARS_HW_SORTED has 152 observations ...
             PROC PRINT -> NOTE: There were 10 observations read from the data set WORK.CLEAN_CARS_HW_SORTED. */
PROC SORT DATA=work.clean_cars_hw OUT=work.clean_cars_hw_sorted;
    BY DESCENDING HP_Per_10k;
RUN;

TITLE "Day 3 驗證 4：HP_Per_10k 最高的前 10 台亞洲車（MSRP <= 50000）";
PROC PRINT DATA=work.clean_cars_hw_sorted (OBS=10);
    VAR Make Model MSRP Horsepower HP_Per_10k Power_Tier;
RUN;
TITLE;
