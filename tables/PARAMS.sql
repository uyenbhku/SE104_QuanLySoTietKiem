USE Savings
GO

-- CREATE PARAMETERS TABLE (THAMSO)
-- Create PARAMS table
CREATE TABLE Params(
	MinimumDeposit MONEY NOT NULL   -- So tien gui toi thieu
);  

GO
CREATE TRIGGER dbo.trgPreventInsertion
ON Params
AFTER INSERT
AS
BEGIN
	DECLARE @NoRows SMALLINT
	SELECT @NoRows=COUNT(*) FROM Params
	IF (@NoRows > 1)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50009, -1, -1)
		END
END
GO

-- STORED PROCEDURE: UPDATE MINIMUM DEPOSIT VALUE
--DROP PROCEDURE updateMinimumDeposit
-- Define procedure 
GO
CREATE PROCEDURE dbo.updateMinimumDeposit 
					@NewMinimumDeposit TEXT
AS
BEGIN
	BEGIN TRY
		UPDATE Params 
		SET MinimumDeposit = CAST(@NewMinimumDeposit AS VARCHAR)
	END TRY
	BEGIN CATCH
		RETURN 1
	END CATCH
END
GO


INSERT INTO Params VALUES (1000000); -- so tien gui toi thieu la 1 trieu VND
--SELECT * FROM Params

--EXEC updateMinimumDeposit '1000000'

