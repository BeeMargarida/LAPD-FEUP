const { server } = require('../config/config.js');

const streamArgs = [
	'-f',
	'image2pipe',
	'-i',
	'-',
	'-f',
	'mpegts',
	'-c:v',
	'mpeg1video',
	// "-q",
	// "10",
	'-b:v',
	'1000k',
	'-maxrate:v',
	'1000k',
	'-bufsize',
	'500k',
	'-an',
	`http://localhost:${server.streamPort}/${server.streamSecret}`
];

const spawn = require('child_process').spawn;
const ffmpegStream = spawn('ffmpeg', streamArgs);
ffmpegStream.stdin.setEncoding('binary');

const livestream = () => {

	ffmpegStream.stdout.on('data', (data) => {
		console.log('stdout: ' + data.toString());
	});

	ffmpegStream.stderr.on('data', (data) => {
		console.log('stderr: ' + data.toString());
	});

	ffmpegStream.on('exit', (code) => {
		console.log('child process exited with code ' + code.toString());
	});
	
};

module.exports = livestream;
