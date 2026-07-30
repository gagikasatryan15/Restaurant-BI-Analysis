/* 5. Hypothesis Testing Prep: Payment Method Comparison
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