## Setup

In the root of this folder: 
* Download yolo config and weight files:
    * ``` mkdir yolo```
    * ``` chmod +x yolo_models.sh ```
    * ``` ./yolo_models ```
* Create and activate virtualenv:
    * ``` virtualenv venv ```
    * ``` . venv/bin/activate ```
* Install dependencies:
    * ``` sudo apt-get install python3-pymongo ```
    * ``` python3 -m pip install opencv-python Flask Flask-PyMongo flask-jwt-extended flask-bcrypt RPi.GPIO baseapi pyfcm```
* Get YOLO models:
    * ``` cd yolo  ```
    * ``` chmod +x yolo_models.sh ```
    * ``` ./yolo_models.sh ```
* Run Server:
    * ``` python3 server.py ```





