/*
Copyright (C) 2015 Olavi Haapala.
<ojhaapala@gmail.com>
Twitter: @olpetik
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
import "../config.js" as DB

CoverBackground {
    property bool active: status == Cover.Active
    onActiveChanged: {
        if(active) {
            if(timerRunning && !breakTimerRunning){
                //console.log("Timer refresh triggered");
                firstPage.updateDuration();
            }
            else if (breakTimerRunning) {
                //console.log("Break refresh triggered");
                firstPage.updateBreakTimerDuration();
            }
            else {
               //console.log("refresh triggered");
               firstPage.getHours();
            }
        }
    }

    CoverPlaceholder {
        id: icon
        icon.source: "wht.png"
        anchors.fill: parent
        opacity: 0.8
        anchors.topMargin: 35
    }
    CoverActionList {
        id: coverAction
        CoverAction {
            id: pauseAddAction
            iconSource:  {
                if(timerRunning && breakTimerRunning)
                    "image://theme/icon-cover-play"
                else if(timerRunning)
                    "image://theme/icon-cover-pause"
                else
                    "image://theme/icon-cover-new"
            }
            onTriggered: {
                if (timerRunning && !breakTimerRunning) {
                    console.log("Break starts...");
                    firstPage.startBreakTimer()
                    //pauseAddAction.iconSource = "image://theme/icon-cover-play"
                }
                else if (breakTimerRunning) {
                    console.log("Break ends...");
                    firstPage.stopBreakTimer()
                    //pauseAddAction.iconSource = "image://theme/icon-cover-pause"
                }
                else {
                    if(pageStack.depth > 1)
                        pageStack.replaceAbove(appWindow.firstPage, Qt.resolvedUrl("../pages/Add.qml"), {dataContainer: appWindow.firstPage, uid: 0, fromCover: true})
                    else
                        pageStack.push(Qt.resolvedUrl("../pages/Add.qml"), {dataContainer: appWindow.firstPage, uid: 0, fromCover: true})
                    appWindow.activate()
                }
            }
        }
        CoverAction {
            iconSource: timerRunning ? "image://theme/icon-cover-cancel" : "image://theme/icon-cover-timer"
            onTriggered: {
                if (timerRunning) {
                    firstPage.stop(true)
                    appWindow.activate()
                }
                else {
                    firstPage.start()
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
                id: todayLabel
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.primaryColor
                text: qsTr("Today")+ ": " + today
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
                id: week
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.primaryColor
                text: qsTr("Week")+ ": " + thisWeek
            }
        }
        Rectangle {
            visible: !timerRunning
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
                color: Theme.primaryColor
                text: qsTr("Month")+ ": " + thisMonth
            }
        }
        Rectangle {
            visible: timerRunning && !breakTimerRunning
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
                color: Theme.primaryColor
                text: durationNow
            }
        }
        Rectangle {
            visible: breakTimerRunning
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryHighlightColor
            radius: 10.0
            width: 210
            height: 80
            Item {
            width: childrenRect.width
                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.paddingMedium
                Image {
                    id: timerIconButton
                    source: "image://theme/icon-cover-timer"
                    width: 20
                    height: 20
                    anchors.rightMargin: Theme.paddingLarge
                }
                Item {
                    id: spacer
                    width: Theme.paddingMedium
                    anchors.left: timerIconButton.right
                }
                Label {
                    anchors.left: spacer.right
                    anchors.verticalCenter: timerIconButton.verticalCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    text: durationNow
                }
            }
            Item {
                width: childrenRect.width
                anchors.horizontalCenter: parent.horizontalCenter
                y: 3 * Theme.paddingMedium
                Image {
                    id: pauseIconButton
                    source: "image://theme/icon-cover-pause"
                    width: 30
                    height: 30
                    anchors.rightMargin: Theme.paddingLarge
                }
                Item {
                    id: spacer2
                    width: Theme.paddingMedium
                    anchors.left: pauseIconButton.right
                }
                Label {
                    anchors.left: spacer2.right
                    anchors.verticalCenter: pauseIconButton.verticalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.primaryColor
                    text: breakDurationNow
                }
            }
        }
    }
}


