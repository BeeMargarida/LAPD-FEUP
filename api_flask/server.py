import socket
import subprocess
import threading
import datetime
import cv2
import functools
import json
import jsonschema
from bson import ObjectId, json_util
from flask import Flask, render_template, Response, request, abort, jsonify, send_from_directory
from flask_pymongo import PyMongo, DESCENDING
from flask_jwt_extended import (JWTManager, create_access_token,
                                jwt_required, jwt_refresh_token_required, get_jwt_identity)
from flask_jwt_extended.exceptions import InvalidHeaderError
from flask_bcrypt import Bcrypt


from models.user_schema import validate_user
from detector import Detector
from camera import Camera
app = Flask(__name__,static_url_path='')


#########################################
#            DATABASE SETUP             #
#########################################

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
#            AUTH FUNCTIONS             #
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
    email = request.form.get("email")
    password = request.form.get("password")
    ''' auth endpoint '''
    data = validate_user({"email": email, "password": password})
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
            return json_util.dumps(user), 200
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
alarmOn = False
livestreamOn = False
firebase_tokens = []


@app.route("/")
def hello():
    return render_template("page.html")


@app.route("/alarm", methods=['POST'])
@jwt_required
def start_alarm():
    global alarmOn
    global alarmThread
    user = get_jwt_identity()
    
    tokens = list(mongo.db.users.find({"firebase_token": { "$exists": True}},{"firebase_token":1, "_id":0}))
    for t in tokens:
        print(t)
        firebase_tokens.append(t["firebase_token"])
            
    print(firebase_tokens)
    
    if alarmOn != True:
        alarmOn = True
        alarmThread = threading.Thread(target=gen_alarm, args=(Camera(), user,))
        alarmThread.start()
        history = create_history("Alarm On", user, datetime.datetime.now(), "")
        return Response(response=history, status=200)
    else:
        return Response(status=200)


@app.route("/alarm/stop", methods=['POST'])
@jwt_required
def stop_alarm():
    global alarmOn
    user = get_jwt_identity()
    if alarmOn != False:
        alarmOn = False
        history= create_history("Alarm Off", user, datetime.datetime.now(), "")
        return Response(response=history, status=200)
    else:
        return Response(status=200)

@app.route("/alarm/status", methods=['GET'])
@jwt_required
def status_alarm():
    global alarmOn
    return Response(response=json.dumps({'status': alarmOn}), status=200)


@app.route('/livestream')
#@jwt_required
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(gen(Camera()),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/livestream/start', methods=['POST'])
@jwt_required
def video_feed_on():
    global livestreamOn
    livestreamOn = True
    return Response(status=200)

@app.route('/livestream/stop', methods=['POST'])
@jwt_required
def video_feed_off():
    global livestreamOn
    livestreamOn = False
    return Response(status=200)

@app.route('/history', methods=['GET'])
@jwt_required
def list_histories():
    ''' route to get all the history entriess '''
    args = request.args
    page = int(args["page"])
    per_page = int(args["per_page"])
    
    data = mongo.db.histories.find().skip(
        per_page*(page-1)).limit(per_page).sort("createdAt", DESCENDING)
    
    return Response(response=json_util.dumps(data), status=200)

@app.route('/alerts/<path:path>')
def send_js(path):
    return send_from_directory('alerts', path)

def create_history(type, user, timestamp, imagePath):

    history = {
        "type": type,
        "user_id": user["id"],
        "imagePath": imagePath,
        "createdAt": timestamp,
        "updatedAt": timestamp
    }
    mongo.db.histories.insert_one(history)

    return json_util.dumps(history)


#########################################
#            HELPER FUNCTIONS           #
#########################################

def gen(camera):
    """Video streaming generator function."""
    while livestreamOn == True:
        frame = camera.get_frame()
        img = cv2.imencode('.jpg', frame)[1]
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + img.tobytes() + b'\r\n')


def gen_alarm(camera, user):
    while alarmOn:
        frame = camera.get_frame()
        detector.detect(frame, datetime.datetime.now(), user, firebase_tokens, create_history)
    return

@app.errorhandler(InvalidHeaderError)
def handle_validation_error(error):
    return Response(response="Unauthorized! Please log in first.", status=401)
    

if __name__ == "__main__":
    detector = Detector()
    app.run(host="0.0.0.0", port=3000, debug=False, threaded=True)
