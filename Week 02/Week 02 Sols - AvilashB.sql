-- Name : Avilash Bhowmick

-- STORED PROCEDURES

-- Q01. Create A Procedure InsertOrederDetails  takes OrderID, ProductID, UnitPrice, Quantity, Discount
--        as input parameters and inserts that order information in the order details table.

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL = NULL,
    @Quantity INT,
    @Discount DECIMAL = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitsInStock INT, @ReorderLevel INT;

    -- Check if UnitPrice is NULL, if yes, fetch UnitPrice from Product table
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @UnitPrice = UnitPrice
        FROM Products
        WHERE ProductID = @ProductID;
    END;

    -- Retrieve UnitsInStock and ReorderLevel for the product
    SELECT @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel
    FROM Products
    WHERE ProductID = @ProductID;

    -- Check if there is enough stock available
    IF @Quantity > @UnitsInStock
    BEGIN
        PRINT 'Not enough stock available. Order aborted.';
        RETURN;
    END;

    -- Insert order details into OrderDetails table
    INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    -- Check if the order was inserted properly
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END;

    -- Update UnitsInStock after successful order insertion
    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;

    -- Check if UnitsInStock drops below ReorderLevel
    IF @UnitsInStock - @Quantity < @ReorderLevel
    BEGIN
        PRINT 'Warning: Quantity in stock dropped below Reorder Level.';
    END;

    PRINT 'Order placed successfully.';
END;


-- Q02. Create a procedure updateOrderDetails.

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQuantity INT, @UnitsInStock INT;

    -- Retrieve the old quantity from OrderDetails
    SELECT @OldQuantity = Quantity
    FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- If Quantity parameter is NULL, retain the old value
    SET @Quantity = ISNULL(@Quantity, @OldQuantity);

    -- Update OrderDetails with the provided parameters
    UPDATE OrderDetails
    SET UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        Quantity = @Quantity,
        Discount = ISNULL(@Discount, Discount)
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    -- Update UnitsInStock in Products table
    SELECT @UnitsInStock = UnitsInStock
    FROM Products
    WHERE ProductID = @ProductID;

    -- Adjust UnitsInStock based on the change in quantity
    UPDATE Products
    SET UnitsInStock = UnitsInStock + @OldQuantity - @Quantity
    WHERE ProductID = @ProductID;

    PRINT 'Order details updated successfully.';
END;

-- Q03. Create a Procedure GetOrderDetails That takes orderID as input parameter and returns all the records for the orderID.

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordCount INT;

    -- Check if records exist for the given OrderID
    SELECT @RecordCount = COUNT(*)
    FROM OrderDetails
    WHERE OrderID = @OrderID;

    IF @RecordCount = 0
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN 1;
    END;

    -- If records exist, return the details for the given OrderID
    SELECT *
    FROM OrderDetails
    WHERE OrderID = @OrderID;
END;



-- Q04. Create a procedure DeleteOrderDetails that takes OrderID and ProductID and deletes that from order details table.
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordCount INT;

    -- Check if the OrderID exists in the OrderDetails table
    SELECT @RecordCount = COUNT(*)
    FROM OrderDetails
    WHERE OrderID = @OrderID;

    IF @RecordCount = 0
    BEGIN
        PRINT 'Invalid OrderID. OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN -1;
    END;

    -- Check if the ProductID exists in the given OrderID
    SELECT @RecordCount = COUNT(*)
    FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    IF @RecordCount = 0
    BEGIN
        PRINT 'Invalid ProductID. ProductID ' + CAST(@ProductID AS VARCHAR(10)) + ' does not exist in OrderID ' + CAST(@OrderID AS VARCHAR(10)) + '.';
        RETURN -1;
    END;

    -- Delete the record from OrderDetails table
    DELETE FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order details for OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' and ProductID ' + CAST(@ProductID AS VARCHAR(10)) + ' deleted successfully.';
END;



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------




-- FUNCTIONS

-- Q001. Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY. 
--        For example if I pass in '2006-11-21 23:34:05.920', the output of the functions should be 11/21/2006

CREATE FUNCTION ConvertedDate (@inputDate DATETIME)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @convertDate VARCHAR(10);
    SET @convertDate = CONVERT(VARCHAR(20), @inputDate, 101);
    RETURN @convertDate;
END;

SELECT dbo.ConvertedDate('2006-11-21 23:34:05.920') AS [Converted Date];

-- Q002. Create a function that takes an input parameter type datetime and returns the date in the format YYYYMMDD.

CREATE FUNCTION ConvertedDateYYYYMMDD (@inputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    DECLARE @convertDate VARCHAR(8);
    SET @convertDate = CONVERT(VARCHAR(8), @inputDate, 112);
    RETURN @convertDate;
END;

SELECT dbo.ConvertedDateYYYYMMDD('2006-11-21 23:34:05.920') AS FormattedDate;




-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------


-- VIEWS

-- Q0001. Create a view vwCustomerOrders which returns CompanyName, OrderID, OrderDate, ProductID,Product Name, 
--        Quantity, UnitPrice, Quantity * od. UnitPrice

CREATE VIEW vwCustomerOrders AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS TotalPrice
FROM 
    Sales.Customer AS c
JOIN 
    Sales.OrderHeader AS o ON c.CustomerID = o.CustomerID
JOIN 
    Sales.OrderDetail AS od ON o.OrderID = od.OrderID
JOIN 
    Production.Product AS p ON od.ProductID = p.ProductID;


-- Q0002. Create a copy of the above view and modify it so that it only returns the above information for orders
--        that were placed yesterday

CREATE VIEW vwCustomerYesterdayOrders AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS TotalPrice
FROM 
    Sales.Customer AS c
JOIN 
    Sales.OrderHeader AS o ON c.CustomerID = o.CustomerID
JOIN 
    Sales.OrderDetail AS od ON o.OrderID = od.OrderID
JOIN 
    Production.Product AS p ON od.ProductID = p.ProductID
WHERE 
    o.OrderDate = CONVERT(date, GETDATE() - 1);


-- Q0003. Use a CREATE VIEW statement to create a view called MyProducts. Your view should contain the ProductID, Product Name,
--        QuantityPerUnit and UnitPrice columns from the Products table. It should also contain the CompanyName column from the
--        Suppliers table and the CategoryName column from the Categories table. Your view should only contain products that are
--        not discontinued.

CREATE VIEW MyProducts AS
SELECT
    p.ProductID,
    p.ProductName,
    p.QuantityPerUnit,
    p.UnitPrice,
    s.CompanyName,
    c.CategoryName
FROM
    Products AS p
JOIN
    Suppliers AS s ON p.SupplierID = s.SupplierID
JOIN
    Categories AS c ON p.CategoryID = c.CategoryID
WHERE
    p.Discontinued = 0;



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

-- TRIGGERS

--Q00001. --If someone cancels an order in northwind database, then you want to delete that order from the Orders table.
         --But you will not be able to delete that Order before deleting the records from Order Details table for that 
         --particular order due to referential integrity constraints. Create an Instead of Delete trigger on Orders table
         --so that if some one tries to delete an Order that trigger gets fired and that trigger should first delete everything
         --in order details table and then delete that order from the Orders table.
		 

CREATE TRIGGER trg_InsteadOfDeleteOnOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM OrderDetails
    WHERE OrderID IN (SELECT OrderID FROM deleted);
    
    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM deleted);
END;


/* Q00002. When an order is placed for X units of product Y, we must first check the Products table to ensure that there
          is sufficient stock to fill the order. This trigger will operate on the Order Details table. If sufficient stock exists,
          then fill the order and decrement X units from the UnitsInStock column in Products. If insufficient stock exists, then
          refuse the order (ie. do not insert it) and notify the user that the order could not be filled because of insufficient stock.*/


CREATE TRIGGER trg_InsteadOfInsertOrderDetails
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT;
    DECLARE @Quantity INT;
    DECLARE @UnitsInStock INT;

    -- Loop through each row in the inserted pseudo-table
    DECLARE inserted_cursor CURSOR FOR
    SELECT ProductID, Quantity
    FROM inserted;

    OPEN inserted_cursor;

    FETCH NEXT FROM inserted_cursor INTO @ProductID, @Quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check the stock for the product
        SELECT @UnitsInStock = UnitsInStock
        FROM Products
        WHERE ProductID = @ProductID;

        -- If there is enough stock, proceed with the insert and decrement stock
        IF @UnitsInStock >= @Quantity
        BEGIN
            -- Insert the order detail
            INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
            SELECT OrderID, ProductID, UnitPrice, Quantity, Discount
            FROM inserted
            WHERE ProductID = @ProductID AND Quantity = @Quantity;

            -- Update the stock
            UPDATE Products
            SET UnitsInStock = UnitsInStock - @Quantity
            WHERE ProductID = @ProductID;
        END
        ELSE
        BEGIN
            -- Notify the user about insufficient stock
            RAISERROR ('Insufficient stock for ProductID %d. Available: %d, Requested: %d.', 16, 1, @ProductID, @UnitsInStock, @Quantity);
        END

        FETCH NEXT FROM inserted_cursor INTO @ProductID, @Quantity;
    END

    CLOSE inserted_cursor;
    DEALLOCATE inserted_cursor;
END;
