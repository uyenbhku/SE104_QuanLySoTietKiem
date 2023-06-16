// const userM = require('../models/user.m');
const passbookM = require('../models/passbook.m')
const userM = require('../models/user.m')


module.exports = {
    homeGet: async (req, res) => {

        var currentDate = new Date()
        var Params = 0
        const accountType = await userM.getAccountTypeByUsername(req.session.passport.user)
        const isAdmin = (accountType[0].AccountTypeName == "Admin" ? true : false)
        if (!isAdmin) {
            var InterestTypeadad = await passbookM.getInterestType()
        }
        else {
            var InterestTypeadad = await passbookM.getInterestTypeAll()
            Params = await passbookM.getParams()
        }
        // console.log(InterestType);
        const sumDeposit = await passbookM.getSumDeposit()
        const monthReport = await passbookM.summaryMonthReport(currentDate.getMonth() + 1, currentDate.getFullYear())

        req.session.accountType = accountType[0].AccountTypeName
        res.render('home', {
            layout: "working",
            title: "Trang chủ",
            style: ["home.css", "table.css", "form.css"],
            script: "home.js",
            form: true,
            InterestTypeadad: InterestTypeadad,
            sumDeposit: sumDeposit[0].Total == null ? 0 : sumDeposit[0].Total,
            Monthwithdraw: monthReport[0].MonthCost == null ? 0 : monthReport[0].MonthCost,
            MonthDeposit: monthReport[0].MonthRevenue == null ? 0 : monthReport[0].MonthRevenue,
            hideForm: isAdmin,
            Params: (Params == 0) ? 0 : Params[0].MinimumDeposit,
        })
    },
    updateparamPost: async (req, res) => {
        const updateParam = await passbookM.updateParam(req.body.money)
        if (updateParam == "err")
            res.json({
                msg: "Lỗi khi thay đổi số tiền gửi tối thiểu!",
            })
        else {
            res.json({
                msg: "Đổi tiền gửi tối thiểu thành công",
            })
        }
    },
    blockOrunlock: async (req, res) => {
        const lockorunlock = await passbookM.blockOrunlock(req.body.text, req.body.InterestTypeID)
        if (lockorunlock == 'err')
            res.json({ msg: `Lỗi khi thay đổi trạng thái của loại tiết kiệm ${req.body.InterestTypeID}` })
        else
            res.json({ msg: `Thay đổi thành công` })
    },
    addInterestType: async (req, res) => {
        const addInterestType = await passbookM.addInterestType(req.body.InterestRate, req.body.Term, req.body.MinimumTimeToWithdrawal)
        if (addInterestType == 'err')
            res.json({ msg: `Lỗi trùng kì hạn và lãi suất vui lòng mở khóa hoặc sử dụng lại cái đã có` })
        else
            res.json({ msg: `Thêm thành công thành công` })
    },
    updateInterestType: async (req, res) => {
        const addInterestType = await passbookM.updateInterestType(req.body.InterestTypeID, req.body.MinimumTimeToWithdrawal)
        if (addInterestType == 'err')
            res.json({ msg: `Lỗi khi sửa thời gian tối thiểu` })
        else
            res.json({ msg: `Thay đổi thành công` })
    }
}