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
	DECLARE @ScrapReasonId INT

	INSERT INTO Production.ScrapReason
        (
			Name,
			ModifiedDate
        )
        SELECT
			scrapReasonName,
			scrapReasonModifiedDate
        FROM inserted

	SET @ScrapReasonId = SCOPE_IDENTITY()
	
    INSERT INTO Production.WorkOrder
        (
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
            product.ProductID,
            orderQty,
            screppedQty,
			startDate,
			endDate,
			dueDate,
			@ScrapReasonId
			workOrderModifiedDate
        FROM inserted
		INNER JOIN Product as product
			ON product.Name = inserted.productName
COMMIT;
GO

CREATE TRIGGER Production.vProductWorkOrder_IOU on Production.vProductWorkOrder
INSTEAD OF UPDATE
AS
BEGIN TRANSACTION
    UPDATE
        Production.WorkOrder
    SET
        ProductId = product.ProductID,
        ModifiedDate = inserted.workOrderModifiedDate,
		ScrappedQty = inserted.screppedQty,
		StartDate = inserted.startDate,
		EndDate = inserted.endDate,
		DueDate = inserted.dueDate
    FROM
        inserted
	INNER JOIN vProductWorkOrder as vWorkOrder
		ON vWorkOrder.productName = inserted.productName
	INNER JOIN Product as product
		ON product.Name = inserted.productName
    WHERE
        product.ProductID = WorkOrder.ProductID

    UPDATE
        Production.ScrapReason
    SET
        Name = inserted.scrapReasonName,
        ModifiedDate = inserted.scrapReasonModifiedDate
    FROM
        inserted
	INNER JOIN vProductWorkOrder as vWorkOrder
		ON vWorkOrder.productName = inserted.productName
    WHERE
        vWorkOrder.scrapReasonId = ScrapReason.ScrapReasonID
COMMIT;
GO

CREATE TRIGGER Production.vProductWorkOrder_IOD on Production.vProductWorkOrder
INSTEAD OF DELETE
AS
BEGIN TRANSACTION	
	DECLARE @name INT

	SELECT @name = productName FROM deleted
	
    DELETE Production.ScrapReason FROM Production.ScrapReason
	INNER JOIN vProductWorkOrder as vWorkOrder
		ON vWorkOrder.productName = @name
	INNER JOIN Production.WorkOrder as workOrder
		ON vWorkOrder.WorkOrderID = workOrder.WorkOrderID
	WHERE Production.ScrapReason.ScrapReasonID = workOrder.ScrapReasonID

	DELETE Production.WorkOrder FROM Production.WorkOrder
	INNER JOIN 
COMMIT;
GO




DROP VIEW Production.vProductWorkOrder;
GO