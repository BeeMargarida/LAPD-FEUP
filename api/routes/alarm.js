const express = require("express");
const router = express.Router({ mergeParams: true });
const { startAlarm, stopAlarm, getLiveStream } = require("../controllers/alarm");

router.route("/start").post(startAlarm);
router.route("/stop").post(stopAlarm);
router.route("/livestream").get(getLiveStream);

module.exports = router;