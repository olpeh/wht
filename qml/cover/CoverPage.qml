/*
Copyright (C) 2017 Olavi Haapala.
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

CoverBackground {
    id: cover
    property bool active: status == Cover.Active

    onActiveChanged: {
        if(active) {
           firstPage.refreshState()
        }
    }

    Image {
        source: 'cover.svg'
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.paddingLarge
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
        opacity: 0.1
        scale: 1.05
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            id: pauseAddAction
            iconSource:  {
                if (appState.timerRunning && appState.breakTimerRunning) {
                    "image://theme/icon-cover-play"
                }

                else if (appState.timerRunning) {
                    "image://theme/icon-cover-pause"
                }

                else {
                    "image://theme/icon-cover-new"
                }
            }
            onTriggered: {
                if (appState.timerRunning && !appState.breakTimerRunning) {
                    logger.info("Break starts...")
                    firstPage.startBreakTimer()
                } else if (appState.breakTimerRunning) {
                    logger.info("Break ends...")
                    firstPage.stopBreakTimer()
                } else {
                    // BreakTimer was not running -> this is now a manual add button
                    var fromCover = true
                    firsPage.addHoursManually(fromCover)
                    appWindow.activate()
                }
            }
        }

        CoverAction {
            iconSource: appState.timerRunning ? "image://theme/icon-cover-cancel" : "image://theme/icon-cover-timer"
            onTriggered: {
                if (appState.timerRunning) {
                    firstPage.stopTimer(true)
                    appWindow.activate()
                } else {
                    firstPage.startTimer()
                }
            }
        }
    }

    Column {
        spacing: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.paddingMedium
        width: parent.width

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            width: parent.width - Theme.paddingLarge
            height: cover.height / 5
            Label {
                anchors.centerIn: parent
                id: todayLabel
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.primaryColor
                text: qsTr("Today")+ ": " + appState.data.today.toString().toHHMM()
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            width: parent.width - Theme.paddingLarge
            height: cover.height / 5
            Label {
                anchors.centerIn: parent
                id: week
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.primaryColor
                text: qsTr("Week")+ ": " + appState.data.thisWeek.toString().toHHMM()
            }
        }

        Rectangle {
            visible: !appState.timerRunning
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            width: parent.width - Theme.paddingLarge
            height: cover.height / 5
            Label {
                anchors.centerIn: parent
                id: month
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.primaryColor
                text: qsTr("Month")+ ": " + appState.data.thisMonth.toString().toHHMM()
            }
        }

        Rectangle {
            visible: appState.timerRunning && !appState.breakTimerRunning
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            width: parent.width - Theme.paddingLarge
            height: cover.height / 5
            IconButton {
                id: iconButton
                icon.source: "image://theme/icon-cover-timer"
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: iconButton.right
                id: durationNow
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.primaryColor
                text: appState.timerRunning ? helpers.formatTimerDuration(appState.timerDuration): ""
            }
        }

        Rectangle {
            visible: appState.breakTimerRunning
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            width: parent.width - Theme.paddingLarge
            height: cover.height / 5

            Item {
                width: childrenRect.width
                anchors.horizontalCenter: parent.horizontalCenter
                y: Theme.paddingMedium

                Image {
                    id: timerIconButton
                    source: "image://theme/icon-cover-timer"
                    width: Theme.paddingLarge
                    height: Theme.paddingLarge
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
                    text: appState.timerRunning ? helpers.formatTimerDuration(appState.timerDuration) : ""
                }
            }

            Item {
                width: childrenRect.width
                anchors.horizontalCenter: parent.horizontalCenter
                y: 3 * Theme.paddingMedium

                Image {
                    id: pauseIconButton
                    source: "image://theme/icon-cover-pause"
                    width: 2 * Theme.paddingLarge
                    height: 2 * Theme.paddingLarge
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
                    text: appState.breakTimerRunning ? helpers.formatTimerDuration(appState.breakTimerDuration) : ""
                }
            }
        }
    }
}


