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

CoverBackground {
    property bool timerRunning: false
    property string startTime: ""
    property string durationNow: "0h 0min"
    property double thisWeek: 0
    property double thisMonth: 0

    property bool active: status == Cover.Active
    onActiveChanged: refreshCover()

    function refreshCover() {
        startTime = DB.getStartTime()
        if (startTime!= "Not started")
            timerRunning = true
        //console.log(timerRunning)
        //console.log(startTime)
        thisWeek = DB.getHoursThisWeek().toFixed(2)
        thisMonth = DB.getHoursThisMonth().toFixed(2)
    }
    function updateDuration(){
        var dateNow = new Date();
        var hoursNow = dateNow.getHours();
        var minutesNow = dateNow.getMinutes();
        var nowInMinutes = hoursNow * 60 + minutesNow;
        var splitted = startTime.split(":");
        //console.log(splitted);
        var startInMinutes = parseInt(splitted[0]) * 60 + parseInt(splitted[1]);
        //console.log(nowInMinutes);
        //console.log(startInMinutes);
        if (nowInMinutes < startInMinutes)
            nowInMinutes += 24*60
        var difference = nowInMinutes - startInMinutes;
        var diffHours = Math.floor(difference / 60)
        var diffMinutes = difference % 60;
        durationNow = diffHours + "h " + diffMinutes + "min";
    }
    CoverPlaceholder {
        id: icon
        icon.source: "wht.png"
        anchors.fill: parent
        //opacity: 0.6
    }
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                if(pageStack.depth > 1)
                    pageStack.replaceAbove(appWindow.firstPage, Qt.resolvedUrl("../pages/Add.qml"), {dataContainer: appWindow.firstPage, uid: 0})
                else
                    pageStack.push(Qt.resolvedUrl("../pages/Add.qml"), {dataContainer: appWindow.firstPage, uid: 0})
                appWindow.activate()
            }
        }
        CoverAction {
            iconSource: timerRunning ? "image://theme/icon-cover-cancel" : "image://theme/icon-cover-timer"
            onTriggered: {
                if (timerRunning) {
                    var splitted = startTime.split(":");
                    var startSelectedMinute = parseInt(splitted[1])
                    var startSelectedHour = parseInt(splitted[0])
                    var dateNow = new Date();
                    var endSelectedHour = dateNow.getHours();
                    var endSelectedMinute = dateNow.getMinutes();
                    var endHour = endSelectedHour
                    if (endSelectedHour < startSelectedHour)
                        endHour +=24
                    var duration = ((((endHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)
                    DB.stopTimer();
                    timerRunning = false
                    durationNow = "0h 0min"
                    //pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"))
                    if(pageStack.depth > 1) {
                        pageStack.replaceAbove(appWindow.firstPage, Qt.resolvedUrl("../pages/Add.qml"), {
                                       dataContainer: appWindow.firstPage,
                                       uid: 0,
                                       startSelectedMinute:startSelectedMinute,
                                       startSelectedHour:startSelectedHour,
                                       duration:duration })
                    }
                    else {
                        pageStack.push(Qt.resolvedUrl("../pages/Add.qml"), {
                                       dataContainer: appWindow.firstPage,
                                       uid: 0,
                                       startSelectedMinute:startSelectedMinute,
                                       startSelectedHour:startSelectedHour,
                                       duration:duration })
                    }
                    console.log("Stopping")
                    appWindow.activate()
                } else {
                    startTime = DB.getStartTime();
                    if(startTime === "Not started"){
                        startTime = DB.startTimer();
                    }
                    updateDuration();
                    timerRunning = true
                }
            }
        }
    }

    Column {
        spacing: Theme.paddingMedium;
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.paddingMedium
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryHighlightColor
            radius: 10.0
            width: 210
            height: 80
            Label {
                anchors.centerIn: parent
                id: week
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.highlightColor
                text: "Week: " + thisWeek
            }
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryHighlightColor
            radius: 10.0
            width: 210
            height: 80
            Label {
                anchors.centerIn: parent
                id: month
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.highlightColor
                text: "Month: " + thisMonth
            }
        }
        Rectangle {
            visible: timerRunning
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryHighlightColor
            radius: 10.0
            width: 210
            height: 80
            IconButton {
                id: iconButton
                icon.source: "image://theme/icon-cover-timer"
                scale: 0.5
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: iconButton.right
                id: timer
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.highlightColor
                text: durationNow
            }
        }
    }
    Component.onCompleted: {
        refreshCover()
        if (timerRunning)
            updateDuration()
    }
    Timer {
        interval: 60000; running: timerRunning; repeat: true
        onTriggered: updateDuration()
    }
}


