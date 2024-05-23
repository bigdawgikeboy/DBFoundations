--*************************************************************************--
-- Title: Assignment06
-- Author: IsaacKareiva
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024 05/22,IsaacKareiva,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_IsaacKareiva')
	 Begin 
	  Alter Database [Assignment06DB_IsaacKareiva] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_IsaacKareiva;
	 End
	Create Database Assignment06DB_IsaacKareiva;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_IsaacKareiva;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


go -- one view per batch
Create 
View vCategories
WITH SCHEMABINDING -- add schema binding
AS 
 Select CategoryID, CategoryName
 From dbo.Categories;

go
Create 
View vProducts
WITH SCHEMABINDING 
AS 
 Select ProductID, ProductName, CategoryID, UnitPrice
 From dbo.Products;

go
Create 
View vInventories
WITH SCHEMABINDING 
AS 
 Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
 From dbo.Inventories;

go
Create 
View vEmployees
WITH SCHEMABINDING 
AS 
 Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
 From dbo.employees;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?


Deny Select On Categories to Public; -- deny acces to original table
Grant Select On vCategories to Public; --grant access to views

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- this essentially amounts to just creating a view for the correct select statement

-- this is the basic select statement
select CategoryName, ProductName, UnitPrice
From vCategories join vProducts -- use base views here
	on vCategories.CategoryID = vProducts.CategoryID  -- this is what links the tables

-- this is doing it as a view
go
create view vProductsByCategories as
	select CategoryName, ProductName, UnitPrice
	From vCategories join vProducts 
		on vCategories.CategoryID = vProducts.CategoryID  

-- and then we add the order by for the final correct statement
go
alter view vProductsByCategories as
	select top 1000000 CategoryName, ProductName, UnitPrice --add a very large number
	From vCategories join vProducts 
		on vCategories.CategoryID = vProducts.CategoryID  
order by CategoryName, ProductName, UnitPrice

go
select * from vProductsByCategories

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

go
create view vInventoriesByProductsByDates  as
	select top 10000000 ProductName, [Count], InventoryDate
	From vProducts join vInventories
		on vProducts.ProductID = vInventories.ProductID
order by ProductName, InventoryDate, [Count]

go
select * from vInventoriesByProductsByDates

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- the below creates the basic structure for the view
go
create view vInventoriesByEmployeesByDates as
	select top 100000000 InventoryDate, EmployeeFirstName
	From vInventories join vEmployees
		on vInventories.EmployeeID = vEmployees.EmployeeID

		go
select * from vInventoriesByEmployeesByDates

-- but we see that we need to (1) have just one employee per date, (2) we would like to combine first and last name

go
alter view vInventoriesByEmployeesByDates as
	select distinct top 100000000 InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName   -- add the distinct here and do full names
	From vInventories join vEmployees
		on vInventories.EmployeeID = vEmployees.EmployeeID

go
select * from vInventoriesByEmployeesByDates


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- we can basically re-use our code from the last assignment here but make it as a view 
-- (and make sure we are building it on top of basic veiws)

go
create view vInventoriesByProductsByCategories as
Select top 1000000
	CategoryName,
	ProductName,
	InventoryDate,
	[count]
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Inner Join Categories
		On Categories.CategoryID = vProducts.CategoryID
Order by CategoryName, ProductName, InventoryDate, [count]

go
select * from vInventoriesByProductsByCategories 

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!


-- and again re-using our code from last assignment
go
create view vInventoriesByProductsByEmployees as
Select top 1000000
	CategoryName,
	ProductName,
	InventoryDate,
	[count],
	vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName as EmployeeName
From vInventories
	Inner Join vEmployees
		On vInventories.EmployeeID = vEmployees.EmployeeID
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Inner Join vCategories
		On vCategories.CategoryID = vProducts.CategoryID
Order by 3,1,2,4

go
select * from vInventoriesByProductsByEmployees




-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 


--and again just wrapping a view clause around code from last assignment (while also again using base views)
go
create view vInventoriesForChaiAndChangByEmployees as
Select top 10000000
	CategoryName,
	ProductName,
	InventoryDate,
	[count],
	vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName as EmployeeName
From vInventories
	Inner Join vEmployees
		On vInventories.EmployeeID = vEmployees.EmployeeID
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Inner Join vCategories
		On vCategories.CategoryID = vProducts.CategoryID  --we just insiert a where subquery here to filter results
Where vInventories.ProductID in
	(Select ProductID From vProducts
		Where ProductName in ('Chai','Chang')
	)
Order by 3,1,2,4

go
select * from vInventoriesForChaiAndChangByEmployees

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

go
create view vEmployeesByManager as
Select top 10000 
	M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
From vEmployees as E Inner Join vEmployees as M  
	On E.ManagerID = M.EmployeeID  
ORder by 1,2

go
select * from vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- the below code joins the four base tables
go
create view vBases as 
select top 10000000
	vCategories.CategoryID
	, CategoryName
	, vProducts.ProductID
	, ProductName
	, UnitPrice
	, InventoryID 
	, InventoryDate
	, [Count]
	, vEmployees.EmployeeID
	, EmployeeFirstNAme + ' ' + EmployeeLastName as Employee
From vInventories 
	join vEmployees
		on vInventories.EmployeeID = vEmployees.EmployeeID
	join vProducts
		on vInventories.ProductID = vProducts.ProductID
	join vCategories
		on vProducts.CategoryID = vCategories.CategoryID
order by CategoryName, ProductName, InventoryID, Employee

go
select * from vBases

-- now the trick is to join to this the table from the last question,
-- which we do by joining form the 'employee' field
go
create view vInventoriesByProductsByCategoriesByEmployees as
	select top 1000000 
	CategoryID
	, CategoryName
	, ProductID
	, ProductName
	, UnitPrice
	, InventoryID 
	, InventoryDate
	, [Count]
	, EmployeeID
	, vBases.Employee
	, Manager
	from vBases join vEmployeesByManager
		on vBases.Employee = vEmployeesByManager.Employee
order by CategoryName, ProductName, InventoryID, Employee

go
select * from vInventoriesByProductsByCategoriesByEmployees


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/