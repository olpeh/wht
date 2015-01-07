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
        summaryModel.set(0,{"hours": 0});
        summaryModel.set(1,{"hours": 0});
        summaryModel.set(2,{"hours": 0});
        summaryModel.set(3,{"hours": 0});
        summaryModel.set(4,{"hours": 0});
    }
    function getHours() {
        //Update hours view after adding or deleting hours
        summaryModel.set(0,{"hours": DB.getHoursToday()});
        summaryModel.set(1,{"hours": DB.getHoursThisWeek()});
        summaryModel.set(2,{"hours": DB.getHoursThisMonth()});
        summaryModel.set(3,{"hours": DB.getHoursThisYear()});
        summaryModel.set(4,{"hours": DB.getHoursAll()});
    }
    function setHours(uid,date,duration,description) {
        DB.setHours(uid,date,duration,description)
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
        console.log("Get hours from database...");
        summaryModel.set(0,{"hours": DB.getHoursToday()});
        summaryModel.set(1,{"hours": DB.getHoursThisWeek()});
        summaryModel.set(2,{"hours": DB.getHoursThisMonth()});
        summaryModel.set(3,{"hours": DB.getHoursThisYear()});
        summaryModel.set(4,{"hours": DB.getHoursAll()});
        //console.log(DB.getHoursAll())
    }

    ListModel {
        id: summaryModel
        ListElement {
            hours: 0
            section: "Today"
        }
        ListElement {
            hours: 0
            section: "This week"
        }
        ListElement {
            hours: 0
            section: "This month"
        }
        ListElement {
            hours: 0
            section: "This year"
        }
        ListElement {
            hours: 0
            section: "All"
        }
    }
    SilicaListView {
        id: listView
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
                text: "Timer"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Timer.qml"), {dataContainer: root})
                }
            }
        }
        model: summaryModel
        header: PageHeader { title: "Working Hours Tracker" }
        section {
            property: 'section'
            delegate: SectionHeader {
                text: section
            }
        }
        delegate: BackgroundItem {
            width: listView.width
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 175
                height: 80
                Label {
                    anchors.centerIn: parent
                    id: duration
                    text: model.hours
                    x: Theme.paddingLarge
                }
            }
            onClicked: pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: section})
        }
        VerticalScrollDecorator {}
    }
}


