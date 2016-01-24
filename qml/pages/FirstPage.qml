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

import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtFeedback 5.0
import "../config.js" as DB


Page {
    id: root
    property bool versionCheckDone: false
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    //ThemeEffect {
        //id: buttonBuzz
        //effect: ThemeEffect.Press
    //}

    function resetDatabase(){
        //console.log(hours);
        DB.resetDatabase();
        summaryModel.set(0,{"hours": "0"});
        summaryModel.set(1,{"hours": "0"});
        summaryModel.set(2,{"hours": "0"});
        summaryModel.set(3,{"hours": "0"});
        summaryModel.set(4,{"hours": "0"});
        summaryModel.set(5,{"hours": "0"});
        summaryModel.set(6,{"hours": "0"});
        summaryModel.set(7,{"hours": "0"});
    }
    function getHours() {
        //Update hours view and cover
        //Log.info("Updating hours")
        today = DB.getHoursDay(0).toString().toHHMM()
        thisWeek = DB.getHoursWeek(0).toString().toHHMM()
        thisMonth = DB.getHoursMonth(0).toString().toHHMM()
        summaryModel.set(0,{"hours": DB.getHoursDay(1).toString().toHHMM() });
        summaryModel.set(1,{"hours": today });
        summaryModel.set(2,{"hours": DB.getHoursWeek(1).toString().toHHMM() });
        summaryModel.set(3,{"hours": thisWeek });
        summaryModel.set(4,{"hours": DB.getHoursMonth(1).toString().toHHMM() });
        summaryModel.set(5,{"hours": thisMonth });
        summaryModel.set(6,{"hours": DB.getHoursAll().toString().toHHMM() });
        summaryModel.set(7,{"hours": DB.getHoursYear(0).toString().toHHMM() });
    }
    function setHours(uid,date,duration,description, breakDuration) {
        DB.setHours(uid,date,duration,description, breakDuration)
    }
    function getAllDay(offset, sortby, projectId){
        return DB.getAllDay(offset, sortby, projectId);
    }
    function getAllWeek(offset, sortby, projectId){
        return DB.getAllWeek(offset, sortby, projectId);
    }
    function getAllMonth(offset, sortby, projectId){
        return DB.getAllMonth(offset, sortby, projectId);
    }
    function getAllThisYear(sortby, projectId){
        return DB.getAllThisYear(sortby, projectId);
    }
    function getAll(sortby, projectId){
        return DB.getAll(sortby, projectId);
        //console.log(projectId);
    }
    function remove(uid){
        DB.remove(uid);
    }
    function getProjects(){
        return DB.getProjects();
    }

    /* if no project is given as a parameter
      try to udpate according to the descriptions in hours */
    function moveAllHoursTo(id){
        return DB.moveAllHoursToProject(id);
    }

    function moveAllHoursToProjectByDesc(){
        if (defaultProjectId !== "")
            return DB.moveAllHoursToProjectByDesc(defaultProjectId);
        return qsTr("No default project found")
    }
    property int startSelectedHour : -1
    property int startSelectedMinute : -1

    function pad(n) { return ("0" + n).slice(-2); }

    function getStartTime(){
        startTime = DB.getStartTime();
    }
    function start(newValue){
        startTime = DB.startTimer(newValue);
        updateStartTime();
        timerRunning = true
    }
    function updateStartTime(){
        var splitted = startTime.split(":");
        startSelectedHour = parseInt(splitted[0]);
        startSelectedMinute = parseInt(splitted[1]);
        startedAt.text = pad(startSelectedHour) +":"+pad(startSelectedMinute);
    }
    function updateDuration(breakDur){
        //console.log("Update duration triggered");
        breakDuration = getBreakTimerDuration();
        if(breakDur)
            breakDuration += breakDur
        //console.log(breakDuration);
        var dateNow = new Date();
        var hoursNow = dateNow.getHours();
        var minutesNow = dateNow.getMinutes();
        var nowInMinutes = hoursNow * 60 + minutesNow;
        var splitted = startTime.split(":");
        var startInMinutes = parseInt(splitted[0]) * 60 + parseInt(splitted[1]);
        if (nowInMinutes < startInMinutes)
            nowInMinutes += 24*60
        var breakInMinutes = Math.round(breakDuration *60);
        //console.log(breakInMinutes);
        var difference = nowInMinutes - startInMinutes - breakInMinutes;
        var diffHours = Math.floor(difference / 60)
        var diffMinutes = difference % 60;
        durationNow = diffHours + "h " + diffMinutes + "min";
    }

    function stop(fromCover){
        if(breakTimerRunning) {
            stopBreakTimer();
            breakTimerRunning = false;
        }
        breakDuration = getBreakTimerDuration();

        var dateNow = new Date();
        var endSelectedHour = dateNow.getHours();
        var endSelectedMinute = dateNow.getMinutes();
        var endHour = endSelectedHour
        if (endSelectedHour < startSelectedHour)
            endHour +=24
        duration = ((((endHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)

        // Add default break duration if settings allow and no break recorded
        // Also only add it if it is less than the duration
        var defaultDur = settings.getDefaultBreakDuration()
        if (!breakDuration && settings.getDefaultBreakInTimer() && defaultDur < duration) {
            breakDuration = defaultDur
        }

        if (stopFromCommandLine) {
            var description = "Automatically saved from command line"
            var project = defaultProjectId
            var uid = DB.getUniqueId()
            var taskId = "0"

            var d = new Date()
            //YYYY-MM-DD
            var yyyy = d.getFullYear().toString();
            var mm = (d.getMonth()+1).toString(); // getMonth() is zero-based
            var dd  = d.getDate().toString();
            var dateString = yyyy +"-"+ (mm[1]?mm:"0"+mm[0]) +"-"+ (dd[1]?dd:"0"+dd[0]); // padding
            var startTime = pad(startSelectedHour) + ":" + pad(startSelectedMinute);
            var endTime = pad(endSelectedHour) + ":" + pad(endSelectedMinute);

            Log.info("AutoSaving: " + uid + "," + dateString + "," + startTime + "," + endTime + "," + duration + "," + project + "," + description + "," + breakDuration + "," + taskId)
            DB.setHours(uid,dateString,startTime, endTime, duration,project,description, breakDuration, taskId)

            getHours()
        }

        else if(!fromCover) {
            pageStack.push(Qt.resolvedUrl("Add.qml"), {
                                  dataContainer: root,
                                  uid: 0,
                                  startSelectedMinute:startSelectedMinute,
                                  startSelectedHour:startSelectedHour,
                                  endSelectedHour:endSelectedHour,
                                  endSelectedMinute:endSelectedMinute,
                                  duration:duration, breakDuration:breakDuration, fromTimer: true}, PageStackAction.Immediate)
        }
        else {
            if(pageStack.depth > 1) {
                pageStack.replaceAbove(appWindow.firstPage, Qt.resolvedUrl("../pages/Add.qml"), {
                               dataContainer: root,
                               uid: 0,
                               startSelectedMinute:startSelectedMinute,
                               startSelectedHour:startSelectedHour,
                               duration:duration, breakDuration:breakDuration, fromCover: true, fromTimer: true })
            }
            else {
                pageStack.push(Qt.resolvedUrl("../pages/Add.qml"), {
                               dataContainer: root,
                               uid: 0,
                               startSelectedMinute:startSelectedMinute,
                               startSelectedHour:startSelectedHour,
                               duration:duration, breakDuration:breakDuration, fromCover: true, fromTimer: true })
            }
        }
        breakDurationNow = "0h 0min";
        breakDuration = 0;
        durationNow = "0h 0min";
        duration = 0;
        DB.stopTimer();
        timerRunning = false;
        clearBreakTimer();

    }

    // Break timer functions
    function getBreakStartTime() {
        breakStartTime = DB.getBreakStartTime();
    }
    function startBreakTimer() {
        breakDuration = 0;
        breakDurationNow = "0h 0min";
        breakStartTime = DB.startBreakTimer();
        breakTimerRunning = true;
    }
    function updateBreakTimerDuration() {
        //console.log("Updating breakTimerDuration Triggered");
        var dateNow = new Date();
        var hoursNow = dateNow.getHours();
        var minutesNow = dateNow.getMinutes();
        var nowInMinutes = hoursNow * 60 + minutesNow;
        var splitted = breakStartTime.split(":");
        var startInMinutes = parseInt(splitted[0]) * 60 + parseInt(splitted[1]);
        if (nowInMinutes < startInMinutes)
            nowInMinutes += 24*60;
        var difference = nowInMinutes - startInMinutes;
        var diffHours = Math.floor(difference / 60);
        var diffMinutes = difference % 60;
        breakDurationNow = diffHours + "h " + diffMinutes + "min";
        // return the duration in hours
        return (difference/60)
    }

    function stopBreakTimer() {
        //console.log("stopBreakTimer clicked!");
        var splitted = breakStartTime.split(":");
        var timerStartHour = parseInt(splitted[0]);
        var timerStartMinute = parseInt(splitted[1]);
        var dateNow = new Date();
        var endSelectedHour = dateNow.getHours();
        var endSelectedMinute = dateNow.getMinutes();
        var endHour = endSelectedHour
        if (endSelectedHour < timerStartHour)
            endHour +=24
        breakDuration = ((((endHour - timerStartHour)*60) + (endSelectedMinute - timerStartMinute)) / 60).toFixed(2)
        DB.stopBreakTimer(breakDuration);
        breakTimerRunning = false;
    }

    function getBreakTimerDuration(){
        return DB.getBreakTimerDuration();

    }
    function clearBreakTimer(){
        DB.clearBreakTimer();
        breakDuration=0;
    }

    onStatusChanged: {
        if (root.status === PageStatus.Active && !versionCheckDone) {
            var lastVersionUsed = settings.getLastVersionUsed();
            console.log(lastVersionUsed);
            var current = appVersion + "-" + appBuildNum;
            console.log(current)
            if (lastVersionUsed !== current) {
                console.log("App updated");
                pageStack.push(Qt.resolvedUrl("WhatsNewPage.qml"))
            }
            settings.setLastVersionUsed(current);
            versionCheckDone = true;
        }

        if (root.status === PageStatus.Active && versionCheckDone) {
            if (projects.length > 1 && pageStack._currentContainer.attachedContainer == null) {
                pageStack.pushAttached(Qt.resolvedUrl("ProjectPage.qml"), {dataContainer: root}, PageStackAction.Immediate);
            }
            if(timerRunning && startTime !== "Not started" && stopFromCommandLine) {
                banner.notify(qsTr("Timer stopped by command line argument"));
                stop();
                pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: qsTr("Today")})
            }
        }
    }

    Component.onCompleted: {
        // Update tables for previous versions
        DB.updateIfNeededToV2();
        DB.updateIfNeededToV3();
        // Initialize the database
        DB.initialize();
        projects = DB.getProjects();
        if (projects.length === 0) {
            Log.info("No projects found so let's create one.");
            var id = DB.getUniqueId();
            DB.setProject(id, qsTr("default"), 0, 0, 0, 0, Theme.secondaryHighlightColor);
            defaultProjectId = id;
            settings.setDefaultProjectId(id);
            moveAllHoursTo(id);
        }
        else {
            defaultProjectId = settings.getDefaultProjectId();
        }

        //console.log("Get hours from database...");
        getHours();
        getStartTime();
        if(startTime !== "Not started") {
            timerRunning = true;
            updateStartTime();
            getBreakStartTime();
            if(breakStartTime !== "Not started"){
                breakTimerRunning = true;
                updateDuration(updateBreakTimerDuration());
            }
            else {
                breakDuration = 0;
                breakDurationNow = "0h 0min";
                updateDuration();
            }
        }
        else {
            duration = 0;
            durationNow = "0h 0min";
            // Start timer from command line
            if (startFromCommandLine) {
                banner.notify(qsTr("Timer started by command line argument"));
                start();
            }

            // Automatically start timer if allowed in settings
            else if(settings.getTimerAutoStart()){
                banner.notify(qsTr("Timer was autostarted"))
                start();
            }
        }
        currencyString = settings.getCurrencyString();
        if(!currencyString){
            currencyString = "€";
            settings.setCurrencyString(currencyString);
        }
    }

    ListModel {
        id: summaryModel
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        ListElement {
            hours: "0"
        }
        function section(index) {
            if (section["text"] === undefined) {
                section.text = [
                    qsTr("Yesterday"),
                    qsTr("Today"),
                    qsTr("Last week"),
                    qsTr("This week"),
                    qsTr("Last month"),
                    qsTr("This month"),
                    qsTr("All"),
                    qsTr("This year"),
                ]
            }
            return section.text[index]
        }
    }

    SilicaGridView {
        anchors.fill: parent
        id: grid

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"), {dataContainer: root})
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Settings.qml"), {dataContainer: root})
                }
            }
            MenuItem {
                text: qsTr("Add Hours")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Add.qml"), {dataContainer: root, uid: 0})
                }
            }
        }
        property PageHeader pageHeader
        header: PageHeader {
            id: pageHeader
            title: "Working Hours Tracker"
            Component.onCompleted: grid.pageHeader = pageHeader
        }

        cellWidth: {
            if (root.orientation == Orientation.PortraitInverted || root.orientation == Orientation.Portrait)
                root.width / 2
            else
                root.width / 4
        }
        cellHeight: {
            if (root.orientation == Orientation.PortraitInverted || root.orientation == Orientation.Portrait)
                (root.height / 5) - pageHeader.height / 5
            else
                (root.height / 3) - pageHeader.height / 3
        }
        model: summaryModel
        snapMode: GridView.SnapToRow
        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight
            BackgroundItem {
                anchors {
                    fill: parent
                    margins: Theme.paddingMedium
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width
                    height: parent.height
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -Theme.paddingLarge
                        text: summaryModel.section(index)
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: Theme.paddingLarge
                        text: model.hours
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: summaryModel.section(index)})
                }
            }
        }
    } // SilicaGridView

    BackgroundItem {
        id: timerControl
        visible: !timerRunning
        anchors {
            bottom: root.bottom
        }
        height: grid.cellHeight
        width: parent.width
        Rectangle {
            color: Theme.secondaryHighlightColor
            radius: Theme.paddingMedium
            anchors.fill: parent
            anchors.margins: Theme.paddingMedium

            Label {
                id: timerText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Timer is not running")
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Click to start")
                font.bold: true
            }
        }
        onClicked: {
            //buttonBuzz.play()
            start()
        }
    }

    Item {
        id: timerItem
        visible: timerRunning
        anchors.bottom: root.bottom
        height: timerControl.height
        width: parent.width
        BackgroundItem {
            width: timerItem.width / 3
            height: parent.height
            Rectangle {
                color: Theme.secondaryHighlightColor
                radius: Theme.paddingMedium
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                Label {
                    visible: breakTimerRunning
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Theme.paddingMedium
                    text: breakDurationNow
                }
                Image {
                    id: pauseImage
                    source: breakTimerRunning ? "image://theme/icon-cover-play" : "image://theme/icon-cover-pause"
                    anchors.centerIn: parent
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height - this.height - Theme.paddingMedium
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Break")
                }
            }
            onClicked: {
                //buttonBuzz.play()
                if(!breakTimerRunning) {
                    startBreakTimer()
                }
                else {
                    stopBreakTimer()
                }
            }
        }
        BackgroundItem {
            width: timerItem.width / 3
            height: timerControl.height
            x: timerItem.width / 3
            Rectangle {
                opacity: breakTimerRunning? 0.5 : 1
                color: Theme.secondaryHighlightColor
                radius: Theme.paddingMedium
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Theme.paddingMedium
                    color: Theme.primaryColor
                    id: durationNowLabel
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: durationNow
                }
                Image {
                    id: stopImage
                    source: "image://theme/icon-cover-cancel"
                    anchors.centerIn: parent
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height - this.height - Theme.paddingMedium
                    color: Theme.primaryColor
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Stop")
                }
            }
            onClicked: {
                if(!breakTimerRunning) {
                    //buttonBuzz.play()
                    stop(false)
                }
            }
        }
        BackgroundItem {
            width: timerItem.width / 3
            height: timerControl.height
            x: 2 * timerItem.width / 3
            function openTimeDialog() {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                hourMode: (DateTime.TwentyFourHours),
                                hour: startSelectedHour,
                                minute: startSelectedMinute,
                             })

                dialog.accepted.connect(function() {
                    startSelectedHour = dialog.hour
                    startSelectedMinute = dialog.minute
                    var newValue = pad(startSelectedHour) + ":" + pad(startSelectedMinute)
                    start(newValue)
                    updateDuration()
                })
            }
            Rectangle {
                opacity: breakTimerRunning? 0.5 : 1
                color: Theme.secondaryHighlightColor
                radius: Theme.paddingMedium
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                Label {
                    y: Theme.paddingMedium
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Started")
                }
                Label {
                    anchors.centerIn: parent
                    id: startedAt
                    color: Theme.secondaryColor
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: startTime
                }
                Label {
                    y: parent.height - this.height - Theme.paddingMedium
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Adjust")
                }
            }
            onClicked: {
                if(!breakTimerRunning) {
                    openTimeDialog()
                    //buttonBuzz.play()
                }
            }
        }
    }

    Timer {
        interval: 60000; running: timerRunning && !breakTimerRunning; repeat: true
        onTriggered: updateDuration()
    }
    Timer {
        interval: 60000; running: breakTimerRunning; repeat: true
        onTriggered: updateBreakTimerDuration()
    }
    Banner {
        id: banner
    }
}


