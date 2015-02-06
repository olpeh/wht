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

Page {

    property double defaultDuration: 8
    property double defaultBreakDuration: 0
    property bool timerAutoStart : false
    id: settingsPage
    property QtObject dataContainer: null

    // helper functions for giving duration in hh:mm format
    function countMinutes(duration) {
        var minutes = duration * 60
        return pad(Math.round(minutes % 60))
    }
    function countHours(duration) {
        var minutes = duration * 60
        return pad(Math.floor(minutes / 60))
    }
    function pad(n) { return ("0" + n).slice(-2); }
    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height
        //contentHeight: column.y + column.height
        Column {
            id: column

            spacing: 20
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            PageHeader {
                title: "Settings"
            }
            RemorseItem { id: remorse }
            SectionHeader { text: "Default duration" }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 250
                height: 75
                ValueButton {
                    id: defaultDurationButton
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var durationHour = parseInt(countHours(defaultDuration))
                        var durationMinute = parseInt(countMinutes(defaultDuration))
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: durationHour,
                                        minute: durationMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            durationHour = dialog.hour
                            durationMinute = dialog.minute
                            defaultDuration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                            console.log(defaultDuration)
                            value = pad(durationHour) + ":" + pad(durationMinute)
                            settings.setDefaultDuration(defaultDuration)
                        })
                    }

                    label: "Value:"
                    value: countHours(defaultDuration) + ":" + countMinutes(defaultDuration);
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            SectionHeader { text: "Default break duration" }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 250
                height: 75
                ValueButton {
                    id: defaultBreakDurationButton
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var durationHour = parseInt(countHours(defaultBreakDuration))
                        var durationMinute = parseInt(countMinutes(defaultBreakDuration))
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: durationHour,
                                        minute: durationMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            durationHour = dialog.hour
                            durationMinute = dialog.minute
                            defaultBreakDuration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                            value = pad(durationHour) + ":" + pad(durationMinute)
                            settings.setDefaultBreakDuration(defaultBreakDuration)
                        })
                    }

                    label: "Value:"
                    value: countHours(defaultBreakDuration) + ":" + countMinutes(defaultBreakDuration);
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }

            SectionHeader { text: "Adding hours" }
            TextSwitch {
                id: timeSwitch
                checked: true
                text: "Ends now by default"
                description: "Endtime will be set to now by default."
                onCheckedChanged: {
                    timeSwitch.text = checked ? "Ends now by default" : "Starts now by default"
                    timeSwitch.description = checked ? "Endtime will be set to now by default." : "Starttime will be set to now by default."
                    if(checked){
                        settings.setEndsNowByDefault("yes")
                    }
                    else {
                        settings.setEndsNowByDefault("no")
                    }
                }
            }

            SectionHeader { text: "Adding break" }
            TextSwitch {
                id: fixedSwitch
                checked: true
                text: "Endtime stays fixed by default."
                description: "Starttime will flex if duration is changed."
                onCheckedChanged: {
                    fixedSwitch.text = checked ? "Endtime stays fixed by default." : "Starttime stays fixed by default."
                    fixedSwitch.description = checked ? "Starttime will flex if duration is changed." : "Endtime will flex if duration is changed."
                    if(checked)
                        settings.setEndTimeStaysFixed("yes")
                    else
                        settings.setEndTimeStaysFixed("no")
                }
            }
            SectionHeader { text: "Startup options" }
            TextSwitch {
                id: autoStartSwitch
                checked: false
                text: "Autostart timer on app startup"
                description: "Timer will get started automatically if not running."
                onCheckedChanged: {
                    autoStartSwitch.description = checked ? "Timer will now get started automatically if not running." : "Timer will not get started automatically."
                    if(checked)
                        settings.setTimerAutoStart(true)
                    else
                        settings.setTimerAutoStart(false)
                }
            }


            SectionHeader { text: "DANGER ZONE!" }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 250
                height: 75
                ValueButton {
                    id: resetButton
                    anchors.centerIn: parent
                    label: "Reset database"
                    width: parent.width
                    onClicked: remorse.execute(settingsPage,"Resetting database", function() {
                        console.log("Resetting database");
                        if (dataContainer != null){
                           settingsPage.dataContainer.resetDatabase();
                           pageStack.replace(Qt.resolvedUrl("FirstPage.qml"));
                        }
                    })
                }
            }
            Text {
                id: warningText
                font.pointSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: "Warning: You will loose all your Working Hours data if you reset the database!"
            }

        }
    }
    Component.onCompleted: {
        var dur = settings.getDefaultDuration()
        if(dur >=0){
            defaultDuration = dur
        }
        else
            console.log("Error when getting defaultDuration")

        var brk = settings.getDefaultBreakDuration()
        if(brk >= 0){
            defaultBreakDuration = brk
        }
        else
            console.log("Error when getting defaultBreakDuration")

        var endFixed = settings.getEndTimeStaysFixed()
        if(endFixed === "yes")
            fixedSwitch.checked = true
        else if(endFixed === "no")
            fixedSwitch.checked = false
        else
            console.log("Error when getting endTimeStaysFixed")

        var nowByDefault = settings.getEndsNowByDefault()
        if(nowByDefault === "yes")
            timeSwitch.checked = true
        else if(nowByDefault === "no")
            timeSwitch.checked = false
        else
            console.log("Error when getting endsNowByDefault")
        var timerAutoStart = settings.getTimerAutoStart()
        if(timerAutoStart === true)
            autoStartSwitch.checked = true
        else if(timerAutoStart === false)
            autoStartSwitch.checked = false
        else
            console.log("Error when getting timerAutoStart")


    }
}










