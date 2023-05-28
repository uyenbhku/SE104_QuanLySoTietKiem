USE SAVINGS
GO

CREATE TABLE AccountTypes( -- NHOMNGUOIDUNG
	AccountTypeID INT,
	AccountTypeName VARCHAR(20),
);

ALTER TABLE AccountTypes 
ADD CONSTRAINT PK_AccountTypes 
PRIMARY KEY(AccountTypeID); 


CREATE TABLE Accounts( -- NGUOIDUNG
	AccountID INT,
	Username VARCHAR(20),
	AccountTypeID VARCHAR(20),
	AccountPassword VARCHAR(50),
);

ALTER TABLE Accounts 
ADD CONSTRAINT PK_Accounts 
PRIMARY KEY(AccountID); 

ALTER TABLE Accounts 
ADD CONSTRAINT FK_Accounts_AccountTypes 
FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID); 


CREATE TABLE UserFunctionality( -- CHUCNANG
	UserFunctionalityID INT,
	UserFunctionalityName VARCHAR(20),
	UFNDescription VARCHAR(100),
);

ALTER TABLE UserFunctionality 
ADD CONSTRAINT PK_UserFunctionality 
PRIMARY KEY(UserFunctionalityID);


CREATE TABLE UserAuthorization( -- PHANQUYEN
	AccountTypeID INT,
	UserFunctionalityID INT,
);

ALTER TABLE UserAuthorization 
ADD CONSTRAINT PK_AccountTypes_UserFunctionality 
PRIMARY KEY(AccountTypeID, UserFunctionalityID);

ALTER TABLE UserAuthorization 
ADD CONSTRAINT FK_UserAuthorization_AccountTypes 
FOREIGN KEY (AccountTypeID) REFERENCES AccountTypes(AccountTypeID);

ALTER TABLE UserAuthorization 
ADD CONSTRAINT FK_UserAuthorization_UserFunctionality 
FOREIGN KEY (UserFunctionalityID) REFERENCES UserFunctionality(UserFunctionalityID);
