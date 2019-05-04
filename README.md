# LAPD-FEUP
Los Angeles Police Department Home Security System


## API

### Setup

* Install mongo on the Raspberry Pi ``` sudo apt-get install mongodb ```
* Run mongo in a terminal (if you have Linux), by running the command ``` mongodb ``` or the shell ``` mongo ```
* In the folder *api*, run ``` npm install ```
* In the folder *api*, run ``` pip3 install -r requirements.txt ```
* Run: 
```
    sudo apt-get install libatlas-base-dev
    sudo apt-get install libjasper-dev
    sudo apt-get install libqtgui4
    sudo apt-get install python3-pyqt5
    sudo apt-get install libqt4-test
```


### Run

* In the folder *api* do ``` npm start ```

### Routes

* Authentication: 
    * Sign Up: **localhost:3000/api/auth/signup**
    * Sign In: **localhost:3000/api/auth/signin**
* History:
    * List history: **localhost:3000/api/history**
* Alarm 
    * Start alarm: **localhost:3000/api/alarm/start**
    * Stop alarm: **localhost:3000/api/alarm/stop**
* Livestream
    * Start Livestream: **localhost:3000/api/alarm/livestream**
    * Stop Livestream: **localhost:3000/api/alarm/livestream/stop**


#### Accounts

    * Name: root
    * Email: root@gmail.com
    * Password: lapd


## Database

### Setup

* Inside the folder *api* run ``` docker-compose up ```
* In another terminal run ``` docker exec -it api_mongo_1 mongo admin ```, which will open the mongo shell.
* Create admin user: ``` db.createUser({ user: "root", pwd: "lapd", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] }) ```
* Change to homesecurity database: ``` use homesecurity ``` 
* Authenticate: ``` db.auth("root", "lapd") ```
* Create homesecurity database and user: ``` db.createUser({ user: "lapd", pwd: "lapd", roles: [{ role: "dbOwner", db: "homesecurity" }] }) ``` , ``` db.auth("lapd","lapd") ``` 

