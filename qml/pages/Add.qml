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
    canAccept: validateHours()
    property QtObject dataContainer: null
    property QtObject editMode: null
    property string description: "No description"
    property string project: "" //default
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
    property bool fromCover: false
    property bool fromTimer: false
    property bool endTimeStaysFixed: true
    property string defaultProjectId: ""

    //Simple validator to avoid adding negative or erroneous hours
    function validateHours() {
        return (duration >=0 && netDuration >=0 && breakDuration >=0 && startSelectedHour < 24 && startSelectedMinute < 60 && endSelectedHour < 24 && endSelectedMinute < 60)
    }

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
        console.log(modelSource.get(projectCombo.currentIndex).id);
        project = modelSource.get(projectCombo.currentIndex).id;
        DB.setHours(uid,dateString,startTime, endTime, duration,project,description, breakDuration)
        if (dataContainer != null)
            page.dataContainer.getHours()

        if (editMode != null)
            page.editMode.updateView()
    }

    // helper functions for giving duration in hh:mm format
    function countMinutes(duration) {
        var minutes = duration * 60
        return pad(Math.round(minutes % 60))
    }
    function countHours(duration) {
        var minutes = duration * 60
        return pad(Math.floor(minutes / 60))
    }

    //move start time
    function updateStartTime() {
        startSelectedHour = endSelectedHour - parseInt(countHours(duration))
        startSelectedMinute = endSelectedMinute - parseInt(countMinutes(duration))
        if (startSelectedHour < 0) {
            startSelectedHour+=24
        }
        if (startSelectedMinute < 0) {
            startSelectedMinute+=60
            startSelectedHour-=1
        }
        if (startSelectedHour < 0) {
            startSelectedHour+=24
        }

        startTime.value = pad(startSelectedHour) + ":" + pad(startSelectedMinute)
    }

    // move end time
    function updateEndTime() {
        endSelectedHour = startSelectedHour + parseInt(countHours(duration))
        console.log(endSelectedHour)
        endSelectedMinute = startSelectedMinute + parseInt(countMinutes(duration))
        console.log(endSelectedMinute)
        if (endSelectedHour >= 24) {
            endSelectedHour-=24
        }
        if (endSelectedMinute >= 60) {
            endSelectedMinute-=60
            endSelectedHour+=1
        }
        if (endSelectedHour >= 24) {
            endSelectedHour-=24
        }
        endTime.value = pad(endSelectedHour) + ":" + pad(endSelectedMinute)
        console.log(pad(endSelectedHour) + ":" + pad(endSelectedMinute))
    }

    //udpating breakDuration
    function updateBreakDuration() {
        breakDurationButton.value = countHours(breakDuration) + ":" + countMinutes(breakDuration)
    }

    //udpating netDuration
    function updateNetDuration() {
        netDuration = duration - breakDuration
        netDurationButton.value = countHours(netDuration) + ":" + countMinutes(netDuration)
    }

    //udpating duration
    function updateDuration() {
        durationButton.value = countHours(duration) + ":" + countMinutes(duration)
    }

    //end now
    function setEndNow() {
        console.log("end now")
        var now = new Date()
        endSelectedHour = now.getHours()
        endSelectedMinute= now.getMinutes()
        endTime.value = pad(endSelectedHour) + ":" + pad(endSelectedMinute)
        updateStartTime()
    }

    //start now
    function setStartNow() {
        console.log("start now")
        var now = new Date()
        startSelectedHour = now.getHours()
        startSelectedMinute= now.getMinutes()
        startTime.value = pad(startSelectedHour) + ":" + pad(startSelectedMinute)
        updateEndTime()
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

            /*SectionHeader { text: "Select date and time" }*/
            TextSwitch {
                id: timeSwitch
                checked: true
                text: "Ends now"
                description: "Endtime will be set to now."
                onCheckedChanged: {
                    timeSwitch.text = checked ? "Ends now" : "Starts now"
                    timeSwitch.description = checked ? "Endtime will be set to now." : "Starttime will be set to now."
                    if(checked){
                        setEndNow()
                        //fixedSwitch.checked = true
                    }
                    else {
                        setStartNow()
                        //fixedSwitch.checked = false
                    }
                }
            }
            BackgroundItem {
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
                onClicked: datePicked.openDateDialog()
            }
            BackgroundItem {
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: startSelectedHour <24 && startSelectedMinute < 60 ? Theme.secondaryHighlightColor : "red"
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
                                var endMinute = endSelectedMinute
                                if (endMinute - startSelectedMinute < 0) {
                                    endMinute +=60
                                    endHour -=1
                                }
                                if (endHour - startSelectedHour < 0)
                                    endHour +=24

                                duration = ((((endHour - startSelectedHour)*60) + (endMinute - startSelectedMinute)) / 60).toFixed(2)
                                updateDuration()
                                updateNetDuration()
                             })
                        }

                        label: "Start time:"
                        value: pad(startSelectedHour) + ":" + pad(startSelectedMinute)
                        width: parent.width
                        onClicked: openTimeDialog()
                    }
                }
                onClicked: startTime.openTimeDialog()
            }
            BackgroundItem {
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: endSelectedHour <24 && endSelectedMinute < 60 ? Theme.secondaryHighlightColor : "red"
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
                                var endMinute = endSelectedMinute
                                if (endMinute - startSelectedMinute < 0) {
                                    endMinute +=60
                                    endHour -=1
                                }
                                if (endHour - startSelectedHour < 0)
                                    endHour +=24
                                duration = ((((endHour - startSelectedHour)*60) + (endMinute - startSelectedMinute)) / 60).toFixed(2)
                                updateDuration()
                                updateNetDuration()
                            })
                        }

                        label: "End time:"
                        value: pad(endSelectedHour) + ":" + pad(endSelectedMinute)
                        width: parent.width
                        onClicked: openTimeDialog()
                    }
                }
                onClicked: endTime.openTimeDialog()
            }
            TextSwitch {
                id: fixedSwitch
                checked: true
                text: "Endtime stays fixed"
                description: "Starttime will flex if duration is changed."
                onCheckedChanged: {
                    fixedSwitch.text = checked ? "Endtime stays fixed" : "Starttime stays fixed"
                    fixedSwitch.description = checked ? "Starttime will flex if duration is changed." : "Endtime will flex if duration is changed."
                    if(checked)
                        endTimeStaysFixed = true
                    else
                        endTimeStaysFixed = false
                }
            }
            BackgroundItem {
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: duration>=0 ? Theme.secondaryHighlightColor : "red"
                    radius: 10.0
                    width: 315
                    height: 80
                    ValueButton {
                        id: durationButton
                        anchors.centerIn: parent
                        function openTimeDialog() {
                            var durationHour = parseInt(countHours(duration))
                            var durationMinute = parseInt(countMinutes(duration))
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
                                //console.log(duration)
                                value = pad(durationHour) + ":" + pad(durationMinute)
                                console.log(countMinutes(duration))
                                if(endTimeStaysFixed)
                                    updateStartTime()
                                else
                                    updateEndTime()
                            })
                        }

                        label: "Duration: "
                        value: countHours(duration) + ":" + countMinutes(duration);
                        width: parent.width
                        onClicked: openTimeDialog()
                    }
                }
                onClicked: durationButton.openTimeDialog()
            }
            BackgroundItem {
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: breakDuration>=0 ? Theme.secondaryHighlightColor : "red"
                    radius: 10.0
                    width: 315
                    height: 80
                    ValueButton {
                        id: breakDurationButton
                        anchors.centerIn: parent
                        function openTimeDialog() {
                            var dialog;
                            var durationHour = parseInt(countHours(breakDuration))
                            var durationMinute = parseInt(countMinutes(breakDuration))
                            dialog = pageStack.push("MyTimePicker.qml", {
                                                        hourMode: (DateTime.TwentyFourHours),
                                                        hour: durationHour,
                                                        minute: durationMinute,
                                                        duration: duration
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
                        value: "00:00"
                        width: parent.width
                        onClicked: openTimeDialog()
                    }
                }
                onClicked: breakDurationButton.openTimeDialog()
            }
            BackgroundItem {
                visible: breakDuration
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: netDuration>=0 ? Theme.secondaryHighlightColor : "red"
                    radius: 10.0
                    width: 315
                    height: 80
                    ValueButton {
                        id: netDurationButton
                        anchors.centerIn: parent
                        function openTimeDialog() {
                            var durationHour = parseInt(countHours(netDuration))
                            var durationMinute = parseInt(countMinutes(netDuration))
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
                                updateDuration();
                                if(endTimeStaysFixed)
                                    updateStartTime()
                                else
                                    updateEndTime()
                            })
                        }
                        label: "Net duration: "
                        value: countHours(netDuration) +":"+countMinutes(netDuration)
                        width: parent.width
                        onClicked: openTimeDialog()
                    }
                }
                onClicked: netDurationButton.openTimeDialog()
            }
            ComboBox {
                id: projectCombo
                label: qsTr("Project")
                menu: ContextMenu {
                    Repeater {
                        width: parent.width
                        model: modelSource
                        delegate: MenuItem {
                            text: model.name
                            color: model.labelColor
                            font.bold: true
                        }
                    }
                }
                onCurrentItemChanged: {
                    var selectedValue = modelSource.get(currentIndex).value
                }
                Component.onCompleted: {
                    var projects = DB.getProjects();
                    for (var i = 0; i < projects.length; i++) {
                        modelSource.set(i, {
                                       'id': projects[i].id,
                                       'name': projects[i].name,
                                       'labelColor': projects[i].labelColor
                                        })
                    }
                    defaultProjectId = "20151131423782795354";
                    _updating = false
                    for (var i = 0; i < modelSource.count; i++) {
                        if (modelSource.get(i).id == defaultProjectId) {
                            currentIndex = i
                            break
                        }
                    }
                }
                description: "Add or edit projects in settings"
            }

            ListModel {
                id: modelSource
            }

            TextField{
                id: descriptionTextArea
                //focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Enter an optional description"
            }
            Item {
                width: parent.width
                height: 10
            }
            Component.onCompleted: {
                if(!editMode && !fromCover && !fromTimer) {
                    var dur = settings.getDefaultDuration()
                    if(dur >=0){
                        duration = dur
                    }
                    else
                        console.log("Error when getting defaultDuration")

                    var brk = settings.getDefaultBreakDuration()
                    if(brk >= 0){
                        breakDuration = brk
                    }
                    else
                        console.log("Error when getting defaultBreakDuration")
                }
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
                if (description != "No description")
                    descriptionTextArea.text = description;
                if(dateText != "Today")
                    updateDateText()
                if (breakDuration > 0) {
                    updateBreakDuration();
                    updateNetDuration();
                }
                updateDuration()
                    updateStartTime()
            }
        }
    }
    onDone: {
            if (result == DialogResult.Accepted) {
                saveHours();
                if (dataContainer != null)
                    page.dataContainer.refreshCover();
            }
            if(fromCover)
                appWindow.deactivate()
    }
}
