const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.withdrawGet)
router.get('/print', passbookC.printWithdrawGet)
router.post('/', passbookC.withdrawPost)

module.exports = router;