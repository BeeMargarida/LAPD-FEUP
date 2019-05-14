const cv = require('opencv4nodejs');
const { createHistory } = require("./history");
const { runWebcamObjectDetect } = require("./detection");
const { opencvSettings } = require('../config/config');


let alarm = null;
let alarmOn = false;
let livestream = false;
let wCap = null;
let io = null;

function startSocketConnection() {
    if (io == null) {
        const server = require("../index").server;
        io = require('socket.io')(server);
    }
    return io;
}

function getCamera() {
    if (wCap == null) {
        wCap = new cv.VideoCapture(opencvSettings.camPort);
    }
}

function stopCamera() {
    if(wCap != null) {
        wCap.release();
        wCap = null;
    }
}

exports.startAlarm = function (req, res, next) {
    alarmOn = true;

    getCamera();

    if (livestream) {
        clearInterval(alarm);
    }
    alarm = runWebcamObjectDetect(wCap, null, alarmOn, livestream, req.user)

    createHistory({
        type: "Turn On Alarm",
        imagePath: null,
        user: req.user
    })
        .then((result) => {
            return res.status(200).json(result);
        })
        .catch((err) => next(err))

}

exports.stopAlarm = async function (req, res, next) {
    if (alarmOn) {

        // If livestream is off, clear everything
        if (!livestream) {
            clearInterval(alarm);
            alarm = null;
            stopCamera();
        }

        alarmOn = false;

        createHistory({
            type: "Turn Off Alarm",
            imagePath: null,
            user: req.user
        }, res, next)
            .then((result) => {
                return res.status(200).json(result);
            });
    }
    return res.status(200);
}

exports.getAlarmState = async function (req, res, next) {
    if (!alarmOn) {
        return res.status(200).json({ alarm: false })
    }
    return res.status(200).json({ alarm: true })
}

exports.getLiveStream = async function (req, res, next) {

    if (!livestream) {

        getCamera();

        livestream = true;

        // If alarm was on, restart it
        if (alarmOn) {
            clearInterval(alarm);
        }
        startSocketConnection();
        io.on('connection', (socket) => { alarm = runWebcamObjectDetect(wCap, socket, alarmOn, livestream, req.user) });
    }

    return res.status(200).json({});
}

exports.stopLiveStream = function (req, res, next) {
    console.log("STOP LIVESTREAM");
    livestream = false;
    clearInterval(alarm);

    // If alarm is on, restart it
    if(alarmOn){
        alarm = runWebcamObjectDetect(wCap, null, alarmOn, livestream, req.user);
    }
    else {
        alarm = null;
        stopCamera();
    }
    return res.status(200).json({});
}

