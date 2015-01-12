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
    id: timerPage
    property QtObject dataContainer: null
    property string startTime: ""
    property int startSelectedHour : -1
    property int startSelectedMinute : -1

    function pad(n) { return ("0" + n).slice(-2); }

    function getStartTime(){
        startTime = DB.getStartTime();
        console.log(startTime);
    }
    function start(){
        startTime = DB.startTimer();
        console.log(startTime);
    }

    function updateStartTime(){
        //getStartTime();
        var splitted = startTime.split(":");
        startSelectedHour = parseInt(splitted[0]);
        startSelectedMinute = parseInt(splitted[1]);
        startedAt.text = pad(startSelectedHour) +":"+pad(startSelectedMinute);
    }

    function updateDuration(){
        var dateNow = new Date();
        var hoursNow = dateNow.getHours();
        var minutesNow = dateNow.getMinutes();
        var nowInMinutes = hoursNow * 60 + minutesNow;
        var splitted = startTime.split(":");
        console.log(splitted);
        var startInMinutes = parseInt(splitted[0]) * 60 + parseInt(splitted[1]);
        //console.log(nowInMinutes);
        //console.log(startInMinutes);
        if (nowInMinutes < startInMinutes)
            nowInMinutes += 24*60
        var difference = nowInMinutes - startInMinutes;
        var diffHours = Math.floor(difference / 60)
        var diffMinutes = difference % 60;
        durationNow.text = diffHours + "h " + diffMinutes + "min";
    }

    function stop(){
        console.log("Stop clicked!");
        if (dataContainer !=null && startSelectedMinute != -1 && startSelectedHour != -1){
            DB.stopTimer();
            var dateNow = new Date();
            var endSelectedHour = dateNow.getHours();
            var endSelectedMinute = dateNow.getMinutes();
            var endHour = endSelectedHour
            if (endSelectedHour < startSelectedHour)
                endHour +=24
            var duration = ((((endHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)
            pageStack.replace(Qt.resolvedUrl("Add.qml"), {
                                  dataContainer: dataContainer,
                                  uid: 0,
                                  startSelectedMinute:startSelectedMinute,
                                  startSelectedHour:startSelectedHour,
                                  endSelectedHour:endSelectedHour,
                                  endSelectedMinute:endSelectedMinute,
                                  duration:duration,
                                  fromTimer: true })
        }
        else
            console.log("Error when stopping the timer!");
    }
    function reset(){
        console.log("Reset clicked!");
        if (dataContainer !=null && startSelectedMinute != -1 && startSelectedHour != -1){
            DB.stopTimer();
            start();
            updateStartTime();
            updateDuration();
        }
        else
            console.log("Error when resetting the timer!");
    }
    Component.onCompleted: {
        getStartTime();
        if(startTime === "Not started"){
            start();
        }
        updateStartTime();
        updateDuration();

        if (startedAt.text != "Error") {
            info2.text = "Timer is now running!"
            info.text =" You may close the app and the timer will remain running."
        }
    }
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        PullDownMenu {
            MenuItem {
                text: "Reset the timer"
                onClicked: {
                    reset();
                }
            }
            MenuItem {
                text: "Stop the timer"
                onClicked: {
                    stop();
                }
            }
        }
        Column {
            id: column
            width: parent.width
            spacing: 25

            PageHeader { title: "Timer" }
            Text {
                id: info2
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                }
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font {pixelSize: Theme.fontSizeMedium; bold:true}
                text: {"An error occured when starting the timer."}
            }
            Text {
                id: info
                width: parent.width
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font {pixelSize: Theme.fontSizeSmall}
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                }
                text: {"Please try again."}
            }
            SectionHeader {
                id: startedSection
                text: "Timer started at"
            }
            Rectangle {
                anchors.horizontalCenter: startedSection.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 180
                height: 80
                Text {
                    id: startedAt
                    color: Theme.highlightColor
                    anchors.centerIn: parent
                    font.pointSize: 24
                    text: "Error"
                }
            }
            SectionHeader {
                id: durationSection
                text: "Duration now"
            }
            Rectangle {
                anchors.horizontalCenter: durationSection.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 180
                height: 80
                Text {
                    id: durationNow
                    color: Theme.highlightColor
                    anchors.centerIn: parent
                    font.pointSize: 24
                    text: "00:00"
                }
            }
            SectionHeader {
                text: "Control"
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 125
                height: 80
                ValueButton {
                    id: stopTimerButton
                    anchors.centerIn: parent
                    label: "Stop"
                    width: parent.width
                    onClicked: stop()
                }
            }
        }
        Timer {
            interval: 60000; running: true; repeat: true
            onTriggered: updateDuration()
        }
    }


}
