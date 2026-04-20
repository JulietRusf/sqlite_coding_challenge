-- SQLite Analytics Coding Challenge
-- Tool used: SQLite 3 (queries written for SQLite syntax).
-- Validation: Queries were reviewed for join logic, aggregation levels, ordering, and SQLite compatibility.
-- Note: I could not access the provided bais_sqlite_lab.db file in this chat environment,
-- so these queries are written to run directly against that database once opened in SQLite.

-- TASK 1: Top 5 Customers by Total Spend
-- Lifetime spend is calculated from line totals (quantity * unit_price), rolled up to the customer level.
SELECT
    c.first_name || ' ' || c.last_name AS customer_full_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spend
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.id
JOIN order_items AS oi
    ON oi.order_id = o.id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY total_spend DESC, customer_full_name ASC
LIMIT 5;


-- TASK 2: Total Revenue by Product Category
-- Revenue is summed from item-level line totals across all orders.
SELECT
    p.category AS category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON oi.product_id = p.id
JOIN orders AS o
    ON o.id = oi.order_id
GROUP BY p.category
ORDER BY revenue DESC, category ASC;


-- TASK 2 (OPTIONAL VARIANT): Revenue by Product Category for Delivered Orders Only
-- This version restricts revenue to delivered orders only.
SELECT
    p.category AS category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_revenue
FROM products AS p
JOIN order_items AS oi
    ON oi.product_id = p.id
JOIN orders AS o
    ON o.id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY delivered_revenue DESC, category ASC;


-- TASK 3: Employees Earning Above Their Department Average
-- A CTE calculates each department's average salary, then employees are compared to that average.
WITH department_salary_avg AS (
    SELECT
        e.department_id,
        AVG(e.salary) AS department_avg_salary
    FROM employees AS e
    GROUP BY e.department_id
)
SELECT
    e.first_name,
    e.last_name,
    d.name AS department_name,
    ROUND(e.salary, 2) AS employee_salary,
    ROUND(dsa.department_avg_salary, 2) AS department_average_salary
FROM employees AS e
JOIN departments AS d
    ON d.id = e.department_id
JOIN department_salary_avg AS dsa
    ON dsa.department_id = e.department_id
WHERE e.salary > dsa.department_avg_salary
ORDER BY department_name ASC, employee_salary DESC, e.last_name ASC, e.first_name ASC;


-- TASK 4: Cities with the Most Loyal Customers
-- Counts only customers whose loyalty_level is Gold.
SELECT
    c.city,
    COUNT(*) AS gold_customer_count
FROM customers AS c
WHERE c.loyalty_level = 'Gold'
GROUP BY c.city
ORDER BY gold_customer_count DESC, c.city ASC;


-- TASK 4 (RECOMMENDED EXTENSION): Loyalty Distribution by City
-- This helps identify geographic patterns across loyalty tiers.
SELECT
    c.city,
    SUM(CASE WHEN c.loyalty_level = 'Gold' THEN 1 ELSE 0 END) AS gold_count,
    SUM(CASE WHEN c.loyalty_level = 'Silver' THEN 1 ELSE 0 END) AS silver_count,
    SUM(CASE WHEN c.loyalty_level = 'Bronze' THEN 1 ELSE 0 END) AS bronze_count,
    COUNT(*) AS total_customers
FROM customers AS c
GROUP BY c.city
ORDER BY gold_count DESC, total_customers DESC, c.city ASC;
