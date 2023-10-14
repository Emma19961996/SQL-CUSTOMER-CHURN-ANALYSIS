--DATA CLEANING
--Finding the total number of customers
SELECT DISTINCT COUNT(CustomerID) as TotalNumberOfCustomers
FROM [SQL PROJECT].[dbo].['E Comm$']

-- Checking for duplicate rows
SELECT CustomerID, COUNT (CustomerID) as Count
FROM ['E Comm$']
GROUP BY CustomerID
Having COUNT (CustomerID) > 1

-- Checking for null values
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE Tenure IS NULL 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE warehousetohome IS NULL 
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE hourspendonapp IS NULL
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE orderamounthikefromlastyear IS NULL 
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE couponused IS NULL 
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE ordercount IS NULL 
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ['E Comm$']
WHERE daysincelastorder IS NULL 

--HANDLING NULL VALUES
UPDATE ['E Comm$']
SET Hourspendonapp = (SELECT AVG(Hourspendonapp) FROM ['E Comm$'])
WHERE Hourspendonapp IS NULL 

UPDATE ['E Comm$']
SET tenure = (SELECT AVG(tenure) FROM ['E Comm$'])
WHERE tenure IS NULL 

UPDATE ['E Comm$']
SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM ['E Comm$'])
WHERE orderamounthikefromlastyear IS NULL 

UPDATE ['E Comm$']
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM ['E Comm$'])
WHERE WarehouseToHome IS NULL 

UPDATE ['E Comm$']
SET couponused = (SELECT AVG(couponused) FROM ['E Comm$'])
WHERE couponused IS NULL 

UPDATE ['E Comm$']
SET ordercount = (SELECT AVG(ordercount) FROM ['E Comm$'])
WHERE ordercount IS NULL 

UPDATE ['E Comm$']
SET daysincelastorder = (SELECT AVG(daysincelastorder) FROM ['E Comm$'])
WHERE daysincelastorder IS NULL 


--Creating a new column from an already existing “churn” column
ALTER TABLE ['E Comm$']
ADD CustomerStatus NVARCHAR(50)

UPDATE ['E Comm$']
SET [CustomerStatus] = 
CASE 
    WHEN Churn = 1 THEN 'Churned' 
    WHEN Churn = 0 THEN 'Stayed'
END 

--Creating a new column from an already existing “complain” column
ALTER TABLE ['E Comm$']
ADD ComplainRecieved NVARCHAR(10)

UPDATE ['E Comm$']
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END


--Checking values in each column for correctness and accuracy
select distinct preferredlogindevice 
from ['E Comm$']

UPDATE ['E Comm$']
SET preferredlogindevice = 'phone'
WHERE preferredlogindevice = 'mobile phone'

-- Fixing redundancy in “PreferedOrderCat” Column
select distinct preferedordercat 
from ['E Comm$']

UPDATE ['E Comm$']
SET preferedordercat = 'Mobile Phone'
WHERE Preferedordercat = 'Mobile'

-- Fixing redundancy in “PreferredPaymentMode” Column
select distinct PreferredPaymentMode 
from ['E Comm$']

UPDATE ['E Comm$']
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD'


--Fixing wrongly entered values in “WarehouseToHome” column
SELECT DISTINCT warehousetohome
FROM ['E Comm$']

UPDATE ['E Comm$']
SET warehousetohome = '27'
WHERE warehousetohome = '127'

UPDATE ['E Comm$']
SET warehousetohome = '26'
WHERE warehousetohome = '126'

--DATA EXPLORATION
-- What is the overall customer churn rate?
SELECT TotalNumberofCustomers, 
       TotalNumberofChurnedCustomers,
       CAST((TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0)*100 AS DECIMAL(10,2)) AS ChurnRate
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM ['E Comm$']) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM ['E Comm$']
WHERE CustomerStatus = 'churned') AS Churned

--How does the churn rate vary based on the preferred login device?
SELECT preferredlogindevice, 
        COUNT(*) AS TotalCustomers,
        SUM(churn) AS ChurnedCustomers,
        CAST(SUM (churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ['E Comm$']
GROUP BY preferredlogindevice

--What is the distribution of customers across different city tiers?
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM (churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ['E Comm$']
GROUP BY citytier
ORDER BY churnrate DESC

--Is there any correlation between the warehouse-to-home distance and customer churn?
ALTER TABLE ['E Comm$']
ADD warehousetohomerange NVARCHAR(50)

UPDATE ['E Comm$']
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END

--Finding a correlation between warehouse to home and churn rate.
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC

--Which is the most preferred payment mode among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC

--What is the typical tenure for churned customers?
ALTER TABLE ['E Comm$']
ADD TenureRange NVARCHAR(50)

UPDATE ['E Comm$']
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END

--Finding typical tenure for churned customers
SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY TenureRange
ORDER BY Churnrate DESC

--Is there any difference in churn rate between male and female customers?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY gender
ORDER BY Churnrate DESC

--How does the average time spent on the app differ for churned and non-churned customers?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ['E Comm$']
GROUP BY customerstatus

--Does the number of registered devices impact the likelihood of churn?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC

-- Which order category is most preferred among churned customers?
SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY preferedordercat
ORDER BY Churnrate DESC

-- Is there any relationship between customer satisfaction scores and churn?
SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY satisfactionscore
ORDER BY Churnrate DESC

--Does the marital status of customers influence churn behavior?
SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY maritalstatus
ORDER BY Churnrate DESC

--How many addresses do churned customers have on average?
SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM ['E Comm$']
WHERE customerstatus = 'stayed'

--Do customer complaints influence churned behavior?
SELECT complainrecieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY complainrecieved
ORDER BY Churnrate DESC

-- How does the use of coupons differ between churned and non-churned customers?
SELECT customerstatus, SUM(couponused) AS SumofCouponUsed
FROM ['E Comm$']
GROUP BY customerstatus

--What is the average number of days since the last order for churned customers?
SELECT AVG(daysincelastorder) AS AverageNumofDaysSinceLastOrder
FROM ['E Comm$']
WHERE customerstatus = 'churned'

--Is there any correlation between cashback amount and churn rate?
ALTER TABLE ['E Comm$']
ADD cashbackamountrange NVARCHAR(50)

UPDATE ['E Comm$']
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END

SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ['E Comm$']
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC

