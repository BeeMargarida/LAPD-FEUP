import numpy as np
import datetime
import cv2


class Detector(object):

    confThreshold = 0.5  # Confidence threshold
    maskThreshold = 0.3  # Mask threshold
    classes = None
    colors = []
    net = None
    lastAlert = None

    def __init__(self):
        classesFile = "mscoco_labels.names"
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

        textGraph = "./mask_rcnn_inception_v2_coco_2018_01_28.pbtxt"
        modelWeights = "./mask_rcnn_inception_v2_coco_2018_01_28/frozen_inference_graph.pb"

        self.net = cv2.dnn.readNetFromTensorflow(modelWeights, textGraph)
        self.lastAlert = datetime.datetime.now()

    def detect(self, frame):
        blob = cv2.dnn.blobFromImage(frame, swapRB=True, crop=False)

        # Set the input to the network
        self.net.setInput(blob)

        # Run the forward pass to get output from the output layers
        boxes, masks = self.net.forward(
            ['detection_out_final', 'detection_masks'])

        # Extract the bounding box and mask for each of the detected objects
        self.postprocess(boxes, masks, frame)

        # Put efficiency information.
        t, _ = self.net.getPerfProfile()
        label = 'Mask-RCNN : Inference time: %.2f ms' % (
            t * 1000.0 / cv2.getTickFrequency())
        cv2.putText(frame, label, (0, 15),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0))

    # For each frame, extract the bounding box and mask for each detected object
    # Draw the predicted bounding box, colorize and show the mask on the image
    def drawBox(self, frame, classId, conf, left, top, right, bottom, classMask):
        # Draw a bounding box.
        cv2.rectangle(frame, (left, top), (right, bottom), (255, 178, 50), 3)

        # Print a label of class.
        label = '%.2f' % conf
        if self.classes:
            assert(classId < len(self.classes))
            label = '%s:%s' % (self.classes[classId], label)

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

    def postprocess(self, boxes, masks, frame):
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
            diff = (datetime.datetime.now() - self.lastAlert).total_seconds()
            if (score > self.confThreshold and classId == 0 and diff > 20):

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
                self.drawBox(frame, classId, score, left,
                             top, right, bottom, classMask)
