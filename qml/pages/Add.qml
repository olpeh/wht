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
Dialog {
    id: page

    property QtObject dataContainer: null
    property QtObject editMode: null
    property string description: "No description"
    property string project: "default" //coming later
    property double duration: 8
    property double breakDuration: 0
    property double netDuration: 8
    property string uid: "0"
    property string dateText: "Today"
    property date selectedDate : new Date()
    property date timeNow : new Date()
    property int startSelectedHour : timeNow.getHours() - 8
    property int startSelectedMinute : timeNow.getMinutes()
    property int endSelectedHour : timeNow.getHours()
    property int endSelectedMinute : timeNow.getMinutes()

    function pad(n) { return ("0" + n).slice(-2); }

    function updateDateText(){
        var date = new Date(dateText);
        var now = new Date();
        if(now.toDateString() === date.toDateString())
            datePicked.value = "Today"
        else {
            var splitted = date.toDateString().split(" ");
            datePicked.value = splitted[1] + " " +splitted[2] + " "+ splitted[3];
        }
    }

    function saveHours() {
        if (descriptionTextArea.text)
           description = descriptionTextArea.text
        if (uid == "0")
            uid = DB.getUniqueId()

        var d = selectedDate
        console.log(d)
        //YYYY-MM-DD
        var yyyy = d.getFullYear().toString();
        var mm = (d.getMonth()+1).toString(); // getMonth() is zero-based
        var dd  = d.getDate().toString();
        var dateString = yyyy +"-"+ (mm[1]?mm:"0"+mm[0]) +"-"+ (dd[1]?dd:"0"+dd[0]); // padding

        var startTime = pad(startSelectedHour) + ":" + pad(startSelectedMinute);
        var endTime = pad(endSelectedHour) + ":" + pad(endSelectedMinute);

        console.log(dateString)
        //.replace(/-/g,"")
        DB.setHours(uid,dateString,startTime, endTime, duration,project,description)
        if (dataContainer != null)
            page.dataContainer.getHours()

        if (editMode != null)
            page.editMode.updateView()
    }

    // helper functions for giving duration in hh:mm format
    function countMinutes(duration) {
        var minutes = duration * 60
        //console.log(Math.round(minutes % 60))
        return pad(Math.round(minutes % 60))
    }
    function countHours(duration) {
        var minutes = duration * 60
        return pad(Math.floor(minutes / 60))
    }

    // changed duration - move start time
    function updateStartTime() {
        startSelectedHour = endSelectedHour - countHours(duration)
        startSelectedMinute = endSelectedMinute - countMinutes(duration)
        if (startSelectedMinute < 0) {
            startSelectedMinute+=60
            startSelectedHour-=1
        }
        if (startSelectedHour < 0) {
            startSelectedHour+=24
        }
        startTime.value = pad(startSelectedHour) + ":" + pad(startSelectedMinute)
    }

    //udpating netDuration
    function updateNetDuration() {
        netDuration = duration - breakDuration
        netDurationButton.value = countHours(netDuration) + ":" + countMinutes(netDuration)
    }

    //udpating duration
    function updateduration() {
        durationButton.value = countHours(duration) + ":" + countMinutes(duration)
    }

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height
        //contentHeight: column.y + column.height
        Column {
            id: column

            DialogHeader {
                        acceptText: "Save"
                        cancelText: "Cancel"
            }

            spacing: 20
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.PaddingLarge

            SectionHeader { text: "Description" }
            TextField{
                id: descriptionTextArea
                //focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Enter an optional description"
            }

            SectionHeader { text: "Select date and time" }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 315
                height: 80
                ValueButton {
                    id: datePicked
                    anchors.centerIn: parent
                    function openDateDialog() {
                        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                        date: new Date()
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.dateText
                            selectedDate = dialog.date
                        })
                    }

                    label: "Date:"
                    value: dateText
                    width: parent.width
                    onClicked: openDateDialog()
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 315
                height: 80
                ValueButton {
                    id: startTime
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: startSelectedHour,
                                        minute: startSelectedMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            startSelectedHour = dialog.hour
                            startSelectedMinute = dialog.minute
                            var endHour = endSelectedHour
                            if (endSelectedHour < startSelectedHour)
                                endHour +=24
                            duration = ((((endHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)
                            durationButton.value = countHours(duration) + ":" + countMinutes(duration)
                         })
                    }

                    label: "Start time:"
                    value: pad(startSelectedHour) + ":" + pad(startSelectedMinute)
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 315
                height: 80
                ValueButton {
                    id: endTime
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: endSelectedHour,
                                        minute: endSelectedMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            endSelectedHour = dialog.hour
                            endSelectedMinute = dialog.minute
                            var endHour = endSelectedHour
                            if (endSelectedHour < startSelectedHour)
                                endHour +=24
                            duration = ((((endHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)
                            durationButton.value = countHours(duration) + ":" + countMinutes(duration)
                        })
                    }

                    label: "End time:"
                    value: pad(endSelectedHour) + ":" + pad(endSelectedMinute)
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            SectionHeader { text: "Duration and break" }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 315
                height: 80
                ValueButton {
                    id: durationButton
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var durationHour = countHours(duration)
                        var durationMinute = countMinutes(duration)
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: durationHour,
                                        minute: durationMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            durationHour = dialog.hour
                            durationMinute = dialog.minute
                            console.log(durationMinute)
                            duration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                            console.log(duration)
                            value = pad(durationHour) + ":" + pad(durationMinute)
                            console.log(countMinutes(duration))
                            updateStartTime()
                        })
                    }

                    label: "Duration: "
                    value: countHours(duration) + ":" + countMinutes(duration);
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 315
                height: 80
                ValueButton {
                    id: breakDurationButton
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var durationHour = countHours(breakDuration)
                        var durationMinute = countMinutes(breakDuration)
                        var dialog;
                        dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: durationHour,
                                        minute: durationMinute,
                                        // @TODO fix this
                                        //canAccept: (((selector.hour)*60 + selector.minute) / 60).toFixed(2) < duration
                                     })

                        dialog.accepted.connect(function() {
                            durationHour = dialog.hour
                            durationMinute = dialog.minute
                            console.log(durationMinute)
                            breakDuration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                            console.log(duration)
                            value = pad(durationHour) + ":" + pad(durationMinute)
                            updateNetDuration();
                        })
                    }

                    label: "Break: "
                    value: "-"
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            Rectangle {
                visible: breakDuration
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 315
                height: 80
                ValueButton {
                    id: netDurationButton
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var durationHour = countHours(netDuration)
                        var durationMinute = countMinutes(netDuration)
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: durationHour,
                                        minute: durationMinute,
                                     })

                        dialog.accepted.connect(function() {
                            durationHour = dialog.hour
                            durationMinute = dialog.minute
                            netDuration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                            value = pad(durationHour) + ":" + pad(durationMinute)
                            duration = netDuration + breakDuration
                            updateduration();
                            updateStartTime();

                        })
                    }

                    label: "Net duration: "
                    value: countHours(netDuration) +":"+countMinutes(netDuration)
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            Component.onCompleted: {
                if (startSelectedHour < 0)
                    startSelectedHour = endSelectedHour + 16;
                if (startSelectedHour.length === 1)
                    startSelectedHour = "0" + startSelectedHour;
                if (endSelectedHour.length === 1)
                    endSelectedHour = "0" + endSelectedHour;
                if (startSelectedMinute.length === 1)
                    startSelectedMinute = "0" + startSelectedMinute;
                if (endSelectedMinute.length === 1)
                    endSelectedMinute = "0" + endSelectedMinute;
                if (description != "No description")
                    descriptionTextArea.text = description;
                if(dateText != "Today")
                    updateDateText()
                updateDuration()
                //console.log(dataContainer)
                if (breakDuration > 0)
                    updateNetDuration();

            }
        }
    }
    onDone: {
            if (result == DialogResult.Accepted) {
                saveHours();
            }
    }
}
