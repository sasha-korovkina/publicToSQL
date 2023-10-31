-- Initial table (formed from the VBA) is publicEquities 
-- Create a stored procedure to add multiple columns to the publicEquitiesTest table
CREATE TABLE publicEquitiesRaw (
    rank INT,
    holderid VARCHAR(255),
    instcode VARCHAR(255),
    fundcode VARCHAR(255),
	clientcode VARCHAR(255),
	note VARCHAR(255),
    entityid VARCHAR(255),
    vlookupdb VARCHAR(255),
    research VARCHAR(255),
    position INT
);

alter PROCEDURE dbo.createColumns
AS
BEGIN
    ALTER TABLE publicEquitiesRawCopy
    ADD [isin] VARCHAR(255);

    ALTER TABLE publicEquitiesRawCopy
    ADD [non_disclosed] INT;

    ALTER TABLE publicEquitiesRawCopy
    ADD [grey_area] INT;

    ALTER TABLE publicEquitiesRawCopy
    ADD [vlref] VARCHAR(255);

	ALTER TABLE publicEquitiesRawCopy
    ADD [holding_date] datetime;

	ALTER TABLE publicEquitiesRawCopy
    ADD [disclosure_source_key] INT;

	ALTER TABLE publicEquitiesRawCopy
    ADD [client_code] VARCHAR(255);

	ALTER TABLE publicEquitiesRawCopy
    ADD [project_code] VARCHAR(255);

	ALTER TABLE publicEquitiesRawCopy
    ADD [listing_key] VARCHAR(255);

	ALTER TABLE publicEquitiesRawCopy
    ADD mapped_user VARCHAR(255);
END;

alter PROCEDURE dbo.updateColumns
AS

	UPDATE publicEquitiesRawCopy
	SET holding_date = getdate();

	UPDATE publicEquitiesRawCopy
	SET disclosure_source_key = 69;

	UPDATE publicEquitiesRawCopy
	SET mapped_user = 'cmds\laura';

	UPDATE publicEquitiesRawCopy
	SET client_code = (
		SELECT [client_code]
		FROM [CDB].[ent].[securities]
		WHERE TICKER COLLATE Latin1_General_CI_AS = (SELECT distinct clientCode COLLATE Latin1_General_CI_AS FROM publicEquitiesRaw)
	);

	UPDATE publicEquitiesRawCopy
	SET listing_key = (select listing_key from [CDB].[ent].[securities] 
	where ticker = 
		(SELECT DISTINCT clientCode COLLATE Latin1_General_CI_AI
		FROM snd.dbo.publicEquitiesRaw));

	ALTER TABLE publicEquitiesRawCopy
	DROP COLUMN clientCode;
	
	/*UPDATE t
	SET t.note = d.note
	FROM publicEquitiesRawCopy AS t
	JOIN [CDB].[ent].[entity] AS e
	ON t.EntityID COLLATE Latin1_General_CI_AS = e.cmi2i_code COLLATE Latin1_General_CI_AS
	JOIN [CDB].[own].[disclosed] d ON e.ent_id = d.fund_ent_id*/

	UPDATE publicEquitiesRawCopy
	SET project_code = (
		SELECT max(project_code)
		FROM [CDB].[ent].[project]
		where client_code = 'VES');



ALTER PROCEDURE dbo.publicToSQL
AS
BEGIN
	SELECT *
	INTO publicEquitiesRawCopy
	FROM publicEquitiesRaw;
	EXEC dbo.createColumns;

	-- Update the new column by converting the string
	UPDATE [publicEquitiesRawCopy]
	SET researchDate = CONVERT(DATETIME, research, 105); -- 105 is the format code for 'dd/mm/yyyy'

	-- Convert the newDateColumn to the 'yyyy-mm-dd' format
	UPDATE [publicEquitiesRawCopy]
	SET researchDate = CONVERT(NVARCHAR(10), researchDate, 23); -- 23 is the format code for 'yyyy-mm-dd'

	-- Drop the 'research' column
	ALTER TABLE [publicEquitiesRawCopy]
	DROP COLUMN research;

    EXEC dbo.updateColumns;
	SELECT c.*
	FROM publicEquitiesRawCopy AS c
	LEFT JOIN [CDB].[map].[code] AS co
	ON c.entityID COLLATE Latin1_General_CI_AS = co.code COLLATE Latin1_General_CI_AS
	WHERE co.code IS NULL;
END;

exec publicToSQL

--------------------------------------------- PREPPING FOR OWN DISCLOSED ---------------------------------------------

select * 
from publicEquitiesRawCopy

select 
	case when e.database_key = 'I' then e.ent_id else null end as advisor_ent_id
	, case when e.database_key = 'F' then e.ent_id else null end as fund_ent_id
	, client_code
	, project_code
	, listing_key 
	, [disclosure_source_key]
	, [vlref]
	, [holding_date]
	, [position]
	, [grey_area]
	, [researchDate] as research
	, [note]
	, [non_disclosed]
	, isin
	, c.[mapped_user]
	, [mapped_datetime]
FROM publicEquitiesRawCopy c
LEFT JOIN [CDB].[map].[code] AS co
ON c.entityID COLLATE Latin1_General_CI_AS = co.code 
LEFT JOIN [CDB].ent.entity AS e
ON e.ent_id = co.ent_id 
where created_user = 'factset'

CREATE PROCEDURE InsertIntoDisclosedTable
AS
BEGIN
    INSERT INTO [CDB].[own].[disclosed] (
        advisor_ent_id,
        fund_ent_id,
        client_code,
        project_code,
        listing_key,
        [disclosure_source_key],
        [vlref],
        [holding_date],
        [position],
        [grey_area],
        research,
        [note],
        [non_disclosed],
        isin,
        [mapped_user],
        [mapped_datetime]
    )
    SELECT 
        CASE WHEN e.database_key = 'I' THEN e.ent_id ELSE NULL END AS advisor_ent_id,
        CASE WHEN e.database_key = 'F' THEN e.ent_id ELSE NULL END AS fund_ent_id,
        client_code,
        project_code,
        listing_key,
        [disclosure_source_key],
        [vlref],
        [holding_date],
        [position],
        [grey_area],
        [researchDate] as research,
        [note],
        [non_disclosed],
        isin,
        c.[mapped_user],
        [mapped_datetime]
    FROM publicEquitiesRawCopy c
    LEFT JOIN [CDB].[map].[code] AS co ON c.entityID COLLATE Latin1_General_CI_AS = co.code
    LEFT JOIN [CDB].ent.entity AS e ON e.ent_id = co.ent_id
    WHERE created_user = 'factset';
END;


EXEC InsertIntoDisclosedTable;
