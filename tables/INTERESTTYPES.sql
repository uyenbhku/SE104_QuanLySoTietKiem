
USE SAVINGS
GO

-- CREATE INTEREST_TYPES TABLE (LoaiTK)
-- Create InterestTypes table
CREATE TABLE InterestTypes( 
	InterestTypeID INT IDENTITY(1,1),		-- Ma loai tiet kiem
	InterestRate DECIMAL(3,2) NOT NULL,		-- Lai suat (%)
	Term INT NOT NULL,						-- So thang trong ky han
	MinimumTimeToWithdrawal INT NOT NULL,	-- Thoi gian toi thieu de duoc rut, mac dinh la 0
);  
-- Add primary key
ALTER TABLE InterestTypes ADD CONSTRAINT PK_InterestType PRIMARY KEY (InterestTypeID);
ALTER TABLE InterestTypes
ADD Status BIT; -- NULL: opened, 1: blocked


-- STORED PROCEDURE: Add New Interest Type
-- Define procedure
GO
ALTER PROCEDURE dbo.addInterestType 
			@InterestRate DECIMAL(3,2), 
			@Term INT, 
			@MinimumTimeToWithdrawal INT = 0
AS
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT * FROM InterestTypes WHERE Term = @Term)
			BEGIN
				RETURN 1
			END
		INSERT INTO InterestTypes (InterestRate, Term, MinimumTimeToWithdrawal)
		VALUES (@InterestRate, @Term, @MinimumTimeToWithdrawal)
	END TRY
	BEGIN CATCH
		RETURN 2
	END CATCH
END
GO



-- STORED PROCEDURE: UPDATE Interest Type
GO
ALTER PROCEDURE dbo.updateInterestType 
			@InterestTypeID INT, 
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
ALTER PROCEDURE dbo.getInterestTypeWithTerm
			@Term INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF (@Term IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked
		END
	ELSE
		BEGIN
			SELECT InterestTypeID, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked
				AND @Term = Term
		END
END
GO


---- TESTING
EXEC dbo.addInterestType 5.7, 6
GO

EXEC dbo.addInterestType 0.4, 13, 342
GO

EXEC dbo.addInterestType 6.2, 12, 0
GO

SELECT * FROM InterestTypes

--DROP PROCEDURE dbo.addInterestType, dbo.updateInterestType 


--DELETE FROM InterestTypes
--ALTER TABLE InterestTypes
--drop constraint dfAutoIncrementPK;
------ drop the function
--drop function dbo.fnAutoIncrementInterestTypeID
--DROP TABLE InterestTypes



EXEC dbo.getInterestTypeWithTerm '6'
