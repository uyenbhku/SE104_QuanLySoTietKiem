const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.reportGet)
router.post('/', passbookC.reportPost)

module.exports = router;