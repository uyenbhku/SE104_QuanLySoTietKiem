
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
					  FROM InterestTypes
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
	DECLARE @InterestTypeID CHAR(10)
	SELECT @InterestTypeID=InterestTypeID FROM inserted
	-- Avoid hacking
	IF (@InterestTypeID NOT LIKE 'IT%[0-9]%' OR @InterestTypeID LIKE 'IT%[^0-9]%')
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50008, -1, -1)
			RETURN
		END

	-- protect database integrity by preventing people type in DepositID
	DECLARE @LatestID CHAR(10)
	SELECT TOP 1 @LatestID = InterestTypeID
		FROM (SELECT TOP 2 * 
			  FROM InterestTypes
			  ORDER BY InterestTypeID DESC) AS Top2Rows
		ORDER BY InterestTypeID 
	IF (CAST(STUFF(@InterestTypeID, 1, 2, '') AS INT) - 1 != CAST(STUFF(@LatestID, 1, 2, '') AS INT))
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50007, -1, -1)
			RETURN
		END
	DECLARE @Term INT
	SELECT @Term=inserted.Term  FROM inserted
	IF (@Term IN (SELECT Term FROM InterestTypes))
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50004, -1, -1)
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
		INSERT INTO InterestTypes(InterestRate, Term, MinimumTimeToWithdrawal)
			VALUES (@InterestRate, @Term, @MinimumTimeToWithdrawal)
	END TRY
	BEGIN CATCH
		IF (ERROR_NUMBER() = 50004)
			BEGIN
				RETURN 1
			END
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




---- TESTING
--EXEC dbo.addInterestType 4.2, 4
--GO

--EXEC dbo.addInterestType 0.4, 0
--GO

--EXEC dbo.updateInterestType 'IT00000002', 0.6
--GO

--SELECT * FROM InterestTypes

--DROP PROCEDURE dbo.addInterestType, dbo.updateInterestType 



--ALTER TABLE InterestTypes
--drop constraint dfAutoIncrementPK;
------ drop the function
--drop function dbo.fnAutoIncrementInterestTypeID
--DROP TABLE InterestTypes
