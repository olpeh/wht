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
        summaryModel.set(0,{"hours": 0, "hoursLast": 0});
        summaryModel.set(1,{"hours": 0, "hoursLast": 0});
        summaryModel.set(2,{"hours": 0, "hoursLast": 0});
        summaryModel.set(3,{"hours": 0, "hoursLast": 0});
     }
    function getHours() {
        //Update hours view after adding or deleting hours
        summaryModel.set(0,{"hours": DB.getHoursDay(0), "hoursLast": DB.getHoursDay(1)});
        summaryModel.set(1,{"hours": DB.getHoursWeek(0), "hoursLast": DB.getHoursWeek(1)});
        summaryModel.set(2,{"hours": DB.getHoursMonth(0), "hoursLast": DB.getHoursMonth(1)});
        summaryModel.set(3,{"hours": DB.getHoursYear(0), "hoursLast": DB.getHoursAll()});
    }
    function setHours(uid,date,duration,description, breakDuration) {
        DB.setHours(uid,date,duration,description, breakDuration)
    }
    function getAllDay(offset){
        return DB.getAllDay(offset);
    }
    function getAllWeek(offset){
        return DB.getAllWeek(offset);
    }
    function getAllMonth(offset){
        return DB.getAllMonth(offset);
    }
    function getAllThisYear(){
        return DB.getAllThisYear();
    }
    function getAll(){
        return DB.getAll();
    }
    function remove(uid){
        console.log("Trying to remove from database!")
        console.log(uid);
        DB.remove(uid);
    }
    property int startSelectedHour : -1
    property int startSelectedMinute : -1

    function pad(n) { return ("0" + n).slice(-2); }

    function getStartTime(){
        startTime = DB.getStartTime();
    }
    function start(){
        startTime = DB.startTimer();
        updateStartTime();
        timerRunning = true
    }

    function updateStartTime(){
        var splitted = startTime.split(":");
        startSelectedHour = parseInt(splitted[0]);
        startSelectedMinute = parseInt(splitted[1]);
        startedAt.text = pad(startSelectedHour) +":"+pad(startSelectedMinute);
    }
    function updateDuration(){
        console.log("Triggered")
        var dateNow = new Date();
        var hoursNow = dateNow.getHours();
        var minutesNow = dateNow.getMinutes();
        var nowInMinutes = hoursNow * 60 + minutesNow;
        var splitted = startTime.split(":");
        var startInMinutes = parseInt(splitted[0]) * 60 + parseInt(splitted[1]);
        if (nowInMinutes < startInMinutes)
            nowInMinutes += 24*60
        var difference = nowInMinutes - startInMinutes;
        var diffHours = Math.floor(difference / 60)
        var diffMinutes = difference % 60;
        durationNow = diffHours + "h " + diffMinutes + "min";
    }

    function stop(fromCover){
        console.log("Stop clicked!");
        DB.stopTimer();
        durationNow = "0h 0min"
        timerRunning = false;
        var dateNow = new Date();
        var endSelectedHour = dateNow.getHours();
        var endSelectedMinute = dateNow.getMinutes();
        var endHour = endSelectedHour
        if (endSelectedHour < startSelectedHour)
            endHour +=24
        var duration = ((((endHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)

        if(!fromCover) {
            pageStack.push(Qt.resolvedUrl("Add.qml"), {
                                  dataContainer: root,
                                  uid: 0,
                                  startSelectedMinute:startSelectedMinute,
                                  startSelectedHour:startSelectedHour,
                                  endSelectedHour:endSelectedHour,
                                  endSelectedMinute:endSelectedMinute,
                                  duration:duration, fromTimer: true })

        }
        else {
            if(pageStack.depth > 1) {
                pageStack.replaceAbove(appWindow.firstPage, Qt.resolvedUrl("../pages/Add.qml"), {
                               dataContainer: root,
                               uid: 0,
                               startSelectedMinute:startSelectedMinute,
                               startSelectedHour:startSelectedHour,
                               duration:duration, fromCover: true })
            }
            else {
                pageStack.push(Qt.resolvedUrl("../pages/Add.qml"), {
                               dataContainer: root,
                               uid: 0,
                               startSelectedMinute:startSelectedMinute,
                               startSelectedHour:startSelectedHour,
                               duration:duration, fromCover: true })
            }
        }
    }

    function reset(){
        console.log("Reset clicked!");
        DB.stopTimer();
        start();
        updateStartTime();
        updateDuration();
        timerRunning = true
    }

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        DB.updateIfNeeded();
        //console.log("Get hours from database...");
        getHours();
        getStartTime();
        if(startTime !== "Not started"){
            timerRunning = true;
            updateStartTime();
            updateDuration();
        }
    }
    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"), {dataContainer: root})
                }
            }
            MenuItem {
                text: "Add Hours"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Add.qml"), {dataContainer: root, uid: 0})
                }
            }
            MenuItem {
                text: timerRunning ? "Stop timer" : "Start timer"
                onClicked: {
                    if (timerRunning)
                        stop(false);
                    else
                        start();
                }
            }
        }
        PushUpMenu {
            visible: timerRunning
            MenuItem {
                text: "Reset the timer"
                onClicked: reset()
            }
            MenuItem {
                text: "Adjust timer start time"
                onClicked: console.log("Coming up!")
            }
        }
        ListModel {
            id: summaryModel
            ListElement {
                hours: 0
                section: "Today"
                hoursLast: 0
                sectionLast: "Yesterday"
            }
            ListElement {
                hours: 0
                section: "This week"
                hoursLast: 0
                sectionLast: "Last week"
            }
            ListElement {
                hours: 0
                section: "This month"
                hoursLast: 0
                sectionLast: "Last month"
            }
            ListElement {
                hours: 0
                section: "This year"
                hoursLast: 0
                sectionLast: "All"
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
                    onClicked: pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: model.sectionLast})
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
                        visible: !timerRunning
                        id: timerText
                        y: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Timer is not running"
                    }
                    Item {
                        visible: timerRunning
                        width: parent.width
                        Label {
                            x: Theme.paddingLarge
                            y: Theme.paddingLarge
                            id: started
                            text: "Started"
                        }
                        Label {
                            x: Theme.paddingLarge
                            y:3 * Theme.paddingLarge
                            id: startedAt
                            font.bold: true
                            text: "Now"
                        }
                        IconButton {
                            id: iconButton
                            icon.source: "image://theme/icon-cover-timer"
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: Theme.paddingSmall
                            scale: 0.5
                        }
                        Label {
                            x: parent.width - this.width - Theme.paddingLarge
                            y: Theme.paddingLarge
                            id: durText
                            text: "Duration"
                        }
                        Label {
                            x: parent.width - this.width - Theme.paddingLarge
                            y:3 * Theme.paddingLarge
                            id: durationNowLabel
                            font.bold: true
                            text: durationNow
                        }
                    }
                    Label {
                        y:3 * Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: timerRunning ? "Click to stop" : "Click to start"
                        font.bold: true
                    }
                }
                onClicked: timerRunning ? stop(false) : start()
            }
        }
        Timer {
            interval: 60000; running: timerRunning; repeat: true
            onTriggered: updateDuration()
        }
    }
}


