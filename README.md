# BigBasket Category Performance Diagnostic

One deterministic dataset, four reporting tools (SQL, spreadsheet, Tableau,
Python), one question: which BigBasket categories are clearing their monthly
revenue target, and which are falling behind? This repo builds the answer once
in SQL, then proves it survives untouched through a spreadsheet and a Tableau
dashboard, and separately proves it survives independent cleaning of the raw,
messy order export in Pandas.

## Project overview

* **Part 1 (SQL)** builds `bigbasket\_capstone.db` from a fixed, seeded generator
and exports `monthly\_category\_revenue.csv` — the single source of truth for
Parts 2 and 3.
* **Part 2 (Spreadsheet)** imports that exact CSV, rebuilds category totals via
a pivot-equivalent, and reconciles them against Part 1's SQL totals to the
rupee.
* **Part 3 (Tableau)** connects the same CSV and turns it into one public
dashboard plus a written data story.
* **Part 4 (Python/Pandas)** works from a separately generated, deliberately
messy raw order export (`orders\_raw.csv`), cleans it from scratch, and
cross-validates that its top category and top supplier match Part 1's SQL
findings.

## Repo structure

```
generate\_data.py                     Deterministic data generator (seed=42) — run first
bigbasket\_capstone.db                SQLite database (products, customers, orders, category\_targets)
orders\_raw.csv                       Messy raw order export — Part 4 input only
products.csv                         Product/supplier lookup — Part 4 input only
verify.sql                           Row-count + status-breakdown verification queries \& results
01\_foundations.sql                   Part 1, Task 3 — SELECT/WHERE, DISTINCT, ORDER BY+LIMIT, Alias, IN, BETWEEN, IS NULL
02\_aggregation\_joins.sql             Part 1, Task 4 — INNER JOIN+HAVING, LEFT JOIN+COUNT
03\_reporting.sql                     Part 1, Task 5 — CASE WHEN tiers, monthly report, variance vs. targets
monthly\_category\_revenue.csv         Fixed export of 03\_reporting.sql Task 5(b) — input to Parts 2 \& 3
bigbasket\_capstone\_analysis.xlsx     Part 2 spreadsheet workbook (Monthly Data / Category Targets / Pivot / Category Summary)
analysis.ipynb                       Part 4 Jupyter notebook — cleaning, IQR outliers, cross-validation, charts
charts/                              PNG exports of the notebook's matplotlib charts
ai\_log.md                            Two RCTCF-structured AI-assisted prompts + verification steps
DATA\_STORY.md                        Part 3 written data story and recommendations
README.md                            This file
```

## How to regenerate the database and raw exports

```bash
python3 generate\_data.py
```

This is deterministic (`random.seed(42)`) — do not edit the seed or the fixed
lists/weights inside the script, since every acceptance number in this project
depends on this exact output. It (re)creates `bigbasket\_capstone.db`,
`orders\_raw.csv`, and `products.csv`.

Verified output of `generate\_data.py`: **31 products, 50 customers, 500 orders,
6 category targets**; `orders.status` splits as Delivered 434 / Cancelled 42 /
Pending 24 (see `verify.sql`).

## Where to find each SQL task

|File|Contents|
|-|-|
|`verify.sql`|Table row counts + status breakdown (run first, confirms the generator worked)|
|`01\_foundations.sql`|WHERE, DISTINCT, ORDER BY+LIMIT, Alias, IN, BETWEEN/NOT BETWEEN, IS NULL|
|`02\_aggregation\_joins.sql`|INNER JOIN + GROUP BY + HAVING (category revenue); LEFT JOIN + COUNT (per-product order counts, including the zero-order product)|
|`03\_reporting.sql`|CASE WHEN product tiering; monthly category business report (exported to `monthly\_category\_revenue.csv`); variance/percentage\_variance vs. `category\_targets`|

All three files were executed against `bigbasket\_capstone.db` via Python's
`sqlite3` module; sample outputs are documented inline in the notebook/log
where relevant. SQLite's `strftime('%Y-%m', order\_date)` is used throughout in
place of BigQuery's `EXTRACT()`/`FORMAT\_DATE()` for month extraction.

**Confirmed SQL totals (Task 5c, Delivered revenue by category):**
Household Essentials 21,715 · Personal Care 16,382 · Bakery 15,410 ·
Dairy \& Eggs 14,090 · Snacks \& Beverages 10,895 · Fruits \& Vegetables 9,790.
Grand total across all 36 monthly-category rows: **88,282**.

## Spreadsheet workbook

`bigbasket\_capstone\_analysis.xlsx` — four sheets:

1. **Monthly Data** — unmodified import of `monthly\_category\_revenue.csv`.
2. **Category Targets** — the 6 fixed category/target pairs.
3. **Pivot (Category Totals)** — category-level `SUM(total\_revenue)` /
`SUM(order\_count)`, built with `SUMIFS` over Monthly Data. This is the
formula-based equivalent of a Rows=category Pivot Table; if you open the
file in Google Sheets you can additionally insert **Data > Pivot table**
pointed at Monthly Data for a fully interactive pivot object — its numbers
will match this sheet to the rupee.
4. **Category Summary** — pivot-referenced total revenue, a target lookup via
`INDEX`/`MATCH` with an `IFERROR("Not Found")` default (this sandbox's
LibreOffice-based recalculation engine cannot evaluate `XLOOKUP`, so
`INDEX`/`MATCH` is used as the functionally identical substitute — swap in
`XLOOKUP` directly if you're working in Google Sheets, which supports it
natively), variance/percentage\_variance formulas, a nested-IF three-tier
tag, conditional formatting on the tag column (green/amber/red), and a
**Matches Part 1 SQL total?** column that reads **Yes** for all 6
categories.

All formulas were recalculated with a formula engine and verified to produce
**zero formula errors** and rupee-exact agreement with Part 1's SQL totals.

## Tableau Public dashboard

&#x20;  \*\*Live dashboard:\*\* Not yet published — Tableau Public dashboard build is in progress. See `DATA\_STORY.md` for the full written analysis in the meantime, and `monthly\_category\_revenue.csv` for the underlying data any reviewer can chart themselves.
Data story
===

See [`DATA\_STORY.md`](./DATA_STORY.md) for the full write-up: which categories
are ahead of target and by how much, which are behind and by how much, and two
concrete recommendations for the category team.

## AI-assisted prompting log

See [`ai\_log.md`](./ai_log.md) for both RCTCF-structured prompts (one SQL, one
Pandas) and the concrete verification step performed on each.

## Part 4 notebook

See [`analysis.ipynb`](./analysis.ipynb) — loads `orders\_raw.csv` and
`products.csv`, cleans duplicates/casing/missing values/outliers, derives new
columns, groups and merges to find the top category and top supplier, and
explicitly cross-validates both against Part 1's SQL findings
(**Household Essentials** / **HomeEssentials Traders** — confirmed match).
Chart PNGs are also saved under `charts/` for quick viewing outside Jupyter.

## What you still need to do (outside this environment)

Everything above was built and verified in a sandboxed environment without a
browser, so three steps that require an interactive account are left for you:

1. **Google Sheets (optional polish):** upload `bigbasket\_capstone\_analysis.xlsx`
to Google Sheets if you want a live interactive Pivot Table object and/or to
swap the `INDEX`/`MATCH` lookup for `XLOOKUP` — both are supported there and
will reproduce the same numbers already in the workbook.
2. **Tableau Public:** connect Tableau Public (free) to
`monthly\_category\_revenue.csv`, build the time-series chart, the 3-tier
colored category bar chart, the 4 KPI cards, and the whole-dashboard filter
described in the project brief, combine them into one Dashboard, publish it,
and paste the live URL into this README where marked above.
3. **GitHub:** create a public repository and push every file in this folder
to it, then submit that repository link.

