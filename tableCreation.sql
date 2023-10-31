-- Initial table (formed from the VBA) is publicEquities 
-- Create a stored procedure to add multiple columns to the publicEquitiesTest table


alter PROCEDURE dbo.createColumns
AS
BEGIN
	
    ALTER TABLE publicEquitiesRawCopy
    ADD [isin] VARCHAR(255);

    ALTER TABLE publicEquitiesRawCopy
    ADD [note] VARCHAR(255);

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
    ADD [listing] VARCHAR(255);
END;

alter PROCEDURE dbo.updateColumns
AS
	UPDATE publicEquitiesRawCopy
	SET listing = 'ORD';

	UPDATE publicEquitiesRawCopy
	SET holding_date = getdate();

	UPDATE publicEquitiesRawCopy
	SET disclosure_source_key = 69;

	UPDATE publicEquitiesRawCopy
	SET client_code = (
		SELECT [client_code]
		FROM [CDB].[ent].[securities]
		WHERE TICKER COLLATE Latin1_General_CI_AS = (SELECT distinct clientCode COLLATE Latin1_General_CI_AS FROM publicEquitiesRaw)
	);

	ALTER TABLE publicEquitiesRawCopy
	DROP COLUMN clientCode;
	
	UPDATE t
	SET t.note = d.note
	FROM publicEquitiesRawCopy AS t
	JOIN [CDB].[ent].[entity] AS e
	ON t.EntityID COLLATE Latin1_General_CI_AS = e.cmi2i_code COLLATE Latin1_General_CI_AS
	JOIN [CDB].[own].[disclosed] d ON e.ent_id = d.fund_ent_id

	UPDATE publicEquitiesRawCopy
	SET project_code = (
		SELECT max(project_code)
		FROM [CDB].[ent].[project]
		where client_code = 'VES');

	UPDATE publicEquitiesRawCopy
	SET listing = (
	SELECT listing
	FROM [CDB].[ent].[securities] s
	JOIN cdb.ref.listing_key l on s.listing_key = l.listing_key
	WHERE ticker = (
		SELECT DISTINCT clientCode COLLATE Latin1_General_CI_AI
		FROM snd.dbo.publicEquitiesTest
	)
)

ALTER PROCEDURE dbo.publicToSQL
AS
BEGIN
	SELECT *
	INTO publicEquitiesRawCopy
	FROM publicEquitiesRaw;

    EXEC dbo.createColumns;
    EXEC dbo.updateColumns;
	SELECT c.*
	FROM publicEquitiesRawCopy AS c
	LEFT JOIN [CDB].[map].[code] AS co
	ON c.entityID COLLATE Latin1_General_CI_AS = co.code COLLATE Latin1_General_CI_AS
	WHERE co.code IS NULL;
END;

exec publicToSQL
select * from publicEquitiesRawCopy
