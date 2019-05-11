const path = require('path');
const fs = require('fs');
const cv = require('opencv4nodejs');

const { createHistory } = require("./history");
const { opencvSettings, classNames } = require('../config/config');

if (!cv.xmodules.dnn) {
    throw new Error('exiting: opencv4nodejs compiled without dnn module');
}

const modelPath = path.resolve(__dirname, '../intruder_detection/models/frozen_inference_graph.pb');
const configPath = path.resolve(
    __dirname,
    '../intruder_detection/models/ssd_mobilenet_v2_coco_2018_03_29.pbtxt'
);

/*if (!fs.existsSync(modelPath) || !fs.existsSync(configPath)) {
    console.log('could not find tensorflow object detection model');
    console.log(
        'download the model from: https://github.com/opencv/opencv/wiki/TensorFlow-Object-Detection-API#use-existing-config-file-for-your-model'
    );
    //throw new Error('exiting: could not find tensorflow object detection model');
}*/

// initialize tensorflow darknet model from modelFile
const net = cv.readNetFromTensorflow(modelPath, configPath);

const assetsDir = "assets/"
// set webcam interval
const camInterval = 1000 / opencvSettings.camFps;
let lastAlert = new Date();
let pathAlert = "";

const objectDetect = async (img, user) => {
    // object detection model works with 300 x 300 images
    const size = new cv.Size(300, 300);
    const vec3 = new cv.Vec(0, 0, 0);

    // network accepts blobs as input
    const inputBlob = cv.blobFromImage(img, 1, size, vec3, true, true);
    net.setInput(inputBlob);

    // forward pass input through entire network, will return
    // classification result as 1x1xNxM Mat
    const outputBlob = net.forward();

    // get height and width from the image
    const [imgHeight, imgWidth] = img.sizes;
    const numRows = outputBlob.sizes.slice(2, 3);

    for (let y = 0; y < numRows; y += 1) {
        const confidence = outputBlob.at([0, 0, y, 2]);
        if (confidence > 0.5) {

            const classId = outputBlob.at([0, 0, y, 1]);
            let timestamp = new Date();
            let diff = (timestamp - lastAlert) / 1000;

            if (classId == 1 && (diff > opencvSettings.secondsDiff)) {

                lastAlert = timestamp;

                const className = classNames[classId];
                const boxX = imgWidth * outputBlob.at([0, 0, y, 3]);
                const boxY = imgHeight * outputBlob.at([0, 0, y, 4]);
                const boxWidht = imgWidth * outputBlob.at([0, 0, y, 5]);
                const boxHeight = imgHeight * outputBlob.at([0, 0, y, 6]);

                const pt1 = new cv.Point(boxX, boxY);
                const pt2 = new cv.Point(boxWidht, boxHeight);
                const rectColor = new cv.Vec(23, 230, 210);
                const rectThickness = 2;
                const rectLineType = cv.LINE_8;

                // draw the rect for the object
                img.drawRectangle(pt1, pt2, rectColor, rectThickness, rectLineType);

                const text = `${className} ${confidence.toFixed(5)}`;
                const org = new cv.Point(boxX, boxY + 15);
                const fontFace = cv.FONT_HERSHEY_SIMPLEX;
                const fontScale = 0.5;
                const textColor = new cv.Vec(123, 123, 255);
                const thickness = 2;

                // put text on the object
                img.putText(text, org, fontFace, fontScale, textColor, thickness);

                pathAlert = "alerts/" + "alert_" + timestamp.toISOString() + ".png";
                cv.imwrite(assetsDir + pathAlert, img);

                createHistory({
                    type: "Alert!",
                    imagePath: pathAlert,
                    user: user
                })
                    .then(() => { })
                    .catch((err) => console.log(err));

            }
        }
    }

    // return the jpg image
    return cv.imencode('.jpg', img);
};


exports.runWebcamObjectDetect = function (camera, socket, alarmOn, livestreamOn, user) {

    let intervalId = setInterval(function () {
        readFrame(camera, socket, alarmOn, livestreamOn, user)
        .then((frame) => {
          if(frame != null && alarmOn) {
            objectDetect(frame, user);
          }  
        })
        .catch((err) => { throw err;});
    }, camInterval);

    return intervalId;

};

async function readFrame(camera, socket, alarmOn, livestreamOn, user){
    const frame = camera.read();
    if (frame.empty) return null;

    if (livestreamOn && socket != null) {
        socket.emit('frame', { buffer: cv.imencode('.png', frame).toString('base64') });
    }
    
}
