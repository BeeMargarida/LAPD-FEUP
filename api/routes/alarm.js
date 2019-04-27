const express = require("express");
const router = express.Router({ mergeParams: true });
const { startAlarm, stopAlarm } = require("../controllers/alarm");

router.route("/start").get(startAlarm);
router.route("/stop").get(stopAlarm);

module.exports = router;