USE AdventureWorks2012;
GO

CREATE PROCEDURE dbo.SubCategoriesByClass
	@classes NVARCHAR(MAX)
AS
	EXEC(
		'SELECT Name, ' + @classes + ' FROM
		(
			SELECT Production.ProductSubcategory.Name, ListPrice, Class as Classes
			FROM Production.ProductSubcategory
			INNER JOIN Production.Product
            ON Production.ProductSubcategory.ProductSubCategoryID = Production.Product.ProductSubCategoryID
		) AS src
		PIVOT
        (
            AVG(ListPrice) FOR Classes IN (' + @classes +')
        ) AS PIV'	
	);
GO

DROP PROCEDURE dbo.SubCategoriesByClass;
GO

EXECUTE dbo.SubCategoriesByClass '[H],[L],[M]'