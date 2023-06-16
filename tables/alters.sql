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




--- 9h15
-- Doi datatype
ALTER TABLE InterestTypes
ALTER COLUMN InterestRate DECIMAL(17, 2)


-- Doi datatype
ALTER PROCEDURE dbo.addInterestType
			@InterestRate DECIMAL(17,2), 
			@Term INT,
			@MinimumTimeToWithdrawal INT = 0
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @TypeName VARCHAR(11)
	SELECT @TypeName = 'LS' + CONVERT(VARCHAR, @InterestRate) + '_KH' + CONVERT(VARCHAR, @Term)
	INSERT INTO InterestTypes (InterestRate, Term, MinimumTimeToWithdrawal, InterestTypeName)
	VALUES (@InterestRate, @Term, @MinimumTimeToWithdrawal, @TypeName)
		-- return 0 thanh cong
END