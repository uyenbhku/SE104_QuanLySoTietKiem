const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.createDepositGet)
router.get('/print', passbookC.printDepositsGet)
router.post('/getcustomes', passbookC.getcustomerspost)

router.post('/', passbookC.createDepositPost)

module.exports = router;