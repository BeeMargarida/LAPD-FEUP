import socket
import subprocess
import threading
import datetime
import cv2
import functools
import jwt
from flask import Flask, render_template, Response, request, abort
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_mongoengine import MongoEngine, Document
from werkzeug.security import generate_password_hash, check_password_hash
from detector import Detector
from camera import Camera
app = Flask(__name__)


#########################################
#            DATABASE SETUP             #
#########################################


app.config['MONGODB_SETTINGS'] = {
    'db': 'homesecurity',
    'host': 'mongodb://lapd:lapd@178.166.11.252:27017/homesecurity'
}

db = MongoEngine(app)
app.config['SECRET_KEY'] = 'asdhuiaisbdpavsdpasdfasoodfbasdfgapsebfase'
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'


#########################################
#            AUTH FUNCTIONS           #
#########################################


class User(UserMixin, db.Document):
    email = db.StringField(max_length=30, required=True)
    name = db.StringField(max_length=30, required=True)
    password = db.PasswordField()


def login_required(method):
    @functools.wraps(method)
    def wrapper(self):
        header = request.headers.get('Authorization')
        _, token = header.split()

        try:
            decoded = jwt.decode(token, app.config['KEY'], algorithms='HS256')
        except jwt.DecodeError:
            abort(400, message='Token is not valid.')
        except jwt.ExpiredSignatureError:
            abort(400, message='Token is expired.')

        email = decoded['email']

        if db.users.find({'email': email}).count() == 0:
            abort(400, message='User is not found.')

        user = db.users.find_one({'email': email})
        return method(self, user)
    return wrapper


@app.route('/login', methods=['POST'])
def login():
    email = request.json['email']
    password = request.json['password']

    if db.users.find({'email': email}).count() == 0:
        abort(400, message='User is not found.')
    user = db.users.find_one({'email': email})
    if not check_password_hash(user['password'], password):
        abort(400, message='Password is incorrect.')

    exp = datetime.datetime.utcnow(
    ) + datetime.timedelta(hours=app.config['TOKEN_EXPIRE_HOURS'])

    encoded = jwt.encode({'email': email, 'exp': exp},
                         app.config['KEY'], algorithm='HS256')

    return {'email': email, 'token': encoded.decode('utf-8')}


#########################################
#                ROUTES                 #
#########################################
detector = None
alarmThread = None


@app.route("/")
def hello():
    return render_template("page.html")


@app.route("/alarm", methods=['GET'])
@login_required
def start_alarm():
    global alarmOn
    global alarmThread
    alarmOn = True
    alarmThread = threading.Thread(target=gen_alarm, args=(Camera(),))
    alarmThread.start()
    return Response(response="Alarm On!", status=200)


@app.route("/alarm/stop", methods=['GET'])
@login_required
def stop_alarm():
    global alarmOn
    alarmOn = False
    return Response(response="Alarm Off!", status=200)


@app.route("/alarm/status", methods=['GET'])
@login_required
def status_alarm():
    global alarmOn
    message = "On"
    if alarmOn == False:
        message = "Off"
    return Response(response=message, status=200)


@app.route('/livestream')
@login_required
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(Camera()),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


#########################################
#            HELPER FUNCTIONS           #
#########################################

def gen(camera):
    """Video streaming generator function."""
    while True:
        frame = camera.get_frame()
        #t = threading.Thread(target=detector.detect, args=(frame,))
        # t.start()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + cv2.imencode('.jpg', frame)[1].tobytes() + b'\r\n')


def gen_alarm(camera):
    while alarmOn:
        frame = camera.get_frame()
        t = threading.Thread(target=detector.detect, args=(
            frame, datetime.datetime.now(),))
        t.start()
    return


if __name__ == "__main__":
    detector = Detector()
    app.run(host="0.0.0.0", port=5555, debug=False, threaded=True)
