const express = require("express");
const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server);
const cv = require('opencv4nodejs');

let child_proccess;
let wCap;

exports.startAlarm = async function (req, res, next) {
    var spawn = require('child_process').spawn;
    child_proccess = spawn('python3',['intruder_detection/video.py']);

    child_proccess.stdout.on('data', function (data) {
        console.log('stdout: ' + data);
    });

    child_proccess.stderr.on('data', function (data) {
        console.log('stderr: ' + data);
    });
}

exports.stopAlarm = async function (req, res, next) {
    child_proccess.kill();
    return res.status(200);
}

exports.getLiveStream = function (req, res, next) {
    wCap = new cv.VideoCapture(0);
    
    setInterval(() => {
        const frame = wCap.read();
        const image = cv.imencode('.jpg', frame).toString('base64');
        io.emit('image', image);
    }, 100)
    
    return res.status(200);
}