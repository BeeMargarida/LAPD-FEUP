import numpy as np
import cv2
import sys
import argparse

cap = None

def startLivestream():
    cap = cv2.VideoCapture(0)
    print(cap)

    while(cap.isOpened()):
        ret, frame = cap.read()
        if ret==True:
            print(frame)
            sys.stdout.flush()

# def stopLivestream(cap):
#     if cap is not None:
#         cap.release()
#         cap = None

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument("-opt", "--option", type=int, required=True,
	help="0 - Livestream OFF | 1 - Livestream ON")
    args = vars(ap.parse_args())

    if args["option"] == 1:
        startLivestream()

