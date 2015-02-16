/*
  Copyright (C) 2015 Olavi Haapala.
  Contact: Olavi Haapala <ojhaapala@gmail.com>
  Twitter: @olpetik
  All rights reserved.
  You may use this file under the terms of BSD license as follows:
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//config.js
.import QtQuick.LocalStorage 2.0 as LS
// Helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("WHT", "1.0", "StorageDatabase", 100000);
}

//reset database
function resetDatabase() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            tx.executeSql('DROP TABLE hours')
            tx.executeSql('DROP TABLE timer')
            tx.executeSql('DROP TABLE breaks')
            tx.executeSql('CREATE TABLE IF NOT EXISTS hours(uid LONGVARCHAR UNIQUE, date TEXT, startTime TEXT, endTime TEXT, duration REAL,project TEXT, description TEXT,breakDuration REAL DEFAULT 0);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS timer(uid INTEGER UNIQUE,starttime TEXT, started INTEGER);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS breaks(id INTEGER PRIMARY KEY,starttime TEXT, started INTEGER, duration REAL DEFAULT -1);');
            tx.executeSql('PRAGMA user_version=2;');
            console.log("Database reset");
        });
}

// We want a unique id for hours
function getUniqueId()
{
     var dateObject = new Date();
     var uniqueId =
          dateObject.getFullYear() + '' +
          dateObject.getMonth() + '' +
          dateObject.getDate() + '' +
          dateObject.getTime();
     return uniqueId;
};

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx){
            tx.executeSql('CREATE TABLE IF NOT EXISTS hours(uid LONGVARCHAR UNIQUE, date TEXT,startTime TEXT, endTime TEXT, duration REAL,project TEXT, description TEXT, breakDuration REAL DEFAULT 0);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS timer(uid INTEGER UNIQUE, starttime TEXT, started INTEGER);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS breaks(id INTEGER PRIMARY KEY, starttime TEXT, started INTEGER, duration REAL DEFAULT -1);');
            tx.executeSql('PRAGMA user_version=2;');
    });
}
function updateIfNeeded () {
    var db = getDatabase();
    db.transaction(
        function(tx){
            var rs = tx.executeSql('PRAGMA user_version');
            //console.log(rs.rows.item(0).user_version);
            if (rs.rows.item(0).user_version < 2){
                var ex = tx.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name='hours';");
                if (ex.rows.item(0).name ==="hours") {
                    //console.log(ex.rows.item(0).name);
                    tx.executeSql('ALTER TABLE hours ADD breakDuration REAL DEFAULT 0;');
                    tx.executeSql('PRAGMA user_version=2;');
                    var r = tx.executeSql('PRAGMA user_version;');
                    //console.log(r.rows.item(0).user_version);
                }
                else
                    console.log("No table named hours...")
            }
    });
}

// This function is used to write hours into the database
function setHours(uid,date,startTime, endTime, duration,project,description, breakDuration) {
    console.log(date)
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO hours VALUES (?,?,?,?,?,?,?,?);', [uid,date,startTime,endTime,duration,project,description, breakDuration]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve hours for a day from the database
function getHoursDay(offset) {
    var db = getDatabase();
    var dur =0;
    db.transaction(function(tx) {
        var sqlstr = 'SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date = strftime("%Y-%m-%d", "now", "-' + offset + ' days", "localtime");';
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve hours for a week from the database
function getHoursWeek(offset) {
    var db = getDatabase();
    var dur = 0;
    //TODO: optimize these
    var sqlstr = ""
    if (offset === 0)
        sqlstr = 'SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-6 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0");';
    else
        sqlstr = 'SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-13 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0", "-7 days");';
    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve hours for a month from the database
function getHoursMonth(offset) {
    var db = getDatabase();
    var dur = 0;
    var sqlstr = "";
    if (offset === 0)
        sqlstr ='SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month") AND strftime("%Y-%m-%d","now","localtime");';
    else {
        sqlstr = 'SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 month") AND strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 day");';
    }
     db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve hours for a year from the database
function getHoursYear(offset) {
    var db = getDatabase();
    var dur=0;
    var sqlstr="";
    if (offset===0)
        sqlstr = 'SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year") AND strftime("%Y-%m-%d", "now", "localtime");';
    else {
        sqlstr ='SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year" , "-1 years") AND strftime("%Y-%m-%d", "now","localtime" , "start of year" ,"-1 day");';
    }
    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve all hours from the database
function getHoursAll() {
    var dur=0;
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM hours');
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}


// This function is used to get all data from the database
function getAll() {
    var db = getDatabase();
    var allHours=[];
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM hours ORDER BY date DESC, startTime DESC');
        for (var i = 0; i < rs.rows.length; i++) {
             var item ={};
             //uid,date,duration,project,description
             item["uid"]=rs.rows.item(i).uid;
             item["date"]= rs.rows.item(i).date;
             //console.log(item["date"]);
             item["startTime"]=rs.rows.item(i).startTime;
             item["endTime"]=rs.rows.item(i).endTime;
             item["duration"]=rs.rows.item(i).duration;
             item["project"]=rs.rows.item(i).project;
             item["description"]=rs.rows.item(i).description;
             item["breakDuration"]= rs.rows.item(i).breakDuration;
             allHours.push(item);
            //console.log(item);
        }
    })
    return allHours;
}

// This function is used to retrieve data for a day from the database
function getAllDay(offset) {
    var db = getDatabase();
    var allHours =[];
    var sqlstr="";
    if (offset ===0)
        sqlstr = 'SELECT * FROM hours WHERE date = strftime("%Y-%m-%d", "now", "localtime") ORDER BY date DESC, startTime DESC;';
    else
        sqlstr ='SELECT * FROM hours WHERE date = strftime("%Y-%m-%d", "now", "localtime", "-1 day") ORDER BY date DESC, startTime DESC;';

    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            var item ={};
            //uid,date,duration,project,description
            item["uid"]=rs.rows.item(i).uid;
            item["date"]= rs.rows.item(i).date;
            //console.log(item["date"]);
            item["startTime"]=rs.rows.item(i).startTime;
            item["endTime"]=rs.rows.item(i).endTime;
            item["duration"]=rs.rows.item(i).duration;
            item["project"]=rs.rows.item(i).project;
            item["description"]=rs.rows.item(i).description;
            item["breakDuration"]= rs.rows.item(i).breakDuration;
            allHours.push(item);
           //console.log(item);
        }
        //console.log(dur);
    })
    return allHours;
}

// This function is used to retrieve data this week from the database
function getAllWeek(offset) {
    var db = getDatabase();
    var allHours=[];
    var sqlstr="";
    if (offset ===0)
        sqlstr = 'SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-6 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0") ORDER BY date DESC, startTime DESC;';
    else
        sqlstr ='SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime", "weekday 0", "-13 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0", "-7 days") ORDER BY date DESC, startTime DESC;';

    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            var item ={};
            //uid,date,duration,project,description
            item["uid"]=rs.rows.item(i).uid;
            item["date"]= rs.rows.item(i).date;
            //console.log(item["date"]);
            item["startTime"]=rs.rows.item(i).startTime;
            item["endTime"]=rs.rows.item(i).endTime;
            item["duration"]=rs.rows.item(i).duration;
            item["project"]=rs.rows.item(i).project;
            item["description"]=rs.rows.item(i).description;
            item["breakDuration"]= rs.rows.item(i).breakDuration;
            allHours.push(item);
           //console.log(item);
        }
    })
    return allHours;
}

// This function is used to retrieve data this month from the database
function getAllMonth(offset) {
    var allHours=[];
    var db = getDatabase();
    var sqlstr="";
    if (offset ===0)
        sqlstr = 'SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month") AND strftime("%Y-%m-%d", "now", "localtime") ORDER BY date DESC, startTime DESC;';
    else
        sqlstr = 'SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 month") AND strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 day") ORDER BY date DESC, startTime DESC;';
    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        for (var i = 0; i < rs.rows.length; i++) {
            var item ={};
            //uid,date,duration,project,description
            item["uid"]=rs.rows.item(i).uid;
            item["date"]= rs.rows.item(i).date;
            //console.log(item["date"]);
            item["startTime"]=rs.rows.item(i).startTime;
            item["endTime"]=rs.rows.item(i).endTime;
            item["duration"]=rs.rows.item(i).duration;
            item["project"]=rs.rows.item(i).project;
            item["description"]=rs.rows.item(i).description;
            item["breakDuration"]= rs.rows.item(i).breakDuration;
            allHours.push(item);
           //console.log(item);
        }
    })
    return allHours;
}

// This function is used to retrieve data this year from the database
function getAllThisYear() {
    var db = getDatabase();
    var allHours =[];
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year") AND strftime("%Y-%m-%d", "now", "localtime") ORDER BY date DESC, startTime DESC');
         for (var i = 0; i < rs.rows.length; i++) {
             var item ={};
             //uid,date,duration,project,description
             item["uid"]=rs.rows.item(i).uid;
             item["date"]= rs.rows.item(i).date;
             item["startTime"]=rs.rows.item(i).startTime;
             item["endTime"]=rs.rows.item(i).endTime;
             item["duration"]=rs.rows.item(i).duration;
             item["project"]=rs.rows.item(i).project;
             item["description"]=rs.rows.item(i).description;
             item["breakDuration"]= rs.rows.item(i).breakDuration;
             allHours.push(item);
            //console.log(item);
        }
    })
    return allHours;
}

/* This function is used to remove items from the
  hours table */
function remove(uid) {
    console.log(uid);
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM hours WHERE uid=?;' , [uid]);
        if (rs.rowsAffected > 0) {
            console.log ("Deleted!");
        } else {
            console.log ("Error deleting. No deletion occured.");
        }
    })
}

/* Get timer starttime
returns the starttime or "Not started" */
function getStartTime(){
    var db = getDatabase();
    var started = 0;
    var resp="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM timer');
        if(rs.rows.length > 0) {
            started = rs.rows.item(0).started;
            if(started)
                resp = rs.rows.item(0).starttime;
            else
                resp = "Not started";
        }
        else{
            resp = "Not started";
        }
    })
    return resp;
}

/* Start the timer
Simply sets the starttime and started to 1
Returns the starttime if inserting is succesful */
function startTimer(newValue){
    var db = getDatabase();
    var resp="";
    var datenow = new Date();
    var startTime = newValue || datenow.getHours().toString() +":" + datenow.getMinutes().toString();
    console.log(startTime);
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO timer VALUES (?,?,?)', [1, startTime, 1]);
        if (rs.rowsAffected > 0) {
            resp = startTime;
            console.log ("Timer was saved to database");
        } else {
            resp = "Error";
            console.log ("Error saving the timer");
        }
    })
    return resp;
}

/* Stop the timer
 Stops the timer, sets started to 0
 and saves the endTime
 NOTE: the endtime is not used anywhere atm. */
function stopTimer(){
    var db = getDatabase();
    var datenow = new Date();
    var endTime = datenow.getHours().toString() +":" + datenow.getMinutes().toString();
    console.log(endTime);
    db.transaction(function(tx) {
        var rs = tx.executeSql('REPLACE INTO timer VALUES (?,?,?);', [1, endTime, 0]);
        if (rs.rowsAffected > 0) {
            console.log ("Timer was stopped");
        } else {
            resp = "Error";
            console.log ("Error stopping the timer");
        }
    })
}



/* BREAK TIMER FUNCTIONS
These functions are used when the timer
is running and the user pauses it */

/* Get break timer starttime
returns the starttime or "Not started" */
function getBreakStartTime(){
    var db = getDatabase();
    var started = 0;
    var resp="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM breaks ORDER BY id DESC LIMIT 1;');
        if(rs.rows.length > 0) {
            started = rs.rows.item(0).started;
            if(started)
                resp = rs.rows.item(0).starttime;
            else
                resp = "Not started";
        }
        else{
            resp = "Not started";
        }
    })
    return resp;
}

/* Start the break timer
Simply sets the break starttime and started to 1
Returns the starttime if inserting is succesful.
Also used for adjusting the starttime */
function startBreakTimer(){
    var db = getDatabase();
    var resp="";
    var datenow = new Date();
    var startTime = datenow.getHours().toString() +":" + datenow.getMinutes().toString();
    console.log(startTime);
    db.transaction(function(tx) {

        var rs = tx.executeSql('INSERT INTO breaks VALUES (NULL,?,?,?)', [startTime, 1, -1]);
        if (rs.rowsAffected > 0) {
            resp = startTime;
            console.log ("break Timer was started and saved to database");
        } else {
            resp = "Error";
            console.log ("Error starting the break timer");
        }
    })
    return resp;
}

/* Stop the break timer
Gets the id of the last added row which
should be the current breaktimer row and
saves the duration in to that row. */
function stopBreakTimer(duration){
    console.log(duration)
    var db = getDatabase();
    var id = 0;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM breaks ORDER BY id DESC LIMIT 1;');
        if(rs.rows.length > 0) {
            id = rs.rows.item(0).id;
        }
    })
    if(id) {
        db.transaction(function(tx) {
            var rs = tx.executeSql('REPLACE INTO breaks VALUES (?,?,?,?);', [id, startTime, 0, duration]);
            if (rs.rowsAffected > 0) {
                console.log ("breakTimer was stopped");
            } else {
                resp = "Error";
                console.log ("Error stopping the breaktimer");
            }
        })
    }
    else
        console.log("error getting last row id")
}

/* Get the break durations from the database
Gets all break rows. Users may use the breaktimer
several times during a work day. */
function getBreakTimerDuration(){
    var db = getDatabase();
    var dur=0.0;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM breaks');
        if(rs.rows.length > 0) {
            for(var i =0; i<rs.rows.length; i++) {
                if (rs.rows.item(i).duration ===-1)
                    console.log("Duration was not set for row number: ", i);
                else
                    dur += rs.rows.item(i).duration;
            }
        }
        //else
            //console.log("No breaktimer rows found");
    })
    return dur;
}

/* Clear out the breaktimer
Only the duration of the breaks
are added to the hours table.
Breaks table can be cleared everytime */
function clearBreakTimer(){
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM breaks');
    })
}





