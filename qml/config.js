/*
Copyright (C) 2015 Olavi Haapala.
<ojhaapala@gmail.com>
Twitter: @olpetik
IRC: olpe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of wht nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
            tx.executeSql('DROP TABLE projects')
            tx.executeSql('CREATE TABLE IF NOT EXISTS hours(uid LONGVARCHAR UNIQUE, date TEXT, startTime TEXT, endTime TEXT, duration REAL,project TEXT, description TEXT,breakDuration REAL DEFAULT 0);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS timer(uid INTEGER UNIQUE,starttime TEXT, started INTEGER);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS breaks(id INTEGER PRIMARY KEY,starttime TEXT, started INTEGER, duration REAL DEFAULT -1);');
            tx.executeSql('CREATE TABLE IF NOT EXISTS projects(id LONGVARCHAR UNIQUE, name TEXT, hourlyRate REAL DEFAULT 0, contractRate REAL DEFAULT 0, budget REAL DEFAULT 0, hourBudget REAL DEFAULT 0, labelColor TEXT);');
            tx.executeSql('PRAGMA user_version=2;');
            Log.info("Database was resetted");
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
            tx.executeSql('CREATE TABLE IF NOT EXISTS projects(id LONGVARCHAR UNIQUE, name TEXT, hourlyRate REAL DEFAULT 0, contractRate REAL DEFAULT 0, budget REAL DEFAULT 0, hourBudget REAL DEFAULT 0, labelColor TEXT);');
            tx.executeSql('PRAGMA user_version=2;');
    });
}
function updateIfNeeded () {
    var db = getDatabase();
    db.transaction(
        function(tx){
            var rs = tx.executeSql('PRAGMA user_version');
            //console.log(rs.rows.item(0).user_version);
            if(rs.rows.length > 0) {
                if (rs.rows.item(0).user_version < 2) {
                    var ex = tx.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name='hours';");
                    //check if rows exist
                    if(ex.rows.length > 0) {
                        if (ex.rows.item(0).name ==="hours") {
                            //console.log(ex.rows.item(0).name);
                            tx.executeSql('ALTER TABLE hours ADD breakDuration REAL DEFAULT 0;');
                            tx.executeSql('PRAGMA user_version=2;');
                            var r = tx.executeSql('PRAGMA user_version;');
                            //console.log(r.rows.item(0).user_version);
                        }
                        else
                            Log.error("No table named hours...");
                    }
                    else
                        Log.error("No table named hours...");
                }
            }
    });
}

// This function is used to write hours into the database
function setHours(uid,date,startTime, endTime, duration, project, description, breakDuration) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO hours VALUES (?,?,?,?,?,?,?,?);', [uid,date,startTime,endTime,duration,project,description, breakDuration]);
        if (rs.rowsAffected > 0) {
            res = "OK";
            Log.info("Hours saved to database");
        } else {
            res = "Error";
            Log.error("Error saving hours to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve hours for a day from the database
function getHoursDay(offset, projectId) {
    var db = getDatabase();
    var dur =0;
    var rs;

    db.transaction(function(tx) {
        if(projectId)
            rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date = strftime("%Y-%m-%d", "now", "-' + offset + ' days", "localtime") AND project=?;', [projectId]);

        else
            rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date = strftime("%Y-%m-%d", "now", "-' + offset + ' days", "localtime");');
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve hours for a week from the database
function getHoursWeek(offset, projectId) {
    var db = getDatabase();
    var dur = 0;
    var rs;

    db.transaction(function(tx) {
        if (offset === 0) {
            if(projectId)
                rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-6 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0") AND  project=?;', [projectId]);
            else
                rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-6 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0");');
        }
        else if (projectId)
            rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-13 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0", "-7 days") AND  project=?;', [projectId]);

        else
            rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-13 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0", "-7 days");');
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve hours for a month from the database
function getHoursMonth(offset, projectId) {
    var db = getDatabase();
    var dur = 0;
    var rs;
     db.transaction(function(tx) {
         if (offset === 0){
             if(projectId)
                 rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month") AND strftime("%Y-%m-%d","now","localtime") AND  project=?;', [projectId]);
             else
                rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month") AND strftime("%Y-%m-%d","now","localtime");');
         }
         else {
             if(projectId)
                 rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 month") AND strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 day") AND  project=?;', [projectId]);
             else
                 rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 month") AND strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 day");');
        }
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve hours for a year from the database
function getHoursYear(offset, projectId) {
    var db = getDatabase();
    var dur=0;
    var rs;
    db.transaction(function(tx) {
        if (offset===0) {
            if(projectId)
                rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year") AND strftime("%Y-%m-%d", "now", "localtime") AND  project=?;', [projectId]);
            else
                rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year") AND strftime("%Y-%m-%d", "now", "localtime");');
        }
        else {
            if(projectId)
                rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year" , "-1 years") AND strftime("%Y-%m-%d", "now","localtime" , "start of year" ,"-1 day") AND  project=?;', [projectId]);
            rs = tx.executeSql('SELECT DISTINCT uid, duration, breakDuration FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year" , "-1 years") AND strftime("%Y-%m-%d", "now","localtime" , "start of year" ,"-1 day");');
        }
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}

// This function is used to retrieve all hours from the database
function getHoursAll(projectId) {
    var dur=0;
    var db = getDatabase();
    var rs;
    db.transaction(function(tx) {
        if(projectId)
            rs = tx.executeSql('SELECT * FROM hours WHERE  project=?;', [projectId]);
        else
            rs = tx.executeSql('SELECT * FROM hours;');
        for (var i = 0; i < rs.rows.length; i++) {
            dur+= rs.rows.item(i).duration;
            dur-= rs.rows.item(i).breakDuration;
        }
    })
    //console.log(dur);
    return dur;
}


// This function is used to get all data from the database
function getAll(sortby, projectId) {
    var db = getDatabase();
    var allHours=[];
    var rs;
    //console.log(projectId)
    db.transaction(function(tx) {
        if(projectId){
            if(sortby === "project")
                rs = tx.executeSql('SELECT * FROM hours WHERE project=? ORDER BY project DESC, date DESC, startTime DESC;', [projectId]);
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE project=? ORDER BY date DESC, startTime DESC;', [projectId]);
        }
        else {
            if(sortby === "project")
                rs = tx.executeSql('SELECT * FROM hours ORDER BY project DESC, date DESC, startTime DESC;');
            else
                rs = tx.executeSql('SELECT * FROM hours ORDER BY date DESC, startTime DESC;');
        }

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
function getAllDay(offset, sortby, projectId) {
    var db = getDatabase();
    var allHours =[];
    var rs;

    db.transaction(function(tx) {
        var orderby = "ORDER BY date DESC, startTime DESC";
        if(sortby === "project")
            orderby = "ORDER BY project DESC, date DESC, startTime DESC";
        if(projectId){
            if (offset ===0)
                rs = tx.executeSql('SELECT * FROM hours WHERE date = strftime("%Y-%m-%d", "now", "localtime") AND project=? ' + orderby + ';', [projectId]);
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE date = strftime("%Y-%m-%d", "now", "localtime", "-1 day") AND project=? ' + orderby + ';', [projectId]);
        }
        else {
            if (offset ===0)
                rs = tx.executeSql('SELECT * FROM hours WHERE date = strftime("%Y-%m-%d", "now", "localtime") ' + orderby + ';');
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE date = strftime("%Y-%m-%d", "now", "localtime", "-1 day") ' + orderby + ';');
        }

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
function getAllWeek(offset, sortby, projectId) {
    var db = getDatabase();
    var allHours=[];
    var rs;
    db.transaction(function(tx) {
        var orderby = "ORDER BY date DESC, startTime DESC";
        if(sortby === "project")
            orderby = "ORDER BY project DESC, date DESC, startTime DESC";
        if(projectId) {
            if (offset ===0)
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-6 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0") AND project=? ' + orderby + ';', [projectId]);
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime", "weekday 0", "-13 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0", "-7 days") AND project=? ' + orderby + ';', [projectId]);
        }
        else {
            if (offset ===0)
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "weekday 0", "-6 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0") ' + orderby + ';');
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime", "weekday 0", "-13 days") AND strftime("%Y-%m-%d", "now", "localtime", "weekday 0", "-7 days") ' + orderby + ';');
        }

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
function getAllMonth(offset, sortby, projectId) {
    var allHours=[];
    var db = getDatabase();
    var orderby = "ORDER BY date DESC, startTime DESC";
    if(sortby === "project")
        orderby = "ORDER BY project DESC, date DESC, startTime DESC";
    var rs;
    db.transaction(function(tx) {
        if(projectId) {
            if (offset ===0)
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month") AND strftime("%Y-%m-%d", "now", "localtime") AND project=? ' + orderby + ';', [projectId]);
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 month") AND strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 day") AND project=? ' + orderby + ';', [projectId]);
        }
        else {
            if (offset ===0)
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month") AND strftime("%Y-%m-%d", "now", "localtime") ' + orderby + ';');
            else
                rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 month") AND strftime("%Y-%m-%d", "now", "localtime", "start of month", "-1 day") ' + orderby + ';');
        }

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
function getAllThisYear(sortby, projectId) {
    var db = getDatabase();
    var orderby = "ORDER BY date DESC, startTime DESC";
    if(sortby === "project")
        orderby = "ORDER BY project DESC, date DESC, startTime DESC";
    var allHours =[];
    var rs;
    db.transaction(function(tx) {
        if(projectId)
            rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year") AND strftime("%Y-%m-%d", "now", "localtime") AND project=? ' + orderby + ';', [projectId]);
        else
            rs = tx.executeSql('SELECT * FROM hours WHERE date BETWEEN strftime("%Y-%m-%d", "now","localtime" , "start of year") AND strftime("%Y-%m-%d", "now", "localtime") ' + orderby + ';');
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
    Log.info("Removing: " + uid);
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM hours WHERE uid=?;' , [uid]);
        if (rs.rowsAffected > 0) {
            Log.info("Deleted!");
        } else {
            Log.error("Error deleting. No deletion occured.");
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
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO timer VALUES (?,?,?)', [1, startTime, 1]);
        if (rs.rowsAffected > 0) {
            resp = startTime;
            Log.info("Timer was saved to database at: " + startTime);
        } else {
            resp = "Error";
            Log.error("Error saving the timer");
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
    db.transaction(function(tx) {
        var rs = tx.executeSql('REPLACE INTO timer VALUES (?,?,?);', [1, endTime, 0]);
        if (rs.rowsAffected > 0) {
            Log.info("Timer was stopped at: "+ endTime);
        } else {
            resp = "Error";
            Log.error("Error stopping the timer");
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
    db.transaction(function(tx) {

        var rs = tx.executeSql('INSERT INTO breaks VALUES (NULL,?,?,?)', [startTime, 1, -1]);
        if (rs.rowsAffected > 0) {
            resp = startTime;
            Log.info("Break Timer was started at: " + startTime);
        } else {
            resp = "Error";
            Log.error("Error starting the break timer");
        }
    })
    return resp;
}

/* Stop the break timer
Gets the id of the last added row which
should be the current breaktimer row and
saves the duration in to that row. */
function stopBreakTimer(duration){
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
                Log.info("BreakTimer was stopped, duration was: " + duration);
            } else {
                resp = "Error";
                Log.error("Error stopping the breaktimer");
            }
        })
    }
    else
        Log.error("Error getting last row id");
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
                if (rs.rows.item(i).duration !==-1)
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

/* PROJECT FUNCTIONS
These functions are for projects */

/* */
function setProject(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor){
    //console.log(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor);
    var db = getDatabase();
    var resp = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO projects VALUES (?,?,?,?,?,?,?);', [id, name, hourlyRate, contractRate, budget, hourBudget, labelColor]);
        if (rs.rowsAffected > 0) {
            resp = "OK";
            Log.info("Project saved to database");
        } else {
            resp = "Error";
            Log.error("Error saving project to database");
        }
    })
    return resp;
}

/* Get projects */
function getProjects(){
    var db = getDatabase();
    var resp = [];
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM projects ORDER BY id DESC');
        if(rs.rows.length > 0) {
            for (var i=0; i<rs.rows.length; i++) {
                var item ={};
                item["id"]=rs.rows.item(i).id;
                item["name"]= rs.rows.item(i).name;
                item["hourlyRate"]=rs.rows.item(i).hourlyRate;
                item["contractRate"]=rs.rows.item(i).contractRate;
                item["budget"]=rs.rows.item(i).budget;
                item["hourBudget"]=rs.rows.item(i).hourBudget;
                item["labelColor"]=rs.rows.item(i).labelColor;
                item["breakDuration"]= rs.rows.item(i).breakDuration;
                resp.push(item);
            }
        }
    })
    return resp;
}

/* Get project by id */
function getProjectById(id){
    var db = getDatabase();
    var item ={};
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM projects WHERE id=?;', [id]);
        if(rs.rows.length > 0) {
            for (var i=0; i<rs.rows.length; i++) {
                item["id"]=rs.rows.item(i).id;
                item["name"]= rs.rows.item(i).name;
                item["hourlyRate"]=rs.rows.item(i).hourlyRate;
                item["contractRate"]=rs.rows.item(i).contractRate;
                item["budget"]=rs.rows.item(i).budget;
                item["hourBudget"]=rs.rows.item(i).hourBudget;
                item["labelColor"]=rs.rows.item(i).labelColor;
                item["breakDuration"]= rs.rows.item(i).breakDuration;
                break;
            }
        }
    })
    return item;
}

function removeProject(id){
    var db = getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM projects WHERE id=?;' , [id]);
        if (rs.rowsAffected > 0) {
            Log.info("Project deleted from database!");
        } else {
            Log.info("Error deleting project. No deletion occured.");
        }
    })
}

function removeProjects(){
    var db = getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM projects');
    })
}

function moveAllHoursToProject(id) {
    var db = getDatabase();
    var resp = "Error updating existing hours!";
    var sqlstr = "UPDATE hours SET project='"+id+"';";
    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        if (rs.rowsAffected > 0) {
            resp = "Updated hours to project id: " + id;
        }
    }
    );
    return resp;
}

function moveAllHoursToProjectByDesc(defaultProjectId) {
    var db = getDatabase();
    var resp = "OK";
    var projects = getProjects();
    var allhours = getAll();
    var i=0
    for (; i < allhours.length; i++) {
        var sqlstr = "UPDATE hours SET project='"+ defaultProjectId +"' WHERE uid='"+ allhours[i].uid +"';";
        if (allhours[i].description !== "No description") {
            for (var k=0; k< projects.length; k++) {
                if((allhours[i].description.toLowerCase()).indexOf(projects[k].name.toLowerCase()) > -1){
                    sqlstr = "UPDATE hours SET project='"+ projects[k].id +"' WHERE uid='"+ allhours[i].uid +"';";
                }
            }
        }
        db.transaction(function(tx) {
            var rs = tx.executeSql(sqlstr);
        }
        );
    }
    return "Updated: " + i + " rows";
}
