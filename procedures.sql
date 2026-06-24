/* 1. Procedures for automated revenue reporting */
CREATE PROCEDURE GetRestaurantRevenue
    @ResID INT 
AS
BEGIN
    SELECT 
        RestaurantID,
        FORMAT(TransactionDate, 'yyyy-MM') AS Month,
        SUM(TotalAmount) AS Revenue,
        COUNT(TransactionID) AS TotalTransactions
    FROM 
        Transactions
    WHERE 
        RestaurantID = @ResID 
    GROUP BY 
        RestaurantID, FORMAT(TransactionDate, 'yyyy-MM')
    ORDER BY 
        Month DESC;
END;
GO


  
/* 2. Advanced Procedure: Adding a new transaction with validation
   This ensures we don't accidentally insert invalid data (like negative amounts).
*/
CREATE PROCEDURE AddNewTransaction
    @RestaurantID INT,
    @CustomerID INT,
    @TotalAmount DECIMAL(10, 2),
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    -- Validation: Check if the amount is valid
    IF @TotalAmount <= 0
    BEGIN
        PRINT 'Error: Transaction amount must be greater than zero.';
        RETURN;
    END

    -- If valid, insert the data
    INSERT INTO Transactions (RestaurantID, CustomerID, TotalAmount, PaymentMethod, TransactionDate)
    VALUES (@RestaurantID, @CustomerID, @TotalAmount, @PaymentMethod, GETDATE());

    PRINT 'Transaction successfully added.';
END;
GO
