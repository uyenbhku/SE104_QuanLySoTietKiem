USE Savings
GO

CREATE TABLE Transactions(
	TransactionID INT IDENTITY(1,1),
	DepositID INT NOT NULL,
	Changes MONEY,
	Balance MONEY,
	TransactionDate SMALLDATETIME
);
-- Add primary key
ALTER TABLE Transactions ADD CONSTRAINT PK_Transaction PRIMARY KEY (TransactionID);

-- Add foreign key on TransactionID
ALTER TABLE Transactions
ADD CONSTRAINT FK_TransactionID
FOREIGN KEY (DepositID) REFERENCES Deposits(DepositID);

ALTER TABLE Transactions
ALTER COLUMN TransactionDate SMALLDATETIME;


GO 
CREATE TRIGGER trgInsertTransaction
ON Transactions
AFTER INSERT
AS
BEGIN
	DECLARE @Status BIT
	SELECT @Status=Status 
		FROM Deposits JOIN inserted 
			ON Deposits.DepositID = inserted.DepositID
	-- khong duoc insert transaction sau khi phieuGT co status = 0 
	IF (@Status = 0)
		BEGIN
			RAISERROR(50010, -1, -1)
			RETURN;
		END
END
GO






-- STORED PROCEDURE: ADD NEW TRANSACTION 
GO
CREATE PROCEDURE addTransaction
			@DepositID CHAR(10),
			@Changes MONEY 
AS
BEGIN
	IF (@Changes IS NOT NULL)
		BEGIN
			BEGIN TRY 
				DECLARE @NewBalance MONEY
				SELECT TOP 1 @NewBalance=(Balance + @Changes)
					FROM Transactions
					WHERE @DepositID = DepositID
					ORDER BY TransactionDate DESC
				INSERT INTO Transactions(DepositID, Changes, Balance, TransactionDate)
					VALUES(@DepositID, @Changes, @NewBalance, GETDATE())
			END TRY
			BEGIN CATCH
				RETURN 1;
			END CATCH
		END
	ELSE 
		BEGIN
			RAISERROR(50011, -1, -1);
		END
END
GO


-- Script trong Jobs
-- step 1:
-- cap nhat neu den ki han cac phieu hien tai
INSERT INTO Transactions 
SELECT Deposits.DepositID, 
		Balance * Deposits.InterestRate / 100 * NoDays / 360, 
		Balance * (1+ Deposits.InterestRate/100 * NoDays / 360), GETDATE()
FROM (SELECT TOP 1 WITH TIES *, DATEDIFF(minute, Transactions.TransactionDate, GETDATE()) AS NoDays
		FROM Transactions 
		ORDER BY ROW_NUMBER() OVER(PARTITION BY DepositID ORDER BY TransactionID DESC)) 
	AS LatestTransactions JOIN Deposits ON LatestTransactions.DepositID = Deposits.DepositID
	JOIN InterestTypes ON Deposits.InterestTypeID = InterestTypes.InterestTypeID
WHERE Term > 0 -- co ki han
	AND Deposits.Status = 1 -- still open
	AND NoDays % (Term * 30) = 0 -- minutes

-- step 2: 
-- auto insert phieuGT vao transactions vao 0h ngay hom sau ngay gui 
INSERT INTO Transactions
SELECT DepositID, Fund, Fund, GETDATE() 
FROM Deposits
WHERE NOT EXISTS (SELECT * FROM Transactions T WHERE DepositID = T.DepositID)


SELECT * FROM Transactions

SELECT * FROM Deposits
SELECT * FROM InterestTypes
EXEC addInterestType 2.3, 1
EXEC addInterestType 4.2, 3

-- TESTING
EXEC dbo.addTransaction 3, 1000



DELETE FROM Transactions