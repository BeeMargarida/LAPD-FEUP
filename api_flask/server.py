import socket
import subprocess
from flask import Flask, render_template, Response
#from flask_cors import CORS
import threading
from camera import Camera
from detector import Detector
import cv2
app = Flask(__name__)
#CORS(app)
# keep runnign process global
proc = None
detector = None
alarmThread = None
# def get_ip_address():
#     s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#     s.connect(("8.8.8.8", 80))
#     return s.getsockname()[0]


@app.route("/")
def hello():
    return render_template("page.html")

@app.route("/alarm", methods=['GET'])
def start_alarm():
    global alarmOn
    global alarmThread
    alarmOn = True
    alarmThread = threading.Thread(target=gen_alarm, args=(Camera(),))
    alarmThread.start();
    return Response(response="Alarm On!", status=200)

@app.route("/alarm/stop", methods=['GET'])
def stop_alarm():
    global alarmOn
    alarmOn = False
    return Response(response="Alarm Off!", status=200)

@app.route("/alarm/status", methods=['GET'])
def status_alarm():
    global alarmOn
    message = "On"
    if alarmOn == False:
        message = "Off"
    return Response(response=message, status=200)

def gen(camera):
    """Video streaming generator function."""
    while True:
        frame = camera.get_frame()
        #t = threading.Thread(target=detector.detect, args=(frame,))
        #t.start()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + cv2.imencode('.jpg', frame)[1].tobytes() + b'\r\n')

def gen_alarm(camera):
    while alarmOn:
        frame = camera.get_frame()
        detector.detect(frame)
    return

@app.route('/video_feed')
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(Camera()),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


if __name__ == "__main__":
    detector = Detector()
    app.run(host="0.0.0.0", port=5555, debug=False, threaded=True)
