const express = require("express");
const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server, { origins: '*:*' });
const cv = require('opencv4nodejs');

const { createHistory } = require("./history");

let alarm = null;
let livestream = null;
let wCap;
let intervalId;

exports.startAlarm = async function (req, res, next) {
    try {
        var spawn = require('child_process').spawn;
        alarm = spawn('python3', ['intruder_detection/video.py']);

        alarm.stdout.on('data', function (data) {
            console.log('stdout: ' + data);
            
            createHistory({
                type: "Alert!",
                imagePath: data, //TODO: Change later
                user: req.user
            }, res, next)

        });

        alarm.stderr.on('data', function (data) {
            console.log('stderr: ' + data);
        });

        createHistory({
            type: "Turn On Alarm",
            imagePath: null, //TODO: Change later
            user: req.user
        }, res, next)
        .then((result) => {
            console.log(result);
            return res.status(200).json(result);
        });
    }
    catch (err) {
        return next({ message: "An error occurred while turning on the alarm. Please try again later." })
    }
}

exports.stopAlarm = async function (req, res, next) {
    if (alarm != null) {
        alarm.kill();
        alarm = null;

        createHistory({
            type: "Turn Off Alarm",
            imagePath: null, //TODO: Change later
            user: req.user
        }, res, next)
        .then((result) => {
            return res.status(200).json(result);
        });
    }
    return res.status(200);
}

exports.getAlarmState = async function (req, res, next) {
    if (child_proccess == null) {
        return res.status(200).json({ alarm: false })
    }
    return res.status(200).json({ alarm: true })
}

exports.getLiveStream = function (req, res, next) {
    // wCap = new cv.VideoCapture(0);

    // intervalId = setInterval(() => {
    //     const frame = wCap.read();
    //     const image = cv.imencode('.jpg', frame).toString('base64');
    //     io.emit('image', image);
    // }, 100)

    try {
        var spawn = require('child_process').spawn;
        livestream = spawn('python3', ['intruder_detection/video.py']);

        livestream.stdout.on('data', function (data) {
            console.log('stdout: ' + data);
        });

        livestream.stderr.on('data', function (data) {
            console.log('stderr: ' + data);
        });
        return res.status(200);
    }
    catch (err) {
        return next({ message: "An error occurred while turning on the livestream. Please try again later." })
    }

}

exports.stopLiveStream = function (req, res, next) {
    if (livestream != null) {
        livestream.kill();
        livestream = null;
    }
    return res.status(200);
}

server.listen(3030)
