# 🛒 Retail Cohort Retention & Churn Analysis

This project performs **Cohort Retention & Churn Analysis** on a retail dataset.  
It cleans raw data, handles missing/problematic values, and generates customer retention cohorts & cohort churns.

---

## 📂 SQL Script

```sql
-- Data exploration
select * from retail limit 10;
| InvoiceNO | StockCode | Description                          | Quantity | InvoiceDate      | UnitPrice | CustomerID | Country        |
|-----------|-----------|--------------------------------------|----------|------------------|-----------|------------|----------------|
| 536365    | 85123A    | WHITE HANGING HEART T-LIGHT HOLDER   | 6        | 12/01/2010 08:26 | 2.55      | 17850      | United Kingdom |
| 536365    | 71053     | WHITE METAL LANTERN                  | 6        | 12/01/2010 08:26 | 3.39      | 17850      | United Kingdom |
| 536365    | 84066B    | CREAM CUPID HEARTS COAT HANGER       | 8        | 12/01/2010 08:26 | 2.75      | 17850      | United Kingdom |
| 536365    | 84029G    | KNITTED UNION FLAG HOT WATER BOTTLE  | 6        | 12/01/2010 08:26 | 3.39      | 17850      | United Kingdom |
| 536365    | 84029E    | RED WOOLLY HOTTIE WHITE HEART.       | 6        | 12/01/2010 08:26 | 3.39      | 17850      | United Kingdom |
| 536365    | 22752     | SET 7 BABUSHKA NESTING BOXES         | 2        | 12/01/2010 08:26 | 7.65      | 17850      | United Kingdom |
| 536365    | 21730     | GLASS STAR FROSTED T-LIGHT HOLDER    | 6        | 12/01/2010 08:26 | 4.25      | 17850      | United Kingdom |
| 536366    | 22633     | HAND WARMER UNION JACK               | 6        | 12/01/2010 08:28 | 1.85      | 17850      | United Kingdom |
| 536366    | 22632     | HAND WARMER RED POLKA DOT            | 6        | 12/01/2010 08:28 | 1.85      | 17850      | United Kingdom |
| 536367    | 84879     | ASSORTED COLOUR BIRD ORNAMENT        | 32       | 12/01/2010 08:34 | 1.69      | 13047      | United Kingdom |
select count(*) from retail; -- 5,41,909
select distinct(country) from retail;
select min(quantity) from retail; -- -80,995
select count(*) from retail
where Quantity < 0 ; -- 10,624 (Problematic Records)
select min(unitprice) from retail; -- 11,062
select count(*) from retail
where UnitPrice < 0; -- 2
select * from retail
where customerid is null;
select count(*) from retail
where customerid is null; -- 1,35,080
select * from retail
where customerid is null limit 100;
select count(*) from retail
where customerid = ''; -- 0
select * from retail
where InvoiceNO like 'C%';
select Count(*) from retail
where InvoiceNO like 'C%' and quantity < 0 ; -- 9,288
select * from retail
where InvoiceNO like 'C%' and quantity < 0;

-- Cohort Analysis
with cte as 
( select
    CustomerID,
    date(str_to_date(invoicedate,'%m/%d/%Y %H:%i')) Formatted_Date,
    round(quantity*unitprice,2) sale_value
  from retail
  where InvoiceNO not like 'C%'
    and Quantity > 0 
    and UnitPrice > 0
    and CustomerID is not null
    and CustomerID != ''
),
CTE1 as
( select 
     CustomerID,
     Formatted_Date as Purchase_Date,
     min(Formatted_Date) over(partition by CustomerID) as First_Transaction_Date
  from CTE    
),
CTE2 as
( select
       CustomerID,
       First_Transaction_Date,
       Purchase_Date,
       concat('Month_', round(datediff(Purchase_Date, First_Transaction_Date)/30,0)) as Cohort_Month,
       date_format(Purchase_Date,'%Y-%m-01') as Purchase_Month,
       date_format(First_Transaction_Date,'%Y-%m-01') as First_Transaction_Month
  from CTE1
)
select
    First_Transaction_Month as Cohort,
    nullif(count(distinct case when Cohort_Month = 'Month_0' then CustomerID end),0) as "Month_0",
    nullif(count(distinct case when Cohort_Month = 'Month_1' then CustomerID end),0) as "Month_1",
    nullif(count(distinct case when Cohort_Month = 'Month_2' then CustomerID end),0) as "Month_2",
    nullif(count(distinct case when Cohort_Month = 'Month_3' then CustomerID end),0) as "Month_3",
    nullif(count(distinct case when Cohort_Month = 'Month_4' then CustomerID end),0) as "Month_4",
    nullif(count(distinct case when Cohort_Month = 'Month_5' then CustomerID end),0) as "Month_5",
    nullif(count(distinct case when Cohort_Month = 'Month_6' then CustomerID end),0) as "Month_6",
    nullif(count(distinct case when Cohort_Month = 'Month_7' then CustomerID end),0) as "Month_7",
    nullif(count(distinct case when Cohort_Month = 'Month_8' then CustomerID end),0) as "Month_8",
    nullif(count(distinct case when Cohort_Month = 'Month_9' then CustomerID end),0) as "Month_9",
    nullif(count(distinct case when Cohort_Month = 'Month_10' then CustomerID end),0) as "Month_10",
    nullif(count(distinct case when Cohort_Month = 'Month_11' then CustomerID end),0) as "Month_11",
    nullif(count(distinct case when Cohort_Month = 'Month_12' then CustomerID end),0) as "Month_12"
from CTE2
group by First_Transaction_Month
order by First_Transaction_Month;

## 📈 Cohort Retention sample result

Each cohort is based on the **first transaction month** of a customer.  
The table shows how many customers returned in subsequent months.

| Cohort    | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|-----------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|----------|
| 2010-12-01| 885     | 266     | 304     | 310     | 350     | 327     | 323     | 304     | 308     | 320     | 333      | 409      | 384      |
| 2011-01-01| 417     | 99      | 103     | 107     | 127     | 110     | 104     | 98      | 124     | 132     | 152      | 67       |          |
| 2011-02-01| 380     | 67      | 85      | 98      | 99      | 88      | 100     | 102     | 102     | 107     | 42       |          |          |
| 2011-03-01| 452     | 73      | 97      | 102     | 98      | 76      | 103     | 112     | 113     | 64       |          |          |          |
| 2011-04-01| 300     | 65      | 65      | 56      | 61      | 58      | 61      | 75      | 40       |          |          |          |          |
| 2011-05-01| 284     | 50      | 47      | 46      | 57      | 63      | 75      | 44       |          |          |          |          |          |
| 2011-06-01| 242     | 43      | 36      | 55      | 61      | 80      | 31       |          |          |          |          |          |          |
| 2011-07-01| 188     | 39      | 31      | 46      | 45      | 26       |          |          |          |          |          |          |          |
| 2011-08-01| 169     | 34      | 43      | 45      | 18       |          |          |          |          |          |          |          |          |
| 2011-09-01| 299     | 73      | 94      | 26       |          |          |          |          |          |          |          |          |          |
| 2011-10-01| 358     | 87      | 40       |          |          |          |          |          |          |          |          |          |          |
| 2011-11-01| 323     | 36       |          |          |          |          |          |          |          |          |          |          |          |
| 2011-12-01| 41      |          |          |          |          |          |          |          |          |          |          |          |          |

---

-- Cohort Churn Analysis
with CTE as 
( select
    CustomerID,
    date(str_to_date(InvoiceDate, '%m/%d/%Y %H:%i')) as Formatted_Date,
    quantity*unitprice as Sale_Value
  from retail
  where InvoiceNo not like 'C%' and
        Quantity > 0 and
        unitprice > 0 and
        customerid is not null and
        customerid != ''
),
CTE1 as
( select
      CustomerID,
      Formatted_Date as Purchase_Date,
      min(Formatted_Date) over(partition by CustomerID) as First_Transaction_date
  from CTE
),
CTE2 as
( select
     CustomerID,
     concat('Month_', round(datediff(Purchase_Date, First_Transaction_Date)/30,0)) Cohort_Month,
     date_format(purchase_date,'%Y-%m-01') Purchase_Month,
     date_format(First_Transaction_Date,'%Y-%m-01') First_Transaction_Month
  from CTE1
),
CTE3 as
( select 
   First_Transaction_Month as Cohort,
   nullif(count(distinct case when Cohort_Month = 'Month_0' then CustomerID else null end),0) as "Month_0",
   nullif(count(distinct case when Cohort_Month = 'Month_1' then CustomerID else null end),0) as "Month_1",
   nullif(count(distinct case when Cohort_Month = 'Month_2' then CustomerID else null end),0) as "Month_2",
   nullif(count(distinct case when Cohort_Month = 'Month_3' then CustomerID else null end),0) as "Month_3",
   nullif(count(distinct case when Cohort_Month = 'Month_4' then CustomerID else null end),0) as "Month_4",
   nullif(count(distinct case when Cohort_Month = 'Month_5' then CustomerID else null end),0) as "Month_5",
   nullif(count(distinct case when Cohort_Month = 'Month_6' then CustomerID else null end),0) as "Month_6",
   nullif(count(distinct case when Cohort_Month = 'Month_7' then CustomerID else null end),0) as "Month_7",
   nullif(count(distinct case when Cohort_Month = 'Month_8' then CustomerID else null end),0) as "Month_8",
   nullif(count(distinct case when Cohort_Month = 'Month_9' then CustomerID else null end),0) as "Month_9",
   nullif(count(distinct case when Cohort_Month = 'Month_10' then CustomerID else null end),0) as "Month_10",
   nullif(count(distinct case when Cohort_Month = 'Month_11' then CustomerID else null end),0) as "Month_11",
   nullif(count(distinct case when Cohort_Month = 'Month_12' then CustomerID else null end),0) as "Month_12"
  from CTE2
  group by First_Transaction_Month
  order by First_Transaction_Month
)
select 
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
from CTE3
order by cohort;

## 📈 Cohort Churn sample result

Each cohort is based on the **first transaction month** of a customer.  
The table shows the rate of how many customers churned in subsequent months.

| Cohort    | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|-----------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|----------|
| 2010-12-01| 885     | 69.94   | 65.65   | 64.97   | 60.45   | 63.05   | 63.50   | 65.65   | 64.20   | 63.62   | 62.37    | 53.79    | 56.61    |
| 2011-01-01| 417     | 76.26   | 75.30   | 74.34   | 69.54   | 73.62   | 75.06   | 76.50   | 70.26   | 68.35   | 63.55    | 83.93    |          |
| 2011-02-01| 380     | 82.37   | 77.63   | 74.21   | 73.95   | 76.84   | 73.68   | 73.16   | 73.16   | 71.84   | 88.95    |          |          |
| 2011-03-01| 452     | 83.85   | 78.54   | 77.43   | 78.32   | 83.19   | 77.21   | 75.22   | 75.00   | 85.84    |          |          |          |
| 2011-04-01| 300     | 78.33   | 78.33   | 81.33   | 79.67   | 80.67   | 79.67   | 75.00   | 86.67    |          |          |          |          |
| 2011-05-01| 284     | 82.39   | 83.45   | 83.80   | 79.93   | 77.82   | 73.59   | 84.51    |          |          |          |          |          |
| 2011-06-01| 242     | 82.23   | 85.12   | 77.27   | 74.79   | 66.94   | 87.19    |          |          |          |          |          |          |
| 2011-07-01| 188     | 79.26   | 83.51   | 75.53   | 76.06   | 86.17    |          |          |          |          |          |          |          |
| 2011-08-01| 169     | 79.88   | 74.56   | 73.37   | 89.35    |          |          |          |          |          |          |          |          |
| 2011-09-01| 299     | 75.59   | 68.56   | 91.30    |          |          |          |          |          |          |          |          |          |
| 2011-10-01| 358     | 75.70   | 88.83    |          |          |          |          |          |          |          |          |          |          |
| 2011-11-01| 323     | 88.85    |          |          |          |          |          |          |          |          |          |          |          |
| 2011-12-01| 41      |          |          |          |          |          |          |          |          |          |          |          |          |

---     
      
📌 *Numbers above are an **illustrative example** of what the final cohort output might look like after running the SQL script.*  
The actual values will depend on the dataset you run it on.

## 📸 Excel Visualization
<image-card alt="Dashboard Screenshot" src="cohort_table.png" ></image-card>

*Note: If the image does not display, ensure the file `cohort_table.png` is correctly uploaded to the repository root and refresh the page.*
