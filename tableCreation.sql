/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Rank]
      ,[HolderID]
      ,[InstCode]
      ,[FundCode]
      ,[EntityID]
      ,[VlookupDB]
      ,[clientCode]
	  , researchDate
  FROM [SND].[dbo].[publicEquitiesTest]

  -- Add a new DATETIME column
ALTER TABLE publicEquitiesTest
ADD researchDate DATETIME;

-- Update the new column by converting the string
UPDATE publicEquitiesTest
SET researchDate = CONVERT(DATETIME, research, 105); -- 105 is the format code for 'dd/mm/yyyy'

-- Convert the newDateColumn to the 'yyyy-mm-dd' format
UPDATE publicEquitiesTest
SET researchDate = CONVERT(NVARCHAR(10), researchDate, 23); -- 23 is the format code for 'yyyy-mm-dd'

-- Drop the 'research' column
ALTER TABLE publicEquitiesTest
DROP COLUMN research;
