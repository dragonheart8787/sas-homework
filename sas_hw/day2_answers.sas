/*****************************************************************
 * 作業標題：SAS 課程作業 Day 2 — 描述統計 (MEANS / FREQ / UNIVARIATE)
 * 日期    ：2026-11-20
 * 學號    ：B1528003
 * 環境    ：SAS OnDemand for Academics (SAS Studio, UTF-8)
 * 說明    ：本檔可一次全部貼上執行；預期結果寫在各題註解中。
 *           Python 影子驗證數字見 shadow/expected.md（非 SAS 實際輸出）。
 *****************************************************************/

/* ===== Day 2 講義原始程式（對照基準） ===== */
/* 說明：以下三段是講義的示範程式，作為任務的對照基準。
   注意：實作者手上沒有講義原文，以下依講義解讀數字
         （平均 $32,775、中位數 $27,635、Hybrid 3 輛、最高價 $192,465）推定，
         若與講義原文不同，請以講義為準替換。 */

/* (A) PROC MEANS：MSRP 的描述統計
   預期：N=428、Mean≈32774.86（約 $32,775）、Median=27635、Max=192465 */
PROC MEANS DATA=sashelp.cars N MEAN MEDIAN STD MIN MAX;
    VAR MSRP;
RUN;

/* (B) PROC FREQ：各車型 (Type) 次數
   預期：Type = Hybrid 的 Frequency = 3 */
PROC FREQ DATA=sashelp.cars;
    TABLES Type;
RUN;

/* (C) PROC UNIVARIATE：MSRP 分布
   預期：Basic Statistical Measures 的 Median = 27635；Highest 極值 = 192465
   注意：UNIVARIATE 的其他分位數（Q1、Q3…）預設 PCTLDEF=5，本作業不比對。 */
PROC UNIVARIATE DATA=sashelp.cars;
    VAR MSRP;
RUN;


/* ===== Day 2 任務 1 ===== */
/* 目的：依產地 (Origin) 分組，計算馬力 (Horsepower) 的 N / 平均 / 中位數 / 標準差 / 最小 / 最大。
   觀察重點：比較 Asia / Europe / USA 三個產地的「平均馬力」與「中位數」，
            並留意平均數與中位數的差距（差距大代表分布右偏、有高馬力車拉高平均）。
   預期：輸出 3 列（Asia、Europe、USA），N 合計 428。
         各產地實際數值：待執行確認（Python 影子值見 shadow/expected.md 第 2 節）。
   LOG 預期：NOTE: There were 428 observations read from the data set SASHELP.CARS. */
PROC MEANS DATA=sashelp.cars N MEAN MEDIAN STD MIN MAX;
    CLASS Origin;
    VAR Horsepower;
RUN;


/* ===== Day 2 任務 2 ===== */
/* 目的：產地 (Origin) × 驅動方式 (DriveTrain) 交叉表；/ MISSING 讓缺值也列為一個類別。
   觀察重點：看每格中的「Row Pct」（列百分比），比較各產地偏好哪種驅動方式
            （All 四驅 / Front 前驅 / Rear 後驅）。
   預期：3 × 3 表格，Total = 428；無缺值類別。
         各格次數與 Row Pct：待執行確認（Python 影子值見 shadow/expected.md 第 3 節）。
   LOG 預期：NOTE: There were 428 observations read from the data set SASHELP.CARS. */
PROC FREQ DATA=sashelp.cars;
    TABLES Origin * DriveTrain / MISSING;
RUN;
