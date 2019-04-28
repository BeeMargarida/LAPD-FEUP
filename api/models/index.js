const mongoose = require("mongoose");
mongoose.set("debug", true);
mongoose.Promise = Promise;
const DB_CONNECTION = process.env.DB_CONNECTION || "mongodb://localhost:27017/homesecurity";
mongoose.connect(DB_CONNECTION, {
    useNewUrlParser: true
});

module.exports.User = require("./user");
module.exports.History = require("./history");
