# python pi_surveillance.py --conf conf.json

# import the necessary packages
# from dropbox.client import DropboxOAuth2FlowNoRedirect
# from dropbox.client import DropboxClient
# from picamera.array import PiRGBArray
# from picamera import PiCamera
from utils import send_email, TempImage
import argparse
import warnings
import datetime
import json
import socketio
import json
import numpy as np
import time
import cv2
import base64
import os
from flask_cors import CORS


# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-c", "--conf", required=True,
                help="path to the JSON configuration file")
ap.add_argument("-d", "--debug", required=False,
                help="debug mode on/off")
args = vars(ap.parse_args())

# filter warnings, load the configuration and initialize the Dropbox
# client
warnings.filterwarnings("ignore")
conf = json.load(open(args["conf"]))
client = None

# set debug mode on
if args['debug']:
    print(' > Debug mode is on !')
    debug_mode = True
else:
    debug_mode = False

confThreshold = 0.5  # Confidence threshold
maskThreshold = 0.3  # Mask threshold

classesFile = "mscoco_labels.names"
classes = None
with open(classesFile, 'rt') as f:
    classes = f.read().rstrip('\n').split('\n')

# Load the colors
colorsFile = "colors.txt"
with open(colorsFile, 'rt') as f:
    colorsStr = f.read().rstrip('\n').split('\n')
colors = []
for i in range(len(colorsStr)):
    rgb = colorsStr[i].split(' ')
    color = np.array([float(rgb[0]), float(rgb[1]), float(rgb[2])])
    colors.append(color)

textGraph = "./mask_rcnn_inception_v2_coco_2018_01_28.pbtxt"
modelWeights = "./mask_rcnn_inception_v2_coco_2018_01_28/frozen_inference_graph.pb"

net = cv2.dnn.readNetFromTensorflow(modelWeights, textGraph)
lastAlert = datetime.datetime.now()

sio = socketio.AsyncServer()
app = socketio.ASGIApp(sio)# Object Detection

# For each frame, extract the bounding box and mask for each detected object
# Draw the predicted bounding box, colorize and show the mask on the image


def drawBox(frame, classId, conf, left, top, right, bottom, classMask):
    # Draw a bounding box.
    cv2.rectangle(frame, (left, top), (right, bottom), (255, 178, 50), 3)

    # Print a label of class.
    label = '%.2f' % conf
    if classes:
        assert(classId < len(classes))
        label = '%s:%s' % (classes[classId], label)

    # Display the label at the top of the bounding box
    labelSize, baseLine = cv2.getTextSize(
        label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
    top = max(top, labelSize[1])
    cv2.rectangle(frame, (left, top - round(1.5*labelSize[1])), (left + round(
        1.5*labelSize[0]), top + baseLine), (255, 255, 255), cv2.FILLED)
    cv2.putText(frame, label, (left, top),
                cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 0, 0), 1)

    cv2.imwrite(
        "alerts/alert_{}.png".format(str(datetime.datetime.now()).replace(" ", "")), frame)

    # Resize the mask, threshold, color and apply it on the image
    # classMask = cv2.resize(classMask, (right - left + 1, bottom - top + 1))
    # mask = (classMask > maskThreshold)
    # roi = frame[top:bottom+1, left:right+1][mask]

    # color = colors[classId % len(colors)]
    # # Comment the above line and uncomment the two lines below to generate different instance colors
    # #colorIndex = random.randint(0, len(colors)-1)
    # #color = colors[colorIndex]

    # frame[top:bottom+1, left:right+1][mask] = (
    #     [0.3*color[0], 0.3*color[1], 0.3*color[2]] + 0.7 * roi).astype(np.uint8)

    # # Draw the contours on the image
    # mask = mask.astype(np.uint8)
    # im2, contours, hierarchy = cv2.findContours(
    #     mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    # cv2.drawContours(frame[top:bottom+1, left:right+1],
    #                 contours, -1, color, 3, cv2.LINE_8, hierarchy, 100)


def postprocess(boxes, masks):
    # Output size of masks is NxCxHxW where
    # N - number of detected boxes
    # C - number of classes (excluding background)
    # HxW - segmentation shape
    numClasses = masks.shape[1]
    numDetections = boxes.shape[2]

    frameH = frame.shape[0]
    frameW = frame.shape[1]

    for i in range(numDetections):
        box = boxes[0, 0, i]
        mask = masks[i]
        score = box[2]
        classId = int(box[1])
        diff = (datetime.datetime.now() - lastAlert).total_seconds()
        if (score > confThreshold and classId == 0 and diff > 20):

            # Extract the bounding box
            left = int(frameW * box[3])
            top = int(frameH * box[4])
            right = int(frameW * box[5])
            bottom = int(frameH * box[6])

            left = max(0, min(left, frameW - 1))
            top = max(0, min(top, frameH - 1))
            right = max(0, min(right, frameW - 1))
            bottom = max(0, min(bottom, frameH - 1))

            # Extract the mask for the object
            classMask = mask[classId]

            # Draw bounding box, colorize and show the mask on the image
            drawBox(frame, classId, score, left, top, right, bottom, classMask)


# initialize the camera and grab a reference to the raw camera capture
# print("[INFO] warming up...")
# time.sleep(conf["camera_warmup_time"])
print('[INFO] talking raspi started !!')

camera = cv2.VideoCapture(0)
while True:

    # Get frame from the video
    hasFrame, frame = camera.read()

    # Stop the program if reached end of video
    if not hasFrame:
        print("Done processing !!!")
        break

    blob = cv2.dnn.blobFromImage(frame, swapRB=True, crop=False)

    # Set the input to the network
    net.setInput(blob)

    # Run the forward pass to get output from the output layers
    boxes, masks = net.forward(['detection_out_final', 'detection_masks'])

    # Extract the bounding box and mask for each of the detected objects
    postprocess(boxes, masks)

    # Put efficiency information.
    t, _ = net.getPerfProfile()
    label = 'Mask-RCNN : Inference time: %.2f ms' % (
        t * 1000.0 / cv2.getTickFrequency())
    cv2.putText(frame, label, (0, 15),
                cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0))

    #data = {"buffer": base64.b64encode(frame)}
    sio.emit('frame', base64.b64encode(frame))
