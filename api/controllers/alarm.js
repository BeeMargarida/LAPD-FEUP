const express = require("express");
const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server, { origins: '*:*'});
const cv = require('opencv4nodejs');

const { createHistory } = require("./history");

let child_proccess;
let wCap;
let intervalId;

exports.startAlarm = async function (req, res, next) {
    try {
        var spawn = require('child_process').spawn;
        child_proccess = spawn('python3',['intruder_detection/video.py']);
    
        child_proccess.stdout.on('data', function (data) {
            console.log('stdout: ' + data);
        });
    
        child_proccess.stderr.on('data', function (data) {
            console.log('stderr: ' + data);
        });
    }
    catch(err) {
        return next({ message: "An error occurred while turning on the alarm. Please try again later."})
    }

    createHistory({
        type: "Turn On Alarm",
        imagePath: null, //TODO: Change later
        user: req.user
    }, res, next);

    return res.status(200);
}

exports.stopAlarm = async function (req, res, next) {
    child_proccess.kill();
    
    createHistory({
        type: "Turn Off Alarm",
        imagePath: null, //TODO: Change later
        user: req.user
    }, res, next);

    return res.status(200);
}

exports.getLiveStream = function (req, res, next) {
    wCap = new cv.VideoCapture(0);
    
    intervalId = setInterval(() => {
        const frame = wCap.read();
        const image = cv.imencode('.jpg', frame).toString('base64');
        io.emit('image', image);
    }, 100)
    
    return res.status(200);
}

exports.stopLiveStream = function(req,res,next) {
    clearInterval(intervalId);
    return res.status(200);
}

server.listen(3030)