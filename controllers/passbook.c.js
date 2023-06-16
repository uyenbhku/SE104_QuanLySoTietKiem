const userM = require('../models/user.m');
const passbookM = require('../models/passbook.m');
const { Int } = require('mssql');


module.exports = {
    getcustomerspost: async (req, res) => {
        customer = await userM.getCustomerDetailWithCitizenID(req.body.id)
        if (customer.length == 0)
            res.json({ status: false })
        else
            res.json({ status: true, data: customer[0] })
    },
    createDepositGet: async (req, res) => {
        const InterestType = await passbookM.getInterestType()
        const Params = await passbookM.getParams()
        res.render('createDeposit', {
            active: { deposit: true },
            layout: "working",
            title: "Gửi tiền",
            style: ["form.css"],
            script: "createdeposit.js",
            form: true,
            InterestType: InterestType,
            MinMoneyDeposit: null,
            Params: (Params.length == 0) ? 0 : Params[0].MinimumDeposit
        })
    },
    createDepositPost: async (req, res) => {
        const customer = await userM.getCustomerDetailWithCitizenID(req.body.citizenID)
        const InterestTypeID = await passbookM.getInterestType(req.body.type.split(' ')[0])
        var CustomerID = -1
        if (customer.length == 0) {
            Customers = {
                CustomerName: req.body.fullname,
                PhoneNumber: req.body.phone,
                CitizenID: req.body.citizenID,
                CustomerAddress: req.body.address,
            }
            CustomerID = await userM.addCustomer(Customers)
            CustomerID = CustomerID[0].CustomerID
            if (!CustomerID)
                res.json({ msg: "Lỗi khi thêm khách hàng!" })
        }
        else {
            CustomerID = customer[0].CustomerID
        }
        Deposits = {
            CustomerID: CustomerID,
            InterestTypeID: InterestTypeID[0].InterestTypeID,
            Fund: req.body.deposit
        }
        const DepositInfo = await passbookM.addDeposits(Deposits)
        if (DepositInfo[0].err != 1) {
            req.session.printdeposit = { DepositID: DepositInfo[0].DepositID }
            res.json({ msg: "Gửi tiền thành công" })
        }
        else {
            res.json({ msg: "Lỗi tạo phiếu gửi!" })
        }
    },
    printDepositsGet: async (req, res) => {
        data = await passbookM.getDeposit(req.session.printdeposit.DepositID)
        res.render('printDeposit', {
            layout: "print",
            title: "In phiếu gửi tiền",
            script: "printDeposit.js",
            data: data[0]
        })
    },

    withdrawGet: (req, res) => {
        res.render('withdrawMoney', {
            active: { withdraw: true },
            layout: "working",
            title: "Rút tiền",
            style: ["form.css"],
            script: "withdraw.js",
            form: true,
        })
    },
    withdrawPost: async (req, res) => {
        const addwithdraw = await passbookM.addWithdrawal(req.body.depositID, req.body.fullname)
        // console.log(addwithdraw)
        if (addwithdraw === 'err') {
            res.json({ msg: `Phiếu gửi với mã ${req.body.depositID} chưa tới ngày rút tối thiểu! Vui lòng quay lại sau.` })
        }
        else if (addwithdraw[0].err === 1) {
            res.json({ msg: `Phiếu gửi với mã ${req.body.depositID} không tồn tại! Vui lòng nhập lại mã phiếu gửi.` })
        }
        else if (addwithdraw[0].err === 2) {
            // req.session.printdeposit = { DepositID: req.body.depositID, Withdrawn: 324324 }
            res.json({ msg: `Phiếu gửi với mã ${req.body.depositID} đã rút và hủy.` })
        }
        else if (typeof (addwithdraw) === "object") {
            req.session.printdeposit = { DepositID: req.body.depositID, Withdrawn: addwithdraw[0].Withdrawn }
            res.json({ msg: "Rút tiền thành công" })
        }
        else
            res.json({ msg: "erro" })
    },
    printWithdrawGet: async (req, res) => {
        data = await passbookM.getDeposit(req.session.printdeposit.DepositID)
        data[0].Withdrawn = req.session.printdeposit.Withdrawn
        res.render('printWithdraw', {
            layout: "print",
            title: "In phiếu rút tiền",
            script: "printWithdraw.js",
            data: data[0]
        })
    },
    passbookGet: async (req, res) => {
        res.render('search', {
            active: { search: true },
            layout: "working",
            title: "Tra Cứu",
            style: ["modal.css", "form.css", "table.css"],
            script: "search.js",
            form: true,
            detailDeposit: false
        })
    },
    passbookPost: async (req, res) => {
        const citizenID = (req.body.citizenID == "") ? null : req.body.citizenID
        const depositID = (req.body.depositID == "") ? null : req.body.depositID
        const dateID = (req.body.dateID == "") ? null : req.body.dateID
        detailDeposit = await passbookM.searchDeposit(citizenID, depositID, dateID)
        res.json({
            detailDeposit: detailDeposit
        })
    },
    detailsPost: async (req, res) => {
        depositInfo = await passbookM.getDeposit(req.body.DepositID)

        res.json({
            depositInfo: depositInfo[0],
        })
    },
    detailchangePost: async (req, res) => {
        if (req.body.DepositID != false) {
            deleteWithdrawal = await passbookM.deleteWithdrawal(req.body.DepositID)
            if (deleteWithdrawal == "err")
                return res.json({
                    status: false,
                    mess: "Warning: Không được đổi người rút sau khi lập phiếu gửi quá 30 phút"
                })
        }
        updataCustomer = await userM.updateCustomer(req.body)
        res.json({
            status: true,
            mess: "Sửa thông tin thành công"
        })
    },
    detaildeletePost: async (req, res) => {
        if (req.session.accountType != "Admin") {
            var deleteDeposit = await passbookM.deleteDeposit(req.body.DepositID)
            if (deleteDeposit == 'err')
                return res.json({ status: false, mess: "Xóa phiếu thất bại do bạn không phải là admin nên chỉ xóa trước 30 phút lập phiếu!" })
            res.json({ status: true, mess: "Xóa phiếu thành công" })

        }
        else {
            var deleteDeposit = await passbookM.deleteDepositWithAdmin(req.body.DepositID)
            if (deleteDeposit == 'err')
                return res.json({ status: false, mess: "Lỗi khi xóa phiếu" })
            res.json({ status: true, mess: "Xóa phiếu thành công" })
        }
    },
    reportGet: (req, res) => {
        res.render('report', {
            active: { report: true },
            layout: "working",
            title: "Tra Cứu",
            style: ["report.css", "form.css", "table.css"],
            script: "report.js",
            form: true,
        })
    },
    reportPost: async (req, res) => {
        const detailReport = await passbookM.makeReportByDay(req.body.dateID)
        res.json({
            detailReport: (detailReport === "err") ? false : detailReport,
        })
    },


}