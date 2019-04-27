
exports.startAlarm = async function (req, res, next) {
    var spawn = require('child_process').spawn,
    ls = spawn('python',['intruder_detection/video.py']);

    ls.stdout.on('data', function (data) {
        console.log('stdout: ' + data);
    });

    ls.stderr.on('data', function (data) {
        console.log('stderr: ' + data);
    });
}

exports.stopAlarm = async function (req, res, next) {

}