-- select example
select FULLDATEALTERNATEKEY as date, ENGLISHDAYNAMEOFWEEK as dayname
from DIMDATE
order by 1
limit 100;

-- sales regions with groups they belong to
select SALESTERRITORYGROUP as "GROUP", SALESTERRITORYREGION as region
from DIMSALESTERRITORY
order by "GROUP", region;

-- sales reasons
select SALESREASONNAME as "SALES REASON"
from DIMSALESREASON
order by SALESREASONNAME;


-- conditions example
select *
from DIMDATE
where ENGLISHMONTHNAME = 'January'
  and (ENGLISHDAYNAMEOFWEEK = 'Monday'
       or ENGLISHDAYNAMEOFWEEK = 'Friday')
  and CALENDARYEAR > '2010'
order by CALENDARYEAR, ENGLISHDAYNAMEOFWEEK desc
limit 100;

-- unique data example
select distinct ENGLISHDAYNAMEOFWEEK as "DAY NAME"
from DIMDATE;

-- sales reasons under Marketing type
select distinct SALESREASONNAME as "Marketing Sales Reason"
from DIMSALESREASON
where SALESREASONREASONTYPE = 'Marketing';

-- distinct week numbers for December 2008
select distinct WEEKNUMBEROFYEAR as "Week No for 2008"
from DIMDATE
where CALENDARYEAR = 2008
  and ENGLISHMONTHNAME = 'December';

-- colours of products sold where dealer price is greater than 300
select distinct COLOR as "Colour of products over $300"
from DIMPRODUCT
where DEALERPRICE > 300;

-- when person named Brian or William return a list of the occupations along with yearly income if they are married
select distinct ENGLISHOCCUPATION as occupation, YEARLYINCOME
from DIMCUSTOMER
where (FIRSTNAME = 'Brian'
       or FIRSTNAME = 'William')
  and MARITALSTATUS = 'M'
order by occupation, YEARLYINCOME;

-- (alt) when person named Brian or William return a list of the occupations along with yearly income if they are married
select distinct ENGLISHOCCUPATION as occupation, YEARLYINCOME
from DIMCUSTOMER
where FIRSTNAME in ('Brian', 'William')
  and MARITALSTATUS = 'M'
order by occupation, YEARLYINCOME;


-- joins

-- List the sales order number for all items ordered in 2011
select f.SALESORDERNUMBER as "Orders from 2011", f.ORDERDATEKEY
from FACTINTERNETSALES f
inner join DIMDATE order_date
    on f.ORDERDATEKEY = DATEKEY
where CALENDARYEAR = 2011;

-- List any product that has been sold
select distinct f.PRODUCTKEY as "Key", prod.ENGLISHPRODUCTNAME as "Name"
from FACTINTERNETSALES f
inner join DIMPRODUCT prod
    on f.PRODUCTKEY = prod.PRODUCTKEY
order by f.PRODUCTKEY;

-- What products were ordered in November 2011
select distinct f.PRODUCTKEY as "Key", prod.ENGLISHPRODUCTNAME as "Name"
from FACTINTERNETSALES f
inner join DIMDATE date
  on f.ORDERDATEKEY = date.DATEKEY
inner join DIMPRODUCT prod
  on f.PRODUCTKEY = prod.PRODUCTKEY
where date.CALENDARYEAR = 2011
  and date.MONTHNUMBEROFYEAR = 11;
  
-- for products sold in 2011, show which regions they were sold
select distinct f.PRODUCTKEY as "Product Key", prod.ENGLISHPRODUCTNAME as "Name", region.SALESTERRITORYREGION as "Region"
from FACTINTERNETSALES f
inner join DIMDATE date
  on f.ORDERDATEKEY = date.DATEKEY
inner join DIMPRODUCT prod
  on f.PRODUCTKEY = prod.PRODUCTKEY
inner join DIMSALESTERRITORY region
  on f.SALESTERRITORYKEY = region.SALESTERRITORYKEY
where date.CALENDARYEAR = 2011
order by f.PRODUCTKEY, region.SALESTERRITORYREGION;

-- which customers ordered products from the marketing category
select distinct cust.CUSTOMERKEY, cust.FIRSTNAME, cust.LASTNAME, reason.SALESREASONREASONTYPE as "Reason" 
from FACTINTERNETSALES f
inner join FACTINTERNETSALESREASON fact_reason
  on f.SALESORDERNUMBER = fact_reason.SALESORDERNUMBER
  and f.SALESORDERLINENUMBER = fact_reason.SALESORDERLINENUMBER
inner join DIMCUSTOMER cust
  on f.CUSTOMERKEY = cust.CUSTOMERKEY
inner join DIMSALESREASON reason
  on fact_reason.SALESREASONKEY = reason.SALESREASONKEY
where reason.SALESREASONREASONTYPE = 'Marketing';

-- what orders shipped in a different year to when they were ordered
select distinct f.SALESORDERNUMBER
from FACTINTERNETSALES f
inner join DIMDATE order_date
  on f.ORDERDATEKEY = order_date.DATEKEY
inner join DIMDATE ship_date
  on f.SHIPDATEKEY = ship_date.DATEKEY
where order_date.CALENDARYEAR <> ship_date.CALENDARYEAR;
