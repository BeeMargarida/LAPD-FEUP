import socket
import subprocess
from flask import Flask, render_template, Response
from flask_cors import CORS
from camera import Camera
app = Flask(__name__)
CORS(app)
# keep runnign process global
proc = None

# def get_ip_address():
#     s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#     s.connect(("8.8.8.8", 80))
#     return s.getsockname()[0]


@app.route("/")
def hello():
    return render_template("page.html")


@app.route("/start", methods=['GET', 'POST'])
def start_talkingraspi():
    global proc
    print(" > Start talkingraspi!")
    proc = subprocess.Popen(
        ["python", "pi_surveillance.py", "-c", "conf.json"])
    print(" > Process id {}".format(proc.pid))
    return "Started!"


@app.route("/stop", methods=['GET', 'POST'])
def stop_talkingraspi():
    global proc
    print(" > Stop talkingraspi!")
    # subprocess.call(["kill", "-9", "%d" % proc.pid])
    proc.kill()
    print(" > Process {} killed!".format(proc.pid))
    return "Stopped!"


@app.route("/status", methods=['GET', 'POST'])
def status_talkingraspi():
    global proc
    if proc is None:
        print(" > Talkingraspi is resting")
        return "Resting!"
    if proc.poll() is None:
        print(" > Talking raspi is running (Process {})!".format(proc.pid))
        return "Running!"
    else:
        print(" > Talkingraspi is resting")
        return "Stopped!"


def gen(camera):
    """Video streaming generator function."""
    while True:
        frame = camera.get_frame()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')


@app.route('/video_feed')
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(Camera()),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5555, debug=False, threaded=True)
