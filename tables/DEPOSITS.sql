USE Savings
GO


-- CREATE DEPOSITS TABLE (PhieuGT)
-- Create table
CREATE TABLE Deposits(
	DepositID INT IDENTITY(1,1),      -- Ma phieu gui tien
	CustomerID INT NOT NULL,	  -- Ma khach hang
	InterestTypeID INT NOT NULL, -- Loai tiet kiem
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





-- STORED PROCEDURE: INSERT INTO TABLE
-- Create trigger
GO
ALTER TRIGGER trgInsertDeposit
ON Deposits
AFTER INSERT
AS
BEGIN
	-- Check if the amount of fund satisfies 
	DECLARE @MinFund MONEY, 
			@Fund MONEY
	SELECT @MinFund = MinimumDeposit FROM Params
	SELECT @Fund=inserted.Fund FROM inserted
	IF (@Fund < @MinFund)
		BEGIN
			ROLLBACK TRANSACTION
			DECLARE @LatestIdentityValue INT
			SELECT @LatestIdentityValue = DepositID - 1 FROM inserted;
			-- Reset the identity column value
			DBCC CHECKIDENT('Deposits', RESEED, @LatestIdentityValue);
			RAISERROR(50002, -1, -1)
			RETURN;
		END
	-- if added successfully
	
END
GO


-- Define Procedure
GO
ALTER PROCEDURE dbo.addDeposit 
					@CustomerID INT, 
					@InterestTypeID INT, 
					@Fund MONEY
AS
BEGIN
	-- Check if the customer is in the database yet (dont need to check)
	BEGIN TRY
		-- Get current interest rate
		IF (NOT EXISTS (SELECT * FROM InterestTypes WHERE @InterestTypeID = InterestTypeID) -- invalid Type
			OR NOT EXISTS (SELECT * FROM Customers WHERE @CustomerID = CustomerID)) -- invalid customer
			BEGIN
				RETURN 1
			END
		DECLARE @CurrentInterestRate DECIMAL(3,2)
		SELECT @CurrentInterestRate = InterestRate FROM InterestTypes
			WHERE @InterestTypeID = InterestTypeID
		-- insert new record
		DECLARE @OutputRecord TABLE (ID INT)
		INSERT INTO Deposits 
		OUTPUT inserted.DepositID INTO @OutputRecord(ID)
		VALUES (@CustomerID, @InterestTypeID, @CurrentInterestRate, GETDATE(), @Fund, 1);
		-- return record set 
		SELECT * FROM Deposits 
			WHERE EXISTS (SELECT * FROM @OutputRecord WHERE ID = DepositID)
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
ALTER TRIGGER trgDeleteDeposit
ON Deposits
AFTER DELETE
AS
BEGIN
	DECLARE @OpenedDate SMALLDATETIME,
			@Status BIT
	SELECT @OpenedDate = deleted.OpenedDate,
			@Status = deleted.Status
		FROM deleted

	-- cannot delete records that were created after 30 minutes and are opened
	IF (DATEDIFF(minute, @OpenedDate, GETDATE()) > 30 AND @Status = 1) 
		BEGIN
			RAISERROR(50005, -1, -1) 
			ROLLBACK TRANSACTION
		END
END
GO
-- Define the procedure
GO
CREATE PROCEDURE dbo.deleteDeposit @DepositID INT 
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
ALTER PROCEDURE dbo.getDepositDetailWithID 
			@DepositID INT 
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM Deposits
	WHERE @DepositID = Deposits.DepositID
END
GO


GO
ALTER PROCEDURE dbo.getDepositDetailWithDateAndID 
			@DepositID INT,
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
DECLARE @d CHAR(10)
EXEC @d=dbo.addDeposit '1', 4, 8000000
PRINT @d

SELECT * FROM Customers
SELECT * FROM Deposits
SELECT * FROM InterestTypesS

