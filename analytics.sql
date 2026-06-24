/* RESTAURANT ANALYTICS QUERIES
   This file contains various business intelligence reports.
*/



-- 1. Monthly transaction growth analysis
-- Calculates how revenue has changed compared to the previous month
WITH MonthlyRestaurantRevenue AS (
    SELECT 
        RestaurantID,
        FORMAT(TransactionDate, 'yyyy-MM') AS Month,
        SUM(TotalAmount) AS Revenue
    FROM Transactions
    GROUP BY RestaurantID, FORMAT(TransactionDate, 'yyyy-MM')
)
SELECT 
    mr.RestaurantID,
    r.Name,
    mr.Month,
    mr.Revenue,
    -- Previous month revenue for the same restaurant
    LAG(mr.Revenue) OVER (PARTITION BY mr.RestaurantID ORDER BY mr.Month) AS PrevMonthRevenue,
    -- Growth Rate calculation
    FORMAT(
        (mr.Revenue - LAG(mr.Revenue) OVER (PARTITION BY mr.RestaurantID ORDER BY mr.Month)) 
        / NULLIF(LAG(mr.Revenue) OVER (PARTITION BY mr.RestaurantID ORDER BY mr.Month), 0), 
        'P'
    ) AS GrowthRate
FROM MonthlyRestaurantRevenue mr
JOIN Restaurants r
    ON mr.RestaurantID = r.RestaurantID
ORDER BY RestaurantID, Month;



-- Top 2. customers for each restaurant
-- Ranks customers by total spend per restaurant using DENSE_RANK
WITH CustomerRanking AS (
	SELECT
		RestaurantID,
		CustomerID,
		SUM(TotalAmount) AS TotalSpent,
		/* DENSE_RANK() assigns a rank to each customer based on their total spend.
           PARTITION BY resets the ranking for every restaurant.
           ORDER BY ... DESC sorts the highest spenders first.
        */
		DENSE_RANK() OVER (PARTITION BY RestaurantID ORDER BY SUM(TotalAmount) DESC) AS Rank
	FROM Transactions
	GROUP BY
		RestaurantID,
		CustomerID
)
SELECT 
	cr.RestaurantID,
	cr.CustomerID,
	c.FullName,
	cr.TotalSpent,
	cr.Rank
FROM CustomerRanking cr
JOIN Customers c
	ON cr.CustomerID = c.CustomerID
WHERE Rank <= 3
ORDER BY RestaurantID, Rank



/* 3. Outlier Analysis (Statistical Approach)
   Finds transactions that are significantly higher than the average revenue 
   per restaurant (more than 2 standard deviations away).
*/
WITH TransactionStats AS (
	SELECT
		RestaurantID,
		AVG(TotalAmount) AS MeanValue,
		STDEV(TotalAmount) AS StDevValue
	FROM Transactions
	GROUP BY RestaurantID
)
SELECT
	t.TransactionID,
	t.RestaurantID,
	t.TotalAmount,
	ts.MeanValue,
	-- Statistical flag: if the amount is more than 2x StdDev above the average
	CASE
		WHEN t.TotalAmount > (ts.MeanValue + (2 * ts.StDevValue)) THEN 'High-Value Outlier'
		ELSE 'Normal'
	END AS TransactionType
FROM Transactions t
JOIN TransactionStats ts
	ON t.RestaurantID = ts.RestaurantID
WHERE t.TotalAmount > (ts.MeanValue + (2 * ts.StDevValue))
ORDER BY t.RestaurantID, t.TotalAmount DESC
GO



/* 4. Hypothesis Testing Prep: Payment Method Comparison
   We want to compare the average transaction amount between 'Card' and 'Cash'.
   This query prepares the descriptive statistics needed for a t-test.
*/
SELECT 
    PaymentMethod,
    COUNT(TransactionID) AS TransactionCount,
    AVG(TotalAmount) AS AvgTransactionAmount,
    STDEV(TotalAmount) AS StdDevAmount
FROM Transactions
WHERE PaymentMethod IN ('Card', 'Cash')
GROUP BY PaymentMethod;
GO
