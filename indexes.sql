-- =============================================
-- Index Name: IX_Transactions_RestaurantID_Date
-- Description: Creates a non-clustered index on Transactions table 
--              to optimize joins, filtering, and grouping by Restaurant and Date.
-- =============================================
CREATE NONCLUSTERED INDEX IX_Transactions_RestaurantID_Date
ON Transactions (RestaurantID, TransactionDate)
INCLUDE (TotalAmount);
GO