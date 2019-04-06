require("dotenv").config();
const express = require("express");
const app = express();
const cors = require("cors");
const bodyParser = require("body-parser");
const errorHandler = require("./controllers/error");
//const db = require("./models");
const authRoutes = require("./routes/auth");
const historyRoutes = require("./routes/history");
const { loginRequired, ensureCorrectUser } = require("./middleware/auth");

const PORT = process.env.PORT;

app.use(cors());
app.use(bodyParser.json());

app.use("/api/auth", authRoutes);
app.use("/api/history", loginRequired, historyRoutes);

app.use(function (req, res, next) {
    let err = new Error("Not Found");
    err.status = 404;
    next(err);
});

app.use(errorHandler);

app.listen(PORT, function () {
    console.log(`Server is starting on port ${PORT}`);
});