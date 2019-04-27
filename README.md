# LAPD-FEUP
Los Angeles Police Department Home Security System


## API

### Setup

* Install mongo in your pc
* Run mongo in a terminal (if you have Linux), by running the command ``` mongodb ``` or the shell ``` mongo ```
* In the folder *api*, run ``` npm install ```
* If you want to use a *virtualenv* for the python dependencies:
    * Install *virtualenv* 
    * Create a virtualenv in *api* by running the command ``` virtualenv venv ```
    * Activate the virtualenv ``` . venv/bin/activate ```
    * Install dependencies ``` pip install -r requirements.txt ```
* If you don't want to use virtualenv, in the folder *api*, run ``` pip install -r requirements.txt ```


### Run

* In the folder *api* do ``` npm start ```

### Routes

* Authentication: 
    * Sign Up: **localhost:8081/api/auth/signup**
    * Sign In: **localhost:8081/api/auth/signin**
* History:
    * List history: **localhost:8081/api/history**