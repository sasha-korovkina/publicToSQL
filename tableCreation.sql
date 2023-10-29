-- Initial table (formed from the VBA) is publicEquities 
-- Create a stored procedure to add multiple columns to the publicEquitiesTest table


alter PROCEDURE dbo.createColumns
AS
BEGIN

    ALTER TABLE publicEquitiesWorking
    ADD [isin] VARCHAR(255);

    ALTER TABLE publicEquitiesWorking
    ADD [note] VARCHAR(255);

    ALTER TABLE publicEquitiesWorking
    ADD [non_disclosed] INT;

    ALTER TABLE publicEquitiesWorking
    ADD [grey_area] INT;

    ALTER TABLE publicEquitiesWorking
    ADD [vlref] VARCHAR(255);

	ALTER TABLE publicEquitiesWorking
    ADD [holding_date] datetime;

	ALTER TABLE publicEquitiesWorking
    ADD [disclosure_source_key] INT;

	ALTER TABLE publicEquitiesWorking
    ADD [client_code] VARCHAR(255);

	ALTER TABLE publicEquitiesWorking
    ADD [project_code] VARCHAR(255);

	ALTER TABLE publicEquitiesWorking
    ADD [listing] VARCHAR(255);
END;

alter PROCEDURE dbo.updateColumns
AS
	UPDATE publicEquitiesWorking
	SET listing = 'ORD';

	UPDATE publicEquitiesWorking
	SET holding_date = getdate();

	UPDATE publicEquitiesWorking
	SET disclosure_source_key = 69;

	UPDATE publicEquitiesWorking
	SET client_code = (
		SELECT DISTINCT clientCode COLLATE Latin1_General_CI_AI
		FROM snd.dbo.publicEquitiesTest
	);

	UPDATE publicEquitiesWorking
	SET project_code = (
		SELECT max(project_code)
		FROM [CDB].[ent].[project]
		where client_code = 'VES');

	UPDATE publicEquitiesWorking
	SET listing = (
	SELECT listing
	FROM [CDB].[ent].[securities] s
	JOIN cdb.ref.listing_key l on s.listing_key = l.listing_key
	WHERE ticker = (
		SELECT DISTINCT clientCode COLLATE Latin1_General_CI_AI
		FROM snd.dbo.publicEquitiesTest
	))

CREATE PROCEDURE dbo.publicToSQL
AS
BEGIN
    EXEC dbo.createColumns;
    EXEC dbo.updateColumns;
END;

select * from publicEquitiesWorking

