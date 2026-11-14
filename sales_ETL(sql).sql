-- using workforce database
use workforce  ;

--select a sample to check how data looks 
select top 10 * from sales_data_Raw ;

  
/*----------------------------------------------------------------------------
WHAT THIS CHANGES : 
Remove the 'ORD' prefix from the order_id column.

ISSUE FACED : 
Running STUFF() without a filter modifies all order_id rows and corrupts 
data if re-run. Added WHERE order_id LIKE 'ORD%' for zero-risk repeatability.

WHAT ELSE CAN BE DONE :
1. SUBSTRING : UPDATE sales_data_Raw SET order_id = SUBSTRING(order_id, 4, LEN(order_id)) WHERE order_id LIKE 'ORD%';
2. RIGHT     : UPDATE sales_data_Raw SET order_id = RIGHT(order_id, LEN(order_id) - 3)    WHERE order_id LIKE 'ORD%';
3. LTRIM     : UPDATE sales_data_Raw SET order_id = LTRIM(order_id, 'ORD')                WHERE order_id LIKE 'ORD%'; -- SQL 2022+
----------------------------------------------------------------------------*/

update  sales_data_Raw 
set order_id = stuff(order_id, 1, 3, '') where order_id like 'ORD%' ;  

-- changed product_id column data type from varchar to int  
alter table sales_data_Raw alter column Product_ID int ;


/*----------------------------------------------------------------------------
WHAT THIS CHANGES : Changed
   Unit_Price_INR 
 , Sales_INR
 , Discount_Amount_INR
 , Net_Sales_INR,Cost_INR
 , Profit_INR 
 column data type from varchar to decimal(10,2)  

ISSUE FACED : 
tryied to  change all at once  but failled so had to change one by one
----------------------------------------------------------------------------*/
alter table sales_data_Raw alter column Discount             DECIMAL(10,2)
alter table sales_data_Raw alter column Unit_Price_INR       DECIMAL(10,2)
alter table sales_data_Raw alter column Sales_INR            DECIMAL(10,2)
alter table sales_data_Raw alter column Discount_Amount_INR  DECIMAL(10,2)
alter table sales_data_Raw alter column Net_Sales_INR        DECIMAL(10,2)
alter table sales_data_Raw alter column Cost_INR             DECIMAL(10,2)
alter table sales_data_Raw alter column Profit_INR           DECIMAL(10,2);



/*---------------------------------------------------------------------------- 
1. Revenue & Profitability (Financial Performance)
 The Business Ask: "How are our top-line sales and bottom-line profits tracking over time,
    and where are we losing money?"

What you look for:
 Total revenue , Net sales, Profit margins, Loss-making transactions or discounts. 

WHAT THIS CHANGES :  
1. calculated total revenue, net sales 
2. created excel as category wise sales and profit report 
3. profit margin calculated as (Total_Profit / Total_Net_revenue) * 100 

ISSUE FACED :  facing issue while making CTE's 


----------------------------------------------------------------------------*/
 With catagory_totals as (

 --created excel as category wise sales and profit report 
  select category, sum(Sales_INR) as Gross_Sales 
      ,sum(Profit_INR) as Total_Profit 
      ,sum(Net_Sales_INR) as Total_Net_revenue 
      ,sum(Discount_Amount_INR) as Total_Discount_Amount
        from sales_data_Raw
        group by Category)

   select category,  
CAST (Gross_Sales as decimal(10,2)) as Gross_Sales
      ,CAST (Total_Profit as decimal(10,2)) as Total_Profit
      ,CAST (Total_Net_revenue as decimal(10,2)) as Total_Net_revenue
      ,CAST (Total_Discount_Amount as decimal(10,2)) as Total_Discount_Amount
 ,   CAST  (( (Total_Profit   /  Total_Net_revenue  ) * 100 )       as decimal(10,2)) as profit_margin
From catagory_totals  ;

 -- loss makikg tranzactions calculated below 

SELECT 
    order_id,
    Category,
    Product_ID,
    Sales_INR,
    Discount,
    Discount_Amount_INR,
    Profit_INR,
    Net_Sales_INR,
    Cost_INR,
    --loss making diccount
  (CASE 
            WHEN Sales_INR >= 25000 THEN 0.10 
            WHEN Sales_INR >= 10000 THEN 0.15
            ELSE 0.30 END ) as discount_RISK_potential

FROM sales_data_Raw
WHERE 
--Loss making tranzaction 
Discount_amount_INR >= profit_INR  

ORDER BY Discount_Amount_INR DESC;
 


 
select * from sales_data_Raw 
 where Profit_INR <0 and  discount_Amount_INR /Nullif(sales_INR, 0) >0.5

/*----------------------------------------------------------------------------  
WHAT THIS CHANGES :
ISSUE FACED :
WHAT ELSE CAN BE DONE :
1.
2.
3.
 ----------------------------------------------------------------------------*/


select top 10 * from sales_data_Raw 
--select a sample to check how data looks 
/*----------------------------------------------------------------------------  
WHAT THIS CHANGES :
ISSUE FACED :
WHAT ELSE CAN BE DONE :
1.
2.
3.
 ----------------------------------------------------------------------------*/
select distinct category , sales_INR , max(Discount_Amount_INR) as max_discount  from sales_data_Raw group by category, sales_INR order by max_discount desc

SELECT 
    order_id,
    Category,
    Product_ID,
    Sales_INR,
    Discount,
    Discount_Amount_INR,
    Profit_INR,
    Net_Sales_INR,
    Cost_INR
FROM sales_data_Raw
WHERE Discount_amount_INR < profit_INR 
ORDER BY Discount_Amount_INR DESC;