CREATE TABLE Production.WorkOrderHst
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(10),
    ModifiedDate DATETIME,
    SourceID INT,
    UserName NVARCHAR(40)
);
GO

CREATE TRIGGER Production.WorkOrder_IUD
    ON Production.WorkOrder
    AFTER INSERT, UPDATE, DELETE AS
BEGIN
    INSERT INTO Production.WorkOrderHst
    (
        Action,
        ModifiedDate,
        SourceID,
        UserName
    )
    SELECT
        CASE
            WHEN inserted.WorkOrderID IS NOT NULL
            AND deleted.WorkOrderID IS NOT NULL
                THEN 'UPDATE'
            WHEN inserted.WorkOrderID IS NOT NULL
                THEN 'INSERT'
            WHEN deleted.WorkOrderID IS NOT NULL
                THEN 'DELETE'
            ELSE
                NULL
        END,
        GETDATE(),
        ISNULL(deleted.WorkOrderID, inserted.WorkOrderID),
        CURRENT_USER
    FROM inserted
        FULL JOIN deleted
        ON inserted.WorkOrderID = deleted.WorkOrderID;
END;
GO

CREATE VIEW Production.vWorkOrder AS
    SELECT * FROM Production.WorkOrder;
GO


INSERT INTO Production.vWorkOrder
    (OrderQty, ProductID, ScrappedQty, StartDate, DueDate) VALUES (10000, 1, 1, GETDATE(), GETDATE());

UPDATE Production.vWorkOrder
    SET StartDate = GETDATE(), EndDate = GETDATE()
    WHERE OrderQty = 10000;

DELETE FROM Production.vWorkOrder
    WHERE OrderQty = 10000;
GO

DROP VIEW Production.vWorkOrder;
GO

SELECT * FROM Production.WorkOrderHst;
GO

DROP TRIGGER Production.ProductCategory_IUD;
GO
