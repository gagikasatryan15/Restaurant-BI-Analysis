CREATE DATABASE RestaurantAnalytics;
GO

USE RestaurantAnalytics;
GO

-- 1. Restaurants
CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY,
    Name NVARCHAR(100),
    City NVARCHAR(50)
);

-- 2. Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    JoinDate DATE
);

-- 3. Menu Categories
CREATE TABLE MenuCategories (
    CategoryID INT PRIMARY KEY,
    CategoryName NVARCHAR(50)
);

-- 4. Menu Items
CREATE TABLE MenuItems (
    ItemID INT PRIMARY KEY,
    RestaurantID INT FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    CategoryID INT FOREIGN KEY REFERENCES MenuCategories(CategoryID), 
    ItemName NVARCHAR(100),
    Price DECIMAL(18, 2)
);

-- 5. Transactions
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    RestaurantID INT FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    TransactionDate DATETIME,
    TotalAmount DECIMAL(18, 2),
    PaymentMethod NVARCHAR(20)
);
GO