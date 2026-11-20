# SAS 課程作業（Day 1–3）

- 學號：B1528003
- 日期：2026-11-20
- 執行環境：SAS OnDemand for Academics（SAS Studio，session encoding = UTF-8）
- 範圍：只做 Day 1–3（Day 4–7 講義只有預告、沒有題目，不寫）

> **數值標示說明**
> - 「待執行確認」：尚未在 SAS 上實際執行，請貼上程式後對照 LOG / Results 填入。
> - 「影子值」：引用 [`shadow/expected.md`](shadow/expected.md)，為 **Python 影子驗證，非 SAS 實際輸出**，僅供對照。

## 檔案

| 檔案 | 內容 |
|---|---|
| `day1_answers.sas` | Day 1：PROC CONTENTS / PROC PRINT |
| `day2_answers.sas` | Day 2：講義原始 MEANS / FREQ / UNIVARIATE + 任務 1、2 |
| `day3_answers.sas` | Day 3：DATA step 輸出 `WORK.CLEAN_CARS_HW` + 4 段驗證 |
| `shadow/verify.py` | Python 影子驗證腳本 |
| `shadow/data/sashelp_cars.csv` | 公開的 sashelp.cars CSV（來源見下） |
| `shadow/expected.md` | 影子驗證結果（非 SAS 實際輸出） |

### 影子驗證資料來源

- URL：<https://raw.githubusercontent.com/sassoftware/restaf/master/data/cars.csv>（SAS 官方 GitHub 組織 `sassoftware/restaf` 的 `data/cars.csv`，欄名與 sashelp.cars 相同）
- 本地檔：`shadow/data/sashelp_cars.csv`，SHA-256 `3c7f804b59ce72ff9dee3af8a61b3a6c2b44e53905f14770a762a6f49aaa56d5`
- 執行：`python -I sas_hw/shadow/verify.py sas_hw/shadow/data/sashelp_cars.csv sas_hw/shadow/expected.md`

---

## Day 1（SASHELP.CARS）

### 任務 1

**題目**：PROC CONTENTS DATA=sashelp.cars，查看總筆數與欄位型態。

```sas
PROC CONTENTS DATA=sashelp.cars;
RUN;
```

**預期輸出重點**

| 項目 | 預期 | SAS 實際 |
|---|---|---|
| Observations | 428（影子值同為 428） | 待執行確認 |
| Variables | 15 | 待執行確認 |
| Char（5） | Make, Model, Type, Origin, DriveTrain | 待執行確認 |
| Num（10） | MSRP, Invoice, EngineSize, Cylinders, Horsepower, MPG_City, MPG_Highway, Weight, Wheelbase, Length | 待執行確認 |
| 各欄 Len / Format | — | 待執行確認 |

[截圖: day1_task1.png]

### 任務 2

**題目**：PROC PRINT DATA=sashelp.cars (OBS=10)，加上 TITLE。

```sas
TITLE "Day 1 任務 2：SASHELP.CARS 前 10 筆資料";
PROC PRINT DATA=sashelp.cars (OBS=10);
RUN;
```

**預期輸出重點**：標題顯示在上方；表格 10 列、15 欄；LOG `There were 10 observations read`。前 10 筆內容：待執行確認。

[截圖: day1_task2.png]

### 任務 3

**題目**：在任務二的基礎上加 `VAR Make Model MSRP;`，只印這 3 欄。最後加 `TITLE;` 清除標題。

```sas
TITLE "Day 1 任務 3：SASHELP.CARS 前 10 筆（Make / Model / MSRP）";
PROC PRINT DATA=sashelp.cars (OBS=10);
    VAR Make Model MSRP;
RUN;
TITLE;
```

**預期輸出重點**：10 列，欄位只有 Obs / Make / Model / MSRP。實際車款與價格：待執行確認。

[截圖: day1_task3.png]

---

## Day 2（SASHELP.CARS）

### 講義原始程式（對照基準）

> 實作者手上沒有講義原文，以下三段依講義解讀數字推定；若與講義不同，以講義為準。

```sas
PROC MEANS DATA=sashelp.cars N MEAN MEDIAN STD MIN MAX;
    VAR MSRP;
RUN;

PROC FREQ DATA=sashelp.cars;
    TABLES Type;
RUN;

PROC UNIVARIATE DATA=sashelp.cars;
    VAR MSRP;
RUN;
```

**驗證檢查點（講義解讀數字）**

| 檢查點 | 講義數字 | 影子值（[expected.md §1](shadow/expected.md)） | SAS 實際 |
|---|---|---|---|
| MSRP 平均 | $32,775 | 32774.86 → PASS | 待執行確認 |
| MSRP 中位數 | $27,635 | 27635 → PASS | 待執行確認 |
| Hybrid 車數 | 3 輛 | 3 → PASS | 待執行確認 |
| MSRP 最高價 | $192,465 | 192465 → PASS | 待執行確認 |

[截圖: day2_baseline.png]

### 任務 1

**題目**：`PROC MEANS DATA=sashelp.cars N MEAN MEDIAN STD MIN MAX; CLASS Origin; VAR Horsepower;`，比較 Asia / Europe / USA 三個產地的平均馬力與中位數。

```sas
PROC MEANS DATA=sashelp.cars N MEAN MEDIAN STD MIN MAX;
    CLASS Origin;
    VAR Horsepower;
RUN;
```

**預期輸出重點**：3 列（Asia / Europe / USA），N 合計 428。

| Origin | 影子值 N / Mean / Median（[expected.md §2](shadow/expected.md)） | SAS 實際 |
|---|---|---|
| Asia | 158 / 190.70 / 187.5 | 待執行確認 |
| Europe | 123 / 251.89 / 225 | 待執行確認 |
| USA | 147 / 212.82 / 200 | 待執行確認 |

[截圖: day2_task1.png]

### 任務 2

**題目**：`PROC FREQ DATA=sashelp.cars; TABLES Origin * DriveTrain / MISSING;`，看 Row Pct 觀察各產地的驅動方式偏好。

```sas
PROC FREQ DATA=sashelp.cars;
    TABLES Origin * DriveTrain / MISSING;
RUN;
```

**預期輸出重點**：3×3 表，Total 428，無缺值類別。

| Origin | 影子值 Row Pct All / Front / Rear（[expected.md §3](shadow/expected.md)） | SAS 實際 |
|---|---|---|
| Asia | 21.52 / 62.66 / 15.82 | 待執行確認 |
| Europe | 29.27 / 30.08 / 40.65 | 待執行確認 |
| USA | 14.97 / 61.22 / 23.81 | 待執行確認 |

[截圖: day2_task2.png]

---

## Day 3（DATA Step → WORK.CLEAN_CARS_HW）

### 任務 1–3（同一個 DATA step）

**題目**：
- 任務一：`WHERE Origin = 'Asia' AND MSRP <= 50000;`（取代原本的 `MSRP <= 100000`），保留原本 Avg_MPG 與 Eco_Level 邏輯（`LENGTH Eco_Level $12`）。
- 任務二：`HP_Per_10k = Horsepower / (MSRP / 10000);`，前面加防呆 `IF MSRP > 0 THEN … ELSE HP_Per_10k = .;`
- 任務三：`LENGTH Power_Tier $12;` 寫在 IF 之前；`IF Horsepower >= 250 THEN Power_Tier = "高性能"; ELSE Power_Tier = "一般動力";`，Horsepower 缺值時設空白。
- KEEP 必須包含 HP_Per_10k 與 Power_Tier。

```sas
DATA work.clean_cars_hw;
    LENGTH Eco_Level  $12;
    LENGTH Power_Tier $12;
    SET sashelp.cars;
    WHERE Origin = 'Asia' AND MSRP <= 50000;

    Avg_MPG = (MPG_City + MPG_Highway) / 2;
    IF Avg_MPG >= 30 THEN Eco_Level = "高節能";      /* 門檻 30/20 為假設，需與講義核對 */
    ELSE IF Avg_MPG >= 20 THEN Eco_Level = "一般";
    ELSE Eco_Level = "高耗能";

    IF MSRP > 0 THEN HP_Per_10k = Horsepower / (MSRP / 10000);
    ELSE HP_Per_10k = .;

    IF MISSING(Horsepower) THEN Power_Tier = " ";
    ELSE IF Horsepower >= 250 THEN Power_Tier = "高性能";
    ELSE Power_Tier = "一般動力";

    KEEP Make Model Type Origin DriveTrain MSRP Horsepower
         MPG_City MPG_Highway Avg_MPG Eco_Level
         HP_Per_10k Power_Tier;
RUN;
```

**重點說明**
- UTF-8 下中文字 3 bytes：「一般動力」= 12 bytes，`$10` 會被截斷；`$12` 剛好放得下（影子值 [expected.md §4.5](shadow/expected.md)）。
- 不先宣告 LENGTH 時，Power_Tier 長度會由第一次指定的 "高性能"（9 bytes）決定，"一般動力" 會被截成 "一般動"。
- SAS 缺值小於任何數字，所以要先用 `MISSING(Horsepower)` 擋掉，否則缺值會落入「一般動力」。
- KEEP 漏掉 HP_Per_10k / Power_Tier → 新欄位被丟掉（本題最容易出錯）。
- ⚠ Eco_Level 門檻 30 / 20 是實作者假設（講義原始門檻未提供），請核對講義後修改。

**預期輸出重點**

| 項目 | 影子值（[expected.md §4](shadow/expected.md)） | SAS 實際 |
|---|---|---|
| WORK.CLEAN_CARS_HW 筆數 | 152 | 待執行確認 |
| 變數數 | 13（KEEP 清單） | 待執行確認 |

[截圖: day3_task1.png]
[截圖: day3_task2.png]
[截圖: day3_task3.png]

### 驗證程式

```sas
PROC CONTENTS DATA=work.clean_cars_hw;
RUN;

PROC FREQ DATA=work.clean_cars_hw;
    TABLES Origin Power_Tier Eco_Level / MISSING;
RUN;

PROC MEANS DATA=work.clean_cars_hw;
    VAR MSRP HP_Per_10k;
RUN;

PROC SORT DATA=work.clean_cars_hw OUT=work.clean_cars_hw_sorted;
    BY DESCENDING HP_Per_10k;
RUN;
PROC PRINT DATA=work.clean_cars_hw_sorted (OBS=10);
    VAR Make Model MSRP Horsepower HP_Per_10k Power_Tier;
RUN;
```

| 驗證 | 檢查重點 | 影子值（[expected.md](shadow/expected.md)） | SAS 實際 |
|---|---|---|---|
| 1. CONTENTS | HP_Per_10k Num 8；Power_Tier、Eco_Level Char 12 | — | 待執行確認 |
| 2. FREQ Origin | 只有 Asia | Asia 152 | 待執行確認 |
| 2. FREQ Power_Tier | 「一般動力」完整未截斷、無缺值 | 一般動力 133 / 高性能 19（§4.3） | 待執行確認 |
| 2. FREQ Eco_Level | 三類完整 | 一般 105 / 高節能 27 / 高耗能 20（§4.4，依假設門檻） | 待執行確認 |
| 3. MEANS MSRP | Max <= 50000 | N 152、Max 48450（§4.1） | 待執行確認 |
| 3. MEANS HP_Per_10k | — | Mean 82.7220、Max 120.3043（§4.1） | 待執行確認 |
| 4. 前 10 名第 1 名 | 降冪排序 | Suzuki Aeno S 4dr，120.3043（§4.2） | 待執行確認 |

[截圖: day3_verify1.png]
[截圖: day3_verify2.png]
[截圖: day3_verify3.png]
[截圖: day3_verify4.png]

---

## 執行後 LOG 檢查清單

| 檔案 | 檢查 1 | 檢查 2 | 檢查 3（觀測筆數 NOTE） |
|---|---|---|---|
| day1_answers.sas | 0 ERROR | 0 WARNING | 兩次 PROC PRINT 皆 `There were 10 observations read from the data set SASHELP.CARS.` |
| day2_answers.sas | 0 ERROR | 0 WARNING | MEANS / FREQ / UNIVARIATE / 任務 1、2 皆讀 428 筆（UNIVARIATE 不一定印此 NOTE） |
| day3_answers.sas | 0 ERROR | 0 WARNING（且無 `Missing values were generated`、`Division by zero`） | `WORK.CLEAN_CARS_HW has 152 observations and 13 variables.`（152 為影子值，待執行確認）；PROC PRINT 讀 10 筆 |
