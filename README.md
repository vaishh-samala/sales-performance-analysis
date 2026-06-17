# Sales Performance Analysis (SQL)

Business analysis of a multi-table sales database using PostgreSQL, uncovering revenue trends, top customers, product performance, customer churn risk, and shipping reliability.

## Dataset
The Northwind database — a sample relational dataset representing a trading company, with 14 linked tables including customers, orders, order details, products, categories, employees, and shippers. Loaded locally into PostgreSQL 16.

## Tools
PostgreSQL, SQL (joins, CTEs, window functions, conditional aggregation)

## Key Questions Answered

**1. Who are our most valuable customers?**
Identified the top 10 customers by total revenue using a 3-table join and discount-adjusted revenue calculation. Top customer (QUICK-Stop) generated ~$110K across 28 orders, with the top 3 customers clustered closely together before a clear drop-off to the rest of the list.

**2. Is revenue growing or shrinking month over month?**
Used the `LAG()` window function to calculate month-over-month percentage change without a self-join. Revenue showed a clear, sustained growth trend from mid-1997 through April 1998 (peaking at ~$123.8K), before an apparent sharp drop in the final month — which corresponds to the dataset ending mid-month rather than an actual business decline. (Noting this distinction matters: raw numbers can be misleading without checking data completeness.)

**3. Which products actually drive revenue?**
Used `RANK()` to rank products by revenue. Found that the top revenue product (Côte de Blaye, ~$141K) sold far fewer units (623) than the 3rd-ranked product (Raclette Courdavault, 1,496 units) — a reminder that top revenue and top volume products aren't always the same, with implications for pricing and inventory strategy.

**4. Which customers are at risk of churning?**
Built a recency analysis using CTEs and date math, identifying customers by days since their last order relative to the dataset's most recent date. The most at-risk customer (Centro comercial Moctezuma) hadn't ordered in 657 days — a candidate for a win-back campaign in a real business setting.

**5. How reliable is order fulfillment?**
Used `COUNT(*) FILTER (WHERE ...)` for conditional aggregation in a single pass over the orders table. Found a 4.57% late-shipment rate (37 late out of 809 shipped orders), indicating strong overall fulfillment reliability.

## Files
- `sql/analysis_queries.sql` — all 5 queries with comments

## Skills Demonstrated
Multi-table joins, Common Table Expressions (CTEs), window functions (`LAG`, `RANK`), conditional aggregation (`FILTER`), date/time calculations, business insight derivation from raw query output.