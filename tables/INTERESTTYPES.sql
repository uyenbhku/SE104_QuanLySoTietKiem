
USE SAVINGS
GO

-- CREATE INTEREST_TYPES TABLE (LoaiTK)
-- Create InterestTypes table
CREATE TABLE InterestTypes( 
	InterestTypeID CHAR(10) NOT NULL,		-- Ma loai tiet kiem
	InterestRate DECIMAL(3,2) NOT NULL,		-- Lai suat (%)
	Term INT NOT NULL,						-- So thang trong ky han
	MinimumTimeToWithdrawal INT NOT NULL	-- Thoi gian toi thieu de duoc rut, mac dinh la 0
);  
-- Add primary key
ALTER TABLE InterestTypes ADD CONSTRAINT PK_InterestType PRIMARY KEY (InterestTypeID);

--sp_help InterestTypes


-- FEATURE: INCREMENT InterestTypeID AUTOMATICALLY
-- Create function increment InterestTypeID automatically
GO
CREATE FUNCTION dbo.fnAutoIncrementInterestTypeID ()
RETURNS CHAR(10)
AS
BEGIN
    DECLARE @InterestTypeID CHAR(10)
    SET @InterestTypeID = (SELECT TOP 1 'IT' + CAST(FORMAT(CAST(STUFF(InterestTypeID, 1, 2, '') AS INT) + 1, '00000000') AS CHAR(10))
					  FROM InterestTypes WITH (TABLOCKX) -- to avoid concurrent insertions
					  ORDER BY InterestTypeID DESC)
    RETURN ISNULL(@InterestTypeID, 'IT00000001')
END
GO

-- Add default constraint to increment ID automatically
ALTER TABLE InterestTypes
ADD CONSTRAINT dfAutoIncrementInterestTypeIDPK
DEFAULT dbo.[fnAutoIncrementInterestTypeID]() FOR InterestTypeID
GO




-- STORED PROCEDURE: Add New Interest Type
--DROP TRIGGER dbo.trgAddInterestType
-- Create trigger
GO 
CREATE TRIGGER dbo.trgAddInterestType
ON InterestTypes
AFTER INSERT
AS
BEGIN
	-- check if there are any invalid insertions
	DECLARE @InterestTypeID INT
	BEGIN TRY
		SELECT @InterestTypeID=CAST(STUFF(InterestTypeID, 1, 2, '') AS INT) FROM inserted
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR(50008, -1, -1)
		RETURN
	END CATCH

	-- protect database integrity by preventing people type in DepositID
	DECLARE @SecondLatestID INT 
	SELECT TOP 1 @SecondLatestID = CAST(STUFF(InterestTypeID, 1, 2, '') AS INT) 
		FROM (SELECT TOP 2 * 
			  FROM InterestTypes
			  ORDER BY InterestTypeID DESC) AS Top2Rows
		ORDER BY InterestTypeID 
	IF (@SecondLatestID = 1 AND @InterestTypeID > 1 
		AND @InterestTypeID - 1!= @SecondLatestID)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50007, -1, -1)
			RETURN
		END
END
GO

-- Define procedure
GO
CREATE PROCEDURE dbo.addInterestType 
			@InterestRate DECIMAL(3,2), 
			@Term INT, 
			@MinimumTimeToWithdrawal INT = 0
AS
BEGIN
	BEGIN TRY
		IF (@Term IN (SELECT Term FROM InterestTypes))
			BEGIN
				RETURN 1
			END
		INSERT INTO InterestTypes(InterestRate, Term, MinimumTimeToWithdrawal)
			VALUES (@InterestRate, @Term, @MinimumTimeToWithdrawal)
	END TRY
	BEGIN CATCH
		RETURN 2
	END CATCH
END
GO



-- STORED PROCEDURE: UPDATE Interest Type
GO
CREATE PROCEDURE dbo.updateInterestType 
			@InterestTypeID CHAR(10), 
			@NewInterestRate DECIMAL(3,2) = NULL,
			@NewMinimumTimeToWithdrawal INT = NULL
AS
BEGIN
	BEGIN TRY
		IF (@NewMinimumTimeToWithdrawal IS NOT NULL)
			BEGIN
				UPDATE InterestTypes
				SET MinimumTimeToWithdrawal = @NewMinimumTimeToWithdrawal
				WHERE InterestTypeID = @InterestTypeID
			END
		IF (@NewInterestRate IS NOT NULL)
			BEGIN
				UPDATE InterestTypes
				SET InterestRate = @NewInterestRate
				WHERE InterestTypeID = @InterestTypeID
			END
	END TRY
	BEGIN CATCH
		IF(ERROR_NUMBER() = 547)
			RETURN 1
	END CATCH
END
GO



-- STORED PROCEDURE: GET Interest Type 
GO
CREATE PROCEDURE dbo.getInterestTypeWithTerm
			@Term INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF (@Term IS NULL)
		BEGIN
			SELECT * FROM InterestTypes
		END
	ELSE
		BEGIN
			SELECT * FROM InterestTypes WHERE @Term = Term
		END
END
GO


---- TESTING
EXEC dbo.addInterestType 5.7, 6
GO

EXEC dbo.addInterestType 0.4, 13, 342
GO

--EXEC dbo.updateInterestType 'IT00000002', 0.6
--GO

--SELECT * FROM InterestTypes

--DROP PROCEDURE dbo.addInterestType, dbo.updateInterestType 


DELETE FROM InterestTypes
--ALTER TABLE InterestTypes
--drop constraint dfAutoIncrementPK;
------ drop the function
--drop function dbo.fnAutoIncrementInterestTypeID
--DROP TABLE InterestTypes

ALTER TABLE InterestTypes
drop constraint FK_InterestTypeID


EXEC dbo.getInterestTypeWithTerm '4'
