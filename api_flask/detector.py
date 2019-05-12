import numpy as np
import datetime
import cv2


class Detector(object):

    confThreshold = 0.5  # Confidence threshold
    nmsThreshold = 0.4  # Mask threshold
    inpWidth = 416  # Width of network's input image
    inpHeight = 416
    classes = None
    colors = []
    net = None
    lastAlert = None

    def __init__(self):
        classesFile = "yolo/coco.names"
        with open(classesFile, 'rt') as f:
            self.classes = f.read().rstrip('\n').split('\n')

        # Load the colors
        colorsFile = "colors.txt"
        with open(colorsFile, 'rt') as f:
            colorsStr = f.read().rstrip('\n').split('\n')
        for i in range(len(colorsStr)):
            rgb = colorsStr[i].split(' ')
            color = np.array([float(rgb[0]), float(rgb[1]), float(rgb[2])])
            self.colors.append(color)

        modelConfiguration = "yolo/yolov3.cfg"
        modelWeights = "yolo/yolov3.weights"

        self.net = cv2.dnn.readNetFromDarknet(modelConfiguration, modelWeights)
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_OPENCV)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)
        self.lastAlert = datetime.datetime.now()

    def detect(self, frame, timestamp):
        blob = cv2.dnn.blobFromImage(
            frame, 1/255, (self.inpWidth, self.inpHeight), [0, 0, 0], 1, crop=False)
        # Set the input to the network
        self.net.setInput(blob)

        # Run the forward pass to get output from the output layers
        outs = self.net.forward(self.getOutputsNames(self.net))

        # Extract the bounding box and mask for each of the detected objects
        self.postprocess(frame, outs, timestamp)

        return

        # t, _ = net.getPerfProfile()
        # label = 'Inference time: %.2f ms' % (
        #     t * 1000.0 / cv2.getTickFrequency())
        # cv2.putText(frame, label, (0, 15),
        #             cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255))

    def getOutputsNames(self, net):
        # Get the names of all the layers in the network
        layersNames = net.getLayerNames()
        # Get the names of the output layers, i.e. the layers with unconnected outputs
        return [layersNames[i[0] - 1] for i in net.getUnconnectedOutLayers()]

    def postprocess(self, frame, outs, timestamp):
        frameHeight = frame.shape[0]
        frameWidth = frame.shape[1]

        classIds = []
        confidences = []
        boxes = []
        # Scan through all the bounding boxes output from the network and keep only the
        # ones with high confidence scores. Assign the box's class label as the class with the highest score.
        classIds = []
        confidences = []
        boxes = []
        for out in outs:
            for detection in out:
                scores = detection[5:]
                classId = np.argmax(scores)
                confidence = scores[classId]
                diff = (timestamp - self.lastAlert).total_seconds()
                if confidence > self.confThreshold and classId == 0 and diff > 5:
                    self.lastAlert = datetime.datetime.now()
                    center_x = int(detection[0] * frameWidth)
                    center_y = int(detection[1] * frameHeight)
                    width = int(detection[2] * frameWidth)
                    height = int(detection[3] * frameHeight)
                    left = int(center_x - width / 2)
                    top = int(center_y - height / 2)
                    classIds.append(classId)
                    confidences.append(float(confidence))
                    boxes.append([left, top, width, height])

        # Perform non maximum suppression to eliminate redundant overlapping boxes with
        # lower confidences.
        indices = cv2.dnn.NMSBoxes(boxes, confidences, self.confThreshold, self.nmsThreshold)
        for i in indices:
            i = i[0]
            box = boxes[i]
            left = box[0]
            top = box[1]
            width = box[2]
            height = box[3]
            self.drawPred(frame, classIds[i], confidences[i], left,
                    top, left + width, top + height)


    def drawPred(self, frame, classId, conf, left, top, right, bottom):
        # Draw a bounding box.
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 0, 255))
        
        label = '%.2f' % conf
            
        # Get the label for the class name and its confidence
        if self.classes:
            assert(classId < len(self.classes))
            label = '%s:%s' % (self.classes[classId], label)
    
        #Display the label at the top of the bounding box
        labelSize, baseLine = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
        top = max(top, labelSize[1])
        cv2.putText(frame, label, (left, top), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255,255,255))

        cv2.imwrite(
            "alerts/alert_{}.png".format(str(datetime.datetime.now()).replace(" ", "")), frame)

    