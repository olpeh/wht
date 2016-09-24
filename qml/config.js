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
