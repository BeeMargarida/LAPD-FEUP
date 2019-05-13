import socket
import subprocess
import threading
import datetime
import cv2
import functools
import json
import jsonschema
from bson.objectid import ObjectId
from flask import Flask, render_template, Response, request, abort, jsonify
# from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
# from werkzeug.security import generate_password_hash, check_password_hash
from flask_pymongo import PyMongo, DESCENDING
from flask_jwt_extended import (JWTManager, create_access_token,
                                jwt_required, jwt_refresh_token_required, get_jwt_identity)
from flask_bcrypt import Bcrypt

from models.user_schema import validate_user
from detector import Detector
from camera import Camera
app = Flask(__name__)


#########################################
#            DATABASE SETUP             #
#########################################


# app.config['MONGODB_SETTINGS'] = {
#     'db': 'homesecurity',
#     'host': 'mongodb://lapd:lapd@178.166.11.252:27017/homesecurity'
# }
# db = MongoEngine(app)

# login_manager = LoginManager()
# login_manager.init_app(app)
# login_manager.login_view = 'login'

class JSONEncoder(json.JSONEncoder):
    ''' extend json-encoder class'''

    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        if isinstance(o, set):
            return list(o)
        if isinstance(o, datetime.datetime):
            return str(o)
        return json.JSONEncoder.default(self, o)


app.config['JWT_ACCESS_TOKEN_EXPIRES'] = datetime.timedelta(days=1)
app.config['JWT_SECRET_KEY'] = 'asdhuiaisbdpavsdpasdfasoodfbasdfgapsebfase'
app.config["MONGO_URI"] = "mongodb://lapd:lapd@178.166.11.252:27017/homesecurity"
mongo = PyMongo(app)
flask_bcrypt = Bcrypt(app)
jwt = JWTManager(app)
app.json_encoder = JSONEncoder

#########################################
#            AUTH FUNCTIONS           #
#########################################


@app.route('/register', methods=['POST'])
def register():
    ''' register user endpoint '''
    data = validate_user(request.get_json())
    if data['ok']:
        data = data['data']
        data['password'] = flask_bcrypt.generate_password_hash(
            data['password'])
        mongo.db.users.insert_one(data)
        return jsonify({'ok': True, 'message': 'User created successfully!'}), 200
    else:
        return jsonify({'ok': False, 'message': 'Bad request parameters: {}'.format(data['message'])}), 400


@app.route('/login', methods=['POST'])
def login_user():
    ''' auth endpoint '''
    data = validate_user(request.get_json())
    if data['ok']:
        data = data['data']
        user = mongo.db.users.find_one({'email': data['email']})
        if user and flask_bcrypt.check_password_hash(user['password'], data['password']):
            del user['password']
            data_token = {
                "email": data["email"],
                "id": user["_id"]
            }
            access_token = create_access_token(identity=data_token)
            #refresh_token = create_refresh_token(identity=data)
            user['token'] = access_token
            #user['refresh'] = refresh_token
            return jsonify({'ok': True, 'data': user}), 200
        else:
            return jsonify({'ok': False, 'message': 'invalid username or password'}), 401
    else:
        return jsonify({'ok': False, 'message': 'Bad request parameters: {}'.format(data['message'])}), 400


@jwt.unauthorized_loader
def unauthorized_response(callback):
    return jsonify({
        'ok': False,
        'message': 'Missing Authorization Header'
    }), 401


#########################################
#                ROUTES                 #
#########################################
detector = None
alarmThread = None


@app.route("/")
def hello():
    return render_template("page.html")


@app.route("/alarm", methods=['POST'])
@jwt_required
def start_alarm():
    global alarmOn
    global alarmThread
    user = get_jwt_identity()
    alarmOn = True
    alarmThread = threading.Thread(target=gen_alarm, args=(Camera(), user,))
    alarmThread.start()
    return Response(response="Alarm On!", status=200)


@app.route("/alarm/stop", methods=['POST'])
@jwt_required
def stop_alarm():
    global alarmOn
    alarmOn = False
    return Response(response="Alarm Off!", status=200)


@app.route("/alarm/status", methods=['GET'])
@jwt_required
def status_alarm():
    global alarmOn
    message = "On"
    if alarmOn == False:
        message = "Off"
    return Response(response=message, status=200)


@app.route('/livestream')
@jwt_required
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(Camera()),
                    mimetype='multipart/x-mixed-replace; boundary=frame')


@app.route('/history', methods=['GET'])
@jwt_required
def list_histories():
    ''' route to get all the history entriess '''
    args = request.args
    page = int(args["page"])
    per_page = int(args["per_page"])
    data = mongo.db.histories.find().skip(
        per_page*(page-1)).limit(per_page).sort("createdAt", DESCENDING)
    return jsonify({'ok': True, 'data': list(data)})


def create_history(type, user, timestamp, imagePath):

    history = {
        "type": type,
        "user_id": user["id"],
        "imagePath": imagePath,
        "createdAt": timestamp,
        "updatedAt": timestamp
    }
    mongo.db.histories.insert_one(history)

    return Response(response=history, status=200)


#########################################
#            HELPER FUNCTIONS           #
#########################################

def gen(camera):
    """Video streaming generator function."""
    while True:
        frame = camera.get_frame()
        # t = threading.Thread(target=detector.detect, args=(frame,))
        # t.start()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + cv2.imencode('.jpg', frame)[1].tobytes() + b'\r\n')


def gen_alarm(camera, user):
    while alarmOn:
        frame = camera.get_frame()
        detector.detect(frame, datetime.datetime.now(), user, create_history)
    return


if __name__ == "__main__":
    detector = Detector()
    app.run(host="0.0.0.0", port=5555, debug=False, threaded=True)
