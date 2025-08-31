create database test_db;
create schema test_db.test_db_schema;



-- Dimension Table: DimDate
CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,
    Date DATE,
    DayOfWeek VARCHAR(10),
    Month VARCHAR(10),
    Quarter INT,
    Year INT,
    IsWeekend BOOLEAN
);

-- Dimension Table: DimCustomers
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY autoincrement start 1 increment 1,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    Email VARCHAR(100),
    PhoneNumber VARCHAR(30),
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(100),
    LoyaltyProgramID INT
);



-- Dimension Table: DimProduct
CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY autoincrement start 1 increment 1,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Brand VARCHAR(50),
    UnitPrice DECIMAL(10, 2)
);


-- Dimension Table: DimStore
CREATE TABLE DimStore (
    StoreID INT PRIMARY KEY autoincrement start 1 increment 1,
    StoreName VARCHAR(100),
    StoreType VARCHAR(50),
	StoreOpeningDate DATE,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Region VARCHAR(100),
    ManagerName VARCHAR(100)
);


-- Dimension Table: DimLoyaltyProgram
CREATE TABLE DimLoyaltyProgram (
    LoyaltyProgramID INT PRIMARY KEY,
    ProgramName VARCHAR(100),
    ProgramTier VARCHAR(50),
    PointsAccrued INT
);

-- Fact Table: FactOrders
CREATE TABLE FactOrders (
    OrderID INT PRIMARY KEY autoincrement start 1 increment 1,
    DateID INT,
    CustomerID INT,
    ProductID INT,
    StoreID INT,
    QuantityOrdered INT,
    OrderAmount DECIMAL(10, 2),
    DiscountAmount DECIMAL(10, 2),
    ShippingCost DECIMAL(10, 2),
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (StoreID) REFERENCES DimStore(StoreID)
);


-----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT CSV_SOURCE_FILE_FORMAT
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
DATE_FORMAT = 'YYYY-MM-DD';
 

------------------------------------------------------------------------------

create or replace stage TESTSTAGE;  


------------------------------------------------------------------------------


PUT 'file://E:/SMIT/project/Real_Life_Data_Integration_Using_Python_Snowflake_PowerBI/OneTimeLoad/DimLoyalty/DimLoyaltyInfo.csv'
    @test_db.test_db_schema.TESTSTAGE/DimLoyaltyInfo/
    auto_compress=false;


PUT 'file://E:/SMIT/project/Real_Life_Data_Integration_Using_Python_Snowflake_PowerBI/OneTimeLoad/DimCustomer/DimCustomerData.csv'
    @test_db.test_db_schema.TESTSTAGE/DimCustomerData/
    auto_compress=false;


PUT 'file://E:/SMIT/project/Real_Life_Data_Integration_Using_Python_Snowflake_PowerBI/OneTimeLoad/DimProduct/DimProductData.csv'
    @test_db.test_db_schema.TESTSTAGE/DimProductData/
    auto_compress=false;

PUT 'file://E:/SMIT/project/Real_Life_Data_Integration_Using_Python_Snowflake_PowerBI/OneTimeLoad/DimDate/DimDate.csv'
    @test_db.test_db_schema.TESTSTAGE/DimDate/
    auto_compress=false;

    

PUT 'file://E:/SMIT/project/Real_Life_Data_Integration_Using_Python_Snowflake_PowerBI/LandingDirectory/*.csv'
    @test_db.test_db_schema.TESTSTAGE/LandingDirectory/
    auto_compress=false;


----------------------------------------------------------------------------------

copy into test_db.test_db_schema.dimloyaltyprogram
from @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/DimLoyaltyInfo.csv
file_format = (format_name = 'CSV_SOURCE_FILE_FORMAT');


SELECT * FROM test_db.test_db_schema.dimloyaltyprogram;

----------------------------------------------------------------------------------


COPY INTO test_db.test_db_schema.DIMCUSTOMER (FirstName, LastName, Gender, DateOfBirth, Email, PhoneNumber, Address, City, State, Zipcode, Country, LoyaltyProgramID)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.DIMCUSTOMER;

----------------------------------------------------------------------------------


COPY INTO test_db.test_db_schema.DIMCUSTOMER (FirstName, LastName, Gender, DateOfBirth, Email, PhoneNumber, Address, City, State, Zipcode, Country, LoyaltyProgramID)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.DIMCUSTOMER;

----------------------------------------------------------------------------------


COPY INTO test_db.test_db_schema.DimProduct (PRODUCTNAME,CATEGORY,BRAND,UNITPRICE)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimProductData/DimProductData.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.DimProduct;

----------------------------------------------------------------------------------


COPY INTO test_db.test_db_schema.DimDate (DATEID,DATE,DAYOFWEEK,MONTH,QUARTER,YEAR,ISWEEKEND)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimDate/DimDate.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.DimDate;

----------------------------------------------------------------------------------


COPY INTO test_db.test_db_schema.DimStore (StoreName, StoreType, StoreOpeningDate, Address, City, State, Country, Region, ManagerName)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimStoreData/DimStoreData.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.DimStore;


----------------------------------------------------------------------------------


COPY INTO test_db.test_db_schema.DimLoyaltyProgram (DATEID,DATE,DAYOFWEEK,MONTH,QUARTER,YEAR,ISWEEKEND)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimDatefolder/DimDate.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.DimLoyaltyProgram;



----------------------------------------------------------------------------------

COPY INTO test_db.test_db_schema.factorders (DATEID,CUSTOMERID,PRODUCTID,STOREID,QUANTITYORDERED,ORDERAMOUNT,DISCOUNTAMOUNT,SHIPPINGCOST,TOTALAMOUNT)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/factorders/factorders.csv'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;


SELECT * FROM test_db.test_db_schema.factorders;


----------------------------------------------------------------------------------

COPY INTO test_db.test_db_schema.factorders (DATEID,CUSTOMERID,PRODUCTID,STOREID,QUANTITYORDERED,ORDERAMOUNT,DISCOUNTAMOUNT,SHIPPINGCOST,TOTALAMOUNT)
FROM '@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/LandingDirectory'
FILE_FORMAT = CSV_SOURCE_FILE_FORMAT;

----------------------------------------------------------------------------------

-- create user 

create or replace user Test_PowerBI_User
    password = ''
    login_name = ''
    default_role = 'ACCOUNTADMIN'
    default_warehouse = 'COMPUTE_WH'
    must_change_password = TRUE;

GRANT ROLE ACCOUNTADMIN TO USER Test_PowerBI_User;

    

    


    