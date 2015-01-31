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
    function getAllToday(){
        return DB.getAllToday();
    }
    function getAllThisWeek(){
        return DB.getAllThisWeek();
    }
    function getAllThisMonth(){
        return DB.getAllThisMonth();
    }
    function getAllThisYear(){
        return DB.getAllThisYear();
    }
    function getAll(){
        return DB.getAll();
    }
    function getStartTime(){
        return DB.getStartTime();
    }
    function startTimer(){
        return DB.startTimer();
    }
    function stopTimer(){
        DB.stopTimer();
    }
    function remove(uid){
        console.log("Trying to remove from database!")
        console.log(uid);
        DB.remove(uid);
    }

    Component.onCompleted: {
        // Initialize the database
        DB.initialize();
        DB.updateIfNeeded();
        //console.log("Get hours from database...");
        getHours();
        console.log(DB.getHoursMonth(0))
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
        width: parent.width
        height: 5*130 + 3*Theme.paddingLarge
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
                text: "Timer"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Timer.qml"), {dataContainer: root})
                }
            }
        }
        model: summaryModel
        header: PageHeader { title: "Working Hours Tracker" }

        delegate: Item {
            width: listView.width
            height: 130 + Theme.paddingLarge
            MouseArea {
                width: listView.width/2
                height: 130
                Rectangle {
                    anchors {
                         rightMargin: Theme.paddingLarge
                    }
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: listView.width/2-1.5*Theme.paddingLarge
                    height: 130
                    x: Theme.paddingLarge
                    Label {
                        y: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.sectionLast
                    }
                    Label {
                        y: 3* Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.hoursLast
                        font.bold: true
                    }
                }
                onClicked: {console.log("last clicked!"); pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: model.sectionLast})}
            }
            MouseArea {
                width: listView.width/2
                height: 130
                x: listView.width/2
                Rectangle {
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: listView.width/2-1.5*Theme.paddingLarge
                    height: 130
                    x: 0.5*Theme.paddingLarge
                    Label {
                        y: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.section
                    }
                    Label {
                        y: 3* Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.hours
                        font.bold: true
                    }
                }
                onClicked: pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: model.section})
            }
        }
    }
    BackgroundItem {
        anchors.top: listView.bottom
        height: 130
        width: parent.width
        Rectangle {
            color: Theme.secondaryHighlightColor
            radius: 10.0
            width: parent.width-2*Theme.paddingLarge
            height: 130
            x: Theme.paddingLarge
            Label {
                y: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Timer is not running"
            }
            Label {
                y: 3* Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Click to start"
                font.bold: true
            }
        }
        onClicked: console.log("Start timer here")
    }
}


