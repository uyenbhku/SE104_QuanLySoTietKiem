/*
Vao SQL Server Agent -> New Job 
->  Tab general: nhap ten Job, chon owner la account connect voi server
->  Tab steps: Tao 2 steps, cach tao 1 step: New..... -> nhap Name, Type (TSQL), Database (la database chua cai bang nay).
				Command: paste code cho step tuong ung

->  Tab schedules: tao 1 schedule moi, dat ten
				Thong so:
				- Schedule type: recurring
				- Frequency: occurs daily, recurs every 1 day
				- Daily frequence: occurs every 1 minute
				- Start day: ngay hien tai
				- No end date
==> Nhap OK

Luu y: phai chay server vao luc 0h thi moi thay nha, de test thi ong co the doi sang minute :v 
*/


-- step 1: cap nhat tien lai khi den ky
INSERT INTO Transactions 
SELECT Deposits.DepositID, 
		Balance * InterestTypes.InterestRate / 100 * NoDays / 360, 
		Balance * (1 + InterestTypes.InterestRate/100 * NoDays / 360), GETDATE()
FROM (SELECT TOP 1 WITH TIES *, DATEDIFF(minute, Transactions.TransactionDate, GETDATE()) AS NoDays -- doi day sang minute de test
		FROM Transactions 
		WHERE Balance > 0 -- is not withdrawn yet
		ORDER BY ROW_NUMBER() OVER(PARTITION BY DepositID ORDER BY TransactionID DESC)) 
	AS LatestTransactions JOIN Deposits ON LatestTransactions.DepositID = Deposits.DepositID
	JOIN InterestTypes ON Deposits.InterestTypeID = InterestTypes.InterestTypeID
WHERE Withdrawer IS NULL AND NoDays > 0
	  AND (Term = 0 OR NoDays % (Term * 30) = 0) -- minutes




-- step 2:  auto insert phieuGT moi vao transactions vao 0h ngay hom sau ngay gui 
INSERT INTO Transactions
SELECT DepositID, Fund, Fund, GETDATE() 
FROM Deposits D
WHERE Withdrawer IS NULL 
	 AND NOT EXISTS (SELECT * FROM Transactions T 
		    WHERE D.DepositID = T.DepositID)



