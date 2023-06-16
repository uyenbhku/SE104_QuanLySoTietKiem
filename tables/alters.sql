USE SOTIETKIEM


GO 
ALTER PROCEDURE dbo.calculateReportByDay
				@Date DATE
AS
BEGIN
	SET NOCOUNT ON
	IF (EXISTS (SELECT * FROM ProfitReports WHERE RecordedDate=@Date))
		BEGIN
			DELETE FROM ReportDetails WHERE RecordedDate=@Date
		END
	-- create a new report
	ELSE
		BEGIN
			-- initialize report
			INSERT INTO ProfitReports(RecordedDate) VALUES (@Date)
		END
	-- calculate details
	INSERT INTO ReportDetails 
	SELECT  Costs.RecordedDate, -- ngay lap phieu
			Costs.InterestTypeID, -- loaitk 
			TotalRevenueEachType, -- tong thu 
			TotalCostEachType, -- tong chi
			TotalRevenueEachType - TotalCostEachType as ProfitEachType -- chenh lech
		FROM (
				SELECT ISNULL(CAST(OpenedDate AS DATE), @Date) AS RecordedDate, 
						 IT.InterestTypeID, 
						 ISNULL(SUM(Fund), 0) AS TotalRevenueEachType
				FROM (SELECT * FROM Deposits WHERE CAST(OpenedDate AS DATE) = @Date) Opens -- bang phu luu cac PhieuGT vao ngay @Date
				RIGHT JOIN InterestTypes IT ON IT.InterestTypeID = Opens.InterestTypeID
				GROUP BY CAST(OpenedDate AS DATE), IT.InterestTypeID
			) AS Revenues -- bang phu luu ngay gui, LoaiTK, tong tien gui cua LoaiTK do
			FULL OUTER JOIN
			(
				SELECT ISNULL(CAST(TransactionDate AS DATE), @Date) AS RecordedDate, 
						InterestTypes.InterestTypeID, 
						ISNULL(-SUM(Changes), 0) AS TotalCostEachType
				FROM (
						SELECT * FROM Transactions
						WHERE Changes < 0 -- is a withdrawal
						AND CAST(TransactionDate AS DATE) = @Date -- at the given date
					) AS MoneyWithdrawn -- luu nhung transactions rut tien vao ngay @Date
				JOIN Deposits D ON D.DepositID = MoneyWithdrawn.DepositID
				RIGHT JOIN InterestTypes ON InterestTypes.InterestTypeID = D.InterestTypeID
				GROUP BY CAST(TransactionDate AS DATE), InterestTypes.InterestTypeID
			) AS Costs -- bang phu luu ngay rut, loaiTK, tong tien rut ra loaiTK do
			ON Costs.InterestTypeID = Revenues.InterestTypeID
	-- summary details
	UPDATE ProfitReports
	SET TotalRevenue = (SELECT ISNULL(SUM(Revenue),0) FROM ReportDetails WHERE RecordedDate = @Date),
		TotalCost = (SELECT ISNULL(SUM(Cost), 0) FROM ReportDetails WHERE RecordedDate = @Date),
		TotalProfit = (SELECT ISNULL(SUM(Profit), 0) FROM ReportDetails WHERE RecordedDate = @Date)
	WHERE RecordedDate = @Date;
END
GO




GO
ALTER PROCEDURE dbo.getDeposit
					@DepositID INT
AS
BEGIN
	SET NOCOUNT ON;
	-- neu phieu da rut 
	IF (EXISTS (SELECT * FROM Deposits WHERE @DepositID = DepositID AND Withdrawer IS NOT NULL))
		BEGIN
			SELECT TOP 1 WITH TIES D.CustomerID, 
					CustomerName, CitizenID, PhoneNumber, 
					CustomerAddress,
					D.DepositID, Fund,
					Term, InterestRate, 
					ISNULL(-Changes - Fund, 0) AS TotalChanges, -- tinh tong tien lai
					ISNULL(Balance, Fund) AS CurrentBalance,  -- so du hien tai
					OpenedDate, -- ngay gui
					Withdrawer, TransactionDate AS WithdrawalDate, -- ngay rut
					DATEDIFF(minute, OpenedDate, TransactionDate) - 1 AS NoDaysDeposited -- so ngay gui -- minute for testing
			FROM Deposits D LEFT JOIN Transactions T
				ON T.DepositID = D.DepositID
				JOIN Customers C 
				ON D.CustomerID = C.CustomerID
				JOIN InterestTypes IT
				ON D.InterestTypeID = IT.InterestTypeID
			WHERE @DepositID = D.DepositID
			ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
		END
	ELSE -- neu phieu chua rut
		BEGIN
			SELECT TOP 1 WITH TIES D.CustomerID, 
					CustomerName, CitizenID, PhoneNumber, 
					CustomerAddress,
					D.DepositID, Fund,
					Term, InterestRate, 
					ISNULL(Balance - Fund, 0) AS TotalChanges,
					ISNULL(Balance, Fund) AS CurrentBalance, OpenedDate,
					Withdrawer, NULL AS WithdrawalDate,
					DATEDIFF(minute, OpenedDate, GETDATE()) - 1 AS NoDaysDeposited -- so ngay gui -- minute for testing
			FROM Deposits D LEFT JOIN Transactions T
				ON T.DepositID = D.DepositID
				JOIN Customers C 
				ON D.CustomerID = C.CustomerID
				JOIN InterestTypes IT
				ON D.InterestTypeID = IT.InterestTypeID
			WHERE @DepositID = D.DepositID
			ORDER BY ROW_NUMBER() OVER(PARTITION BY D.DepositID ORDER BY TransactionID DESC)
		END
END
GO


GO
ALTER PROCEDURE dbo.makeReportByDay
					@Date DATE -- format 'ydm'
AS 
BEGIN
	SET NOCOUNT ON
	IF (@Date > GETDATE())  -- cannot create reports for the future
		BEGIN
			RAISERROR(50022, -1, -1)
			RETURN
		END
	
	EXEC dbo.calculateReportByDay @Date

	
	-- return reports
	SELECT TotalRevenue, TotalCost, TotalProfit
		 FROM ProfitReports WHERE RecordedDate = @Date
	SELECT IT.InterestTypeID, InterestTypeName, Revenue, Cost, Profit
		FROM ReportDetails RD JOIN InterestTypes IT ON IT.InterestTypeID = RD.InterestTypeID
		WHERE RecordedDate = @Date
		ORDER BY Profit DESC
END
GO





GO 
ALTER TRIGGER dbo.trgUpdateInterestType
ON InterestTypes
AFTER UPDATE
AS
BEGIN
	DECLARE @InsTerm INT,
			@DelTerm INT,
			@InsInterestRate DECIMAL(17,2),
			@DelInterestRate DECIMAL(17,2)
	SELECT @InsTerm = Term, @InsInterestRate = InterestRate FROM Inserted
	SELECT @DelTerm = Term, @DelInterestRate = InterestRate FROM Deleted
	IF (@InsTerm != @DelTerm OR @InsInterestRate != @DelInterestRate)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50013, -1, -1) -- loi trung voi record co san
			RETURN;
		END
END


GO
ALTER PROCEDURE dbo.getInterestType
			@Term INT = NULL,
			@InterestRate DECIMAL(17,2) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF (@Term IS NULL AND @InterestRate IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
		END
	ELSE IF (@Term IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
				AND @InterestRate = InterestRate
		END
	ELSE IF (@InterestRate IS NULL)
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
				AND @Term = Term
		END
	ELSE
		BEGIN
			SELECT InterestTypeID, InterestTypeName, InterestRate, Term, MinimumTimeToWithdrawal 
			FROM InterestTypes
			WHERE Status IS NULL -- is not blocked/hidden
				AND @Term = Term AND @InterestRate = InterestRate
		END
END
GO



GO
ALTER TRIGGER trgInsertandDeleteWithdrawal
ON dbo.Deposits
AFTER UPDATE
AS
BEGIN	
	DECLARE @InsWithdrawer VARCHAR(40),
			@DelWithdrawer VARCHAR(40),
			@DepositID INT
	SELECT @DepositID = DepositID FROM inserted
	SELECT @InsWithdrawer = Withdrawer FROM inserted
	SELECT @DelWithdrawer = Withdrawer FROM deleted
	-- Khong cap nhat phieu rut khi da co Ten nguoi rut !! 
	IF (@DelWithdrawer IS NOT NULL AND @InsWithdrawer IS NOT NULL AND @DelWithdrawer != @InsWithdrawer)
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR(50016, -1, -1)
			RETURN
		END
	-- Khi Insert Phieu RT vao Transaction
	IF (@DelWithdrawer IS NULL AND @InsWithdrawer IS NOT NULL)
		BEGIN
			--------
			-- Tinh so ngay gui
			DECLARE @NumOfDaysDeposited INT
			SELECT @NumOfDaysDeposited = DATEDIFF(minute, OpenedDate, GETDATE()) - 1 FROM deleted -- minutes for testing
			-- Kiem tra dieu kien so ngay gui
			DECLARE @MinimumTimeToWithdrawal INT
			SELECT @MinimumTimeToWithdrawal = MinimumTimeToWithdrawal FROM InterestTypes
				WHERE InterestTypeID = (SELECT InterestTypeID FROM deleted)

			--IF (@NumOfDaysDeposited != -1)
			--	BEGIN
			IF (@NumOfDaysDeposited < @MinimumTimeToWithdrawal)
				BEGIN
					ROLLBACK TRANSACTION
					RAISERROR(50017, -1, -1)
					RETURN
				END
			--	END
			--ELSE SET @NumOfDaysDeposited = 0 -- neu ngay rut trung ngay gui 

			-- Lay so du trong ngay cap nhat moi nhat
			DECLARE @Balance MONEY,
					@NewBalance MONEY
					--@TransactionID INT
			SELECT TOP 1 @Balance = Balance 
					FROM Transactions 
					WHERE DepositID = @DepositID 
					ORDER BY TransactionDate DESC
			SET @NewBalance = @Balance
			-- Tinh so ky da gui neu la loai TK co ky han
			DECLARE @Term INT
			SELECT @Term = Term FROM InterestTypes
							WHERE InterestTypeID = (SELECT InterestTypeID FROM deleted)
			-- Neu la loai co ky han
			IF (@Term > 0)
				BEGIN
					DECLARE @RemaningNumOfDays INT
					SET @RemaningNumOfDays = @NumOfDaysDeposited % (@Term * 30)
					-- Neu rut giua ky thi cap nhat so du moi nhat
					IF (@RemaningNumOfDays != 0)
						BEGIN
							-- Lay lai suat cua loai khong ky han thap nhat
							DECLARE @InterestRate DECIMAL(17,2)
							SELECT TOP 1 @InterestRate = InterestRate FROM InterestTypes 
													WHERE Term = 0 ORDER BY InterestRate ASC
							-- Cap nhat so du moi
							SET @NewBalance = @Balance * (1 + @InterestRate / 100 * @RemaningNumOfDays / 360)
							INSERT INTO Transactions
							VALUES(@DepositID, @NewBalance - @Balance, @NewBalance, GETDATE())
						END
					END
			-- Insert to Transaction with Balance is 0
			INSERT INTO Transactions(DepositID, Changes, Balance, TransactionDate)
				VALUES(@DepositID, -@NewBalance, 0, GETDATE())
			RETURN
			--------
		END
	-- Khi xoa phieu rut
	IF (@DelWithdrawer IS NOT NULL AND @InsWithdrawer IS NULL)
		BEGIN
			DECLARE @TransactionID INT,
					@CurrentBalance MONEY,
					@WithdrawalDate SMALLDATETIME
			SELECT TOP 1 @TransactionID = TransactionID, 
						@CurrentBalance = Balance, 
						@WithdrawalDate = TransactionDate
				FROM Transactions
				WHERE DepositID = @DepositID
				ORDER BY TransactionID DESC
			IF (@CurrentBalance > 0)
			BEGIN
				ROLLBACK TRANSACTION
				RAISERROR(50019, -1, -1)
				RETURN
			END
		-- Xoa phieu rut
			DELETE FROM Transactions
				WHERE TransactionID = @TransactionID	
		-- Xoa Transaction truoc do neu la co ky han va rut truoc ky han
			-- Tinh so ngay gui
			DECLARE @NoDaysDeposited INT
			SELECT @NoDaysDeposited = DATEDIFF(minute, OpenedDate, @WithdrawalDate) - 1  -- minute for testing
				FROM Deposits
				WHERE DepositID = @DepositID
			-- Tim ky han
			DECLARE @TheTerm INT
			SELECT @TheTerm = Term FROM InterestTypes
							WHERE InterestTypeID = (SELECT InterestTypeID FROM Deposits
													WHERE DepositID = @DepositID)
			-- Neu la loai co ky han
			IF (@TheTerm > 0)
				BEGIN
					DECLARE @RemainingNumOfDays INT
					SET @RemainingNumOfDays = @NoDaysDeposited % (@TheTerm * 30)
					-- Neu rut giua ky
					IF (@RemainingNumOfDays != 0)
						BEGIN
							-- Xoa Transaction cu
							SELECT TOP 1 @TransactionID = TransactionID
								FROM Transactions
								WHERE DepositID = @DepositID 
								ORDER BY TransactionID DESC
							DELETE FROM Transactions
								WHERE TransactionID = @TransactionID			
						END
				END
		END
END
GO