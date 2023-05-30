USE Savings
GO

-- CREATE DEPOSITS TABLE (PhieuGT)
-- Create table
CREATE TABLE Deposits(
	DepositID CHAR(10) NOT NULL,      -- Ma phieu gui tien
	CustomerID CHAR(10) NOT NULL,	  -- Ma khach hang
	InterestTypeID CHAR(10) NOT NULL, -- Loai tiet kiem
	InterestRate DECIMAL(3,2),		  -- Lai suat hien tai 
	OpenedDate SMALLDATETIME,		  -- Ngay tao (tu dong)
	Fund MONEY NOT NULL,			  -- So tien gui
	Status BIT						  -- Tinh trang: 0 dong, 1 mo
);
-- Add primary key
ALTER TABLE Deposits ADD CONSTRAINT PK_Deposit PRIMARY KEY (DepositID);

-- Add foreign key on CustomerID
ALTER TABLE Deposits 
ADD CONSTRAINT FK_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

-- Add foreign key on InterestTypeID
ALTER TABLE Deposits
ADD CONSTRAINT FK_InterestTypeID
FOREIGN KEY (InterestTypeID) REFERENCES InterestTypes(InterestTypeID);




-- FEATURE: INCREMENT DEPOSITID AUTOMATICALLY
-- Create function increment DepositID automatically
GO
CREATE FUNCTION dbo.fnAutoIncrementDepositID ()
RETURNS CHAR(10)
AS
BEGIN
    DECLARE @DepositID CHAR(10)
    SET @DepositID = (SELECT TOP 1 'D' + CAST(FORMAT(CAST(STUFF(DepositID, 1, 1, '') AS INT) + 1, '000000000') AS CHAR(10))
					  FROM Deposits WITH (TABLOCKX) -- to avoid concurrent insertions
					  ORDER BY DepositID DESC)
    RETURN ISNULL(@DepositID, 'D000000001')
END
GO

-- Add default constraint to increment ID automatically
ALTER TABLE Deposits
ADD CONSTRAINT dfAutoIncrementDepositIDPK
DEFAULT dbo.[fnAutoIncrementDepositID]() for DepositID
GO




-- STORED PROCEDURE: INSERT INTO TABLE
-- Create trigger
GO
CREATE TRIGGER trgInsertDeposit
ON Deposits
AFTER INSERT
AS
BEGIN
	-- check if there are any invalid insertions
	DECLARE @DepositID INT
	BEGIN TRY
		SELECT @DepositID=CAST(STUFF(DepositID, 1, 1, '') AS INT) FROM inserted
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR(50008, -1, -1)
		RETURN
	END CATCH

	-- protect database integrity by preventing people type in DepositID
	DECLARE @SecondLatestID INT 
	SELECT TOP 1 @SecondLatestID = CAST(STUFF(DepositID, 1, 1, '') AS INT) 
		FROM (SELECT TOP 2 * 
			  FROM Deposits
			  ORDER BY DepositID DESC) AS Top2Rows
		ORDER BY DepositID 
	IF (@SecondLatestID = 1 AND @DepositID > 1 
		AND @DepositID - 1 != @SecondLatestID)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50007, -1, -1)
			RETURN
		END

	-- Check if the amount of fund satisfies 
	DECLARE @MinFund MONEY, 
			@Fund MONEY
	SELECT @MinFund = MinimumDeposit FROM Params
	SELECT @Fund=inserted.Fund FROM inserted
	IF (@Fund < @MinFund)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50002, -1, -1)
			RETURN;
		END
	-- if added successfully
	
END
GO


-- Define Procedure
GO
CREATE PROCEDURE dbo.addDeposit 
					@CustomerID CHAR(10), 
					@InterestTypeID CHAR(10), 
					@Fund MONEY
AS
BEGIN
	-- Check if the customer is in the database yet
	BEGIN TRY
		-- Get current interest rate
		DECLARE @CurrentInterestRate DECIMAL(3,2)
		SELECT @CurrentInterestRate = InterestRate FROM InterestTypes
			WHERE @InterestTypeID = InterestTypeID
		-- insert new record
		INSERT INTO Deposits (CustomerID, InterestTypeID, InterestRate, OpenedDate, Fund, Status)
			VALUES (@CustomerID, @InterestTypeID, @CurrentInterestRate, GETDATE(), @Fund, 1);
	END TRY
	BEGIN CATCH
		IF (ERROR_NUMBER() = 547)
			RETURN 1
		ELSE IF (ERROR_NUMBER() = 50002)
			RETURN 2
	END CATCH 
END
GO




-- STORED PROCEDURE: DELETE FROM TABLE
-- Create trigger after delete
GO
CREATE TRIGGER trgDeleteDeposit
ON Deposits
AFTER DELETE
AS
BEGIN
	DECLARE @DepositID CHAR(10),
			@OpenedDate SMALLDATETIME,
			@Fund MONEY
	SELECT @DepositID = deleted.DepositID, 
			@OpenedDate = deleted.OpenedDate,
			@Fund = deleted.Fund
		FROM deleted

	-- cannot delete records that were created after 30 minutes and have money
	IF (DATEDIFF(minute, @OpenedDate, GETDATE()) > 30 AND @Fund > 0) 
		BEGIN
			RAISERROR(50005, -1, -1) 
			ROLLBACK TRANSACTION
		END
END
GO
-- Define the procedure
GO
CREATE PROCEDURE dbo.deleteDeposit @DepositID CHAR(10)
AS
BEGIN
	BEGIN TRY
		DELETE FROM Deposits
		WHERE DepositID = @DepositID
	END TRY
	BEGIN CATCH
		RETURN 1
	END CATCH
END
GO



-- STORED PROCEDURE: GET DATA IN THIS TABLE 
GO
CREATE PROCEDURE dbo.getDepositDetailWithDate 
			@OpenedDate SMALLDATETIME 
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM Deposits
	WHERE @OpenedDate = CAST(CONVERT(VARCHAR(10), Deposits.OpenedDate, 101) AS DATE)
END
GO


GO
CREATE PROCEDURE dbo.getDepositDetailWithID 
			@DepositID CHAR(10)
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM Deposits
	WHERE @DepositID = Deposits.DepositID
END
GO


GO
CREATE PROCEDURE dbo.getDepositDetailWithDateAndID 
			@DepositID CHAR(10),
			@OpenedDate SMALLDATETIME
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM Deposits
	WHERE @DepositID = Deposits.DepositID
		AND @OpenedDate = CAST(CONVERT(VARCHAR(10), Deposits.OpenedDate, 101) AS DATE)
END
GO


------ TESTING
--EXEC dbo.getDepositDetailWithID 'D000000001'
--EXEC dbo.getDepositDetailWithDate '2023-05-28'
--EXEC dbo.deleteDeposit 'D000000002'
--INSERT INTO Deposits (DepositID, CustomerID, InterestTypeID, Fund)
--		VALUES ('D00000006@', 'C00000001', 'IT00000001', 8000000);

--EXEC dbo.addDeposit 'C00000001', 'IT00000001', 600000
--EXEC dbo.addDeposit 'C00000001', 'IT00000002', 80000000
--SELECT * FROM Deposits
--SELECT * from interesttypes
---- SQL Injection
--EXEC dbo.addDeposit '' INSERT INTO Deposits (DepositID, CustomerID, InterestTypeID, Fund)
--		VALUES ('D000000006', 'C00000001', 'IT00000001', 8000000);, 'IT00000001', 6000000

--SELECT * From Customers
--DELETE FROM Deposits WHERE DepositID = 'D00000006@'
--SELECT * From Deposits D1
--	where DepositID NOT IN (
--		DELETE FROM Deposits 
--		WHERE InterestRate is NULL
--			OR DepositID LIKE 'D%[^0-9]%'
--	)


--sp_help deposits

--EXEC dbo.addInterestType 5.2, 0, 15
