const express = require("express");
const router = express.Router({ mergeParams: true });
const { listHistory } = require("../controllers/history");

router.route("/").get(listHistory);

module.exports = router;