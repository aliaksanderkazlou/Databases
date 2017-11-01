CREATE FUNCTION dbo.getLineTotalSum(@orderID INT) RETURNS INT
BEGIN
    RETURN (
        SELECT SUM(LineTotal)
        FROM Purchasing.PurchaseOrderDetail
        WHERE PurchaseOrderID = @orderID
    )
END;
GO

SELECT dbo.getLineTotalSum(1) as sum;
GO

CREATE FUNCTION dbo.topOrders(@customerId INT, @stringCount INT) RETURNS TABLE
AS
RETURN
    (
        SELECT TOP (@stringCount) Sales.SalesOrderHeader.* FROM Sales.SalesOrderHeader
		WHERE Sales.SalesOrderHeader.CustomerID = @customerId
		ORDER BY TotalDue DESC
    );
GO

DROP FUNCTION dbo.topOrders;
GO

SELECT * FROM (
    SELECT CustomerID FROM Sales.Customer
) as customer
CROSS APPLY dbo.topOrders(customer.CustomerID, 3);
GO

SELECT * FROM (
    SELECT CustomerID FROM Sales.Customer
) as customer
OUTER APPLY dbo.topOrders(customer.CustomerID, 3)
GO


CREATE FUNCTION dbo.topOrders(@customerId INT, @stringCount INT)
RETURNS @TopOrder TABLE (
    CustomerID INT,
    OrderID INT,
    TotalDue INT
)
AS
BEGIN
    INSERT INTO @TopOrder 
    SELECT TOP (@stringCount) Sales.SalesOrderHeader.CustomerID, Sales.SalesOrderHeader.SalesOrderID, Sales.SalesOrderHeader.TotalDue  FROM Sales.SalesOrderHeader
		WHERE Sales.SalesOrderHeader.CustomerID = @customerId
		ORDER BY TotalDue DESC
    RETURN;
END;
GO

SELECT * FROM dbo.topOrders(29825, 2);
GO
