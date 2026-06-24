-- Inserting Restaurants
INSERT INTO Restaurants (RestaurantID, Name, City) VALUES
(1, 'Lavash', 'Yerevan'), (2, 'Sherep', 'Yerevan'), (3, 'Tavern', 'Yerevan'), 
(4, 'Anteb', 'Yerevan'), (5, 'Tumanyan', 'Yerevan'),
(6, 'Semoi Mot', 'Sevan'), (7, 'Yasaman', 'Sevan'), (8, 'Gwoog', 'Gyumri'), (9, 'Cherkezi Dzor', 'Gyumri'),
(10, 'Craftsmens', 'Tsaghkadzor'), (11, 'Dahook', 'Tsaghkadzor'), (12, 'Kecharis', 'Tsaghkadzor'),
(13, 'Alexandrowski', 'Gyumri'), (14, 'Chichkhan', 'Gyumri'),
(15, 'Kchuch', 'Dilijan'), (16, 'Pandok Yerevan', 'Yerevan'), 
(17, 'Yeraz', 'Yerevan'), (18, 'Tsirani', 'Yerevan'), (19, 'Vostan', 'Yerevan'), (20, 'Kilikia', 'Yerevan');
GO

-- Inserting Customers
INSERT INTO Customers (CustomerID, FullName, JoinDate)
SELECT TOP 1000
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    'Customer ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NVARCHAR(10)),
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 730), GETDATE()) -- Վերջին 2 տարվա ընթացքում
FROM sys.all_columns a CROSS JOIN sys.all_columns b;
GO

-- 1. General menu items (common for all)
INSERT INTO MenuItems (ItemID, RestaurantID, CategoryID, ItemName, Price)
SELECT 
    (R.RestaurantID * 1000) + U.ItemID,
    R.RestaurantID,
    (ABS(CHECKSUM(NEWID())) % 4) + 1,
    U.ItemName,
    (ABS(CHECKSUM(NEWID())) % 50 + 10) * 100
FROM Restaurants R
CROSS JOIN (
    SELECT 1 AS ItemID, 'Khorovats' AS ItemName UNION ALL SELECT 2, 'Coca Cola' UNION ALL 
    SELECT 3, 'Coffee' UNION ALL SELECT 4, 'Tea' UNION ALL SELECT 5, 'Salad' UNION ALL
    SELECT 6, 'Lavash' UNION ALL SELECT 7, 'Soup' UNION ALL SELECT 8, 'Water' UNION ALL
    SELECT 9, 'Pizza' UNION ALL SELECT 10, 'Ice Cream' UNION ALL SELECT 11, 'Bread' UNION ALL
    SELECT 12, 'French Fries' UNION ALL SELECT 13, 'Burger' UNION ALL SELECT 14, 'Juice' UNION ALL
    SELECT 15, 'Beer' UNION ALL SELECT 16, 'Wine' UNION ALL SELECT 17, 'Cake' UNION ALL
    SELECT 18, 'Cheese' UNION ALL SELECT 19, 'Chicken' UNION ALL SELECT 20, 'Beef'
) AS U;

-- 2. 80 unique "Special" items (specific for each restaurant)
INSERT INTO MenuItems (ItemID, RestaurantID, CategoryID, ItemName, Price)
SELECT 
    (R.RestaurantID * 1000) + N.Num + 20,
    R.RestaurantID,
    (ABS(CHECKSUM(NEWID())) % 4) + 1,
    'R' + CAST(R.RestaurantID AS NVARCHAR(2)) + '_Special_' + CAST(N.Num AS NVARCHAR(3)),
    (ABS(CHECKSUM(NEWID())) % 100 + 20) * 100
FROM Restaurants R
CROSS JOIN (SELECT TOP 80 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as Num FROM sys.objects) AS N;
GO

-- 1. Insert 50,000 transactions
INSERT INTO Transactions (TransactionID, RestaurantID, CustomerID, TransactionDate, TotalAmount, PaymentMethod)
SELECT TOP 50000
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    (ABS(CHECKSUM(NEWID())) % 1000) + 1,
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 730), GETDATE()),
    (ABS(CHECKSUM(NEWID())) % 281 + 20) * 100,
    CASE 
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 60 THEN 'Card'
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 85 THEN 'Cash'
        ELSE 'Online'
    END
FROM sys.objects a CROSS JOIN sys.objects b; 
GO

-- 2. Insert 600 transactions with higher amounts (outliers)
INSERT INTO Transactions (TransactionID, RestaurantID, CustomerID, TransactionDate, TotalAmount, PaymentMethod)
SELECT TOP 600
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 50000,
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    (ABS(CHECKSUM(NEWID())) % 1000) + 1,
    GETDATE(),
    (ABS(CHECKSUM(NEWID())) % 2201 + 300) * 100, -- from 30,000 to 250,000
    CASE 
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 60 THEN 'Card'
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 85 THEN 'Cash'
        ELSE 'Online'
    END
FROM sys.objects a CROSS JOIN sys.objects b; 
GO

-- 3. Insert 200 small transactions
INSERT INTO Transactions (TransactionID, RestaurantID, CustomerID, TransactionDate, TotalAmount, PaymentMethod)
SELECT TOP 200
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 50600,
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    (ABS(CHECKSUM(NEWID())) % 1000) + 1,
    GETDATE(),
    (ABS(CHECKSUM(NEWID())) % 16 + 5) * 100, -- from 500 to 2,000
    CASE 
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 60 THEN 'Card'
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 85 THEN 'Cash'
        ELSE 'Online'
    END
FROM sys.objects a CROSS JOIN sys.objects b; 
GO
