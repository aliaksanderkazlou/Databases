Select DepartmentID, Name from AdventureWorks2012.HumanResources.Department
where Name like 'P%'

Select BusinessEntityID, JobTitle, Gender, VacationHours, SickLeaveHours from AdventureWorks2012.HumanResources.Employee
where VacationHours Between 10 and 13

Select BusinessEntityID, JobTitle, Gender, BirthDate, HireDate from AdventureWorks2012.HumanResources.Employee
where day(HireDate) in (1)
order by BusinessEntityID asc
OFFSET     3 ROWS       
FETCH NEXT 5 ROWS ONLY;