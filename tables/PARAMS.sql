
-- CREATE PARAMETERS TABLE (THAMSO)
-- Create PARAMS table
CREATE TABLE Params(
	MinimumDeposit MONEY NOT NULL   -- So tien gui toi thieu
);  


-- STORED PROCEDURE: UPDATE MINIMUM DEPOSIT VALUE
GO
CREATE PROCEDURE dbo.updateMinimumDeposit 
					@NewMinimumDeposit MONEY
AS
BEGIN
	UPDATE Params 
	SET MinimumDeposit = @NewMinimumDeposit
END
GO


INSERT INTO Params VALUES (1000000); -- so tien gui toi thieu la 1 trieu VND
--SELECT * FROM Params
