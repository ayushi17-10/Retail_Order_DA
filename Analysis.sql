SELECT * FROM PortfolioProject.dbo.clean_orders;

--find top 10 highest reveue generating products 

SELECT top 10 Product_id,sum(Sale_Price) as Sales
FROM PortfolioProject.dbo.clean_orders
GROUP BY Product_Id
ORDER BY Sales DESC;

--find top 5 highest selling products in each region

With cte as (
SELECT Region, Product_id,sum(Sale_Price) as Sales
FROM PortfolioProject.dbo.clean_orders
GROUP BY  Region,Product_Id)
SELECT * FROM (
SELECT * 
, ROW_NUMBER() over (partition by Region ORDER BY Sales DESC ) as rn
from cte) A 
where rn<= 5;


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte AS (
SELECT distinct YEAR(Order_Date)AS Order_Year,MONTH(Order_Date) AS Order_Month,
SUM(Sale_Price) AS Sales 
From PortfolioProject.dbo.clean_orders
GROUP BY YEAR(Order_Date),MONTH(Order_Date)
--ORDER BY YEAR(Order_Date),MONTH(Order_Date)
)
SELECT Order_Month
, SUM(Case When Order_Year = 2022 THEN Sales Else 0 end) AS Sales_2022
, SUM(Case When Order_Year = 2023 THEN Sales Else 0 end) AS Sales_2023
from cte
GROUP BY Order_Month
ORDER BY Order_Month;


--for each category which month had highest sales 


With cte as(
SELECT Category,format(Order_Date,'yyyyMM') AS Order_Year_Month 
,SUM(Sale_Price) as Sales
FROM PortfolioProject.dbo.clean_orders
GROUP BY Category,FORMAT(Order_Date,'yyyyMM')
--ORDER BY Category,FORMAT(Order_Date,'yyyyMM')
)
SELECT * FROM(
SELECT *,
ROW_NUMBER() over (partition by Category ORDER BY Sales DESC ) AS rn
FROM cte
) A
WHERE rn=1;


--which sub category had highest growth by profit in 2023 compare to 2022


with cte as (
select Sub_Category,year(Order_Date) as Order_Year,
sum(Sale_Price) as Sales
from PortfolioProject.dbo.clean_orders
group by sub_category,year(Order_Date)
--order by year(Order_Date),month(Order_Date)
	)
, cte2 as (
select Sub_Category
, sum(case when Order_Year=2022 then Sales else 0 end) as Sales_2022
, sum(case when Order_Year=2023 then Sales else 0 end) as Sales_2023
from cte 
group by Sub_Category
)
select top 1 *
,(Sales_2023-Sales_2022)
from  cte2
order by (Sales_2023-Sales_2022) desc
