select employee.BusinessEntityID, JobTitle, department.DepartmentID,  department.Name 
from AdventureWorks2012.HumanResources.Department as department
inner join AdventureWorks2012.HumanResources.EmployeeDepartmentHistory as history
	on Department.DepartmentID = history.DepartmentID
inner join AdventureWorks2012.HumanResources.Employee as employee
	on history.BusinessEntityID = Employee.BusinessEntityID
where year(history.ModifiedDate) = year(DATEADD(year,-14,getdate()))


select department.DepartmentID, Name, COUNT(*) as EmpCount from HumanResources.Employee as employee
inner join HumanResources.EmployeeDepartmentHistory as history 
	on history.BusinessEntityID = employee.BusinessEntityID
inner join HumanResources.Department as department 
	on history.DepartmentID = department.DepartmentID
where EndDate is null
group by department.DepartmentID, department.Name

select 
	employee.JobTitle, 
	payHistory.Rate,
	payHistory.RateChangeDate, 
	CONCAT('The rate for ', employee.JobTitle, ' was set to ', payHistory.Rate, ' at ', payHistory.RateChangeDate) as Report
from HumanResources.Employee as employee
inner join HumanResources.EmployeePayHistory as payHistory on payHistory.BusinessEntityID = employee.BusinessEntityID

