--checking the contents of the respective tables before executing the task queries
select * from HumanResources.Employee;
select * from HumanResources.vEmployee;
select * from Sales.Customer;
select * from Person.Person;

--	QUERIES FOR TASK 01 : WEEK 01 --

--1. List of all customers
SELECT CustomerID, PersonType, Title, FirstName, MiddleName, LastName, Suffix, CompanyName
FROM Sales.Customer;

--2. list of all customers where company name ending in N
SELECT CustomerID, PersonType, Title, FirstName, MiddleName, LastName, Suffix, CompanyName
FROM Sales.Customer
WHERE CompanyName LIKE '%N';

--3. list of all customers who live in Berlin or London
SELECT CustomerID, PersonType, Title, FirstName, MiddleName, LastName, Suffix, City
FROM Sales.Customer
WHERE City IN ('Berlin', 'London');

--4. list of all customers who live in UK or USA
SELECT CustomerID, PersonType, Title, FirstName, MiddleName, LastName, Suffix, CountryRegionName
FROM Sales.Customer
WHERE CountryRegionName IN ('United Kingdom', 'United States');

--5. list of all products sorted by product name
SELECT ProductID, Name
FROM Production.Product
ORDER BY Name;

--6. list of all products where product name starts with an A
SELECT ProductID, Name
FROM Production.Product
WHERE Name LIKE 'A%';

--7. List of customers who ever placed an order
SELECT DISTINCT c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID;

--8. list of Customers who live in London and have bought chai
SELECT c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE c.City = 'London' AND p.Name = 'Chai';

--9. List of customers who never place an order
SELECT c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix
FROM Sales.Customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderHeader so
    WHERE c.CustomerID = so.CustomerID
);

--10. List of customers who ordered Tofu
SELECT c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

--11. Details of first order of the system
SELECT c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix, COUNT(so.SalesOrderID) AS NumOrders
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix;

--12. Find the details of most expensive order date
SELECT TOP 1 so.OrderDate, SUM(sod.LineTotal) AS TotalAmount
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
GROUP BY so.OrderDate
ORDER BY TotalAmount DESC;

--13. For each order get the OrderID and Average quantity of items in that order
SELECT so.SalesOrderID, AVG(sod.OrderQty) AS AvgQuantity
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
GROUP BY so.SalesOrderID;

--14. For each order get the orderID, minimum quantity and maximum quantity for that order
SELECT so.SalesOrderID, MIN(sod.OrderQty) AS MinQuantity, MAX(sod.OrderQty) AS MaxQuantity
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
GROUP BY so.SalesOrderID;

--15. Get a list of all managers and total number of employees who report to them.
SELECT e.ManagerID, m.FirstName AS ManagerFirstName, m.LastName AS ManagerLastName, COUNT(*) AS NumEmployees
FROM HumanResources.Employee e
INNER JOIN HumanResources.Employee m ON e.ManagerID = m.EmployeeID
GROUP BY e.ManagerID, m.FirstName, m.LastName;

--16. Get the OrderID and the total quantity for each order that has a total quantity of greater than 300
SELECT so.SalesOrderID, SUM(sod.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
GROUP BY so.SalesOrderID
HAVING SUM(sod.OrderQty) > 300;

--17. list of all orders placed on or after 1996/12/31
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';

--18. list of all orders shipped to Canada
SELECT SalesOrderID, ShipCountry
FROM Sales.SalesOrderHeader
WHERE ShipCountry = 'Canada';

--19. list of all orders with order total > 200
SELECT SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > '200';

--20. List of countries and sales made in each country
SELECT CountryRegionCode, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY CountryRegionCode;

--21. List of Customer ContactName and number of orders they placed
SELECT c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix, COUNT(so.SalesOrderID) AS NumOrders
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.PersonType, c.Title, c.FirstName, c.MiddleName, c.LastName, c.Suffix;

--22. List of customer contactnames who have placed more than 3 orders
SELECT c.ContactName, COUNT(so.SalesOrderID) AS NumOrders
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
GROUP BY c.ContactName
HAVING COUNT(so.SalesOrderID) > 3;

--23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998
SELECT p.ProductID, p.Name AS ProductName
FROM Production.Product p
INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
INNER JOIN Sales.SalesOrderHeader so ON sod.SalesOrderID = so.SalesOrderID
WHERE p.DiscontinuedDate BETWEEN '1997-01-01' AND '1998-01-01';

--24. List of employee firsname, lastName, superviser FirstName, LastName
SELECT e.FirstName, e.LastName, m.FirstName AS SupervisorFirstName, m.LastName AS SupervisorLastName
FROM HumanResources.Employee e
LEFT JOIN HumanResources.Employee m ON e.ManagerID = m.EmployeeID;

--25. List of Employees id and total sale condcuted by employee
SELECT e.EmployeeID, SUM(so.TotalDue) AS TotalSales
FROM HumanResources.Employee e
INNER JOIN Sales.SalesOrderHeader so ON e.EmployeeID = so.SalesPersonID
GROUP BY e.EmployeeID;

--26. list of employees whose FirstName contains character a
SELECT EmployeeID, FirstName, LastName
FROM HumanResources.Employee
WHERE FirstName LIKE '%a%';

--27. List of managers who have more than four people reporting to them.
SELECT m.EmployeeID, m.FirstName AS ManagerFirstName, m.LastName AS ManagerLastName, COUNT(e.EmployeeID) AS NumReports
FROM HumanResources.Employee m
LEFT JOIN HumanResources.Employee e ON m.EmployeeID = e.ManagerID
GROUP BY m.EmployeeID, m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) > 4;

--28. List of Orders and ProductNames
SELECT so.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID;

--29. List of orders place by the best customer
-- Replace 'YourCriteriaHere' with the actual criteria for the best customer
SELECT so.SalesOrderID, c.CustomerID, c.ContactName
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.Customer c ON so.CustomerID = c.CustomerID
WHERE c.CustomerID = 'YourCriteriaHere';

--30. List of orders placed by customers who do not have a Fax number
SELECT so.SalesOrderID, c.CustomerID, c.ContactName
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.Customer c ON so.CustomerID = c.CustomerID
WHERE c.Fax IS NULL;

--31. List of Postal codes where the product Tofu was shipped
SELECT DISTINCT so.PostalCode
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

--32. List of product Names that were shipped to France
SELECT DISTINCT p.Name AS ProductName
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE so.ShipCountry = 'France';

--33. List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.
SELECT p.Name AS ProductName, c.Name AS CategoryName
FROM Production.Product p
INNER JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
WHERE p.ProductID IN (
    SELECT ProductID
    FROM Purchasing.ProductVendor
    WHERE BusinessEntityID IN (
        SELECT BusinessEntityID
        FROM Purchasing.Vendor
        WHERE Name = 'Specialty Biscuits, Ltd.'
    )
);

--34. List of products that were never ordered
SELECT p.ProductID, p.Name AS ProductName
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--35. List of products where units in stock is less than 10 and units on order are 0.
SELECT p.ProductID, p.Name AS ProductName
FROM Production.Product p
WHERE p.UnitsInStock < 10 AND p.UnitsOnOrder = 0;

--36. List of top 10 countries by sales
SELECT CountryRegionCode, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY CountryRegionCode
ORDER BY TotalSales DESC
LIMIT 10;

--37. Number of orders each employee has taken for customers with Customerle between A and A0
SELECT e.EmployeeID, e.FirstName, e.LastName, COUNT(SalesOrderID) AS NumOrders
FROM HumanResources.Employee e
INNER JOIN Sales.SalesOrderHeader so ON e.EmployeeID = so.SalesPersonID
INNER JOIN Sales.Customer c ON so.CustomerID = c.CustomerID
WHERE c.CustomerID BETWEEN 'A' AND 'A0'
GROUP BY e.EmployeeID, e.FirstName, e.LastName;

--38. Orderdate of most expensive order
SELECT TOP 1 so.OrderDate
FROM Sales.SalesOrderHeader so
INNER JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
ORDER BY sod.LineTotal DESC;

--39. Product name and total revenue from that product
SELECT p.Name AS ProductName, SUM(sod.LineTotal) AS TotalRevenue
FROM Production.Product p
INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name;

--40. Supplierid and number of products offered
SELECT pv.BusinessEntityID AS SupplierID, COUNT(DISTINCT pv.ProductID) AS NumProductsOffered
FROM Purchasing.ProductVendor pv
GROUP BY pv.BusinessEntityID;

--41. Top ten customers based on their business
-- Replace 'YourCriteriaHere' with the actual criteria for the top customers
SELECT c.CustomerID, c.ContactName, SUM(so.TotalDue) AS TotalBusiness
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.ContactName
ORDER BY TotalBusiness DESC
LIMIT 10;

--42. What is the total revenue of the company.
SELECT SUM(TotalDue) AS CompanyRevenue
FROM Sales.SalesOrderHeader;
