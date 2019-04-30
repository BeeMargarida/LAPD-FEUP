const express = require("express");
const router = express.Router({ mergeParams: true });
const { startAlarm, stopAlarm, getLiveStream, stopLiveStream } = require("../controllers/alarm");

router.route("/start").post(startAlarm);
router.route("/stop").post(stopAlarm);
router.route("/livestream").get(getLiveStream);
router.route("/livestream/stop").post(stopLiveStream);

module.exports = router;