
const db = require('../config/connectDB')

module.exports = {
    addUser: async user => {
        try {
            oldeAccount = await db.Query(`select * from Accounts where Username='${user.Username}'`)
            if (!oldeAccount.length) {
                maxAccountId = await db.Query('select max(AccountID) as max  from Accounts')
                nextAccountId = parseInt(maxAccountId[0].max) + 1
                if (maxAccountId[0].max === null) maxAccountId[0].max = 0;
                a = await db.Query(`insert into Accounts (AccountID,Username,AccountTypeID, AccountPasword) values ('${nextAccountId}', N'${user.Username}', '${user.AccountTypeID}', N'${user.Password}')`)
                return 0
            }
            else return 1
        }
        catch (error) {
            console.log(error)
            return 2
        }
    },
    getAccountByUsername: async Username => {
        var rs = await db.Query(`select * from Accounts where Username= '${Username}'`)
        return rs;
    },
    getAccountTypeByUsername: async Username => {
        var rs = await db.Query(`select AccountTypeName  from AccountTypes where  AccountTypeID =(select AccountTypeID from Accounts where USERNAME='${Username}')`)
        return rs;
    },
    addCustomer: async Customer => {

        var rs = await db.Query(`exec dbo.addCustomer N'${Customer.CustomerName}', ${Customer.PhoneNumber}, ${Customer.CitizenID},N'${Customer.CustomerAddress}'`)
        return rs;
    },
    getCustomerDetailWithCitizenID: async (CitizenID = null) => {
        var rs = await db.Query(`EXEC dbo.getCustomerDetailWithCitizenID  '${CitizenID}' `)
        return rs;
    },
    getCustomersByCustomerName: async (CustomerName = null) => {
        if (CustomerName == null) {
            var rs = await db.Query(`select * from Customers`)
        }
        else {
            var rs = await db.Query(`select * from Customers where CustomerName='${CustomerName}' `)
        }
        return rs;
    },
    updateCustomer: async (Customer = null) => {
        if (Customer.CustomerName == null && Customer.CustomerAddress == null)
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , ${Customer.CustomerName} , ${Customer.PhoneNumber} , ${Customer.CitizenID} , ${Customer.CustomerAddress} `)
        else if (Customer.CustomerName == null)
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , ${Customer.CustomerName} , ${Customer.PhoneNumber} , ${Customer.CitizenID} , N'${Customer.CustomerAddress}' `)
        else if (Customer.CustomerAddress == null)
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , N'${Customer.CustomerName}' , ${Customer.PhoneNumber} , ${Customer.CitizenID} , ${Customer.CustomerAddress} `)
        else
            var rs = await db.Query(`exec dbo.updateCustomer ${Customer.CustomerID} , N'${Customer.CustomerName}' , ${Customer.PhoneNumber} , ${Customer.CitizenID} , N'${Customer.CustomerAddress}' `)
        return rs;
    },
}


