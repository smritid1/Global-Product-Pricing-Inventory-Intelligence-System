USE etl;

-- List tables in this database.
SHOW TABLES;

-- Inspect exact columns and data types.
DESCRIBE priceproductt;

-- Alternative schema inspection.
SHOW COLUMNS FROM priceproductt;

-- Inspect the table creation definition and indexes.
SHOW CREATE TABLE priceproductt;

-- Count rows.
SELECT COUNT(*) AS row_count
FROM priceproductt;

-- Preview a few rows.
SELECT *
FROM priceproductt
LIMIT 10;

-- Check for duplicate product IDs.
SELECT product_id, COUNT(*) AS occurrences
FROM priceproductt
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check rows missing a product ID.
SELECT *
FROM priceproductt
WHERE product_id IS NULL OR TRIM(product_id) = '';


-- Select only the columns needed for a product catalogue.
SELECT product_id, product_name, category, brand, base_price_npr
FROM priceproductt;

-- Products costing more than NPR 200.
SELECT product_name, category, base_price_npr
FROM priceproductt
WHERE base_price_npr > 200
ORDER BY base_price_npr DESC;

-- Products within a price range.
SELECT product_name, base_price_npr
FROM priceproductt
WHERE base_price_npr BETWEEN 100 AND 250
ORDER BY base_price_npr;

-- Products from selected categories.
SELECT product_id, product_name, category
FROM priceproductt
WHERE category IN ('Dairy', 'Produce', 'Bakery')
ORDER BY category, product_name;

-- Find names containing a word.
SELECT product_id, product_name
FROM priceproductt
WHERE product_name LIKE '%Bread%';

-- Products with a long shelf life.
SELECT product_name, shelf_life_days
FROM priceproductt
WHERE shelf_life_days >= 180
ORDER BY shelf_life_days DESC;

-- Most expensive products.
SELECT product_name, category, base_price_npr
FROM priceproductt
ORDER BY base_price_npr DESC
LIMIT 10;

-- Cheapest products.
SELECT product_name, base_price_npr
FROM priceproductt
ORDER BY base_price_npr ASC
LIMIT 10;

-- Return unique categories and brands.
SELECT DISTINCT category
FROM priceproductt
ORDER BY category;

SELECT DISTINCT brand
FROM priceproductt
ORDER BY brand;

-- Give output columns readable aliases.
SELECT
    product_name AS product,
    base_price_npr AS price_in_npr,
    unit_cost_npr AS cost_in_npr
FROM priceproductt
LIMIT 20;

-- Overall summary statistics.
SELECT
    COUNT(*) AS total_products,
    MIN(base_price_npr) AS minimum_price_npr,
    MAX(base_price_npr) AS maximum_price_npr,
    ROUND(AVG(base_price_npr), 2) AS average_price_npr,
    ROUND(AVG(unit_cost_npr), 2) AS average_cost_npr
FROM priceproductt;

-- Average and maximum price by category.
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(base_price_npr), 2) AS avg_price_npr,
    MAX(base_price_npr) AS max_price_npr
FROM priceproductt
GROUP BY category
ORDER BY avg_price_npr DESC;

-- Average price by brand.
SELECT brand, COUNT(*) AS product_count,
       ROUND(AVG(base_price_npr), 2) AS avg_price_npr
FROM priceproductt
GROUP BY brand
ORDER BY avg_price_npr DESC;

-- Categories with at least five products.
SELECT category, COUNT(*) AS product_count
FROM priceproductt
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY product_count DESC;

-- Compare price and cost totals.
SELECT
    SUM(base_price_npr) AS sum_of_list_prices_npr,
    SUM(unit_cost_npr) AS sum_of_unit_costs_npr
FROM priceproductt;

-- Count null values in important fields.
SELECT
    SUM(product_id IS NULL) AS null_product_id,
    SUM(product_name IS NULL) AS null_product_name,
    SUM(category IS NULL) AS null_category,
    SUM(base_price_npr IS NULL) AS null_base_price,
    SUM(unit_cost_npr IS NULL) AS null_unit_cost,
    SUM(ExchangeRate_EUR IS NULL) AS null_eur_rate,
    SUM(ExchangeRate_CAD IS NULL) AS null_cad_rate,
    SUM(data_pulled_date IS NULL) AS null_pull_timestamp
FROM priceproductt;

-- Label products by price band.
SELECT
    product_name,
    base_price_npr,
    CASE
        WHEN base_price_npr IS NULL THEN 'Unknown'
        WHEN base_price_npr < 100 THEN 'Low'
        WHEN base_price_npr < 250 THEN 'Medium'
        ELSE 'High'
    END AS price_band
FROM priceproductt
ORDER BY base_price_npr;

-- Flag invalid / suspicious values.
SELECT *
FROM priceproductt
WHERE base_price_npr < 0
   OR unit_cost_npr < 0
   OR shelf_life_days < 0
   OR supplier_lead_time_days < 0
   OR reorder_point < 0
   OR reorder_qty < 0
   OR base_daily_demand_units < 0;

-- Find products whose unit cost is greater than the base price.
SELECT product_id, product_name, base_price_npr, unit_cost_npr
FROM priceproductt
WHERE unit_cost_npr > base_price_npr;

-- Find missing / blank text values.
SELECT *
FROM priceproductt
WHERE product_name IS NULL OR TRIM(product_name) = ''
   OR category IS NULL OR TRIM(category) = ''
   OR brand IS NULL OR TRIM(brand) = '';

-- Identify repeated product names.
SELECT product_name, COUNT(*) AS occurrences
FROM priceproductt
GROUP BY product_name
HAVING COUNT(*) > 1;

-- Check currency codes.
SELECT Currency_1, COUNT(*) AS rows_for_currency
FROM priceproductt
GROUP BY Currency_1;

-- Check distinct exchange rates.
SELECT ExchangeRate_EUR, ExchangeRate_CAD, COUNT(*) AS row_count
FROM priceproductt
GROUP BY ExchangeRate_EUR, ExchangeRate_CAD
ORDER BY row_count DESC;

-- Check date range and pull batches.
SELECT
    MIN(data_pulled_date) AS first_pull,
    MAX(data_pulled_date) AS latest_pull,
    COUNT(DISTINCT data_pulled_date) AS distinct_pull_timestamps
FROM priceproductt;

-- Rows pulled in the last 7 days.
SELECT *
FROM priceproductt
WHERE data_pulled_date >= NOW() - INTERVAL 7 DAY
ORDER BY data_pulled_date DESC;

-- Recalculate the stored converted unit-cost values.
SELECT
    product_id,
    product_name,
    unit_cost_npr,
    ExchangeRate_EUR,
    ROUND(unit_cost_npr * ExchangeRate_EUR, 6) AS calculated_unit_cost_eur,
    ExchangeRate_CAD,
    ROUND(unit_cost_npr * ExchangeRate_CAD, 6) AS calculated_unit_cost_cad
FROM priceproductt
ORDER BY product_name;

-- Compare stored converted unit-cost values with the formula.
SELECT
    product_id,
    product_name,
    unit_cost_npr,
    TotalSalesEUR AS stored_eur_value,
    ROUND(unit_cost_npr * ExchangeRate_EUR, 6) AS recalculated_eur,
    TotalSalesCAD AS stored_cad_value,
    ROUND(unit_cost_npr * ExchangeRate_CAD, 6) AS recalculated_cad
FROM priceproductt
ORDER BY product_name;

-- Summarize converted unit costs by category.
SELECT
    category,
    ROUND(AVG(unit_cost_npr * ExchangeRate_EUR), 6) AS avg_unit_cost_eur,
    ROUND(AVG(unit_cost_npr * ExchangeRate_CAD), 6) AS avg_unit_cost_cad
FROM priceproductt
GROUP BY category
ORDER BY category;

-- Currency rates by pull date.
SELECT
    DATE(data_pulled_date) AS pull_date,
    ROUND(AVG(ExchangeRate_EUR), 6) AS avg_eur_rate,
    ROUND(AVG(ExchangeRate_CAD), 6) AS avg_cad_rate,
    COUNT(*) AS rows_in_batch
FROM priceproductt
GROUP BY DATE(data_pulled_date)
ORDER BY pull_date DESC;

-- Products priced above the overall average.
SELECT product_id, product_name, base_price_npr
FROM priceproductt
WHERE base_price_npr > (
    SELECT AVG(base_price_npr) FROM priceproductt
)
ORDER BY base_price_npr DESC;

-- Products priced above their category's average.
SELECT p.product_id, p.product_name, p.category, p.base_price_npr
FROM priceproductt AS p
WHERE p.base_price_npr > (
    SELECT AVG(p2.base_price_npr)
    FROM priceproductt AS p2
    WHERE p2.category = p.category
)
ORDER BY p.category, p.base_price_npr DESC;

-- create a temporary named result for category statistics.
WITH category_stats AS (
    SELECT category,
           COUNT(*) AS product_count,
           AVG(base_price_npr) AS avg_price
    FROM priceproductt
    GROUP BY category
)
SELECT category, product_count, ROUND(avg_price, 2) AS avg_price_npr
FROM category_stats
ORDER BY avg_price DESC;

-- price conversion then category summary.
WITH converted AS (
    SELECT category, product_id, product_name,
           unit_cost_npr * ExchangeRate_EUR AS unit_cost_eur,
           unit_cost_npr * ExchangeRate_CAD AS unit_cost_cad
    FROM priceproductt
),
category_summary AS (
    SELECT category,
           COUNT(*) AS product_count,
           AVG(unit_cost_eur) AS avg_eur,
           AVG(unit_cost_cad) AS avg_cad
    FROM converted
    GROUP BY category
)
SELECT category, product_count,
       ROUND(avg_eur, 6) AS avg_unit_cost_eur,
       ROUND(avg_cad, 6) AS avg_unit_cost_cad
FROM category_summary
ORDER BY category;

-- Rank products by price overall.
SELECT
    product_name,
    category,
    base_price_npr,
    RANK() OVER (ORDER BY base_price_npr DESC) AS price_rank
FROM priceproductt;

-- Rank products within each category.
SELECT
    product_name,
    category,
    base_price_npr,
    DENSE_RANK() OVER (
        PARTITION BY category ORDER BY base_price_npr DESC
    ) AS category_price_rank
FROM priceproductt
ORDER BY category, category_price_rank;

-- Compare each product's price to the previous price in its category.
SELECT
    product_name,
    category,
    base_price_npr,
    LAG(base_price_npr) OVER (
        PARTITION BY category ORDER BY base_price_npr
    ) AS previous_price_in_category,
    base_price_npr - LAG(base_price_npr) OVER (
        PARTITION BY category ORDER BY base_price_npr
    ) AS difference_from_previous
FROM priceproductt;

-- Top 3 most expensive products in each category.
WITH ranked_products AS (
    SELECT
        product_id, product_name, category, base_price_npr,
        ROW_NUMBER() OVER (
            PARTITION BY category ORDER BY base_price_npr DESC, product_id
        ) AS row_num
    FROM priceproductt
)
SELECT product_id, product_name, category, base_price_npr
FROM ranked_products
WHERE row_num <= 3
ORDER BY category, base_price_npr DESC;

-- Products with high supplier lead times.
SELECT product_id, product_name, supplier_lead_time_days,
       reorder_point, reorder_qty
FROM priceproductt
ORDER BY supplier_lead_time_days DESC
LIMIT 15;

-- Potentially short-shelf-life products with long lead times.
SELECT product_name, shelf_life_days, supplier_lead_time_days
FROM priceproductt
WHERE shelf_life_days <= 7
  AND supplier_lead_time_days >= 3
ORDER BY supplier_lead_time_days DESC;

-- Compare reorder quantity with reorder point.
SELECT
    product_name,
    reorder_point,
    reorder_qty,
    reorder_qty - reorder_point AS reorder_qty_minus_point
FROM priceproductt
ORDER BY reorder_qty_minus_point DESC;

-- Daily demand relative to reorder point.
SELECT
    product_name,
    base_daily_demand_units,
    reorder_point,
    ROUND(reorder_point / NULLIF(base_daily_demand_units, 0), 2)
        AS reorder_point_days_of_demand
FROM priceproductt
ORDER BY reorder_point_days_of_demand;

-- Approximate demand coverage represented by reorder quantity.
SELECT
    product_name,
    reorder_qty,
    base_daily_demand_units,
    ROUND(reorder_qty / NULLIF(base_daily_demand_units, 0), 2)
        AS reorder_qty_days_of_demand
FROM priceproductt
ORDER BY reorder_qty_days_of_demand DESC;

-- Rank high-demand products.
SELECT product_name, category, base_daily_demand_units,
       RANK() OVER (ORDER BY base_daily_demand_units DESC) AS demand_rank
FROM priceproductt;

-- Simple restocking-priority score.
SELECT
    product_name,
    shelf_life_days,
    supplier_lead_time_days,
    reorder_point,
    base_daily_demand_units,
    CASE
        WHEN supplier_lead_time_days >= 4
             AND base_daily_demand_units >= 8 THEN 'High review priority'
        WHEN supplier_lead_time_days >= 3
             OR base_daily_demand_units >= 7 THEN 'Medium review priority'
        ELSE 'Normal review priority'
    END AS review_priority
FROM priceproductt
ORDER BY
    CASE
        WHEN supplier_lead_time_days >= 4
             AND base_daily_demand_units >= 8 THEN 1
        WHEN supplier_lead_time_days >= 3
             OR base_daily_demand_units >= 7 THEN 2
        ELSE 3
    END;

-- Count rows by load date.
SELECT DATE(data_pulled_date) AS load_date, COUNT(*) AS rows_loaded
FROM priceproductt
GROUP BY DATE(data_pulled_date)
ORDER BY load_date DESC;

-- See the most recent rows loaded.
SELECT *
FROM priceproductt
ORDER BY data_pulled_date DESC
LIMIT 20;

-- Check whether each product appears in multiple pull batches.
SELECT product_id, COUNT(DISTINCT data_pulled_date) AS pull_timestamps
FROM priceproductt
GROUP BY product_id
HAVING COUNT(DISTINCT data_pulled_date) > 1
ORDER BY pull_timestamps DESC;

-- Find exact duplicate business records (excluding load timestamp).
SELECT
    product_id, product_name, category, brand, base_price_npr, unit_cost_npr,
    COUNT(*) AS duplicate_count
FROM priceproductt
GROUP BY
    product_id, product_name, category, brand, base_price_npr, unit_cost_npr
HAVING COUNT(*) > 1;

-- Example audit summary.
SELECT
    COUNT(*) AS rows_total,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(*) - COUNT(DISTINCT product_id) AS possible_duplicate_id_rows,
    SUM(product_id IS NULL) AS missing_ids,
    SUM(base_price_npr IS NULL) AS missing_prices,
    SUM(data_pulled_date IS NULL) AS missing_load_timestamps
FROM priceproductt;

-- Create a view for consistently useful clean product fields.
CREATE OR REPLACE VIEW vw_product_pricing_clean AS
SELECT
    product_id,
    TRIM(product_name) AS product_name,
    TRIM(category) AS category,
    TRIM(brand) AS brand,
    base_price_npr,
    unit_cost_npr,
    shelf_life_days,
    supplier_lead_time_days,
    reorder_point,
    reorder_qty,
    base_daily_demand_units,
    Currency_1,
    ExchangeRate_EUR,
    ExchangeRate_CAD,
    TotalSalesEUR,
    TotalSalesCAD,
    data_pulled_date
FROM priceproductt
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> '';

-- Query the view.
SELECT * FROM vw_product_pricing_clean LIMIT 20;

-- Price distribution summary.
SELECT
    COUNT(base_price_npr) AS n,
    MIN(base_price_npr) AS min_price,
    MAX(base_price_npr) AS max_price,
    ROUND(AVG(base_price_npr), 2) AS mean_price,
    ROUND(STDDEV_POP(base_price_npr), 2) AS population_stddev_price
FROM priceproductt;

-- Z-score-style price outlier screening.
WITH stats AS (
    SELECT AVG(base_price_npr) AS avg_price,
           NULLIF(STDDEV_POP(base_price_npr), 0) AS sd_price
    FROM priceproductt
)
SELECT
    p.product_id,
    p.product_name,
    p.base_price_npr,
    ROUND((p.base_price_npr - s.avg_price) / s.sd_price, 2) AS price_z_score
FROM priceproductt AS p
CROSS JOIN stats AS s
WHERE s.sd_price IS NOT NULL
  AND ABS((p.base_price_npr - s.avg_price) / s.sd_price) >= 2
ORDER BY ABS((p.base_price_npr - s.avg_price) / s.sd_price) DESC;

-- Correlation between price and unit cost.
SELECT
    (
      COUNT(*) * SUM(base_price_npr * unit_cost_npr)
      - SUM(base_price_npr) * SUM(unit_cost_npr)
    ) /
    NULLIF(
      SQRT(
        (COUNT(*) * SUM(base_price_npr * base_price_npr)
          - POW(SUM(base_price_npr), 2))
        *
        (COUNT(*) * SUM(unit_cost_npr * unit_cost_npr)
          - POW(SUM(unit_cost_npr), 2))
      ),
      0
    ) AS price_cost_correlation
FROM priceproductt
WHERE base_price_npr IS NOT NULL
  AND unit_cost_npr IS NOT NULL;

-- Compare price, cost, and gross margin per unit.
SELECT
    product_id,
    product_name,
    base_price_npr,
    unit_cost_npr,
    base_price_npr - unit_cost_npr AS gross_margin_per_unit_npr,
    ROUND(
        100 * (base_price_npr - unit_cost_npr) /
        NULLIF(base_price_npr, 0), 2
    ) AS gross_margin_percent
FROM priceproductt
ORDER BY gross_margin_percent;

-- Find negative or zero margins.
SELECT product_id, product_name, base_price_npr, unit_cost_npr
FROM priceproductt
WHERE base_price_npr <= unit_cost_npr
ORDER BY base_price_npr - unit_cost_npr;

-- Category-level average gross margin.
SELECT
    category,
    ROUND(AVG(base_price_npr - unit_cost_npr), 2) AS avg_margin_npr,
    ROUND(AVG(
        100 * (base_price_npr - unit_cost_npr) /
        NULLIF(base_price_npr, 0)
    ), 2) AS avg_margin_percent
FROM priceproductt
GROUP BY category
ORDER BY avg_margin_percent DESC;

-- If the column exists but values need filling, carefully inspect first:
SELECT COUNT(*) AS null_pull_dates
FROM priceproductt
WHERE data_pulled_date IS NULL;

/*
How many product rows and unique product IDs are present?
The first number is row count; the second is unique non-NULL IDs.
If they differ, investigate duplicate IDs or NULL IDs.
*/
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_ids
FROM priceproductt;

/*
Business question: What are the 10 most expensive products by base/list price in NPR?
*/
SELECT product_id, product_name, category, base_price_npr
FROM priceproductt
ORDER BY base_price_npr DESC
LIMIT 10;

/*
Which products have a base/list price between NPR 100 and NPR 250?
*/
SELECT product_id, product_name, base_price_npr
FROM priceproductt
WHERE base_price_npr BETWEEN 100 AND 250
ORDER BY base_price_npr;

/*
What categories exist, and how many products are in each?
*/
SELECT category, COUNT(*) AS product_count
FROM priceproductt
GROUP BY category
ORDER BY product_count DESC, category;

/*
Business question: Which product names contain “Bread”?
*/
SELECT product_id, product_name, category, brand
FROM priceproductt
WHERE product_name LIKE '%Bread%'
ORDER BY product_name;

/*
What is the average, minimum, and maximum base/list price in NPR?
NULL prices are ignored by AVG, MIN, and MAX.
*/
SELECT
    ROUND(AVG(base_price_npr), 2) AS average_base_price_npr,
    MIN(base_price_npr) AS minimum_base_price_npr,
    MAX(base_price_npr) AS maximum_base_price_npr,
    COUNT(base_price_npr) AS rows_with_base_price
FROM priceproductt;

/*
How many products belong to each brand?
*/
SELECT brand, COUNT(*) AS product_count
FROM priceproductt
GROUP BY brand
ORDER BY product_count DESC, brand;

/*
Which products have a shelf life of 7 days or less?
*/
SELECT product_id, product_name, category, shelf_life_days
FROM priceproductt
WHERE shelf_life_days <= 7
ORDER BY shelf_life_days, product_name;

/*
What is the average base/list price for each category?
*/
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(base_price_npr), 2) AS avg_base_price_npr
FROM priceproductt
GROUP BY category
ORDER BY avg_base_price_npr DESC;

/*
Which products are priced above the overall average base/list price?
*/
SELECT product_id, product_name, category, base_price_npr
FROM priceproductt
WHERE base_price_npr > (SELECT AVG(base_price_npr) FROM priceproductt)
ORDER BY base_price_npr DESC;

/*
Which products are priced above their own category's average?
*/
SELECT p.product_id, p.product_name, p.category, p.base_price_npr
FROM priceproductt AS p
WHERE p.base_price_npr > (
    SELECT AVG(p2.base_price_npr)
    FROM priceproductt AS p2
    WHERE p2.category = p.category
)
ORDER BY p.category, p.base_price_npr DESC;

/*
What is the unit-cost total and average in NPR by category?
*/
SELECT
    category,
    COUNT(*) AS product_count,
    ROUND(SUM(unit_cost_npr), 2) AS sum_of_unit_costs_npr,
    ROUND(AVG(unit_cost_npr), 2) AS avg_unit_cost_npr
FROM priceproductt
GROUP BY category
ORDER BY sum_of_unit_costs_npr DESC;

/*
Which products have a unit cost greater than their base/list price?
*/
SELECT product_id, product_name, base_price_npr, unit_cost_npr,
       unit_cost_npr - base_price_npr AS cost_minus_base_price_npr
FROM priceproductt
WHERE unit_cost_npr > base_price_npr
ORDER BY cost_minus_base_price_npr DESC;

/*
What is the per-unit difference between base/list price and unit cost?
*/
SELECT
    product_id,
    product_name,
    base_price_npr,
    unit_cost_npr,
    base_price_npr - unit_cost_npr AS price_minus_cost_npr,
    ROUND(100 * (base_price_npr - unit_cost_npr) /
          NULLIF(base_price_npr, 0), 2) AS price_cost_difference_percent
FROM priceproductt
ORDER BY price_minus_cost_npr DESC;

/*
What would the base/list price be in EUR and CAD?
*/
SELECT
    product_id,
    product_name,
    base_price_npr,
    ROUND(base_price_npr * ExchangeRate_EUR, 6) AS base_price_eur,
    ROUND(base_price_npr * ExchangeRate_CAD, 6) AS base_price_cad
FROM priceproductt
ORDER BY product_name;

/*
Which categories have at least five product rows?
*/
SELECT category, COUNT(*) AS product_count
FROM priceproductt
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY product_count DESC;

/*
Which required fields contain NULL or blank values?
*/
SELECT
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_id,
    SUM(product_name IS NULL OR TRIM(product_name) = '') AS missing_product_name,
    SUM(category IS NULL OR TRIM(category) = '') AS missing_category,
    SUM(brand IS NULL OR TRIM(brand) = '') AS missing_brand,
    SUM(base_price_npr IS NULL) AS missing_base_price,
    SUM(unit_cost_npr IS NULL) AS missing_unit_cost,
    SUM(data_pulled_date IS NULL) AS missing_pull_date
FROM priceproductt;

/*
Are there negative values in price, cost, lead time, shelf life,
reorder, or demand fields?
*/
SELECT *
FROM priceproductt
WHERE base_price_npr < 0
   OR unit_cost_npr < 0
   OR shelf_life_days < 0
   OR supplier_lead_time_days < 0
   OR reorder_point < 0
   OR reorder_qty < 0
   OR base_daily_demand_units < 0;

/*
How many rows have a NULL product ID?
*/
SELECT COUNT(*) AS rows_with_null_product_id
FROM priceproductt
WHERE product_id IS NULL;

/*
Business question: Do product IDs have leading/trailing spaces?
*/
SELECT product_id, TRIM(product_id) AS trimmed_product_id
FROM priceproductt
WHERE product_id <> TRIM(product_id);

/*
How can I query the clean view after creating it?
*/
SELECT *
FROM vw_product_pricing_clean
ORDER BY product_id
LIMIT 25;

/*
How can I inspect indexes before deciding whether to add one?
*/
SHOW INDEX FROM priceproductt;

/*
What is the distribution summary of base/list prices?
*/
SELECT
    COUNT(base_price_npr) AS n_prices,
    MIN(base_price_npr) AS minimum_price,
    MAX(base_price_npr) AS maximum_price,
    ROUND(AVG(base_price_npr), 2) AS mean_price,
    ROUND(STDDEV_POP(base_price_npr), 2) AS population_stddev_price
FROM priceproductt;

/*
Which products have the largest difference between base/list price
and unit cost?
*/
SELECT
    product_id,
    product_name,
    category,
    base_price_npr,
    unit_cost_npr,
    base_price_npr - unit_cost_npr AS price_cost_difference_npr
FROM priceproductt
ORDER BY price_cost_difference_npr DESC
LIMIT 15;

/*
Which products have high daily demand and long supplier lead times?
*/
SELECT
    product_id,
    product_name,
    category,
    base_daily_demand_units,
    supplier_lead_time_days,
    reorder_point,
    reorder_qty
FROM priceproductt
WHERE base_daily_demand_units >= 8
  AND supplier_lead_time_days >= 3
ORDER BY base_daily_demand_units DESC, supplier_lead_time_days DESC;

/*
Which short-shelf-life products also have long supplier lead times?
*/
SELECT
    product_id,
    product_name,
    shelf_life_days,
    supplier_lead_time_days,
    base_daily_demand_units
FROM priceproductt
WHERE shelf_life_days <= 7
  AND supplier_lead_time_days >= 3
ORDER BY shelf_life_days ASC, supplier_lead_time_days DESC;

/*
How can I identify product records that have changed across snapshots?
*/
SELECT
    product_id,
    MIN(base_price_npr) AS min_base_price_npr,
    MAX(base_price_npr) AS max_base_price_npr,
    COUNT(DISTINCT base_price_npr) AS distinct_base_prices,
    MIN(data_pulled_date) AS first_seen,
    MAX(data_pulled_date) AS last_seen
FROM priceproductt
GROUP BY product_id
HAVING COUNT(DISTINCT base_price_npr) > 1
ORDER BY distinct_base_prices DESC, product_id;

/*
What is the newest data-pull timestamp for each product?
*/
WITH latest_pull AS (
    SELECT product_id, MAX(data_pulled_date) AS latest_data_pulled_date
    FROM priceproductt
    GROUP BY product_id
)
SELECT p.*
FROM priceproductt AS p
JOIN latest_pull AS l
  ON p.product_id = l.product_id
 AND p.data_pulled_date = l.latest_data_pulled_date
ORDER BY p.product_id;

SELECT category, COUNT(*) AS product_count
FROM priceproductt
WHERE product_id IS NOT NULL
GROUP BY category
HAVING COUNT(*) >= 5;

SELECT product_id, COUNT(*) AS row_count
FROM priceproductt
GROUP BY product_id
HAVING COUNT(*) > 1;

/*
What is a transaction?
*/
START TRANSACTION;
SELECT product_id, product_name, base_price_npr
FROM priceproductt
WHERE product_id = 'NP0001';
ROLLBACK;
