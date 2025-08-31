SELECT * FROM DIMSTORE;

UPDATE DIMSTORE SET STOREOPENINGDATE=DATEADD(DAY,UNIFORM(0,3800,RANDOM()),'2014-01-01')

SELECT DATEDIFF(DAY,'2014-01-01',CURRENT_DATE)
--3800

SELECT DATEADD(DAY,UNIFORM(0,3800,RANDOM()),'2014-01-01')



--------------------------------------------------------------------------1

SELECT * FROM DIMSTORE where storeid between 91 and 100;

UPDATE DIMSTORE SET STOREOPENINGDATE= DATEADD(DAY,UNIFORM(0,360,RANDOM()),'2023-07-30')

SELECT DATEADD(year,-1,current_date)

select DATEADD(DAY,UNIFORM(0,360,RANDOM()),'2023-07-30')

COMMIT;

SELECT DATEDIFF(DAY,'2014-01-01',CURRENT_DATE)
--3800

SELECT DATEADD(DAY,UNIFORM(0,3800,RANDOM()),'2014-01-01')

where stored between 91 and 100;


--------------------------------------------------------------------------2


SELECT * FROM DIMCUSTOMER where dateofbirth >=dateadd(year,-12,current_date);

UPDATE DIMCUSTOMER set dateofbirth = dateadd(year,-12,dateofbirth) where dateofbirth >=dateadd(year,-12,current_date);
commit;

select dateadd(year,-12,current_date)



--------------------------------------------------------------------------3

update FACTORDERS f
set f.dateid = r.dateid 
from 
(select orderid, d.dateid 
 from 
 (SELECT orderid,
         Dateadd(day,
         DATEDIFF(DAY,S.STOREOPENINGDATE,CURRENT_DATE) * UNIFORM(1,10,RANDOM())*.1,S.STOREOPENINGDATE) as new_Date
  FROM FACTORDERS F
  JOIN DIMDATE D ON F.DATEID=D.DATEID
  JOIN DIMSTORE S ON F.STOREID=S.STOREID
  WHERE D.DATE<S.STOREOPENINGDATE) o
  join dimdate d on o.new_Date=d.date) r
where f.orderid=r.orderid;

commit;

--------------------------------------------------------------------------4

-- Customer who have placed the order in last 30 days

select * from dimcustomer where customerid not in (  
    select distinct c.Customerid from dimcustomer c  
    join factorders f on c.customerid=f.customerid  
    join dimdate d on f.dateid=d.dateid  
    where d.date >=dateadd(month,-1,current_date));

--------------------------------------------------------------------------5

with store_rank as
(
    SELECT storeid,storeopeningdate,row_number() over (order by storeopeningdate desc) as final_Rank FROM DIMSTORE
),
most_recent_store as
(
    select storeid from store_rank where final_rank=1
),
store_amount as
(
    select o.storeid,sum(totalamount)as totalamount from factorders o join most_recent_store s on o.storeid=s.storeid group by o.storeid
)
select s.*,a.totalamount from dimstore s join store_amount a on s.storeid=a.storeid

--------------------------------------------------------------------------6

WITH BASE_DATA AS
(
SELECT O.CUSTOMERID,P.CATEGORY FROM FACTORDERS O JOIN DIMDATE D ON O.DATEID=D.DATEID
JOIN DIMPRODUCT P ON O.PRODUCTID= P.PRODUCTID
WHERE D.DATE >=DATEADD(MONTH,-6,CURRENT_DATE)
GROUP BY O.CUSTOMERID,P.CATEGORY
)
SELECT CUSTOMERID
FROM BASE_DATA
GROUP BY CUSTOMERID
HAVING COUNT(DISTINCT CATEGORY)>3


--------------------------------------------------------------------------7

SELECT MONTH,SUM(TOTALAMOUNT) AS MONTHLY_AMOUNT FROM FACTORDERS O JOIN DIMDATE D ON O.DATEID=D.DATEID
WHERE D.YEAR=EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY MONTH
ORDER BY MONTH


--------------------------------------------------------------------------8

with base_data as
(
    SELECT discountAMOUNT,row_number() over ( order by discountAMOUNT desc ) as discountAMOUNT_rank FROM FACTORDERS O JOIN DIMDATE D ON O.DATEID=D.DATEID
    WHERE D.DATE >=dateadd(year,-1,current_date)
)
select * from base_data where discountAMOUNT_rank=1

--------------------------------------------------------------------------9

select sum(quantityordered*unitprice) from factorders o join dimproduct p on o.productid=p.productid

--------------------------------------------------------------------------10

-- Query 11
-- Max Discount by Customer id in their lifetime
-- rank or row_number

select customerid 
from factorders f 
group by customerid 
order by sum(discountamount) desc limit 1

--------------------------------------------------------------------------11

--List the customer who was placed maximum number of orders till date

with base_data as
(
    select customerid,count(orderid) as order_count from factorders f
    group by customerid
),
    order_Rank_data as
(
    select b.*,row_number() over ( order by order_count desc ) as order_rank from base_data b
)

select customerid,order_count from order_Rank_data where order_rank=1


--------------------------------------------------------------------------12


--Show the top 3 brands based on there sales in the last 1 year

with brand_Sales
as (
SELECT brand,sum(totalamount) as total_Sales FROM
FACTORDERS F join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid
where d.date>=dateadd(year,-1,current_date)
group by brand
),
brand_sales_rank as
(
select s.*,row_number() over (order by total_Sales desc ) as sales_rank from brand_Sales s
)
select brand,total_sales from brand_sales_rank where sales_rank<=3


--------------------------------------------------------------------------13

-- If the discount amount and the shipping cost was made static at 5 and 8% respectiveLy
--will the sum of new total amount be greater than the total amount we have

select case when sum(orderamount - orderamount*.05 - orderamount*.08) > sum(totalamount) then 'yes' else 'no' end from factorders f

--------------------------------------------------------------------------14
--Share the number of customers and their current LoyaLty program status

select L.programtier,count(customerid) as customer_count from dimcustomer d join dimloyaltyprogram L on d.LoyaLtyprogramid=L.LoyaLtyprogramid
group by L.programtier

--------------------------------------------------------------------------15

--Show the region category wise total amount for the last 6 months.

SELECT region,category,sum(totalamount) as total_sales
 FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid
join dimstore s on f.storeid=s.storeid
where d.date>=dateadd(month,-6,current_date)
group by region,category

--------------------------------------------------------------------------16
--Show the top 5 products based on quantity ordered in the last 3 years

WITH QUANTITY_DATA AS
(
SELECT F.PRODUCTID,SUM(QUANTITYORDERED) AS TOTAL_Quantity FROM FACTORDERS F join DIMDATE D ON F.DATEID=D.DATEID
WHERE D.DATE>=DATEADD(YEAR,-3,CURRENT_DATE)
GROUP BY F.PRODUCTID
),
quantity_rank_data as
(
SELECT q.*,row_number() over( order by TOTAL_Quantity desc ) as quantity_Wise_rank FROM QUANTITY_DATA q
)
select productid,TOTAL_Quantity from quantity_rank_data where quantity_Wise_rank<=5

--------------------------------------------------------------------------17
--List the total amount for each loyalty program tier since year 2023

SELECT p.programname,sum(totalamount) as total_sales FROM FACTORDERS F join dimdate d on f.dateid=d.dateid join dimcustomer c on f.customerid=c.customerid join dimloyaltyprogram p on c.loyaltyprogramid=p.loyaltyprogramid where d.year >= 2023 group by p.programname

--------------------------------------------------------------------------18
--Calculate the revenue generated by each store manager in June 2024
SELECT s.managername,sum(totalamount) as total_sales FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimstore s on f.storeid=s.storeid
where d.year = 2024 and d.month=6
group by s.managername

--------------------------------------------------------------------------19
--List the average order amount per store, along with the store name and type for the year 2024.

SELECT s.storename,s.storetype,avg(totalamount) as total_sales FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimstore s on f.storeid=s.storeid
where d.year = 2024
group by s.storename,s.storetype

--------------------------------------------------------------------------20

--Query data from the customer csv file that is present in the stage

SELECT $1,$2,$3
FROM
@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT');

--------------------------------------------------------------------------21

--Aggregate Data , Share the count of records in the Dim Customer File from Stage

SELECT count($1)
FROM
@TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT');


--------------------------------------------------------------------------22

--Filter Data , Share the records from Dim Customer File  where Customer DOB after 1st Jan 2000

SELECT $1, $2, $3,$4, $5, $6,$7,$8
FROM @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
WHERE $4 > '2000-01-01';


--------------------------------------------------------------------------23

with customer_data as
(
    SELECT $1 as First_Name , $12 as Loyalty_Program_ID
    FROM
    @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv
    (FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
),
    Loyalty_data as
(
    SELECT $1 as Loyalty_Program_ID , $3 as program_tier
    FROM
    @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimLoyaltyInfo/DimLoyaltyInfo.csv
    (FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
)
select First_Name,program_tier from customer_data c join loyalty_data l on c.Loyalty_Program_ID=l.Loyalty_Program_ID

--------------------------------------------------------------------------24

WITH customer_data AS
(
    SELECT $1 AS First_Name, $12 AS Loyalty_Program_ID
    FROM @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv
    (FILE_FORMAT => CSV_SOURCE_FILE_FORMAT)
),
loyalty_data AS
(
    SELECT $1 AS Loyalty_Program_ID, $3 AS program_tier
    FROM @TEST_DB.TEST_DB_SCHEMA.TESTSTAGE/DimCustomerData/DimCustomerData.csv
    (FILE_FORMAT => CSV_SOURCE_FILE_FORMAT)
)
SELECT l.program_tier, COUNT(1) AS total_count
FROM customer_data c
JOIN loyalty_data l
  ON c.Loyalty_Program_ID = l.Loyalty_Program_ID
GROUP BY l.program_tier;

-- Run separately
SELECT * FROM DimCustomerData;



--------------------------------------------------------------------------25
