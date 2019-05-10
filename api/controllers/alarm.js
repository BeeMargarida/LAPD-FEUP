const express = require("express");
const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server, { origins: '*:*' });
const cv = require('opencv4nodejs');

const { createHistory } = require("./history");
const { runWebcamObjectDetect } = require("./detection");
const { opencvSettings } = require('../config/config');

let alarm = null;
let alarmOn = false;
let livestream = false;
let wCap = null;

exports.startAlarm = async function (req, res, next) {

    alarmOn = true;
    if(wCap == null) {
        wCap = new cv.VideoCapture(opencvSettings.camPort);
    }

    alarm = runWebcamObjectDetect(wCap, alarmOn, livestream, io, req, res, next);

    createHistory({
        type: "Turn On Alarm",
        imagePath: null, //TODO: Change later
        user: req.user
    }, res, next)
        .then((result) => {
            return res.status(200).json(result);
        });
}

exports.stopAlarm = async function (req, res, next) {
    if (alarmOn) {
        
        if(!livestream){
            clearInterval(alarm);
            alarm = null;
            wCap.release();
            wCap = null;
        }

        alarmOn = false;

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
    if (alarm == null) {
        return res.status(200).json({ alarm: false })
    }
    return res.status(200).json({ alarm: true })
}

exports.getLiveStream = async function (req, res, next) {

    if(wCap == null) {
        wCap = new cv.VideoCapture(opencvSettings.camPort);
    }
    
    livestream = true;

    if(alarm != null){
        clearInterval(alarm);
    }

    alarm = runWebcamObjectDetect(wCap, alarmOn, livestream, io, req, res, next); // Review this!
    return res.status(200).json({});
}

exports.stopLiveStream = async function (req, res, next) {
    livestream = false;
    clearInterval(alarm);
    alarm = runWebcamObjectDetect(wCap, alarmOn, livestream, io, req, res, next); // Review this!
    return res.status(200).json({});
}

server.listen(5555)

