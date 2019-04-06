const mongoose = require("mongoose");
mongoose.set("debug", true);
mongoose.Promise = Promise;
mongoose.connect("mongodb://localhost:27017/homesecurity", {
    keepAlive: true
});

module.exports.User = require("./user");
module.exports.History = require("./history");
