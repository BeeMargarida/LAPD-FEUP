const express = require("express");
const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server, { origins: '*:*'});
const cv = require('opencv4nodejs');

const { createHistory } = require("./history");

let child_proccess = null;
let wCap;
let intervalId;

exports.startAlarm = async function (req, res, next) {
    try {
        var spawn = require('child_process').spawn;
	child_proccess = spawn('ls');
        child_proccess = spawn('python3',['intruder_detection/video.py']);
    
        child_proccess.stdout.on('data', function (data) {
            console.log('stdout: ' + data);
        });
    
        child_proccess.stderr.on('data', function (data) {
            console.log('stderr: ' + data);
        });
        
        let history = createHistory({
            type: "Turn On Alarm",
            imagePath: null, //TODO: Change later
            user: req.user
        }, res, next);
	
	history.then((result) => {
	    console.log(result);
            return res.status(200).json(result);
	});
    }
    catch(err) {
        return next({ message: "An error occurred while turning on the alarm. Please try again later."})
    }
}

exports.stopAlarm = async function (req, res, next) {
    if(child_process != null) {
	child_proccess.kill();
    	child_proccess = null;

   	let history =  createHistory({
        	type: "Turn Off Alarm",
        	imagePath: null, //TODO: Change later
        	user: req.user
   	 }, res, next);

    	history.then((result) => {
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
