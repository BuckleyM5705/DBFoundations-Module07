--*************************************************************************--
-- Title: Assignment07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_BuckleyM')
	 Begin 
	  Alter Database [Assignment07DB_BuckleyM] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_BuckleyM;
	 End
	Create Database Assignment07DB_BuckleyM;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_BuckleyM;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

/*
-- Show a list of all columns Product
Select
	*
From
	vProducts ;
Go


-- Show a list of Product names and the price of each product.
Select
	ProductName ,
	UnitPrice
From
	vProducts ;
Go


-- Use a function to format the price as US dollars.
Select
    ProductName ,
    FORMAT ( UnitPrice , 'C' , 'en-US' ) As UnitPrice
From
    vProducts ;
Go
*/

-- Order the result by the product name.
Select
    ProductName ,
    FORMAT ( UnitPrice , 'C' , 'en-US' ) As UnitPrice
From
    vProducts
Order By ProductName ;
Go


-- Question 2 (10% of pts):
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

/*
-- Show a list of all columns in the Category and Product views
Select
	*
From
	vCategories ;
Go

Select
	*
From
	vProducts ;
Go


-- Join Category and Product views
Select
	*
From
	vCategories AS C JOIN vProducts AS P ON C.CategoryID = P.CategoryID ;
Go


-- Show a list of Category and Product names, and the price of each product
Select
	C.CategoryName ,
	P.ProductName ,
	P.UnitPrice
From
	vCategories AS C JOIN vProducts AS P ON C.CategoryID = P.CategoryID ;
Go


-- Use a function to format the price as US dollars.
Select
	C.CategoryName ,
	P.ProductName ,
	FORMAT ( P.UnitPrice , 'C' , 'en-US' ) AS UnitPrice
From
	vCategories AS C JOIN vProducts AS P ON C.CategoryID = P.CategoryID ;
Go
*/

-- Order the result by the Category and Product.
Select
	C.CategoryName ,
	P.ProductName ,
	FORMAT ( P.UnitPrice , 'C' , 'en-US' ) AS UnitPrice
From
	vCategories AS C JOIN vProducts AS P ON C.CategoryID = P.CategoryID
Order by
	C.CategoryName ,
	P.ProductName ;
Go


-- Question 3 (10% of pts):
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
-- Step 1 : Show all columns in Product and Inventory
Select
	*
From
	vProducts ;
Go

Select
	*
From
	vInventories ;
Go


-- Step 2 : Join Product and Inventory views
Select
	*
From
	vProducts AS P JOIN vInventories AS I ON P.ProductID = I.ProductID ;
Go


-- Step 3 : Return Product names, Inventory Date, and Inventory Count
Select
	P.ProductName ,
	I.InventoryDate ,
	I.Count
From
	vProducts AS P JOIN vInventories AS I ON P.ProductID = I.ProductID ;
Go


-- Q3S4 : Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Q3S4 : Format the date like 'January, 2017'.
Select
	P.ProductName ,
	FORMAT ( I.InventoryDate , 'MMMM, yyyy' ) AS InventoryDate,
	FORMAT ( I.Count , 'N0' , 'en-US' ) AS InventoryCount
From
	vProducts AS P JOIN vInventories AS I ON P.ProductID = I.ProductID ;
Go
*/

-- Q3S5 : -- Order the results by the Product and Date
Select
	P.ProductName ,
	FORMAT ( I.InventoryDate , 'MMMM, yyyy' ) AS InventoryDate,
	FORMAT ( I.Count , 'N0' , 'en-US' ) AS InventoryCount
From
	vProducts AS P JOIN vInventories AS I ON P.ProductID = I.ProductID
Order By
	P.ProductName ,
	I.InventoryDate ;
Go


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.


/*
-- Q4S1 : Show all columns in views vProducts and vInventories
Select
	*
From
	vProducts ;
Go

Select
	*
From
	vInventories ;
Go


-- Q4S2 : Join vProducts and vInventories views, show all columns
Select
	*
From
	vProducts AS P JOIN vInventories as I ON P.ProductID = I.ProductID ;
Go


-- Q4S3 : Return just Product names, Inventory Date, and Inventory Count
Select
	P.ProductName ,
	I.InventoryDate ,
	I.[Count] AS InventoryCount
From
	vProducts AS P JOIN vInventories as I ON P.ProductID = I.ProductID ;
Go


-- Q4S4 : CREATE A VIEW called vProductInventories
Create
View vProductInventories
AS
	Select
		P.ProductName ,
		I.InventoryDate ,
		I.[Count] AS InventoryCount
	From
		vProducts AS P JOIN vInventories as I ON P.ProductID = I.ProductID ;
Go
*/

-- Q4S5 : Format the date like 'January, 2017'; format number
Create
View vProductInventories
AS
	Select
		P.ProductName ,
		FORMAT ( I.InventoryDate , 'MMMM, yyyy' , 'en-US' ) AS InventoryDate ,
		FORMAT ( I.[Count] , 'N0' , 'en-US' ) AS InventoryCount
	From
		vProducts AS P JOIN vInventories as I ON P.ProductID = I.ProductID ;
Go


-- Q4S6 : Check that it works: Select * From vProductInventories;
Select
	*
From
	vProductInventories ;
Go


-- Q4S7 : Order the results by the Product and Date.
Select
	*
From
	vProductInventories
Order By
	ProductName ,
	PARSE ( InventoryDate as Date USING 'en-US' ) ;
Go


-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product ( ASSUME RR MEANT : CategoryName) and Date.
-- Check that it works: Select * From vCategoryInventories;

/*
-- Q5S1 : Show all columns in views vCategories, vProducts, and vInventories
Select
	*
From
	vCategories ;
Go

Select
	*
From
	vProducts ;
Go

Select
	*
From
	vInventories ;
Go


-- Q5S2 : Join vCategories and vProducts and vInventories views, show all columns
Select
	*
From
	vCategories AS C
	JOIN vProducts as P ON C.CategoryID = P.CategoryID
	JOIN vInventories as I ON P.ProductID = I.ProductID ;
Go


-- Q5S3 : Return just Category names, Inventory Dates, and a Inventory Count; Format the date like 'January, 2017'
Select
	C.CategoryName ,
	FORMAT ( I.InventoryDate , 'MMMM, yyyy' , 'en-US' ) ,
	I.[Count]
From
	vCategories AS C
	JOIN vProducts as P ON C.CategoryID = P.CategoryID
	JOIN vInventories as I ON P.ProductID = I.ProductID ;
Go


-- Q5S4 : Return just Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
Select
	C.CategoryName ,
	FORMAT ( I.InventoryDate , 'MMMM, yyyy' , 'en-US' ) AS [InventoryDate] ,
	SUM ( I.[Count] ) AS [InventoryCountByCategory]
From
	vCategories AS C
	JOIN vProducts as P ON C.CategoryID = P.CategoryID
	JOIN vInventories as I ON P.ProductID = I.ProductID
Group By
	C.CategoryName ,
	FORMAT ( I.InventoryDate , 'MMMM, yyyy' , 'en-US' ) ;
Go
*/

-- Q5S5 : CREATE A VIEW called vCategoryInventories. 
Create
View vCategoryInventories
AS
	Select
		C.CategoryName ,
		FORMAT ( I.InventoryDate , 'MMMM, yyyy' , 'en-US' ) AS [InventoryDate] ,
		SUM ( I.[Count] ) AS [InventoryCountByCategory]
	From
		vCategories AS C
		JOIN vProducts as P ON C.CategoryID = P.CategoryID
		JOIN vInventories as I ON P.ProductID = I.ProductID
	Group By
		C.CategoryName ,
		FORMAT ( I.InventoryDate , 'MMMM, yyyy' , 'en-US' ) ;
	Go
	

-- Q5S6 : Check that it works: Select * From vCategoryInventories;
Select
	*
From
	vCategoryInventories ;
Go


-- Q5S7 : Order the results by the Product (ASSUME RR MEANT : CategoryName ) and Date.
Select
	*
From
	vCategoryInventories
Order By
	CategoryName ,
	PARSE ( InventoryDate AS [Date] USING 'en-US' ) ;
Go


-- Question 6 (10% of pts):
-- CHECK :  CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCount. 
-- CHECK :  Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- CHECK :  Use functions to set any January NULL counts to zero. 
-- CHECK :  Order the results by the Product and Date.
-- CHECK :  This new view must use your vProductInventories view.
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCount;


/*
-- Q6S1 : This new view must use your vProductInventories view.
Select
	*
From
	vProductInventories ;
Go


-- Q6S2 : Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
Select
	* ,
	LAG ( InventoryCount , 1 ) OVER (
	PARTITION BY ProductName
	Order By Parse ( InventoryDate AS DATE USING 'en-US' )
	) AS [PreviousMonthCount]
From
	vProductInventories
Order By
	ProductName ,
	PARSE ( InventoryDate AS DATE USING 'en-US' ) ;
Go


-- Q6S3 : Use functions to set any January NULL counts to zero. 
Select
	* ,
	ISNULL (
		LAG ( InventoryCount , 1 ) OVER (
			PARTITION BY ProductName
			Order By Parse ( InventoryDate AS DATE USING 'en-US' )
		) , '0'
	) AS [PreviousMonthCount]
	From
	vProductInventories
Order By
	ProductName ,
	PARSE ( InventoryDate AS DATE USING 'en-US' ) ;
Go
*/


-- Q6S4 : CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCount
Create
View vProductInventoriesWithPreviouMonthCount
AS
	Select
		* ,
		ISNULL (
			LAG ( InventoryCount , 1 ) OVER (
				PARTITION BY ProductName
				Order By Parse ( InventoryDate AS DATE USING 'en-US' )
			) , '0'
		) AS [PreviousMonthCount]
		From
		vProductInventories ;
	Go


-- Q6S5 : Check that it works: Select * From vProductInventoriesWithPreviouMonthCount
Select
	*
From
	vProductInventoriesWithPreviouMonthCount ;
Go


-- Q6S6 : Order by ProductName and InventoryDate
Select
	*
From
	vProductInventoriesWithPreviouMonthCount
Order By
	ProductName ,
	PARSE ( InventoryDate AS DATE USING 'en-US' ) ;
Go



-- Q6S7 : CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCount (NEW VIEW ACCOUNTING FOR TYPO)
Create
View vProductInventoriesWithPreviousMonthCount
AS
	Select
		* ,
		ISNULL (
			LAG ( InventoryCount , 1 ) OVER (
				PARTITION BY ProductName
				Order By Parse ( InventoryDate AS DATE USING 'en-US' )
			) , '0'
		) AS [PreviousMonthCount]
		From
		vProductInventories ;
	Go

-- Q6S8 : Check that it works: Select * From vProductInventoriesWithPreviousMonthCount
Select
	*
From
	vProductInventoriesWithPreviousMonthCount ;
Go

-- Q6S9 : Order by ProductName and InventoryDate
Select
	*
From
	vProductInventoriesWithPreviousMonthCount
Order By
	ProductName ,
	PARSE ( InventoryDate AS DATE USING 'en-US' ) ;
Go


-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- xxx...  Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- xxx...  The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- xxx...   Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
-- xxx...  Important: This new view must use your vProductInventoriesWithPreviousMonthCount view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountWithKPIs;

/*
-- Q7S1.1 :  Important: This new view must use your vProductInventoriesWithPreviousMonthCount view!
-- Q7S1.2 :  Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
Select
	*
From
	vProductInventoriesWithPreviouMonthCount ;
Go


-- Q7S2.1 :  The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Q7S2.2 :  Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
Select
	* ,
	[CountVsPreviousMonthCountKPI] = Case
		When PARSE ( InventoryCount AS INT USING 'en-US' ) > PARSE ( PreviousMonthCount AS INT USING 'en-US' ) Then 1
		When PARSE ( InventoryCount AS INT USING 'en-US' ) = PARSE ( PreviousMonthCount AS INT USING 'en-US' ) Then 0
		When PARSE ( InventoryCount AS INT USING 'en-US' ) < PARSE ( PreviousMonthCount AS INT USING 'en-US' ) Then -1
	End
From
	vProductInventoriesWithPreviouMonthCount ;
Go
*/

-- Q7S3 :  CREATE a VIEW called vProductInventoriesWithPreviousMonthCountWithKPIs.
Create
View vProductInventoriesWithPreviousMonthCountWithKPIs
AS
	Select
		* ,
		[CountVsPreviousMonthCountKPI] = Case
			When PARSE ( InventoryCount AS INT USING 'en-US' ) > PARSE ( PreviousMonthCount AS INT USING 'en-US' ) Then 1
			When PARSE ( InventoryCount AS INT USING 'en-US' ) = PARSE ( PreviousMonthCount AS INT USING 'en-US' ) Then 0
			When PARSE ( InventoryCount AS INT USING 'en-US' ) < PARSE ( PreviousMonthCount AS INT USING 'en-US' ) Then -1
		End
	From
		vProductInventoriesWithPreviouMonthCount ;
	Go


-- Q7S4 :  Check that it works: Select * From vProductInventoriesWithPreviousMonthCountWithKPIs;
Select
	*
From
	vProductInventoriesWithPreviousMonthCountWithKPIs ;
Go


-- Q7S5 :  Verify that the results are ordered by the Product and Date.
Select
	*
From
	vProductInventoriesWithPreviousMonthCountWithKPIs
Order By
	ProductName ,
	PARSE ( InventoryDate AS DATE USING 'en-US' ) ;
Go


-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

Create Or Alter Function dbo.fProductInventoriesWithPreviousMonthCountWithKPIs
(
	@KPI INT
)
Returns Table
As
Return
(	Select
		*
	From
		vProductInventoriesWithPreviousMonthCountWithKPIs
	Where
		[CountVsPreviousMonthCountKPI] = @KPI
) ;
Go

Print 'Note: You will get an error until the views and functions are created!'
-- Check that it works:
Select * From vProductInventories;
Select * From vCategoryInventories;
Select * From vProductInventoriesWithPreviousMonthCount;
Select * From vProductInventoriesWithPreviousMonthCountWithKPIs;

Select * From fProductInventoriesWithPreviousMonthCountWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountWithKPIs(-1);