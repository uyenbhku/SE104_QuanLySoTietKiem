const express = require('express');
const router = express.Router();
const homeC = require('../controllers/home.c.js')

router.get('/', homeC.homeGet)
router.post('/', homeC.updateparamPost)

router.post('/lockorunlock', homeC.blockOrunlock)
router.post('/add', homeC.addInterestType)
router.post('/update', homeC.updateInterestType)
module.exports = router;