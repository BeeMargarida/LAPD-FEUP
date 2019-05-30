# LAPD-FEUP
Los Angeles Police Department Home Security System (ah ah)

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
