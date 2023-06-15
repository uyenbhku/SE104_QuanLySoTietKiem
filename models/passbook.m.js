const db = require('../config/connectDB')

module.exports = {
    addDeposits: async Deposits => {
        rs = await db.Query(`EXEC dbo.addDeposit '${Deposits.CustomerID}','${Deposits.InterestTypeID}','${Deposits.Fund}'`)
        return rs
    },
    addWithdrawal: async (DepositID, Withdrawer) => {
        rs = await db.Query(`EXEC dbo.addWithdrawal '${DepositID}','${Withdrawer}'`)
        return rs
    },
    getParams: async () => {
        rs = await db.Query(`select * from Params`)
        return rs
    },
    getInterestType: async (Term = null, InterestRate = null) => {
        var rs = await db.Query(`EXEC dbo.getInterestType ${Term}, ${InterestRate}`)
        return rs;
    },
    getInterestTypeAll: async () => {
        var rs = await db.Query(`select * from InterestTypes `)
        return rs;
    },
    getSumDeposit: async () => {
        var rs = await db.Query(`EXEC  dbo.sumActiveDeposit `)
        return rs;
    },
    getDeposit: async (DepositID) => {
        var rs = await db.Query(`exec dbo.getDeposit ${DepositID}  `)
        return rs;
    },
    searchDeposit: async (citizenID, depositID, dateID) => {
        if (dateID !== null)
            var rs = await db.Query(`EXEC dbo.searchDeposit ${depositID},${citizenID},'${dateID}' `)
        else
            var rs = await db.Query(`EXEC dbo.searchDeposit ${depositID},${citizenID},${dateID} `)
        return rs;
    },
    makeReportByDay: async Day => {
        var rs = await db.QueryALL(`exec dbo.makeReportByDay '${Day}'`)
        return rs
    },
    summaryMonthReport: async (Month, Year) => {
        var rs = await db.Query(`exec dbo.summaryMonthReport '${Month}','${Year}'`)
        return rs
    },
    deleteWithdrawal: async (DepositID) => {
        var rs = await db.Query(`exec dbo.deleteWithdrawal ${DepositID}`)
        return rs
    },
    deleteDeposit: async (DepositID) => {
        var rs = await db.Query(`exec dbo.deleteDeposit ${DepositID}`)
        return rs
    },
    deleteDepositWithAdmin: async (DepositID) => {
        const deleteTransactions = db.Query(`delete Transactions where DepositID= ${DepositID}`)
        var rs = await db.Query(`delete  Deposits where DepositID= ${DepositID}`)
        return rs
    },
    updateParam: async (MinimumDeposit) => {
        var rs = await db.Query(`exec dbo.updateMinimumDeposit '${MinimumDeposit}' `)
        return rs
    },
    blockOrunlock: async (state, InterestTypeID) => {
        if (state == 'Khóa')
            var rs = await db.Query(`exec dbo.blockInterestType ${InterestTypeID}`)
        else if (state == "Mở")
            var rs = await db.Query(`exec dbo.unblockInterestType  ${InterestTypeID}`)
        return rs
    },
    addInterestType: async (InterestRate, Term, MinimumTimeToWithdrawal) => {
        var rs = await db.Query(`exec dbo.addInterestType  ${InterestRate},${Term},${MinimumTimeToWithdrawal}`)
        return rs
    },
    updateInterestType: async (InterestTypeID, MinimumTimeToWithdrawal) => {

        var rs = await db.Query(`exec dbo.updateInterestType ${InterestTypeID},${MinimumTimeToWithdrawal}`)
        return rs
    }
}

