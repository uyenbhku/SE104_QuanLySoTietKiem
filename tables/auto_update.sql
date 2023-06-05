-- step 1: cap nhat tien lai khi den ky
INSERT INTO Transactions 
SELECT Deposits.DepositID, 
		Balance * InterestTypes.InterestRate / 100 * NoDays / 360, 
		Balance * (1 + InterestTypes.InterestRate/100 * NoDays / 360), GETDATE()
FROM (SELECT TOP 1 WITH TIES *, DATEDIFF(minute, Transactions.TransactionDate, GETDATE()) AS NoDays
		FROM Transactions 
		WHERE Balance > 0 -- is not withdrawn yet
		ORDER BY ROW_NUMBER() OVER(PARTITION BY DepositID ORDER BY TransactionID DESC)) 
	AS LatestTransactions JOIN Deposits ON LatestTransactions.DepositID = Deposits.DepositID
	JOIN InterestTypes ON Deposits.InterestTypeID = InterestTypes.InterestTypeID
WHERE Withdrawer IS NULL
	  AND (Term = 0 OR NoDays % (Term * 30) = 0) -- minutes




-- step 2:  auto insert phieuGT moi vao transactions vao 0h ngay hom sau ngay gui 
INSERT INTO Transactions
SELECT DepositID, Fund, Fund, GETDATE() 
FROM Deposits D
WHERE Withdrawer IS NULL
	 AND NOT EXISTS (SELECT * FROM Transactions T 
		    WHERE D.DepositID = T.DepositID)



