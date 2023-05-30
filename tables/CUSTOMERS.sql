USE SAVINGS
GO

-- CREATE CUSTOMER TABLE
-- Creat Customer table
CREATE TABLE Customers
(
	CustomerID 	CHAR(10),
	CustomerName	VARCHAR(40),
	PhoneNumber	VARCHAR(20),
	CitizenID	VARCHAR(20),
	CustomerAddress	VARCHAR(100),
)
-- Add primary key
ALTER TABLE Customers ADD CONSTRAINT PK_Customers PRIMARY KEY (CustomerID)
