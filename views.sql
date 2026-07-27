-- =============================================
-- View Name: vw_MonthlyRestaurantPerformance
-- Description: Aggregates transaction data by restaurant, year, and month 
--              to track revenue and performance efficiently.
-- =============================================
CREATE VIEW vw_MonthlyRestaurantPerformance AS
SELECT 
    r.RestaurantID,
    r.Name,
    YEAR(t.TransactionDate) AS PerformanceYear,
    MONTH(t.TransactionDate) AS PerformanceMonth,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.TotalAmount) AS TotalRevenue,
    AVG(t.TotalAmount) AS AverageOrderValue
FROM 
    Restaurants r
JOIN 
    Transactions t ON r.RestaurantID = t.RestaurantID
GROUP BY 
    r.RestaurantID, 
    r.Name, 
    YEAR(t.TransactionDate),
    MONTH(t.TransactionDate);
GO