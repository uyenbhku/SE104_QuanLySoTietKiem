USE Savings
GO

USE master
CREATE TABLE Transactions(
	TransactionID CHAR(10) NOT NULL,
	DepositID CHAR(10) NOT NULL,
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



-- FEATURE: INCREMENT InterestTypeID AUTOMATICALLY
-- Create function increment InterestTypeID automatically
GO
CREATE FUNCTION dbo.fnAutoIncrementTransactionID ()
RETURNS CHAR(10)
AS
BEGIN
    DECLARE @TransactionID CHAR(10)
    SET @TransactionID = (SELECT TOP 1 'T' + CAST(FORMAT(CAST(STUFF(TransactionID, 1, 1, '') AS INT) + 1, '000000000') AS CHAR(10))
					  FROM Transactions WITH (TABLOCKX) -- to avoid concurrent insertions
					  ORDER BY TransactionID DESC)
    RETURN ISNULL(@TransactionID, 'T000000001')
END
GO

-- Add default constraint to increment ID automatically
ALTER TABLE Transactions
ADD CONSTRAINT dfAutoIncrementTransactionIDPK
DEFAULT dbo.[fnAutoIncrementTransactionID]() FOR TransactionID
GO



-- STORED PROCEDURE: ADD NEW TRANSACTION 
GO
CREATE PROCEDURE addTransaction
			@DepositID CHAR(10),
			@Changes TEXT = NULL -- NULL is automatically increase balance
AS
BEGIN
	IF (@Changes IS NOT NULL)
	BEGIN
		BEGIN TRY 
			DECLARE @NewBalance MONEY
			SELECT TOP 1 @NewBalance=(Balance + CAST(@Changes AS VARCHAR))
				FROM Transactions
				WHERE @DepositID = DepositID
				ORDER BY TransactionDate DESC
			INSERT INTO Transactions(DepositID, Changes, Balance, TransactionDate)
				VALUES(@DepositID, @Changes, @NewBalance, GETDATE())
		END TRY
		BEGIN CATCH
		END CATCH
	END
	ELSE 
	BEGIN
		BEGIN TRY
			INSERT INTO Transactions(DepositID, Changes)
				VALUES (@DepositID, @Changes)
		END TRY
	END
END
GO


-- TESTING

