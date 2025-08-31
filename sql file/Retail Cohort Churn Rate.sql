 -- Drop View Cohort_Churn_Rate;
 -- Create View Cohort_Churn_Rate AS
With CTE as 
(Select
CustomerID,
Date(str_to_date(InvoiceDate, '%m/%d/%Y %H:%i')) as Formatted_Date,
quantity*unitprice as Sale_Value
From Retail
Where InvoiceNo not like 'C%' and
	  Quantity > 0 and
      unitprice > 0 and
      customerid is not null and
      customerid != ''
),
CTE1 as
(Select
      CustomerID,
      Formatted_Date as Purchase_Date,
      min(Formatted_Date) over(Partition by CustomerID) as First_Transaction_date
      From CTE
      ),
 CTE2 as
 (Select
     CustomerID,
     Concat('Month_',Round(Datediff(Purchase_Date,First_Transaction_Date)/30,0)) Cohort_Month,
     date_format(purchase_date,'%Y-%m-01') Purchase_Month,
     date_format(First_Transaction_Date,'%Y-%m-01') First_Transaction_Month
     From CTE1
     ),
 CTE3 as
(Select 
   First_Transaction_Month as Cohort,
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
   From CTE2
   group by First_Transaction_Month
   order by First_Transaction_Month
   )
   Select 
       Cohort,
       Month_0,
       round((Month_0-Month_1)*100/Month_0,2) Month_1,
       round((Month_0-Month_2)*100/Month_0,2) Month_2,
       round((Month_0-Month_3)*100/Month_0,2) Month_3,
       round((Month_0-Month_4)*100/Month_0,2) Month_4,
       round((Month_0-Month_5)*100/Month_0,2) Month_5,
       round((Month_0-Month_6)*100/Month_0,2) Month_6,
       round((Month_0-Month_7)*100/Month_0,2) Month_7,
       round((Month_0-Month_8)*100/Month_0,2) Month_8,
       round((Month_0-Month_9)*100/Month_0,2) Month_9,
       round((Month_0-Month_10)*100/Month_0,2) Month_10,
       round((Month_0-Month_11)*100/Month_0,2) Month_11,
       round((Month_0-Month_12)*100/Month_0,2) Month_12
       From CTE3
       order by cohort;
          
     
      