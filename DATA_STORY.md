# Data Story — BigBasket Category Performance (Jan–Jun 2026)

All numbers below are drawn directly from Part 1's SQL diagnostic (`03_reporting.sql`,
Task 5c) and reconciled to the rupee in Part 2's spreadsheet and Part 3's Tableau
dashboard, using `monthly_category_revenue.csv` as the shared source of truth.

## Categories ahead of target (Above Target)

| Category | Delivered Revenue | Target | Ahead by | % Ahead |
|---|---:|---:|---:|---:|
| Household Essentials | ₹21,715 | ₹17,000 | ₹4,715 | +27.7% |
| Bakery | ₹15,410 | ₹12,000 | ₹3,410 | +28.4% |
| Personal Care | ₹16,382 | ₹15,500 | ₹882 | +5.7% |

Household Essentials and Bakery are both comfortably clear of target — roughly
28% ahead each — while Personal Care has cleared its target but by a much
thinner margin (+5.7%), making it the category most at risk of slipping back
below target if demand softens even slightly in the second half of the year.

## Categories behind target (Below Target)

| Category | Delivered Revenue | Target | Shortfall | % Shortfall | Tier |
|---|---:|---:|---:|---:|---|
| Dairy & Eggs | ₹14,090 | ₹16,500 | ₹2,410 | -14.6% | Below Target - Watch |
| Snacks & Beverages | ₹10,895 | ₹13,000 | ₹2,105 | -16.2% | Below Target - Critical |
| Fruits & Vegetables | ₹9,790 | ₹12,000 | ₹2,210 | -18.4% | Below Target - Critical |

Dairy & Eggs sits just inside the 15% watch threshold, so it is close to target
and worth monitoring rather than acting on urgently. Snacks & Beverages and
Fruits & Vegetables both breach the 15% critical threshold, with Fruits &
Vegetables missing target by the widest margin of any category (-18.4%).

## Recommendations for the category team

1. **Prioritize a Fruits & Vegetables catalog and promotion review.** It is the
   single worst-performing category against target (-18.4%) and also the
   lowest-revenue category outright. A targeted push — expanded SKU range,
   better placement, or a short-term promotion — is the highest-leverage single
   move available, since it is furthest from target and has the most room to
   recover.

2. **Review supplier terms and product mix for Snacks & Beverages.** It is the
   second category flagged "Below Target - Critical" (-16.2%) despite having the
   highest order *count* of any category in the raw Part 4 analysis, which
   suggests a volume-without-value problem — many low-ticket orders rather than
   too few orders. The category team should examine whether supplier pricing or
   basket-building incentives (e.g. bundling higher-margin snack items) can lift
   average order value without needing more traffic.

These recommendations are grounded only in the revenue-vs-target numbers above,
all of which are the same figures shown on the Tableau Public dashboard and the
Category Summary sheet of the spreadsheet workbook.
