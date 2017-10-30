ALTER TABLE dbo.Address ADD
    CountryRegionCode NVARCHAR(3),
    TaxRate SMALLMONEY,
    DiffMin AS (TaxRate - 5.00);
GO

CREATE TABLE #Address
(
    AddressID INT PRIMARY KEY,
    AddressLine1 NCHAR(60),
    AddressLine2 NVARCHAR(60),
    City NVARCHAR(30),
    StateProvinceId INT,
    PostalCode NVARCHAR(15),
	ModifiedDate DATETIME,
    CountryRegionCode NVARCHAR(3),
    TaxRate SMALLMONEY,
);
GO

WITH Address_CTE (StateProvinceID, TaxRate)
AS (
	SELECT StateProvinceID, TaxRate
	FROM Sales.SalesTaxRate
	WHERE TaxRate > 5
)

INSERT INTO #Address (AddressID, AddressLine1, AddressLine2, City, StateProvinceId, PostalCode, ModifiedDate, CountryRegionCode, TaxRate)
SELECT
	dbo.Address.AddressID,
	AddressLine1,
	AddressLine2,
	City,
	dbo.Address.StateProvinceID,
	PostalCode,
	dbo.Address.ModifiedDate,
	Person.StateProvince.CountryRegionCode,
	Address_CTE.TaxRate
FROM dbo.Address
	INNER JOIN Address_CTE
		ON dbo.Address.StateProvinceID = Address_CTE.StateProvinceID
	INNER JOIN Person.StateProvince
		ON dbo.Address.StateProvinceID = Person.StateProvince.StateProvinceID

SELECT * FROM #Address

DELETE FROM #Address

DELETE TOP(1) FROM dbo.Address
	WHERE StateProvinceID = 36;
GO


SET IDENTITY_INSERT dbo.Address ON

MERGE dbo.Address as dest
    USING #Address AS src
        ON (dest.AddressID = src.AddressID)
WHEN MATCHED THEN
    UPDATE SET
        dest.CountryRegionCode = src.CountryRegionCode,
        dest.TaxRate = src.TaxRate
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        AddressID,
		AddressLine1,
		AddressLine2,
		City,
		StateProvinceId,
		PostalCode,
		ModifiedDate,
		CountryRegionCode,
		TaxRate
    )

    VALUES (
        src.AddressID,
		src.AddressLine1,
		src.AddressLine2,
		src.City,
		src.StateProvinceId,
		src.PostalCode,
		src.ModifiedDate,
		src.CountryRegionCode,
		src.TaxRate
    )
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT $action, inserted.*;

SET IDENTITY_INSERT dbo.Address OFF;
GO
