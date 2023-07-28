/* TITLE: BLACK FRIDAY SALES
   CREATED BY: HIMANSHU GUSAIN 
   CONCEPTS USED: WINDOW FUNCTIONS, AGGREGATE FUNCTIONS, virtual tables,joins

*/





select * from [portfolio project]..sales

---Number of customers from both genders

select gender, count(*) as count_genders from [portfolio project]..sales
group by gender


---Number of purchases from each city
select City_Category , count(*) as no_of_purchases from [portfolio project]..sales
group by City_Category


---User that has the maximum purchase
select USER_ID, purchase
from [portfolio project]..sales
where purchase in (select max(Purchase) from [portfolio project]..sales)



---Top 3 age groups with large purchases
select top 3 * from
(select Age,sum(purchase) as Total_purchase
from [portfolio project]..sales
group by Age)c
order by c.Total_purchase Desc,c.Age asc



---Details of Top 10 male customers having large purchases
with cte_rep as
 (select USER_ID,sum(purchase) as Total_purchase from [portfolio project]..sales
        where Gender ='M' 
		group by USER_ID
		)
	
	select distinct s.User_ID, s.Age, r.Total_purchase from cte_rep r
	join [portfolio project]..sales s on  s.User_ID= r.User_ID
	order by Total_purchase DESC
	OFFSET  0 ROWS 
    FETCH NEXT 10 ROWS ONLY 



---List of users that have stayed the maximum in the current city
select distinct USER_ID, gender, age, Stay_In_Current_CIty_Years
from [portfolio project]..sales
where Stay_In_Current_CIty_Years in (select max(Stay_In_Current_CIty_Years) from [portfolio project]..sales)
order by Age



---number of married people wrt age who haven't stayed at a particular city
with cte_count as (select distinct USER_ID, gender, age, Stay_In_Current_City_Years
from [portfolio project]..sales
where Stay_In_Current_City_Years=0 and Marital_Status=1 
)
select Age , count(*) as no_of_married from cte_count
group by Age
order by Age




---Lowest 5 purchases by female with occupation > 16 and city category either a or b

with cte_user as (select User_ID,sum(purchase) as Total_purchase,max(Occupation) as occ
from [portfolio project]..sales
where  City_Category ='A' or City_Category='B'
group by User_ID)

select distinct s.User_ID,s.City_Category,c.Total_purchase from [portfolio project]..sales s
join cte_user c on c.USER_ID=s.User_ID
where c.occ>16 and s.gender='F'
order by c.Total_purchase
OFFSET  0 ROWS 
FETCH NEXT 5 ROWS ONLY 



---The most purchased product of every city

with cte_number as (select Product_ID ,count(Product_ID) as purchase_frequency,City_Category
from [portfolio project]..sales
group by Product_ID,City_Category
)

select Product_id,city_category,purchase_frequency from(
select *, ROW_NUMBER() over ( partition by city_category order by purchase_frequency Desc) as rank_num
from cte_number)a
where rank_num=1



---User ID of Married and non married users that did minimum purchase

select USER_ID,marital_status,purchase from(
select USER_ID, purchase, marital_status,ROW_NUMBER() over(partition by Marital_Status order by purchase) as row_num
from [portfolio project]..sales)a
where row_num=1


---Percentage of people living in each city

select City_Category , round((cast (n as float)/cast(tot_sum as float)),4) *100 as percentage_people 
from
(
select *, sum(n) over() as tot_sum
from (
select count(distinct USER_ID) as n , City_Category from [portfolio project]..sales
group by City_Category)a
)b
order by City_Category



---Users from each age group that stayed the minimum in a particular city but has the maximum purchase

with cte_min as (select distinct USER_ID, gender, age, Stay_In_Current_CIty_Years
from [portfolio project]..sales
where Stay_In_Current_CIty_Years in (select min(Stay_In_Current_CIty_Years) from [portfolio project]..sales)
)
select USER_ID, gender,age, purchase
from 
(select c.USER_ID, c.gender,c.age,s.purchase, ROW_NUMBER() over(partition by c.age order by s.purchase desc) as rnk from [portfolio project]..sales s
join cte_min c on c.User_ID=s.User_ID
)a
where rnk=1




























	










        
