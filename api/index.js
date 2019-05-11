/*
require("dotenv").config();
const express = require("express");
const app = express();
const cors = require("cors");
const morgan = require('morgan');
const bodyParser = require("body-parser");
const errorHandler = require("./controllers/error");
const authRoutes = require("./routes/auth");
const historyRoutes = require("./routes/history");
const alarmRoutes = require("./routes/alarm");
const { loginRequired, ensureCorrectUser } = require("./middleware/auth");

const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
//app.use(express.static('./assets'));

const http = require('http');
const path = require('path');
const staticFolder = path.join(__dirname, 'public');
app.use(morgan('dev'));
app.use('/public', express.static(staticFolder));

app.get('*', function (req, res) {
  res.sendFile('index.html', { root: staticFolder });
});
// HTTP server
var server = http.createServer(app);
server.listen(PORT, function () {
  console.log('HTTP server listening on port ' + PORT);
});
// WebSocket server
var io = require('socket.io')(server, {origins: '*:*'});
io.on('connection', require('./controllers/detection'));



app.use("/api/auth", authRoutes);
app.use("/api/history", loginRequired, historyRoutes);
app.use("/api/alarm", alarmRoutes);

app.use(function (req, res, next) {
    let err = new Error("Not Found");
    err.status = 404;
    next(err);
});

app.use(errorHandler);

app.listen(PORT, function () {
    console.log(`Server is starting on port ${PORT}`);
});
*/

require("dotenv").config();
const express = require("express");
const app = express();
const cors = require("cors");

const path = require('path');
const morgan = require('morgan');
const http = require('http');

const bodyParser = require("body-parser");
const errorHandler = require("./controllers/error");
const authRoutes = require("./routes/auth");
const historyRoutes = require("./routes/history");
const alarmRoutes = require("./routes/alarm");
const { loginRequired, ensureCorrectUser } = require("./middleware/auth");
const PORT = process.env.PORT || 3000;


app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(express.static('./assets'));

const staticFolder = path.join(__dirname, 'public');
app.use(morgan('dev'));
app.use('/public', express.static(staticFolder));


// TODO: Remove later
app.get('/', function (req, res) {
  res.sendFile('index.html', { root: staticFolder });
});


app.use("/api/auth", authRoutes);
app.use("/api/history", loginRequired, historyRoutes);
app.use("/api/alarm", loginRequired, alarmRoutes);

app.use(function (req, res, next) {
    let err = new Error("Not Found");
    err.status = 404;
    next(err);
});

app.use(errorHandler);

// HTTP server
var server = http.createServer(app);
server.listen(3000, function () {
  console.log('HTTP server listening on port ' + 3000);
});

module.exports.server = server;
