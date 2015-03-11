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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB


Page {
    id: root
    function resetDatabase(){
        //console.log(hours);
        DB.resetDatabase();
        summaryModel.set(0,{"hours": "0", "hoursLast": "0"});
        summaryModel.set(1,{"hours": "0", "hoursLast": "0"});
        summaryModel.set(2,{"hours": "0", "hoursLast": "0"});
        summaryModel.set(3,{"hours": "0", "hoursLast": "0"});
     }
    function getHours() {
        //Update hours view after adding or deleting hours
        summaryModel.set(0,{"hours": DB.getHoursDay(0).toString().toHHMM(), "hoursLast": DB.getHoursDay(1).toString().toHHMM()});
        summaryModel.set(1,{"hours": DB.getHoursWeek(0).toString().toHHMM(), "hoursLast": DB.getHoursWeek(1).toString().toHHMM()});
        summaryModel.set(2,{"hours": DB.getHoursMonth(0).toString().toHHMM(), "hoursLast": DB.getHoursMonth(1).toString().toHHMM()});
        summaryModel.set(3,{"hours": DB.getHoursYear(0).toString().toHHMM(), "hoursLast": DB.getHoursAll().toString().toHHMM()});
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
        if(!fromCover) {
            pageStack.push(Qt.resolvedUrl("Add.qml"), {
                                  dataContainer: root,
                                  uid: 0,
                                  startSelectedMinute:startSelectedMinute,
                                  startSelectedHour:startSelectedHour,
                                  endSelectedHour:endSelectedHour,
                                  endSelectedMinute:endSelectedMinute,
                                  duration:duration, breakDuration:breakDuration, fromTimer: true})
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

    function refreshCover() {
        today = DB.getHoursDay(0).toString().toHHMM()
        thisWeek = DB.getHoursWeek(0).toString().toHHMM()
        thisMonth = DB.getHoursMonth(0).toString().toHHMM()
    }
    onStatusChanged: {
        if (root.status === PageStatus.Active && projects.length > 1) {
            if (pageStack._currentContainer.attachedContainer == null) {
                pageStack.pushAttached(Qt.resolvedUrl("ProjectPage.qml"), {dataContainer: root});
            }
        }
    }

    Component.onCompleted: {
        // Update tables for previous versions
        DB.updateIfNeeded();
        // Initialize the database
        DB.initialize();
        projects = DB.getProjects();
        if (projects.length === 0) {
            var id = DB.getUniqueId();
            DB.setProject(id, qsTr("default"), 0, 0, 0, 0, Theme.secondaryHighlightColor);
            defaultProjectId = id;
            settings.setDefaultProjecId(id);
            moveAllHoursTo(id);
        }
        else {
            defaultProjectId = settings.getDefaultProjecId();
        }

        //console.log("Get hours from database...");
        getHours();
        getStartTime();
        if(startTime !== "Not started"){
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

            // Automatically start timer if allowed in settings
            if(settings.getTimerAutoStart()){
                start();
            }
        }
        currencyString = settings.getCurrencyString();
        if(!currencyString){
            currencyString = "€";
            settings.setCurrencyString(currencyString);
        }
    }
    SilicaFlickable {
        anchors.fill: parent
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

        ListModel {
            id: summaryModel
            ListElement {
                hours: "0"
                section: qsTr("Today")
                hoursLast: "0"
                sectionLast: qsTr("Yesterday")
            }
            ListElement {
                hours: "0"
                section: qsTr("This week")
                hoursLast: "0"
                sectionLast: qsTr("Last week")
            }
            ListElement {
                hours: "0"
                section: qsTr("This month")
                hoursLast: "0"
                sectionLast: qsTr("Last month")
            }
            ListElement {
                hours: "0"
                section: qsTr("This year")
                hoursLast: "0"
                sectionLast: qsTr("All")
            }
        }
        SilicaListView {
            id: listView
            header: PageHeader { title: "Working Hours Tracker" }
            anchors.fill: parent
            model: summaryModel
            delegate: Item {
                width: listView.width
                height: 140 + Theme.paddingLarge
                BackgroundItem {
                    width: listView.width/2
                    height: 140
                    Rectangle {
                        anchors {
                             rightMargin: Theme.paddingLarge
                        }
                        color: Theme.secondaryHighlightColor
                        radius: 10.0
                        width: listView.width/2-1.5*Theme.paddingLarge
                        height: 140
                        x: Theme.paddingLarge
                        Label {
                            y: Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.sectionLast
                        }
                        Label {
                            y: 3 * Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.hoursLast
                            font.bold: true
                        }
                    }
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: model.sectionLast})
                    }
                }
                BackgroundItem {
                    width: listView.width/2
                    height: 140
                    x: listView.width/2
                    Rectangle {
                        color: Theme.secondaryHighlightColor
                        radius: 10.0
                        width: listView.width/2-1.5*Theme.paddingLarge
                        height: 140
                        x: 0.5*Theme.paddingLarge
                        Label {
                            y: Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.section
                        }
                        Label {
                            y:3 * Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.hours
                            font.bold: true
                        }
                    }
                    onClicked: pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: model.section})
                }
            }
            BackgroundItem {
                visible: !timerRunning
                y: 110 + 4*140 + 4*Theme.paddingLarge
                height: 140
                width: parent.width
                Rectangle {
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: parent.width-2*Theme.paddingLarge
                    height: 140
                    x: Theme.paddingLarge
                    Label {
                        id: timerText
                        y: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Timer is not running")
                    }
                    Label {
                        y:3 * Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Click to start")
                        font.bold: true
                    }
                }
                onClicked: start()
            }

            Item {
                id: timerItem
                visible: timerRunning
                y: 110 + 4*140 + 4*Theme.paddingLarge
                height: 140
                width: parent.width
                BackgroundItem {
                    width: timerItem.width /3
                    height: 140
                    Rectangle {
                        color: Theme.secondaryHighlightColor
                        radius: 10.0
                        width: (timerItem.width-4*Theme.paddingLarge) / 3
                        height: 140
                        x: Theme.paddingLarge
                        Label {
                            visible: breakTimerRunning
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: Theme.paddingMedium
                            font.bold: true
                            font.pixelSize: Theme.fontSizeSmall
                            text: breakDurationNow
                        }
                        Image {
                            id: pauseImage
                            source: breakTimerRunning ? "image://theme/icon-cover-play" : "image://theme/icon-cover-pause"
                            anchors.centerIn: parent
                            scale: 0.5
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
                        if(!breakTimerRunning) {
                            startBreakTimer()
                        }
                        else {
                            stopBreakTimer()
                        }
                    }
                }
                BackgroundItem {
                    width: timerItem.width /3
                    height: 140
                    x: timerItem.width/3
                    Rectangle {
                        opacity: breakTimerRunning? 0.5 : 1
                        color: Theme.secondaryHighlightColor
                        radius: 10.0
                        width: (timerItem.width-4*Theme.paddingLarge) / 3
                        height: 140
                        x: (2/3) * Theme.paddingLarge
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
                            scale: 0.5
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
                    onClicked: if(!breakTimerRunning) stop(false)
                }
                BackgroundItem {
                    width: timerItem.width /3
                    height: 140
                    x: 2 * timerItem.width/3
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
                        radius: 10.0
                        width: (timerItem.width-4*Theme.paddingLarge) / 3
                        height: 140
                        x: (1/3)*Theme.paddingLarge
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
                    onClicked: if(!breakTimerRunning) openTimeDialog()
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
    }
}


