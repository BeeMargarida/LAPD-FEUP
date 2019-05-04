import numpy as np
import cv2
import sys
import datetime

assetsDir = "assets/"

def check_frame(frame, timestamp, avg):

    alert = False
    
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, tuple([21,21]), 0) #[21,21] is blur_size
    if avg is None:
        avg = gray.copy().astype("float")
        cv2.imwrite("{}avg.png".format(assetsDir), gray)
        return avg

    frameDelta = cv2.absdiff(gray, cv2.convertScaleAbs(avg))
    cv2.accumulateWeighted(gray, avg, 0.5)

    thresh = cv2.threshold(frameDelta, 5, 255,cv2.THRESH_BINARY)[1]
    thresh = cv2.dilate(thresh, None, iterations=2)
    im2 ,cnts, _ = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)

    #cv2.imwrite("im2_{}".format(timestamp), thresh)

    for c in cnts:
		# if the contour is too small, ignore it
        if cv2.contourArea(c) < 5000: # minimal area
            continue

		# compute the bounding box for the contour, draw it on the frame,
		# and update the text
        (x, y, w, h) = cv2.boundingRect(c)
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
        alert = True

    
    if alert == True:
        path = "alerts/" + "alert_{}.png".format(timestamp.replace(" " ,""))
        cv2.imwrite(assetsDir + path, frame)
        print(path)
        sys.stdout.flush()
        
    return avg


avg = None

cap = cv2.VideoCapture(0)

# Define the codec and create VideoWriter object
fourcc = cv2.VideoWriter_fourcc(*'XVID')
out = cv2.VideoWriter('{}video/output.avi'.format(assetsDir),fourcc, 5.0, (640,480))

while(cap.isOpened()):
    ret, frame = cap.read()
    if ret==True:
        #frame = cv2.flip(frame,0)
        avg = check_frame(frame,datetime.datetime.now(), avg)
        # write the flipped frame
        out.write(frame)

        #cv2.imshow('frame',frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    else:
        break

# Release everything if job is finished
cap.release()
out.release()
cv2.destroyAllWindows()


