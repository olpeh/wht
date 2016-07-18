/*
Copyright (C) 2015 Olavi Haapala.
<harbourwht@gmail.com>
Twitter: @0lpeh
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

.import QtQuick.LocalStorage 2.0 as LS
var db = LS.LocalStorage.openDatabaseSync("WHT", "1.0", "StorageDatabase", 100000);

/* Get timer starttime
returns the starttime or "Not started" */
function getStartTime() {
    var started = 0;
    var resp = "";

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM timer');
        if (rs.rows.length > 0) {
            started = rs.rows.item(0).started;

            if (started) {
                resp = rs.rows.item(0).starttime;
            }
            else {
                resp = "Not started";
            }
        }
        else {
            resp = "Not started";
        }
    });

    return resp;
}

/* Start the timer
Simply sets the starttime and started to 1
Returns the starttime if inserting is successful */
function startTimer(newValue) {
    var resp = "";
    var datenow = new Date();
    var startTime = newValue || datenow.getHours().toString() + ":" + datenow.getMinutes().toString();

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO timer VALUES (?,?,?)', [1, startTime, 1]);

        if (rs.rowsAffected > 0) {
            resp = startTime;
            Log.info("Timer was saved to database at: " + startTime);
        }
        else {
            resp = "Error";
            Log.error("Error saving the timer");
        }
    });

    return resp;
}

/* Stop the timer
 Stops the timer, sets started to 0
 and saves the endTime
 NOTE: the endtime is not used anywhere atm. */
function stopTimer() {
    var datenow = new Date();
    var endTime = datenow.getHours().toString() + ":" + datenow.getMinutes().toString();

    db.transaction(function(tx) {
        var rs = tx.executeSql('REPLACE INTO timer VALUES (?,?,?);', [1, endTime, 0]);

        if (rs.rowsAffected > 0) {
            Log.info("Timer was stopped at: "+ endTime);
        }
        else {
            Log.error("Error stopping the timer");
        }
    });
}



/* BREAK TIMER FUNCTIONS
These functions are used when the timer
is running and the user pauses it */

/* Get break timer starttime
returns the starttime or "Not started" */
function getBreakStartTime() {
    var started = 0;
    var resp = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM breaks ORDER BY id DESC LIMIT 1;');
        if (rs.rows.length > 0) {
            started = rs.rows.item(0).started;
            if (started) {
                resp = rs.rows.item(0).starttime;
            }
            else {
                resp = "Not started";
            }
        }
        else {
            resp = "Not started";
        }
    });

    return resp;
}

/* Start the break timer
Simply sets the break starttime and started to 1
Returns the starttime if inserting is successful.
Also used for adjusting the starttime */
function startBreakTimer() {
    var resp = "";
    var datenow = new Date();
    var startTime = datenow.getHours().toString() +":" + datenow.getMinutes().toString();

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT INTO breaks VALUES (NULL,?,?,?)', [startTime, 1, -1]);
        if (rs.rowsAffected > 0) {
            resp = startTime;
            Log.info("Break Timer was started at: " + startTime);
        }
        else {
            resp = "Error";
            Log.error("Error starting the break timer");
        }
    });

    return resp;
}

/* Stop the break timer
Gets the id of the last added row which
should be the current breaktimer row and
saves the duration in to that row. */
function stopBreakTimer(duration) {
    var id = 0;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM breaks ORDER BY id DESC LIMIT 1;');
        if (rs.rows.length > 0) {
            id = rs.rows.item(0).id;
        }
    });
    if (id) {
        db.transaction(function(tx) {
            var rs = tx.executeSql('REPLACE INTO breaks VALUES (?,?,?,?);', [id, startTime, 0, duration]);

            if (rs.rowsAffected > 0) {
                Log.info("BreakTimer was stopped, duration was: " + duration);
            }
            else {
                resp = "Error";
                Log.error("Error stopping the breaktimer");
            }
        });
    }
    else {
        Log.error("Error getting last row id");
    }
}

/* Get the break durations from the database
Gets all break rows. Users may use the breaktimer
several times during a work day. */
function getBreakTimerDuration() {
    var dur = 0.0;
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM breaks');
        if (rs.rows.length > 0) {
            for(var i = 0; i<rs.rows.length; i++) {
                if (rs.rows.item(i).duration !==-1)
                    dur += rs.rows.item(i).duration;
            }
        }
    });

    return dur;
}

/* Clear out the breaktimer
Only the duration of the breaks
are added to the hours table.
Breaks table can be cleared everytime */
function clearBreakTimer() {
    db.transaction(function(tx) {
        tx.executeSql('DELETE FROM breaks');
    });
}

/* PROJECT FUNCTIONS
These functions are for projects */

function setProject(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor) {
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
    });

    return resp;
}


function getProjectById(id) {
    var item = {};
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM projects WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            for (var i = 0; i<rs.rows.length; i++) {
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
    });

    return item;
}


function moveAllHoursToProject(id) {
    var resp = "Error updating existing hours!";
    var sqlstr = "UPDATE hours SET project='"+id+"';";
    db.transaction(function(tx) {
        var rs = tx.executeSql(sqlstr);
        if (rs.rowsAffected > 0) {
            resp = "Updated hours to project id: " + id;
        }
    });

    return resp;
}

function moveAllHoursToProjectByDesc(defaultProjectId) {
    var resp = "OK";
    var projects = getProjects();
    var allhours = getAll();
    for (var i = 0; i < allhours.length; i++) {
        var sqlstr = "UPDATE hours SET project='"+ defaultProjectId +"' WHERE uid='"+ allhours[i].uid +"';";
        if (allhours[i].description !== "No description") {
            for (var k = 0; k < projects.length; k++) {
                if ((allhours[i].description.toLowerCase()).indexOf(projects[k].name.toLowerCase()) > -1) {
                    sqlstr = "UPDATE hours SET project='"+ projects[k].id +"' WHERE uid='"+ allhours[i].uid +"';";
                }
            }
        }

        db.transaction(function(tx) {
            var rs = tx.executeSql(sqlstr);
        });
    }

    return "Updated: " + i + " rows";
}



// Tasks

// Save task
function setTask(taskId, projectId, name) {
    var resp = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO tasks VALUES (?,?,?);', [taskId, projectId, name]);
        if (rs.rowsAffected > 0) {
            resp = "OK";
            Log.info("Task saved to database");
        }
        else {
            resp = "Error";
            Log.error("Error saving task to database");
        }
    });

    return resp;
}

function getProjectTasks(projectId) {
    var resp = [];
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM tasks WHERE projectId=? ORDER BY id ASC;', [projectId]);

        if (rs.rows.length > 0) {
            for (var i = 0; i<rs.rows.length; i++) {
                var item = {};
                item["id"]=rs.rows.item(i).id;
                item["name"]= rs.rows.item(i).name;
                resp.push(item);
            }
        }
    });

    return resp;
}

function getTaskById(id) {
    var item = {};
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM tasks WHERE id=?;', [id]);
        if (rs.rows.length > 0) {
            for (var i = 0; i<rs.rows.length; i++) {
                item["id"]=rs.rows.item(i).id;
                item["name"]= rs.rows.item(i).name;
                break;
            }
        }
    });
    return item;
}

/* Fetch last used input */
function getLastUsed(projectId, taskId) {
    var rs;
    var result = {
        projectId: "",
        taskId: "",
        description: "",
    }

    db.transaction(function(tx) {
        if (projectId && taskId) {
            rs = tx.executeSql('SELECT project, taskId, description FROM hours WHERE project=? AND taskId=? ORDER BY strftime("%Y-%m-%d", date) DESC LIMIT 1;', [projectId, taskId]);
        }
        else if (projectId && !taskId) {
            rs = tx.executeSql('SELECT project, taskId, description FROM hours WHERE project=? ORDER BY strftime("%Y-%m-%d", date) DESC LIMIT 1;', [projectId]);
        }
        else {
            rs = tx.executeSql('SELECT project, taskId, description FROM hours ORDER BY strftime("%Y-%m-%d", date) DESC LIMIT 1;');
        }

        if (rs.rows.length > 0) {
            if (rs.rows.item(0).project) {
                result['projectId'] = rs.rows.item(0).project;
            }

            if (rs.rows.item(0).taskId) {
                result['taskId'] = rs.rows.item(0).taskId;
            }

            if (rs.rows.item(0).description && rs.rows.item(0).description != 'No description') {
                result['description'] = rs.rows.item(0).description;
            }
        }
    });

    return result;
}
