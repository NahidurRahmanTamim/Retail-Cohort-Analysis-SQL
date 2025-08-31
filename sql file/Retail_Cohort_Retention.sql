select * from retail limit 10;
select count(*) from retail; -- 5,41,909
select distinct(country) from retail;
select min(quantity) from retail; -- 80,995
select count(*) from retail
where Quantity < 0 ; -- 10,624 (Prolematic Records)
select min(unitprice) from retail; -- 11,062
select count(*) from retail
where UnitPrice < 0; -- 2
select * from retail
where customerid is null;
select count(*) from retail
where customerid is null; -- 1,35,080
select * from retail
where CustomerID is null limit 100;
select count(*) from retail
where customerid = ''; -- 0
select * from retail
where InvoiceNO  like 'C%';
select Count(*) from retail
where  InvoiceNO like'C%' and quantity < 0 ; -- 9,288
select * from retail
where  InvoiceNO like'C%' and quantity < 0 ;
-- cohort analysis
-- Create view Cohort_Retention as 
with cte as 
( select
    CustomerID,
    date(str_to_date(invoicedate,'%m/%d/%Y %H:%i')) Formatted_Date,
    round(quantity*unitprice,2) sale_value
  From retail
   where
     InvoiceNO not like 'C%'
AND  Quantity > 0 
AND  UnitPrice > 0
AND CustomerID is not null
AND CustomerID != ''
),
CTE1 as
(Select 
	 CustomerID,
     Formatted_Date as Purchase_Date,
     Min(Formatted_Date)over(partition by CustomerID) as First_Transaction_Date
 From CTE    
 ),
 CTE2 as
 ( select
       CustomerID,
       First_Transaction_Date,
       Purchase_Date,
       
       concat(
       'Month_', Round(Datediff(Purchase_Date,First_Transaction_Date)/30,0)
       ) AS Cohort_Month,
       date_format(Purchase_Date,'%Y-%m-01') as Purchase_Month,
       date_format(First_Transaction_Date,'%Y-%m-01') as First_Transaction_Month
       From CTE1
)
SELECT
	FIRST_TRANSACTION_MONTH AS COHORT,
   Nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_0' THEN CUSTOMERID ELSE null END),0) AS "MONTH_0",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_1' THEN CUSTOMERID ELSE null END),0) AS "MONTH_1",
    nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_2' THEN CUSTOMERID ELSE null END),0) AS "MONTH_2",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_3' THEN CUSTOMERID ELSE null END),0) AS "MONTH_3",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_4' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_4",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_5' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_5",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_6' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_6",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_7' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_7",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_8' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_8",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_9' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_9",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_10' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_10",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_11' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_11",
   nullif( COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_12' THEN CUSTOMERID ELSE NULL END),0) AS "MONTH_12"
FROM CTE2
GROUP BY FIRST_TRANSACTION_MONTH
ORDER BY FIRST_TRANSACTION_MONTH;
    






