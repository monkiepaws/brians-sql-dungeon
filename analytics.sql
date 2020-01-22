-- sum of sales by product category and year
with products as (
    select p.PRODUCTKEY, c.ENGLISHPRODUCTCATERYNAME
    from DIMPRODUCT p
         inner join DIMPRODUCTSUBCATERY s on p.PRODUCTSUBCATERYKEY = s.PRODUCTSUBCATERYKEY
         inner join DIMPRODUCTCATERY c on s.PRODUCTCATERYKEY = c.PRODUCTCATERYKEY
)
select products.ENGLISHPRODUCTCATERYNAME, d.CALENDARYEAR, sum(f.SALESAMOUNT) from products
inner join FACTINTERNETSALES f on products.PRODUCTKEY = f.PRODUCTKEY
inner join DIMDATE d on f.ORDERDATEKEY = d.DATEKEY
group by products.ENGLISHPRODUCTCATERYNAME, d.CALENDARYEAR
order by products.ENGLISHPRODUCTCATERYNAME, d.CALENDARYEAR;
-- check sum
select sum(SALESAMOUNT) from FACTINTERNETSALES;


-- percentage of total sales for each product category
with products as (
    select p.PRODUCTKEY, s.ENGLISHPRODUCTSUBCATERYNAME, c.ENGLISHPRODUCTCATERYNAME
    from DIMPRODUCT p
        inner join DIMPRODUCTSUBCATERY s on p.PRODUCTSUBCATERYKEY = s.PRODUCTSUBCATERYKEY
        inner join DIMPRODUCTCATERY c on s.PRODUCTCATERYKEY = c.PRODUCTCATERYKEY
)
select products.ENGLISHPRODUCTSUBCATERYNAME,
       products.ENGLISHPRODUCTCATERYNAME,
       sum(f.SALESAMOUNT) as "Sales",
       sum("Sales") over () as "Total Sales",
       100 * ratio_to_report(sum(f.SALESAMOUNT)) over (partition by products.ENGLISHPRODUCTCATERYNAME) as "% of Cat Sales"
from products
inner join FACTINTERNETSALES f on products.PRODUCTKEY = f.PRODUCTKEY
group by products.ENGLISHPRODUCTCATERYNAME, products.ENGLISHPRODUCTSUBCATERYNAME
order by products.ENGLISHPRODUCTCATERYNAME;


-- sales for each month, with running sum of sales resetting each year
-- Year, Month, Sales for month, running sum of sales for year. Then add Product.
select d.CALENDARYEAR,
       d.MONTHNUMBEROFYEAR,
       d.ENGLISHMONTHNAME,
       p.ENGLISHPRODUCTNAME,
       sum(f.SALESAMOUNT) as "Sales",
       sum("Sales") over (partition by d.CALENDARYEAR order by d.MONTHNUMBEROFYEAR, p.ENGLISHPRODUCTNAME) as "Running"
from FACTINTERNETSALES f
inner join DIMDATE d on f.ORDERDATEKEY = d.DATEKEY
inner join DIMPRODUCT p on f.PRODUCTKEY = p.PRODUCTKEY
group by p.ENGLISHPRODUCTNAME, d.CALENDARYEAR, d.MONTHNUMBEROFYEAR, d.ENGLISHMONTHNAME
order by d.CALENDARYEAR, d.MONTHNUMBEROFYEAR, p.ENGLISHPRODUCTNAME;


-- return comma delimited list of products sold in 2014 for each product category
-- Category / Products (comma delimited)
with sales as (
    select p.PRODUCTKEY, p.ENGLISHPRODUCTNAME, c.ENGLISHPRODUCTCATERYNAME
    from FACTINTERNETSALES f
    inner join DIMPRODUCT p on f.PRODUCTKEY = p.PRODUCTKEY
    inner join DIMPRODUCTSUBCATERY s on p.PRODUCTSUBCATERYKEY = s.PRODUCTSUBCATERYKEY
    inner join DIMPRODUCTCATERY c on s.PRODUCTCATERYKEY = c.PRODUCTCATERYKEY
    inner join DIMDATE d on f.ORDERDATEKEY = d.DATEKEY
    where d.CALENDARYEAR = 2014
)
select sales.ENGLISHPRODUCTCATERYNAME as category,
       listagg(sales.ENGLISHPRODUCTNAME, ',') as products
from sales
group by sales.ENGLISHPRODUCTCATERYNAME;


-- what was the increase / decrease month to month of profit (salesamount - totalproductcost)
-- for each sales territory country
select d.CALENDARYEAR,
       d.MONTHNUMBEROFYEAR,
       d.ENGLISHMONTHNAME,
       t.SALESTERRITORYCOUNTRY,
       sum(f.SALESAMOUNT - f.TOTALPRODUCTCOST) as profit, profit - lag(profit, 1, 0) over (order by t.SALESTERRITORYCOUNTRY, d.CALENDARYEAR, d.MONTHNUMBEROFYEAR) as change_from_last_month
from FACTINTERNETSALES f
inner join DIMDATE d on f.ORDERDATEKEY = d.DATEKEY
inner join DIMSALESTERRITORY t on f.SALESTERRITORYKEY = t.SALESTERRITORYKEY
group by d.CALENDARYEAR, d.MONTHNUMBEROFYEAR, t.SALESTERRITORYCOUNTRY, d.ENGLISHMONTHNAME
order by d.CALENDARYEAR, d.MONTHNUMBEROFYEAR, t.SALESTERRITORYCOUNTRY;
