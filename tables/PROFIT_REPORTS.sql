USE Savings
GO

SET DATEFORMAT dmy

CREATE TABLE ProfitReports (
	RecordedDate  DATE NOT NULL, 
	TotalRevenue MONEY,
	TotalCost MONEY,
	TotalProfit MONEY
);

CREATE TABLE ReportDetails (
	RecordedDate DATE NOT NULL,
	InterestTypeID CHAR(10) NOT NULL,
	Revenue MONEY,
	Cost MONEY,
	Profit MONEY
)

-- Add primary key
ALTER TABLE ProfitReports ADD CONSTRAINT PK_Report PRIMARY KEY (RecordedDate);
ALTER TABLE ReportDetails ADD CONSTRAINT PK_ReportDetail PRIMARY KEY (RecordedDate, InterestTypeID);

-- Add foreign key on InterestTypeID
ALTER TABLE ReportDetails
ADD CONSTRAINT FK_ReportInterestTypeID
FOREIGN KEY (InterestTypeID) REFERENCES InterestTypes(InterestTypeID);

ALTER TABLE ReportDetails
ADD CONSTRAINT FK_RecordedDate
FOREIGN KEY (RecordedDate) REFERENCES ProfitReports(RecordedDate);




-- STORED PROCEDURE: MAKE REPORT By Day
GO
CREATE PROCEDURE dbo.makeReportByDay
					@Date Date -- format 'dmy'
AS 
BEGIN
	SET NOCOUNT ON
	IF (@Date > GETDATE())  -- cannot create reports for the future
		BEGIN
			RETURN 1	
		END
	-- if exists a report, only update existed record
	IF EXISTS (SELECT * FROM ProfitReports WHERE RecordedDate=@Date)
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
	SELECT Costs.RecordedDate, Costs.InterestTypeID, TotalRevenue, TotalCost, TotalRevenue - TotalCost as Profit
		FROM (SELECT ISNULL(CAST(OpenedDate AS DATE), @Date) AS RecordedDate, 
				IT.InterestTypeID, 
				ISNULL(SUM(Fund),0) AS TotalRevenue
			FROM (SELECT * FROM Deposits WHERE CAST(OpenedDate AS DATE) = @Date) D -- bang phu luu cac PhieuGT vao ngay @Date
					RIGHT JOIN InterestTypes IT ON IT.InterestTypeID = D.InterestTypeID
					GROUP BY CAST(OpenedDate AS DATE), IT.InterestTypeID) 
			AS Revenues -- bang phu luu ngay gui, LoaiTK, tong tien gui cua LoaiTK do
			FULL OUTER JOIN
			(SELECT ISNULL(CAST(TransactionDate AS DATE), @Date) AS RecordedDate, 
					InterestTypes.InterestTypeID, 
					-ISNULL(SUM(Changes), 0) AS TotalCost 
			FROM (SELECT * FROM Transactions
					WHERE Changes < 0 -- is a withdrawal
						AND CAST(TransactionDate AS DATE) = @Date -- at the given date
					) AS MoneyWithdrawn -- luu nhung transactions vao ngay @Date
					JOIN Deposits D ON D.DepositID = MoneyWithdrawn.DepositID
					RIGHT JOIN InterestTypes ON InterestTypes.InterestTypeID = D.InterestTypeID
					GROUP BY CAST(TransactionDate AS DATE), InterestTypes.InterestTypeID) 
			AS Costs -- bang phu luu ngay rut, loaiTK, tong tien rut ra loaiTK do
			ON Costs.InterestTypeID = Revenues.InterestTypeID

	-- summary details
	UPDATE ProfitReports
	SET TotalRevenue = (SELECT SUM(Revenue) FROM ReportDetails WHERE RecordedDate = @Date),
		TotalCost = (SELECT SUM(Cost) FROM ReportDetails WHERE RecordedDate = @Date),
		TotalProfit = (SELECT SUM(Profit) FROM ReportDetails WHERE RecordedDate = @Date)
	WHERE RecordedDate = @Date;
	-- return reports
	SELECT * FROM ProfitReports WHERE RecordedDate = @Date
	SELECT * FROM ReportDetails WHERE RecordedDate = @Date
END
GO



-- STORED PROCEDURE: Summary month report
GO
CREATE PROCEDURE dbo.summaryMonthReport
					@Month INT,
					@Year INT
AS
BEGIN
	IF (@Month < 1 OR @Month > 12 OR @Month > MONTH(GETDATE()) OR @Year > YEAR(GETDATE())) -- invalid month 
		BEGIN
			RETURN 1 -- cannot summary report
		END
	SELECT SUM(TotalRevenue) AS MonthRevenue, SUM(TotalCost) AS MonthCost, SUM(TotalProfit) AS MonthProfit
	FROM ProfitReports
	WHERE MONTH(RecordedDate) = @Month AND YEAR(RecordedDate) = @Year
END
GO



---- TESTING 
--EXEC  dbo.summaryMonthReport 5, 2023
--DELETE FROM ReportDetails
--DELETE FROM ProfitReports


--SELECT * FROM InterestTypes
--SELECT * FROM Deposits

--EXEC makeReportByDay'2023-05-28'
--EXEC makeReportByDay'2023-05-29'
--EXEC makeReportByDay'2023-05-30'

--SELECT * FROM ProfitReports
--SELECT * FROM ReportDetails