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
Qt.include("helpers.js")

WorkerScript.onMessage = function(message) {
    if (message.type === 'all')
        all(message);
    else if (message.type ==='categorySummary') {
        categorySummary(message);
    }
    else {
        console.log("Unknown request to workerScript");
    }
}

function categorySummary(message){
    var allHours = message.allHours;
    var projects = message.projects;
    var lastDate = "";
    var results=[];
    var item ={
        'project': {},
        'projectDuration': 0,
        'projectPrice': 0,
        'projectWorkdays': 0,
        'projectEntries': 0
    }
    for (var i = 0; i < allHours.length; i++) {
        var project = getProject(allHours[i].project, projects);
        if(i === 0) {
            item.project = project;
        }
        if(project.id !== item.project.id) {
            results.push(item);
            item = {
                'project': project,
                'projectDuration': 0,
                'projectPrice': 0,
                'projectWorkdays': 0,
                'projectEntries': 0
            };
            lastDate = "";
        }
        var netDuration = allHours[i].duration - allHours[i].breakDuration;
        item.projectDuration+= netDuration;
        if (project.hourlyRate)
            item.projectPrice += project.hourlyRate * netDuration;
        if(allHours[i].date!==lastDate){
            item.projectWorkdays+=1;
            lastDate = allHours[i].date;
        }
        item.projectEntries+=1;
    }
    results.push(item);
    if(results.length) {
        for(var j=0; j<results.length; j++) {
            var data = {
               'header': results[j].project.name,
               'duration': qsTr("Duration") + ": " + results[j].projectDuration.toString().toHHMM(),
               'days': qsTr("Workdays") + ": " + results[j].projectWorkdays,
               'entries': qsTr("Entries") + ": " + results[j].projectEntries,
               'price': results[j].projectPrice,
               'labelColor': results[j].project.labelColor
            }
            WorkerScript.sendMessage({ 'status': 'ok', 'data': data });
        }
    }
    else {
        WorkerScript.sendMessage({ 'status': 'empty' });
    }
}

function all(message){
    var allHours = message.allHours;
    var projects = message.projects;
    var lastDate = "";
    var categoryDuration = 0;
    var categoryPrice = 0;
    var categoryWorkdays = 0;
    var categoryEntries = 0;

    for (var i = 0; i < allHours.length; i++) {
        var project = getProject(allHours[i].project, projects);
        var taskId = "0"
        if (allHours[i].taskId !== "0")
            taskId = allHours[i].taskId
        var taskName = ""
        if (taskId !=="" && taskId !=="0" && !project.error) {
            taskName = getTaskName(project, allHours[i].taskId)
        }
        var data  = {
            'uid': allHours[i].uid,
            'date': allHours[i].date,
            'startTime': allHours[i].startTime,
            'endTime': allHours[i].endTime,
            'duration': allHours[i].duration,
            'project' : allHours[i].project,
            'projectName': project.name,
            'description': allHours[i].description,
            'breakDuration': allHours[i].breakDuration,
            'labelColor': project.labelColor,
            'hourlyRate': project.hourlyRate,
            'taskId': taskId,
            'taskName': taskName
        }
        WorkerScript.sendMessage({ 'status': 'running', 'data': data });
        var netDuration = allHours[i].duration - allHours[i].breakDuration;
        categoryDuration+= netDuration;
        if (project.hourlyRate)
            categoryPrice += project.hourlyRate * netDuration;
        if(allHours[i].date!==lastDate){
            categoryWorkdays+=1;
            lastDate = allHours[i].date;
        }
        categoryEntries+=1;
    }
    var summary  = {
        'categoryDuration': categoryDuration,
        'categoryPrice': categoryPrice,
        'categoryWorkdays': categoryWorkdays,
        'categoryEntries': categoryEntries,
    }
    WorkerScript.sendMessage({ 'status': 'done', 'data': summary });
}

function getProject(projectId, projects) {
    var found = projects.findById(projectId);
    if(found) {
        return found;
    }
    return {
        'name':qsTr('Project was not found'),
        'labelColor': Theme.secondaryHighlightColor,
        'error': true
    };
}

function getTaskName(project, taskId) {
    if (project.tasks) {
        var found = project.tasks.findById(taskId);
        if(found) {
            return found.name;
        }
    }
    return '';
}
