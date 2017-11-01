DECLARE @persons XML = (
	SELECT BusinessEntityID AS "@id", FirstName, LastName
    FROM Person.Person
    FOR XML PATH ('Person'), ROOT ('Person')
);

SELECT @persons AS RESULT;

SELECT
    t.col.value('@id', 'int') as BusinessEntityID,
    t.col.value('FirstName[1]', 'NVARCHAR(50)') as FirstName,
    t.col.value('LastName[1]', 'NVARCHAR(50)') as LastName
INTO #TempPerson
FROM @persons.nodes('/Person/Person') as t(col);

SELECT * FROM #TempPerson;

DROP TABLE #TempPerson;
GO