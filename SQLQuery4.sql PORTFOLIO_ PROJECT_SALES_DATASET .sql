-- LOOKING THRIUGHT DATA--
SELECT *
 FROM [sales_data].[dbo].[sales_data_sample]

 -- INSPECTING UNIQUE VALUES --
 SELECT DISTINCT PRODUCTLINE
 FROM[sales_data].[dbo].[sales_data_sample]
 SELECT DISTINCT  STATUS
 FROM[sales_data].[dbo].[sales_data_sample]
  SELECT DISTINCT  COUNTRY
 FROM[sales_data].[dbo].[sales_data_sample]
  SELECT DISTINCT  TERRITORY
 FROM[sales_data].[dbo].[sales_data_sample]
  SELECT  DISTINCT  DEALSIZE
 FROM[sales_data].[dbo].[sales_data_sample]

-- ANALYSIS---
--SALES BY PRODYCTLINE--
SELECT PRODUCTLINE,SUM(SALES) AS TOTAL_SALES
FROM [sales_data].[dbo].[sales_data_sample]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

--SALES BY YEAR--
SELECT YEAR_ID,SUM(SALES) AS TOTAL_SALES
FROM [sales_data].[dbo].[sales_data_sample]
GROUP BY YEAR_ID
ORDER BY 2 DESC

--REASON WHY SALES IS LOW IN 2005--
SELECT DISTINCT MONTH_ID FROM [dbo].[sales_data_sample]
WHERE YEAR_ID=2005

--DEALSIZE BY SUM OF SALES --
SELECT DEALSIZE ,SUM(SALES) AS TOTAL_SALES
FROM [sales_data].[dbo].[sales_data_sample]
GROUP BY DEALSIZE
ORDER BY 2 DESC

--BEST MONTH OF SALES  IN A SPECIFIC YEAR, HOW MUCH WAS EARNED THAT YEAR
SELECT MONTH_ID ,SUM(SALES) AS RENENUE ,COUNT (ORDERNUMBER)FREQUENCY
FROM [sales_data].[dbo].[sales_data_sample]
WHERE YEAR_ID=2004
GROUP BY MONTH_ID
ORDER BY 2 DESC

--PRODUCT THAT SOLD THE MOST NOVEMBWE --
SELECT MONTH_ID ,SUM(SALES) AS RENENUE ,COUNT (ORDERNUMBER)FREQUENCY,PRODUCTLINE
FROM [sales_data].[dbo].[sales_data_sample]
WHERE YEAR_ID=2004 AND MONTH_ID=11
GROUP BY MONTH_ID,PRODUCTLINE
ORDER BY 2 DESC
---RFM ANALYSIS FOR CUSTOMER--
--DROP TABLE IF EXIST #RFM
WITH RFM AS 
(
SELECT
CUSTOMERNAME,
SUM(SALES) AS MONETRY_VALUE,
AVG(SALES) AS AVG_MONETRY_VALUE,
COUNT(ORDERNUMBER)AS FREQUENCY,
MAX(ORDERDATE) AS LAST_ORDER_DATE,
(SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample]) AS MAX_ORDER_DATE,
DATEDIFF(DD,MAX(ORDERDATE),(SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample])) AS RECENCY
FROM [sales_data].[dbo].[sales_data_sample]
GROUP BY CUSTOMERNAME
),
 RFM_CACULATION AS 
(

SELECT *,
NTILE(4)OVER (ORDER BY  RECENCY)RECENCY_RFM,
NTILE(4)OVER (ORDER BY FREQUENCY)FREQUENCY_RFM,
NTILE(4)OVER (ORDER BY MONETRY_VALUE )MONETRY_VALUE_RFM
FROM
RFM 
)
SELECT *, RECENCY_RFM + FREQUENCY_RFM + MONETRY_VALUE_RFM AS RFM_CELL,
CAST(RECENCY_RFM AS nvarchar)+CAST(FREQUENCY_RFM  AS nvarchar)+CAST( MONETRY_VALUE_RFM AS nvarchar) AS STRING_RFM_CELL
INTO #RFM
FROM 
RFM_CACULATION

SELECT 
CUSTOMERNAME,RECENCY_RFM,FREQUENCY_RFM,MONETRY_VALUE_RFM,
CASE 
WHEN STRING_RFM_CELL IN (112,121,123,133,143,144) THEN 'LOW CUSTOMER'
WHEN STRING_RFM_CELL IN (211,222,232,233,243,244) THEN 'MID_CUSTOMERS'
WHEN STRING_RFM_CELL IN (311,312,321,322,323,332,333,334,441,411,412,421,422,423,432,433,444) THEN 'HIGH CUSTOMER'
END RFM_CATEGORIZATION
FROM #RFM
ORDER BY 2

