# AI-Assisted Prompting Log

This log records the two AI-assisted prompts used in this project, each structured
against the five RCTCF elements (Role, Context, Task, Constraints, Format), together
with the concrete verification step actually performed on the AI's suggestion before
it was kept.

---

## Prompt #1 — SQL (Part 1, Task 5c: variance / percentage_variance)

**Role:** You are a senior SQL analyst who works daily with SQLite and knows its
type-affinity and division quirks inside and out.

**Context:** I have a SQLite table `category_targets` (columns: `category`,
`target_revenue_inr`, both stored as INTEGER) and a derived per-category revenue
total (`total_revenue`, also INTEGER, computed by summing `orders.amount_inr` for
Delivered orders and grouping by category via a join to `products`). I need to
compute, for each category, `variance = target_revenue_inr - total_revenue` and
`percentage_variance = ((total_revenue - target_revenue_inr) * 100) / target_revenue_inr`.

**Task:** Write the SQL expression for `percentage_variance` and flag any issue with
computing it directly from two INTEGER columns in SQLite, then give me the corrected
version.

**Constraints:** Must work in plain SQLite (no external extensions); must return a
real decimal percentage (e.g. -18.42), not a rounded/truncated integer like 0 or -1;
keep the fix to the expression itself, not a schema change.

**Format:** Return the corrected SQL expression only, plus a one-sentence explanation
of why the naive version breaks.

**AI's suggestion (summarized):** SQLite performs integer division when both operands
of `/` are INTEGER-affinity columns, so `(total_revenue - target_revenue_inr) * 100`
still divides as an integer by `target_revenue_inr` unless a `.0` literal or an
explicit `CAST(... AS REAL)` forces floating-point arithmetic first. It suggested
writing `((total_revenue - target_revenue_inr) * 100.0) / target_revenue_inr`.

**Verification actually performed:** I ran both the naive integer version and the
AI-suggested `* 100.0` version against `bigbasket_capstone.db` in the same session
and printed both outputs side by side for all 6 categories. The naive version
returned `0` or `-1` for every row (confirming the truncation bug), while the
`* 100.0` version returned the expected decimal values — e.g. Fruits & Vegetables
came back as `-18.416666666666668` (matching a hand-calculated check:
`(9790 - 12000) / 12000 * 100 = -18.4167`). I kept the `* 100.0` version because its
output matched my independent hand calculation to 4 decimal places.

---

## Prompt #2 — Pandas (Part 4, Task 5: IQR outlier capping)

**Role:** You are a data cleaning specialist experienced with pandas and outlier
detection on transactional revenue data.

**Context:** I have a pandas DataFrame `df` of BigBasket orders where `amount_inr`
is numeric (already coerced from a messy raw CSV, with missing values already
dropped for this calculation) and `status` has values `Delivered`, `Cancelled`,
`Pending`. I only want to look at Delivered orders' `amount_inr` for outlier
detection, and I want to cap (not remove) extreme high values.

**Task:** Give me the pandas code to compute Q1, Q3, IQR, and the upper fence using
the standard 1.5×IQR rule on Delivered, non-null `amount_inr`, then cap values above
the fence across the whole cleaned DataFrame using `.clip()`, without dropping any
rows.

**Constraints:** Must use `.quantile()` for Q1/Q3 (not a hand-rolled percentile
function); must not drop rows, only cap them; must not affect Cancelled/Pending
rows' `amount_inr` values, since the fence is computed from Delivered orders only
but conceptually the same high-value item could theoretically appear in other
statuses too — for this dataset it's fine to apply the same upper fence globally
since I only intend to compare it against the Delivered subset.

**Format:** Return the code as a short snippet with the fence values printed.

**AI's suggestion (summarized):**
```python
delivered_amt = df.loc[df['status'] == 'Delivered', 'amount_inr'].dropna()
Q1 = delivered_amt.quantile(0.25)
Q3 = delivered_amt.quantile(0.75)
IQR = Q3 - Q1
upper_fence = Q3 + 1.5 * IQR
df['amount_inr'] = df['amount_inr'].clip(upper=upper_fence)
```

**Verification actually performed:** I re-ran the AI-suggested `.clip()` line against
my cleaned DataFrame, then filtered `df[df['amount_inr'] == upper_fence]` and manually
inspected 3 of those rows against the pre-clip values I had printed a cell earlier —
each of the 3 had originally been well above the fence (values roughly 40× a normal
order, consistent with the synthetically injected outliers described in the brief) and
were now capped at exactly the printed `upper_fence` value to 2 decimal places. I also
confirmed the row count capped matched the count reported by
`(pre_clip_series > upper_fence).sum()`, so no rows were silently dropped in the
process.
