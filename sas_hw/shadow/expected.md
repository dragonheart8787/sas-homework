# Python 影子驗證預期值 (expected.md)

> **本檔所有數字皆為「Python 影子驗證，非 SAS 實際輸出」。** 請以 SAS LOG / Results 為準，本檔只供對照。

- 資料來源：https://raw.githubusercontent.com/sassoftware/restaf/master/data/cars.csv
- 產生方式：`python -I sas_hw/shadow/verify.py sas_hw/shadow/data/sashelp_cars.csv sas_hw/shadow/expected.md`
- pandas 版本：3.0.5

## 1. 講義檢查點 （Python 影子驗證，非 SAS 實際輸出）

| 項目 | 預期 | Python 實際 | 結果 |
|---|---|---|---|
| 筆數 = 428 | 428 | 428 | PASS |
| MSRP 平均 ≈ 32774.86 | 32774.86 | 32774.86 | PASS |
| MSRP 平均四捨五入 = $32,775 | 32775 | 32775 | PASS |
| MSRP 中位數 = 27635 | 27635 | 27635.0 | PASS |
| MSRP 最大值 = 192465 | 192465 | 192465.0 | PASS |
| Type == 'Hybrid' 筆數 = 3 | 3 | 3 | PASS |

## 2. Day 2 任務一：各 Origin 的 Horsepower （Python 影子驗證，非 SAS 實際輸出）

| Origin | N | Mean | Median | Std | Min | Max |
|---|---|---|---|---|---|---|
| Asia | 158 | 190.70 | 187.50 | 59.39 | 73 | 340 |
| Europe | 123 | 251.89 | 225 | 80.74 | 100 | 493 |
| USA | 147 | 212.82 | 200 | 63.75 | 103 | 500 |

## 3. Day 2 任務二：Origin × DriveTrain 次數 （Python 影子驗證，非 SAS 實際輸出）

| Origin | All | Front | Rear |
|---|---|---|---|
| Asia | 34 | 99 | 25 |
| Europe | 36 | 37 | 50 |
| USA | 22 | 90 | 35 |

### Row Pct（%）（Python 影子驗證，非 SAS 實際輸出）

| Origin | All | Front | Rear |
|---|---|---|---|
| Asia | 21.52 | 62.66 | 15.82 |
| Europe | 29.27 | 30.08 | 40.65 |
| USA | 14.97 | 61.22 | 23.81 |

## 4. Day 3：WORK.CLEAN_CARS_HW （Python 影子驗證，非 SAS 實際輸出）

- Origin == 'Asia' 且 MSRP <= 50000 的筆數：**152**（Python 影子驗證，非 SAS 實際輸出）
- Origin 類別：['Asia']（Python 影子驗證，非 SAS 實際輸出）

### 4.1 PROC MEANS VAR MSRP HP_Per_10k （Python 影子驗證，非 SAS 實際輸出）

| Variable | N | Mean | Std | Min | Max |
|---|---|---|---|---|---|
| MSRP | 152 | 23212.5263 | 8063.9218 | 10280 | 48450 |
| HP_Per_10k | 152 | 82.7220 | 14.0611 | 38.1999 | 120.3043 |

### 4.2 HP_Per_10k 前 10 名 （Python 影子驗證，非 SAS 實際輸出）

| Make | Model | MSRP | Horsepower | HP_Per_10k | Power_Tier |
|---|---|---|---|---|---|
| Suzuki | Aeno S 4dr | 12884 | 155 | 120.3043 | 一般動力 |
| Toyota | Tundra Regular Cab V6 | 16495 | 190 | 115.1864 | 一般動力 |
| Nissan | Titan King Cab XE | 26650 | 305 | 114.4465 | 高性能 |
| Toyota | Tacoma | 12800 | 142 | 110.9375 | 一般動力 |
| Suzuki | Aerio LX 4dr | 14500 | 155 | 106.8966 | 一般動力 |
| Nissan | 350Z coupe 2dr | 26910 | 287 | 106.6518 | 高性能 |
| Nissan | Altima SE 4dr | 23290 | 245 | 105.1954 | 一般動力 |
| Toyota | Camry Solara SE V6 2dr | 21965 | 225 | 102.4357 | 一般動力 |
| Kia | Rio 4dr manual | 10280 | 104 | 101.1673 | 一般動力 |
| Honda | Accord LX V6 4dr | 23760 | 240 | 101.0101 | 一般動力 |

### 4.3 Power_Tier 次數 （Python 影子驗證，非 SAS 實際輸出）

| Power_Tier | Frequency |
|---|---|
| 一般動力 | 133 |
| 高性能 | 19 |

### 4.4 Eco_Level 次數 （Python 影子驗證，非 SAS 實際輸出）

> 門檻為假設值：Avg_MPG >= 30 高節能、>= 20 一般、其餘高耗能（講義原始門檻未提供，需與講義核對；若門檻不同，此表無效）。

| Eco_Level | Frequency |
|---|---|
| 一般 | 105 |
| 高節能 | 27 |
| 高耗能 | 20 |

### 4.5 UTF-8 字串長度 （Python 影子驗證，非 SAS 實際輸出）

| 字串 | UTF-8 bytes | <= 12 ($12 不截斷) | <= 10 ($10 不截斷) |
|---|---|---|---|
| 高節能 | 9 | 是 | 是 |
| 一般 | 6 | 是 | 是 |
| 高耗能 | 9 | 是 | 是 |
| 高性能 | 9 | 是 | 是 |
| 一般動力 | 12 | 是 | 否（會被截斷） |

## 5. SAS 與 pandas 的差異（對照時注意）

1. **中位數**：SAS PROC MEANS 的 MEDIAN 與 pandas `median()` 定義相同（偶數筆取中間兩值平均），可直接比對。但 PROC UNIVARIATE 的分位數預設 `PCTLDEF=5`，與 pandas `quantile()` 預設的線性內插不同，**所以只比較中位數，不比較 Q1/Q3/P90 等其他分位數**。
2. **缺值**：SAS PROC MEANS 會自動排除缺值（N 只算非缺值）；本腳本一律用 `count()` 與 `skipna=True`，保持一致。sashelp.cars 中 Cylinders 有 2 筆缺值（Mazda RX-8），本作業用到的 MSRP / Horsepower / MPG 皆無缺值。
3. **PROC FREQ / MISSING**：SAS 加 `/ MISSING` 會把缺值當一個類別列出；pandas 用 `dropna=False` 對應。本資料 Origin / DriveTrain / Power_Tier 無缺值，所以有無 MISSING 結果相同。
4. **排序同值**：PROC SORT 預設 EQUALS（同值保留原順序），pandas 用 `kind='stable'` 對應。
5. **字元比較**：SAS 字元比較會忽略尾端空白；pandas 字串比較不會，但 CSV 內 Origin 無尾端空白，不影響。
6. **顯示格式**：SAS 預設輸出小數位數與 pandas 不同，比對時以數值四捨五入後相同為準。
