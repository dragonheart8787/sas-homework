/*****************************************************************
 * 作業標題：SAS 課程作業 Day 1 — 認識資料集 (SASHELP.CARS)
 * 日期    ：2026-11-20
 * 學號    ：B1528003
 * 環境    ：SAS OnDemand for Academics (SAS Studio, UTF-8)
 * 說明    ：本檔可一次全部貼上執行；預期結果寫在各題註解中。
 *           標「待執行確認」者為尚未以 SAS 實際執行驗證的數值。
 *****************************************************************/

/* ===== Day 1 任務 1 ===== */
/* 目的：用 PROC CONTENTS 查看 sashelp.cars 的總筆數、變數數與欄位型態。
   預期（Results 的「Observations / Variables」與變數清單）：
     - Observations（總筆數）= 428
     - Variables（變數個數）  = 15
     - Char（字元型，5 個）：Make, Model, Type, Origin, DriveTrain
     - Num （數值型，10 個）：MSRP, Invoice, EngineSize, Cylinders, Horsepower,
                              MPG_City, MPG_Highway, Weight, Wheelbase, Length
     - 各欄位的 Len（長度）與 Format：待執行確認
   LOG 預期：無 ERROR / WARNING（PROC CONTENTS 不產生觀測筆數 NOTE）。 */
PROC CONTENTS DATA=sashelp.cars;
RUN;


/* ===== Day 1 任務 2 ===== */
/* 目的：用 PROC PRINT 只列出前 10 筆 (OBS=10)，並加上標題。
   預期：Results 上方顯示標題，表格共 10 列（Obs 1~10），全部 15 個欄位。
   LOG 預期：NOTE: There were 10 observations read from the data set SASHELP.CARS. */
TITLE "Day 1 任務 2：SASHELP.CARS 前 10 筆資料";
PROC PRINT DATA=sashelp.cars (OBS=10);
RUN;


/* ===== Day 1 任務 3 ===== */
/* 目的：在任務 2 的基礎上加 VAR 敘述，只印 Make、Model、MSRP 三欄。
   預期：表格 10 列，欄位只有 Obs、Make、Model、MSRP。
         前 10 筆的實際車款與價格：待執行確認。
   LOG 預期：NOTE: There were 10 observations read from the data set SASHELP.CARS. */
TITLE "Day 1 任務 3：SASHELP.CARS 前 10 筆（Make / Model / MSRP）";
PROC PRINT DATA=sashelp.cars (OBS=10);
    VAR Make Model MSRP;
RUN;

/* 清除標題，避免帶到下一段程式的輸出 */
TITLE;
