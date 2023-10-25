SELECT TOP (1000) [disclosed_id]
      ,[advisor_ent_id] -- INST CODE - done
      ,[fund_ent_id] -- FUND CODE PUBLIC - done 
      ,[client_code] -- MATCH C6 OR B3 CLIENT OR SECURITIES FOR TOCKER 
      ,[project_code] -- GET THE LAST PROJ FOR CLI ABOVE
      ,[listing_key] -- INFER FROM THE TICKER IN SEC 
      ,[disclosure_source_key] -- 69 
      ,[vlref] -- IGNORE
      ,[holding_date] -- YESTERDAY 
      ,[position]
      ,[grey_area] -- IGNORE
      ,[research] --REPORT DATE FROM FILE 
      ,[note] -- IGNORE 
      ,[non_disclosed] -- IGNORE 
      ,[isin] -- IGNORE 
      ,[mapped_user] -- LAURA
      ,[mapped_datetime] -- CURR DATETIME 
  FROM [SND].[dbo].[disclosed2]
