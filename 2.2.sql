SELECT TOP 0 
	AddressID,
	AddressLine1,
	AddressLine2,
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate
INTO dbo.Address
FROM AdventureWorks2012.Person.Address

ALTER TABLE dbo.Address  
ADD CONSTRAINT PK_StateProvinceId_PostalCode PRIMARY KEY (StateProvinceId, PostalCode); 

 ALTER TABLE dbo.Address  
ADD CONSTRAINT CheckAddress Check (PostalCode not like '%[a-zA-Z]%'); 

insert into dbo.Address (StateProvinceID, City, AddressLine1, PostalCode) 
values (1, '1', '1', '2')

ALTER TABLE dbo.Address  
ADD CONSTRAINT def 
DEFAULT CURRENT_TIMESTAMP FOR ModifiedDate;  

insert into dbo.Address 
select 
	AddressLine1,
	AddressLine2,
	City,
	StateProvinceID,
	PostalCode,
	ModifiedDate
	from (
	Select address.* , row_number() over(partition by province.StateProvinceId, address.PostalCode order by AddressId desc) as numb
		from Person.Address as address
	inner join Person.StateProvince as province on province.StateProvinceID = address.StateProvinceID
	where province.CountryRegionCode = 'US' and PostalCode not like '%[a-zA-Z]%' ) as innerTable where innerTable.numb = 1

Alter table dbo.Address
Alter column City nvarchar(5)
