# LAPD-FEUP
Los Angeles Police Department Home Security System


## API

### Setup

* Install mongo on the Raspberry Pi ``` sudo apt-get install mongodb ```
* Run mongo in a terminal (if you have Linux), by running the command ``` mongodb ``` or the shell ``` mongo ```
* In the folder *api*, run ``` npm install ```
* In the folder *api*, run ``` pip3 install -r requirements.txt ```


### Run

* In the folder *api* do ``` npm start ```

### Routes

* Authentication: 
    * Sign Up: **localhost:8081/api/auth/signup**
    * Sign In: **localhost:8081/api/auth/signin**
* History:
    * List history: **localhost:8081/api/history**
* Alarm 
    * Start alarm : **localhost:8081/api/alarm/start**
    * Stop alarm : **localhost:8081/api/alarm/stop**