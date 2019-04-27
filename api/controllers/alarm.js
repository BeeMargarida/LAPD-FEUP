let child_proccess;

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