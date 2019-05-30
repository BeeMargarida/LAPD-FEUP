# LAPD-FEUP
Los Angeles Police Department Home Security System (ah ah)

## Main Functionalities

* Intruder Detection with Object Detection system
* Livestream of camera feed
* History of actions and events - alerts have images of captured intruder
* News feed from PSP website
* When an intruder is detected, a buzzer rings and a push notification is sent to all users in the household

## User Requirements

* As a Visitor, I want to log in through the app so that I can control the system
* As an User, I want to turn the system off through  the  app  so  that  I  can  control  its activity 
* As an User, I want to turn the system on through the app so that I can start monitoring the area
* As an User,  I  want  to  access  the  camera feed in the app so that I can visualize the secured area anywhere and anytime
* As an User, I want to be informed with a push notification when the system senses someone so that I know that my house is insecure
* As an User, I want to view the history of past  activities  including  previous  alarms and actions so that I can keep track of past events
* As an User, I want to log out through the app  so  that  no  else  has  access  to  my  account
* As an User, I want to see the news from the Polícia de Segurança Pública website,so that I can be informed of recent crimes and dangerous situations
* As an User,  I  want  to  see  each  of  the pieces of news from the Polícia de Segurança Pública website in more detail, so that I can know what happened.

### Setup

#### Raspberry Pi
* Run: 
```
    sudo apt-get install libatlas-base-dev
    sudo apt-get install libjasper-dev
    sudo apt-get install libqtgui4
    sudo apt-get install python3-pyqt5
    sudo apt-get install libqt4-test
```

#### MongoDB
* Inside the folder *api* run ``` docker-compose up ```
* In another terminal run ``` docker exec -it api_mongo_1 mongo admin ```, which will open the mongo shell.
* Create admin user: ``` db.createUser({ user: "root", pwd: "lapd", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] }) ```
* Change to homesecurity database: ``` use homesecurity ``` 
* Authenticate: ``` db.auth("root", "lapd") ```
* Create homesecurity database and user: ``` db.createUser({ user: "lapd", pwd: "lapd", roles: [{ role: "dbOwner", db: "homesecurity" }] }) ``` , ``` db.auth("lapd","lapd") ``` 

#### Flask API
* In the folder *api_flask*:
    * Download yolo config and weight files:
        * ``` mkdir yolo```
        * ``` chmod +x yolo_models.sh ```
        * ``` ./yolo_models ```
    * Create and activate virtualenv:
        * ``` virtualenv venv ```
        * ``` . venv/bin/activate ```
    * Install dependencies:
        * ``` sudo apt-get install python3-pymongo ```
        * ``` python -m pip install opencv-python Flask Flask-PyMongo flask-jwt-extended flask-bcrypt RPi.GPIO```
    * Get YOLO models:
        * ``` cd yolo  ```
        * ``` chmod +x yolo_models.sh ```
        * ``` ./yolo_models.sh ```



### Run

* In the folder *api_flask* do ``` python3 server.py ```

### Routes

* Authentication: 
    * Sign In: **<IP>:3000/login**
* History:
    * List history: **<IP>:3000/history**
* Alarm 
    * Start alarm: **<IP>:3000/alarm**
    * Stop alarm: **<IP>:3000/alarm/stop**
    * Alarm status: **<IP>:3000/alarm/status**
* Livestream
    * Start Livestream: **<IP>:3000/livestream/start**
    * Stop Livestream: **<IP>:3000/livestream/stop**
    * Access Livestream: **<IP>:3000/livestream**

* Sign in Webpage: **<IP>:3000/**
