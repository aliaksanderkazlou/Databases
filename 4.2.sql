CREATE VIEW Production.vProductWorkOrder
    WITH ENCRYPTION, SCHEMABINDING
    AS SELECT
        workOrder.WorkOrderID,
		workOrder.ProductID as productId,
		workOrder.OrderQty as orderQty,
		workOrder.StockedQty as stokedQty,
		workOrder.ScrappedQty as screppedQty,
		workOrder.StartDate as startDate,
		workOrder.EndDate as endDate,
		workOrder.DueDate as dueDate,
		workOrder.ScrapReasonID,
		workOrder.ModifiedDate as workOrderModifiedDate,
		scrapReason.ModifiedDate as scrapReasonModifiedDate,
		scrapReason.Name as scrapReasonName,
		scrapReason.ScrapReasonID as scrapReasonId,
		product.Name as productName
    FROM
        Production.WorkOrder AS workOrder 
			INNER JOIN 
				Production.ScrapReason AS scrapReason ON scrapReason.ScrapReasonID = workOrder.ScrapReasonID
			INNER JOIN  
				Production.Product AS product ON product.ProductID = workOrder.ProductID
GO

CREATE UNIQUE CLUSTERED INDEX IX_vProductWorkOrder
    ON Production.vProductWorkOrder (WorkOrderId);
GO

DROP TRIGGER Production.vProductWorkOrder_IOI

CREATE TRIGGER Production.vProductWorkOrder_IOI on Production.vProductWorkOrder
INSTEAD OF INSERT
AS
BEGIN TRANSACTION
    SET IDENTITY_INSERT Production.WorkOrder ON;
    INSERT INTO Production.WorkOrder
        (
            WorkOrderID,
			ProductID,
			OrderQty,
			ScrappedQty,
			StartDate,
			EndDate,
			DueDate,
			ScrapReasonID,
			ModifiedDate
        )
        SELECT
			WorkOrderID,
            productId,
            orderQty,
            screppedQty,
			startDate,
			endDate,
			dueDate,
			scrapReasonId,
			workOrderModifiedDate
        FROM inserted
    SET IDENTITY_INSERT Production.ProductCategory OFF;


    SET IDENTITY_INSERT Production.ScrapReason ON;
    INSERT INTO Production.ScrapReason
        (
            ScrapReasonID,
			Name,
			ModifiedDate
        )
        SELECT
            scrapReasonId,
			scrapReasonName,
			scrapReasonModifiedDate
        FROM inserted
    SET IDENTITY_INSERT Production.ProductSubcategory OFF;
COMMIT;
GO



DROP VIEW Production.vProductWorkOrder;
GO