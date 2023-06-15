const express = require('express');
const router = express.Router();
const passbookC = require('../controllers/passbook.c.js')

router.get('/', passbookC.passbookGet)
router.post('/', passbookC.passbookPost)

router.post('/detail', passbookC.detailsPost)
router.post('/detail/change', passbookC.detailchangePost)
router.post('/detail/delete', passbookC.detaildeletePost)

module.exports = router;