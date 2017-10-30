ALTER TABLE dbo.Address ADD
	AddressType nvarchar(50)
GO

DECLARE @Address Table
(
	AddressId INT PRIMARY KEY,
	AddressLine1 NVARCHAR(60),
	AddressLine2 NVARCHAR(60),
	City NVARCHAR(20),
	StateProvinceID INT,
	PostalCode NVARCHAR(15),
	ModifiedDate DATETIME,
	AddressType NVARCHAR(50)
);

INSERT INTO @Address (AddressId, AddressLine1, AddressLine2, City, StateProvinceID, PostalCode, ModifiedDate, AddressType)
SELECT
	dbo.Address.AddressID,
	AddressLine1,
	AddressLine2,
	City,
	StateProvinceID,
	PostalCode,
	dbo.Address.ModifiedDate,
	Person.AddressType.Name
FROM dbo.Address
	INNER JOIN Person.BusinessEntityAddress
		ON dbo.Address.AddressID = Person.BusinessEntityAddress.AddressID
	INNER JOIN Person.AddressType
		ON Person.BusinessEntityAddress.AddressTypeID = Person.AddressType.AddressTypeID

SELECT * FROM @Address

UPDATE dbo.Address
SET 
	AddressType = tmp.AddressType,
	AddressLine2 = CASE WHEN dbo.Address.AddressLine2 IS NULL THEN dbo.Address.AddressLine1 ELSE dbo.Address.AddressLine2 END 
FROM @Address tmp
	WHERE tmp.AddressId = dbo.Address.AddressID

SELECT * FROM dbo.Address

DELETE x FROM (
  SELECT *, rn=row_number() OVER (PARTITION BY AddressType ORDER BY AddressID)
  FROM dbo.Address  
) x
WHERE rn > 1;

SELECT * FROM dbo.Address

ALTER TABLE dbo.Address DROP
    COLUMN AddressType;
GO


DECLARE @ConstraintQuery VARCHAR(MAX);
DECLARE @ConstraintName SYSNAME;

DECLARE cur CURSOR LOCAL FOR
    SELECT QUOTENAME(CONSTRAINT_NAME) as ConstraintName
        FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Address'
    UNION SELECT QUOTENAME(sys.default_constraints.name) as ConstraintName
        FROM sys.all_columns
            INNER JOIN sys.tables
            ON sys.all_columns.object_id = sys.tables.object_id

            INNER JOIN sys.schemas
            ON sys.tables.schema_id = sys.schemas.schema_id

            INNER JOIN sys.default_constraints
            ON sys.all_columns.default_object_id = sys.default_constraints.object_id
        WHERE
            sys.schemas.name = 'dbo' AND sys.tables.name = 'Address';

OPEN cur;

FETCH NEXT FROM cur INTO @ConstraintName;

WHILE @@FETCH_STATUS = 0 BEGIN
    IF (@ConstraintQuery IS NULL OR @ConstraintQuery = '')
        SET @ConstraintQuery = 'ALTER TABLE dbo.Address DROP CONSTRAINT ' + @ConstraintName
    ELSE
        SET @ConstraintQuery = @ConstraintQuery + ', ' + @ConstraintName;

    FETCH NEXT FROM cur INTO @ConstraintName;
END;

CLOSE cur;
DEALLOCATE cur;

EXEC(@ConstraintQuery);
GO

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Address';

DROP TABLE dbo.Address;
GO
