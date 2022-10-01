select* from audi 
select* from cclass 
alter table cclass add  tax int  null
alter table cclass add  mpg float  null

alter table cclass add car_name nvarchar(20) not null default 'CClass'


create view cclass1 as
select id,model_id,year,price,mileage,tax,mpg,enginesize,transmission_id,fuel_id,car_name from cclass

create view brandtype as
select* from audi union
select* from bmw union 
select* from hyndai union 
select* from merc union
select* from cclass1
select * from fueltype
select* from models
select * from transmission
select * from cars



CREATE view cars as
select a.*,b.fueltype,c.model_name,d.transmission from brandtype as a left join fueltype as b on a.fuel_ID= b.fuel_ID 
left join models as c on a.model_ID= c.model_ID
left join transmission d on a.transmission_ID= d.ID

select * from cars order by id
--------------------------------------------------------------------------------------------------------------------------
--a.  Create an analysis to find income class of UK citizens based on price of Cars
--(You can use per-capita income in UK from internet sources)
select A.model_id,c.model_name,A.price,B.per_capita_income ,B.year,
concat(abs((A.price)*100/per_capita_income),'%') as perc from audi as A
inner join per_capita as B on A.year=B.year
inner join models as c on a.model_ID = c.model_id

create view brands as 
select A.model_id,c.model_name,A.price,B.per_capita_income ,B.year,
concat(abs((A.price)*100/per_capita_income),'%') as perc from audi as A
inner join per_capita as B on A.year=B.year
inner join models as c on a.model_ID = c.model_id

select * from brands
------------------------------------------------
select *, case when perc>='130%' then 'rich'
when perc >='70%' then 'middle_class'
when perc >='0%' then 'poor' 
end as class_of_customer 
from brands
order by year desc
-----------------------------------------------------------------------------------------------------------------------

---	a. price changes across the years and identify the categories which has seen significant jump in its price
create VIEW pricee as
SELECT id, year, model_id ,model_name, price, car_name FROM cars WHERE year > 2017
create VIEW priceel as
SELECT avg(price) as avg_price, year, model_name, car_name from pricee GROUP BY model_name, year,car_name

SELECT car_name, model_name, [2018],[2019],[2020],
([2019]-[2018]) as jump_1, ([2020]-[2019]) as jump_2
FROM priceel
pivot (avg(avg_price) for year in ([2018], [2019], [2020])) as a

select * from priceel

--------------------------

--	b. changes in no of cars sold across the years and identify the categories which has seen significant jump in its sales 
--Using the above identified categories for both points (a) & (b),
--do a root cause analysis to identify the probable reason for their increase. 
--For, e.g., Its fuel efficiency as compared to other types of car could be a reason.

select model_id,year,price,car_name,fueltype, COUNT(model_id)as car_sold from CARS 
where fueltype='petrol' and year='2017' group by model_id,year,price,car_name,fueltype ;

alter proc sold_cars @year nvarchar(20), @fueltype nvarchar(20),@car nvarchar(20)
as begin 
select model_id,year,price,car_name,fueltype, COUNT(model_id)as car_sold from CARS 
where fueltype= @fueltype  and year= @year and car_name=@car group by model_id,year,price,car_name,fueltype 
end;

exec sold_cars   2019 ,'petrol','audi'
select * from cars order by id
------------------------------------------------------------------------------------------

--c. Find relationship between fuel efficiency & price of car/sales of car/fuel type/, etc.

select * into recent from cars
where year >'2016';

select * from recent;

select * from cars;
select max(mileage) from recent
select min(mileage) from recent
select max(price) from recent
select min(Price) from recent


select count(id)as cars_sold_petrol from recent
where car_name = 'bmw' and fueltype = 'petrol';

select count(id)cars_sold_diesel from recent
where car_name = 'bmw' and fueltype = 'diesel';

select *,count(id) over(partition by fueltype order by mileage desc) from recent
where car_name = 'merc' and fueltype = 'petrol';

select * ,count(id) over(partition by fueltype order by mileage desc) from recent
where car_name = 'merc' and fueltype = 'diesel';

select model_id,mileage,price, DENSE_RANK()over( order by mileage desc)as rank from recent
where car_name = 'merc';
--------------------------------------------------------------------------------------------------
--DYou are also asked to rank across all the models based on their 
--total sales, average price, average mileage, average engine size, etc. 
--and now filter the top 5 basis their sales. Observe the identified models and provide your inference.

----avg_price
select proc avg_price @car_name varchar(50) ,@year nvarchar(20)
as begin
select top 5 year, model_name, car_name, avg(price) as avg_price ,
DENSE_RANK() over (order by avg(price)desc)as rank from cars
where year= @year and car_name= @car_name group by year, model_name, car_name
end;
exec avg_price merc,2019;
--------------------------------
-----avg_mileage
select proc avg_mileage @car_name varchar(50) ,@year nvarchar(20)
as begin
select top 5 year, model_name, car_name, avg(mileage) as avg_mileage ,
DENSE_RANK() over (order by avg(mileage)desc)as rank from cars
where year= @year and car_name= @car_name group by year, model_name, car_name
end;
exec avg_mileage merc,2019;
-------------------------------------
----avg_enginesize
create proc engine @car_name varchar(50) ,@year nvarchar(20)
as begin
select top 5 year, model_name, car_name, avg(enginesize) as avg_enginesize ,
DENSE_RANK() over (order by avg(enginesize)desc)as rank from cars
where year= @year and car_name= @car_name group by year, model_name, car_name
end;
exec engine merc,2019;
---------------------------------
---count_sales
create proc count_sales @car_name varchar(50) ,@year nvarchar(20)
as begin
select top 5 year, model_name, car_name, count(model_name) as count_sales ,
DENSE_RANK() over (order by count(model_name)desc)as rank from cars
where year= @year and car_name= @car_name group by year, model_name, car_name
end;
exec count_sales merc,2019;
