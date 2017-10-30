Use NewDatabase;
Go
Create Schema sales;
Go
Create Schema persons;
Go
CREATE TABLE sales.Orders (OrderNum INT NULL);

BACKUP DATABASE NewDatabase 
TO DISK = 'D:\NewDatabase.BAK'
GO

Use master;
Go
Drop Database NewDatabase;
Go

RESTORE Database NewDatabase FROM DISK='d:\NewDatabase.bak'