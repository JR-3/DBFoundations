--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-05-25,JRosenblum,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JRosenblum')
	 Begin 
	  Alter Database [Assignment06DB_JRosenblum] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JRosenblum;
	 End
	Create Database Assignment06DB_JRosenblum;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JRosenblum;

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

Create View vCategories 
With SCHEMABINDING 
As Select CategoryID, CategoryName 
From dbo.Categories 
Go

Create View vProducts 
With SCHEMABINDING
As Select ProductID, ProductName,CategoryID,UnitPrice
From dbo.Products
Go

Create View vInventories 
With SCHEMABINDING 
As Select InventoryID, InventoryDate, EmployeeID,ProductID,Count
From dbo.Inventories 
Go

Create View vEmployees 
With SCHEMABINDING
As Select EmployeeID, EmployeeFirstName,EmployeeLastName,ManagerID
From dbo.Employees
Go


Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories To Public;
Grant Select On vCategories To Public;
Go

Deny Select On dbo.Products To Public;
Grant Select On vProducts To Public;
Go

Deny Select On dbo.Inventories To Public;
Grant Select On vInventories To Public;
Go

Deny Select On dbo.Employees To Public;
Grant Select On vEmployees To Public;
Go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create view vProductsByCategories
As Select Top 100000 CategoryName, ProductName, UnitPrice 
From dbo.Products Join dbo.Categories
 On dbo.Products.CategoryID = dbo.Categories.CategoryID
Order By CategoryName, ProductName;
go

Select * From [dbo].[vProductsByCategories]
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create view vInventoriesByProductsByDates
As Select Top 100000 ProductName, InventoryDate, Count
From dbo.Products Join dbo.Inventories
 On dbo.Products.ProductID = dbo.Inventories.ProductID
Order By ProductName, InventoryDate,Count;
go

Select * From [dbo].[vInventoriesByProductsByDates]
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create view vInventoriesByEmployeesByDates
As Select Distinct Top 10000 InventoryDate, [Employee] = EmployeeFirstName + ' ' + EmployeeLastName
From dbo.Inventories Join dbo.Employees
 On dbo.Inventories.EmployeeID = dbo.Employees.EmployeeID
 Order by InventoryDate;
go

Select * From [dbo].[vInventoriesByEmployeesByDates]
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create view vInventoriesByProductsByCategories
As Select Top 10000 CategoryName, ProductName, InventoryDate, Count
From dbo.Categories 
Join dbo.Products
 On dbo.Categories.CategoryID = dbo.Products.CategoryID
Join Inventories
 On dbo.Products.ProductID = dbo.Inventories.ProductID
Order By CategoryName, ProductName, InventoryDate, Count;
go

Select * From [dbo].[vInventoriesByProductsByCategories]
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create view vInventoriesByProductsByEmployees
As Select Top 10000 CategoryName, ProductName, InventoryDate, Count, [Employee] = EmployeeFirstName + ' ' + EmployeeLastName
From dbo.Categories 
Join dbo.Products
	On dbo.Products.CategoryID = dbo.Categories.CategoryID
Join dbo.Inventories
	On dbo.Products.ProductID = dbo.Inventories.ProductID
Join dbo.Employees 
	On dbo.Inventories.EmployeeID = dbo.Employees.EmployeeID
Order By InventoryDate, CategoryName, ProductName, Employee;
go

Select * From [dbo].[vInventoriesByProductsByEmployees]
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create view vInventoriesForChaiAndChangByEmployees
As Select Top 10000 CategoryName, ProductName, InventoryDate, Count, [Employee] = EmployeeFirstName + ' ' + EmployeeLastName
From dbo.Categories 
Join dbo.Products
	On dbo.Products.CategoryID = dbo.Categories.CategoryID
Join dbo.Inventories
	On dbo.Products.ProductID = dbo.Inventories.ProductID
Join dbo.Employees 
	On dbo.Inventories.EmployeeID = dbo.Employees.EmployeeID
Where dbo.Products.ProductID = 1 or dbo.Products.ProductID=2
Order By InventoryDate, CategoryName, ProductName, Employee;
go

Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create view vEmployeesbyManager
As Select Top 10000 CONCAT(m.employeefirstname,' ',m.employeelastname) as Manager, CONCAT(e.employeefirstname,' ',e.employeelastname) as Employee
From dbo.Employees as E 
Left Join dbo.Employees as m on m.employeeID=e.managerID
order by manager, employee
go

Select * From [dbo].[vEmployeesByManager]
go


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create view v1EmployeesbyManager as
select e.EmployeeID as eid,e.EmployeeFirstName as efn ,e.EmployeeLastName as eln, e.ManagerID as emgrid, 
m.EmployeeID as mgrid ,m.EmployeeFirstName as mname, m.EmployeeLastName as mln
From dbo.Employees as E 
Left Join dbo.Employees as m on m.employeeID=e.managerID
go

select * from v1EmployeesbyManager;
go

Create view vInventoriesByProductsByCategoriesByEmployees as
Select Top 10000
C.CategoryID, 
C.CategoryName, 
P.ProductID, 
P.ProductName, 
P.UnitPrice, 
I.InventoryID, 
I.InventoryDate,
I.Count, 
I.EmployeeID as EmployeeID, 
[Employee] = E.efn + ' ' + e.eln,
[Manager] = e.mname + ' ' + e.mln
From dbo.vCategories as C
Join dbo.vProducts as P
	On C.CategoryID=P.CategoryID
Join dbo.vInventories as I
	On P.ProductID = I.ProductID
Join dbo.v1EmployeesbyManager as E
	On I.EmployeeID = E.eid
Order by C.CategoryID, P.ProductID, I.InventoryID,e.eid,e.emgrid
Go

Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
go


/***************************************************************************************/

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