----------------------------------------------------
----------- A/B TEST: MARKETING CAMPAIGN -----------
----------------------------------------------------

-- Sanity check for any NULL values in the data
# No NULL values

SELECT 
SUM(CASE WHEN market_id IS NULL THEN 1 ELSE 0 END) AS null_market_id,
SUM(CASE WHEN market_size IS NULL THEN 1 ELSE 0 END) AS null_market_size,
SUM(CASE WHEN location_id IS NULL THEN 1 ELSE 0 END) AS null_location_id,
SUM(CASE WHEN age_of_store IS NULL THEN 1 ELSE 0 END) AS null_age,
SUM(CASE WHEN promotion IS NULL THEN 1 ELSE 0 END) AS null_promotion,
SUM(CASE WHEN week IS NULL THEN 1 ELSE 0 END) AS null_week,
SUM(CASE WHEN sales_in_thousands IS NULL THEN 1 ELSE 0 END) AS null_sales
FROM `turing_data_analytics.wa_marketing_campaign`

-- Checking minimum and maximum values for sales
# Min: 17.34
# Max: 99.65

SELECT
  MIN(sales_in_thousands) AS min_sales,
  MAX(sales_in_thousands) AS max_sales
FROM `turing_data_analytics.wa_marketing_campaign`

-- Checking for outliers
# Based on the IQR calculation, some outliers are present. However, the maximum value in the dataset (99.65) is not unreasonably off from the upper bound (87.73). And since we want to detect positive effects from this test as higher sales, the decision is not remove those outliers.

WITH quartiles AS (
  SELECT
    APPROX_QUANTILES(sales_in_thousands, 100)[OFFSET(25)] AS Q1,
    APPROX_QUANTILES(sales_in_thousands, 100)[OFFSET(75)] AS Q3
  FROM
    `turing_data_analytics.wa_marketing_campaign`
),
iqr_calculation AS (
  SELECT
    Q1,
    Q3,
    Q3 - Q1 AS IQR,
    Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
    Q3 + 1.5 * (Q3 - Q1) AS upper_bound
  FROM
    quartiles
)
SELECT
  *,
  CASE
    WHEN sales_in_thousands < lower_bound OR sales_in_thousands > upper_bound THEN 'Outlier'
    ELSE 'Not Outlier'
  END AS outlier_status
FROM
  `turing_data_analytics.wa_marketing_campaign`,
  iqr_calculation;



-- Understand the proportion size of each test group, ideally the test groups should be equal size.
# Promo 2 and 3 are both equally present (34.3%). But promo 1 is a bit less present (31.4%).
SELECT
SUM(CASE WHEN promotion = 1 THEN 1 ELSE 0 END) / COUNT(*) AS promo_1,
SUM(CASE WHEN promotion = 2 THEN 1 ELSE 0 END) / COUNT(*) AS promo_2,
SUM(CASE WHEN promotion = 3 THEN 1 ELSE 0 END) / COUNT(*) AS promo_3
FROM `turing_data_analytics.wa_marketing_campaign`

-- Grouping different variables to understand the distribution of different groups and continue to work with them in Google Sheets.

SELECT 
promotion,
COUNT(*) AS promo_count,
COUNT (DISTINCT location_id) AS number_locations,
AVG(age_of_store) AS avg_store_age,
SUM(sales_in_thousands) AS total_sales,
AVG(sales_in_thousands) AS avg_sales,
SUM(CASE WHEN market_size = 'Small' THEN 1 ELSE 0 END) AS small,
SUM(CASE WHEN market_size = 'Medium' THEN 1 ELSE 0 END) AS medium,
SUM(CASE WHEN market_size = 'Large' THEN 1 ELSE 0 END) AS large
FROM `turing_data_analytics.wa_marketing_campaign`
GROUP BY promotion;

SELECT market_size, COUNT(*)
FROM `turing_data_analytics.wa_marketing_campaign`
GROUP BY market_size

-- Table with target variable (sales) to derive calculations from

SELECT promotion,
SUM(CASE WHEN week = 1 THEN sales_in_thousands ELSE 0 END) AS week_1, 
SUM(CASE WHEN week = 2 THEN sales_in_thousands ELSE 0 END) AS week_2, 
SUM(CASE WHEN week = 3 THEN sales_in_thousands ELSE 0 END) AS week_3, 
SUM(CASE WHEN week = 4 THEN sales_in_thousands ELSE 0 END) AS week_4 
FROM `turing_data_analytics.wa_marketing_campaign`
GROUP BY promotion;
