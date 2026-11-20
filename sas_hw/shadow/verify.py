"""
SAS 作業 Python 影子驗證（Python shadow verification）
學號 B1528003

用途：在沒有 SAS 的環境下，用公開的 sashelp.cars CSV 重現 Day 2 / Day 3 的邏輯，
產生「預期值」供對照 SAS 實際輸出。這不是 SAS 實際輸出。

執行方式（在 repo 根目錄）：
    python -I sas_hw/shadow/verify.py sas_hw/shadow/data/sashelp_cars.csv sas_hw/shadow/expected.md

流程：
  1. 先比對講義檢查點（筆數、MSRP 平均/中位數/最大值、Hybrid 筆數）
     任何一項不符 -> 印 FAIL 與差異，exit 1，不執行第 2 步
  2. 檢查點全部通過 -> 重現 Day 2 / Day 3，寫出 expected.md
"""
import sys

import pandas as pd

SOURCE_URL = "https://raw.githubusercontent.com/sassoftware/restaf/master/data/cars.csv"
TAG = "（Python 影子驗證，非 SAS 實際輸出）"

# Day 3 Eco_Level 門檻：依講義原文，必須與 day3_answers.sas 內的門檻一致。
ECO_HIGH = 28   # Avg_MPG >= 28 -> 高節能
ECO_MID = 20    # Avg_MPG >= 20 -> 一般；其餘 -> 高耗能


def check_points(df):
    """回傳 [(項目, 預期, 實際, 是否通過)]"""
    msrp = df["MSRP"]
    mean = msrp.mean(skipna=True)
    rows = [
        ("筆數 = 428", 428, len(df), len(df) == 428),
        ("MSRP 平均 ≈ 32774.86", 32774.86, round(mean, 2), abs(mean - 32774.86) < 0.005),
        ("MSRP 平均四捨五入 = $32,775", 32775, int(round(mean)), int(round(mean)) == 32775),
        ("MSRP 中位數 = 27635", 27635, msrp.median(skipna=True), msrp.median(skipna=True) == 27635),
        ("MSRP 最大值 = 192465", 192465, msrp.max(skipna=True), msrp.max(skipna=True) == 192465),
        ("Type == 'Hybrid' 筆數 = 3", 3, int((df["Type"] == "Hybrid").sum()),
         int((df["Type"] == "Hybrid").sum()) == 3),
    ]
    return rows


def md_table(frame, index=True, floatfmt="{:.4f}"):
    """簡易 DataFrame -> Markdown 表格（不依賴 tabulate）"""
    f = frame.reset_index() if index else frame
    cols = [str(c) for c in f.columns]
    out = ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
    for _, r in f.iterrows():
        cells = []
        for v in r:
            if isinstance(v, float):
                if pd.isna(v):
                    cells.append(".")
                elif v.is_integer():
                    cells.append(str(int(v)))
                else:
                    cells.append(floatfmt.format(v))
            else:
                cells.append(str(v))
        out.append("| " + " | ".join(cells) + " |")
    return "\n".join(out)


def eco_level(avg):
    if pd.isna(avg):
        return ""
    if avg >= ECO_HIGH:
        return "高節能"
    if avg >= ECO_MID:
        return "一般"
    return "高耗能"


def power_tier(hp):
    # 與 SAS 一致：缺值 -> 空白，不可落入「一般動力」
    if pd.isna(hp):
        return ""
    return "高性能" if hp >= 250 else "一般動力"


def main(csv_path, out_path):
    df = pd.read_csv(csv_path)

    # ---------- 步驟 2：檢查點 ----------
    results = check_points(df)
    print(f"{'項目':<32}{'預期':>12}{'實際':>14}  結果")
    for name, exp, act, ok in results:
        print(f"{name:<32}{exp!s:>12}{act!s:>14}  {'PASS' if ok else 'FAIL'}")
    failed = [r for r in results if not r[3]]
    if failed:
        for name, exp, act, _ in failed:
            try:
                diff = float(act) - float(exp)
            except (TypeError, ValueError):
                diff = "n/a"
            print(f"FAIL: {name}  預期={exp}  實際={act}  差異={diff}")
        sys.exit(1)
    print("所有檢查點 PASS，繼續重現 Day 2 / Day 3。")

    # ---------- 步驟 3：Day 2 ----------
    hp = df.groupby("Origin")["Horsepower"]
    day2_means = pd.DataFrame({
        "N": hp.count(),                        # SAS N = 非缺值筆數
        "Mean": hp.mean(skipna=True),
        "Median": hp.median(skipna=True),
        "Std": hp.std(skipna=True, ddof=1),     # SAS 預設 VARDEF=DF
        "Min": hp.min(skipna=True),
        "Max": hp.max(skipna=True),
    })
    ct = pd.crosstab(df["Origin"], df["DriveTrain"], dropna=False)
    row_pct = pd.crosstab(df["Origin"], df["DriveTrain"], normalize="index", dropna=False) * 100

    # ---------- 步驟 3：Day 3 ----------
    sub = df[(df["Origin"] == "Asia") & (df["MSRP"] <= 50000)].copy()
    # 與 SAS MEAN() 對齊：略過缺值，只要一個非缺值就有平均
    sub["Avg_MPG"] = sub[["MPG_City", "MPG_Highway"]].mean(axis=1, skipna=True)
    sub["Eco_Level"] = sub["Avg_MPG"].map(eco_level)
    sub["HP_Per_10k"] = sub["Horsepower"] / (sub["MSRP"] / 10000)
    sub.loc[~(sub["MSRP"] > 0), "HP_Per_10k"] = float("nan")
    sub["Power_Tier"] = sub["Horsepower"].map(power_tier)

    # 對應 SAS KEEP：講義 8 個變數 + HP_Per_10k、Power_Tier
    keep = ["Make", "Model", "Type", "Origin", "MSRP", "Horsepower", "Avg_MPG", "Eco_Level",
            "HP_Per_10k", "Power_Tier"]
    sub = sub[keep]
    assert len(sub.columns) == 10, f"輸出欄位數 {len(sub.columns)} != 10"

    # SAS PROC SORT 預設 EQUALS（同值保留原順序）-> pandas 用 stable sort
    top10 = sub.sort_values("HP_Per_10k", ascending=False, kind="stable").head(10)
    top10_view = top10[["Make", "Model", "MSRP", "Horsepower", "HP_Per_10k", "Power_Tier"]]

    tier_cnt = sub["Power_Tier"].replace("", "(缺值)").value_counts().rename_axis("Power_Tier").to_frame("Frequency")
    eco_cnt = sub["Eco_Level"].replace("", "(缺值)").value_counts().rename_axis("Eco_Level").to_frame("Frequency")
    v_means = pd.DataFrame({
        v: {"N": sub[v].count(), "Mean": sub[v].mean(skipna=True), "Std": sub[v].std(skipna=True),
            "Min": sub[v].min(skipna=True), "Max": sub[v].max(skipna=True)}
        for v in ["MSRP", "HP_Per_10k"]
    }).T.rename_axis("Variable")

    # UTF-8 長度檢查
    labels = ["高節能", "一般", "高耗能", "高性能", "一般動力"]
    byte_len = {s: len(s.encode("utf-8")) for s in labels}
    for s, n in byte_len.items():
        assert n <= 12, f"{s} 佔 {n} bytes，超過 $12"
    assert sub["MSRP"].max() <= 50000
    assert set(sub["Origin"]) == {"Asia"}

    # ---------- 步驟 4：寫 expected.md ----------
    L = []
    L.append("# Python 影子驗證預期值 (expected.md)\n")
    L.append(f"> **本檔所有數字皆為「Python 影子驗證，非 SAS 實際輸出」。** 請以 SAS LOG / Results 為準，本檔只供對照。\n")
    L.append(f"- 資料來源：{SOURCE_URL}")
    L.append(f"- 產生方式：`python -I sas_hw/shadow/verify.py sas_hw/shadow/data/sashelp_cars.csv sas_hw/shadow/expected.md`")
    L.append(f"- pandas 版本：{pd.__version__}\n")

    L.append(f"## 1. 講義檢查點 {TAG}\n")
    L.append("| 項目 | 預期 | Python 實際 | 結果 |\n|---|---|---|---|")
    for name, exp, act, ok in results:
        L.append(f"| {name} | {exp} | {act} | {'PASS' if ok else 'FAIL'} |")
    L.append("")

    L.append(f"## 2. Day 2 任務一：各 Origin 的 Horsepower {TAG}\n")
    L.append(md_table(day2_means, floatfmt="{:.2f}"))
    L.append("")
    L.append(f"## 3. Day 2 任務二：Origin × DriveTrain 次數 {TAG}\n")
    L.append(md_table(ct))
    L.append("")
    L.append(f"### Row Pct（%）{TAG}\n")
    L.append(md_table(row_pct, floatfmt="{:.2f}"))
    L.append("")

    L.append(f"## 4. Day 3：WORK.CLEAN_CARS_HW {TAG}\n")
    L.append(f"- Origin == 'Asia' 且 MSRP <= 50000 的筆數：**{len(sub)}**{TAG}")
    L.append(f"- Origin 類別：{sorted(set(sub['Origin']))}{TAG}")
    L.append(f"- 輸出欄位數：**{len(sub.columns)}**（{', '.join(sub.columns)}）{TAG}\n")
    L.append(f"### 4.1 PROC MEANS VAR MSRP HP_Per_10k {TAG}\n")
    L.append(md_table(v_means, floatfmt="{:.4f}"))
    L.append("")
    L.append(f"### 4.2 HP_Per_10k 前 10 名 {TAG}\n")
    L.append(md_table(top10_view, index=False, floatfmt="{:.4f}"))
    L.append("")
    L.append(f"### 4.3 Power_Tier 次數 {TAG}\n")
    L.append(md_table(tier_cnt))
    L.append("")
    L.append(f"### 4.4 Eco_Level 次數 {TAG}\n")
    L.append(f"> 門檻依講義原文：Avg_MPG = MEAN(MPG_City, MPG_Highway)；>= {ECO_HIGH} 高節能、>= {ECO_MID} 一般、"
             "其餘高耗能；Avg_MPG 缺值 -> 空白。\n")
    L.append(md_table(eco_cnt))
    L.append("")
    L.append(f"### 4.5 UTF-8 字串長度 {TAG}\n")
    L.append("| 字串 | UTF-8 bytes | <= 12 ($12 不截斷) | <= 10 ($10 不截斷) |\n|---|---|---|---|")
    for s, n in byte_len.items():
        L.append(f"| {s} | {n} | {'是' if n <= 12 else '否'} | {'是' if n <= 10 else '否（會被截斷）'} |")
    L.append("")

    L.append("## 5. SAS 與 pandas 的差異（對照時注意）\n")
    L.append("1. **中位數**：SAS PROC MEANS 的 MEDIAN 與 pandas `median()` 定義相同（偶數筆取中間兩值平均），可直接比對。"
             "但 PROC UNIVARIATE 的分位數預設 `PCTLDEF=5`，與 pandas `quantile()` 預設的線性內插不同，"
             "**所以只比較中位數，不比較 Q1/Q3/P90 等其他分位數**。")
    L.append("2. **缺值**：SAS PROC MEANS 會自動排除缺值（N 只算非缺值）；本腳本一律用 `count()` 與 `skipna=True`，保持一致。"
             "sashelp.cars 中 Cylinders 有 2 筆缺值（Mazda RX-8），本作業用到的 MSRP / Horsepower / MPG 皆無缺值。Avg_MPG 用 `mean(axis=1, skipna=True)` 對齊 SAS 的 `MEAN()`（略過缺值），而非 `(a+b)/2`。")
    L.append("3. **PROC FREQ / MISSING**：SAS 加 `/ MISSING` 會把缺值當一個類別列出；pandas 用 `dropna=False` 對應。"
             "本資料 Origin / DriveTrain / Power_Tier 無缺值，所以有無 MISSING 結果相同。")
    L.append("4. **排序同值**：PROC SORT 預設 EQUALS（同值保留原順序），pandas 用 `kind='stable'` 對應。")
    L.append("5. **字元比較**：SAS 字元比較會忽略尾端空白；pandas 字串比較不會，但 CSV 內 Origin 無尾端空白，不影響。")
    L.append("6. **顯示格式**：SAS 預設輸出小數位數與 pandas 不同，比對時以數值四捨五入後相同為準。")
    L.append("")

    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    print(f"已寫出 {out_path}")
    print(f"Day3 筆數 = {len(sub)}；UTF-8 bytes = {byte_len}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("用法: python -I verify.py <cars.csv> <expected.md>")
        sys.exit(2)
    main(sys.argv[1], sys.argv[2])
