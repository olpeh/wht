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

Dialog {
    id: page
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    canAccept: getNetDurationInMilliseconds() > 0

    property bool fromCover: false
    property bool fromTimer: false

    property bool editMode: false
    property QtObject hourRow: null

    // By default we assume we are adding hours manually
    // These values can be overwritten when opening in editMode or fromTimer
    property variant startMoment : moment()
    property variant endMoment: moment().add(settings.getDefaultDuration() > 0 ? settings.getDefaultDuration() : 8, 'hours')
    property int breakDurationInMilliseconds: 0

    property bool endTimeStaysFixed: true
    property bool projectComboInitialized: false

    function getDurationInMilliseconds() {
       return moment(endMoment).diff(moment(startMoment))
    }

    function getNetDurationInMilliseconds() {
        return getDurationInMilliseconds() - breakDurationInMilliseconds
    }

    function saveHours() {
        var values = {
            // TODO: CHANGE THE FORMAT (?)
            "date": startMoment.format("YYYY-MM-DD"),
            "startTime": startMoment.format("HH:mm"),
            "endTime": endMoment.format("HH:mm"),
            // For legacy reasons
            "duration": helpers.millisecondsToHours(getDurationInMilliseconds()),
            "project": appState.currentProjectId ,
            "description": descriptionTextArea.text,
            // For legacy reasons
            "breakDuration": helpers.millisecondsToHours(breakDurationInMilliseconds),
            "taskId": appState.currentTaskId
        };

        if (hourRow && hourRow.uid) {
            values.uid = hourRow.uid
        }

        Log.info("Trying to save: " + JSON.stringify(values));

        if(db.saveHourRow(values)) {
            firstPage.refreshState()
        } else {
            banner.notify("Error when saving!")
        }
    }

    function setEndNow() {
        endMoment = moment()
        startMoment = moment().subtract(getDurationInMilliseconds(), 'milliseconds')
    }

    function setStartNow() {
        startMoment = moment()
        endMoment = moment().add(getDurationInMilliseconds(), 'milliseconds')
    }

    function showBreakDurationTimepicker () {
        openTimeDialog(moment(breakDurationInMilliseconds), durationSelected, "breakDuration")
    }

    function showDurationTimepicker () {
        openTimeDialog(moment(getDurationInMilliseconds()), durationSelected, "duration")
    }

    function showNetDurationTimepicker () {
        var netDurationMoment = moment(getNetDurationInMilliseconds())
        openTimeDialog(netDurationMoment, durationSelected, "netDuration")
    }

    function durationSelected (momentObj, durationType) {
        if (durationType === "duration") {
            // Duration changed -> move either start time or end timeSwitch
            if (endTimeStaysFixed) {
                startMoment = moment(endMoment).subtract(helpers.momentAsMilliseconds(momentObj), 'milliseconds')
            } else {
                endMoment = moment(startMoment).add(helpers.momentAsMilliseconds(momentObj), 'milliseconds')
            }
        } else if (durationType === "breakDuration") {
            breakDurationInMilliseconds = helpers.momentAsMilliseconds(momentObj)
        } else if (durationType === "netDuration") {
            // Net duration changed > move either startTime or endTime
            // Break time stays of course untouched
            if (endTimeStaysFixed) {
                startMoment = moment(endMoment).subtract(helpers.momentAsMilliseconds(momentObj) + breakDurationInMilliseconds, 'milliseconds')
            } else {
                endMoment = moment(startMoment).add(helpers.momentAsMilliseconds(momentObj) + breakDurationInMilliseconds, 'milliseconds')
            }
        }

    }

    function startTimeSelected(momentObj) {
        startMoment = moment(momentObj)
    }

    function endTimeSelected(momentObj) {
        endMoment = moment(momentObj)
    }

    function openTimeDialog(momentObj, callBack, durationType) {
        if (durationType !== undefined) {
            momentObj = momentObj.utc()
        }

        var durationInMilliseconds = -1
        if (durationType === "breakDuration") {
            durationInMilliseconds = getDurationInMilliseconds()
        }

        var dialog = pageStack.push("MyTimePicker.qml", {
                                        hourMode: DateTime.TwentyFourHours,
                                        momentObj: momentObj,
                                        durationInMilliseconds: durationInMilliseconds
                                    })
        dialog.accepted.connect(function() {
            callBack(dialog.momentObj, durationType)
        })
    }

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.PaddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: editMode ? qsTr("Cancel") : qsTr("Discard")
            }

            TextSwitch {
                id: timeSwitch
                checked: true
                text: qsTr("Ends now")
                width: parent.width * 0.7
                description: qsTr("Endtime will be set to now.")
                anchors.horizontalCenter: parent.horizontalCenter
                onCheckedChanged: {
                    timeSwitch.text = checked ? qsTr("Ends now") : qsTr("Starts now")
                    timeSwitch.description = checked ? qsTr("Endtime will be set to now.") : qsTr("Starttime will be set to now.")

                    if (checked) {
                        setEndNow()
                    } else {
                        setStartNow()
                    }
                }
            }

            BackgroundItem {
                onClicked: datePicked.openDateDialog()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: datePicked.height

                    ValueButton {
                        id: datePicked
                        anchors.centerIn: parent
                        label: qsTr("Start date:")
                        value: startMoment.format("DD.MM.YYYY")
                        onClicked: openDateDialog()

                        function openDateDialog() {
                            var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: startMoment.toDate() })

                            dialog.accepted.connect(function() {
                                //  @TODO: Why so complicated?
                                var lastSelectedHours = startMoment.hours()
                                var lastSelectedMinutes = startMoment.minutes()
                                startMoment = moment(dialog.date)
                                startMoment.hours(lastSelectedHours)
                                startMoment.minutes(lastSelectedMinutes)
                            })
                        }
                    }
                }
            }

            BackgroundItem {
                onClicked: startTime.doOnClicked()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: startTime.height

                    ValueButton {
                        id: startTime
                        anchors.centerIn: parent
                        label: qsTr("Start time:")
                        value: startMoment.format("H:mm")
                        width: parent.width
                        onClicked: doOnClicked()

                        function doOnClicked() {
                            openTimeDialog(moment(startMoment), startTimeSelected)
                        }
                    }
                }
            }

            BackgroundItem {
                onClicked: endDatePicker.openDateDialog()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: endDatePicker.height

                    ValueButton {
                        id: endDatePicker
                        anchors.centerIn: parent
                        label: qsTr("End date:")
                        value: endMoment.format("DD.MM.YYYY")
                        onClicked: openDateDialog()

                        function openDateDialog() {
                            var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: endMoment.toDate() })

                            dialog.accepted.connect(function() {
                                //  @TODO: Why so complicated?
                                var lastSelectedEndHours = endMoment.hours()
                                var lastSelectedEndMinutes = endMoment.minutes()
                                endMoment = moment(dialog.date)
                                endMoment.hours(lastSelectedEndHours)
                                endMoment.minutes(lastSelectedEndMinutes)
                            })
                        }
                    }
                }
            }

            BackgroundItem {
                onClicked: endTime.doOnClicked()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: endTime.height

                    ValueButton {
                        id: endTime
                        anchors.centerIn: parent
                        label: qsTr("End time:")
                        value: endMoment.format("H:mm")
                        width: parent.width
                        onClicked: doOnClicked()

                        function doOnClicked() {
                            openTimeDialog(moment(endMoment), endTimeSelected)
                        }
                    }
                }
            }

            TextSwitch {
                id: fixedSwitch
                checked: true
                width: parent.width * 0.7
                text: qsTr("Endtime stays fixed")
                description: qsTr("Starttime will flex if duration is changed.")
                anchors.horizontalCenter: parent.horizontalCenter

                onCheckedChanged: {
                    fixedSwitch.text = checked ? qsTr("Endtime stays fixed") : qsTr("Starttime stays fixed")
                    fixedSwitch.description = checked ? qsTr("Starttime will flex if duration is changed.") : qsTr("Endtime will flex if duration is changed.")
                    endTimeStaysFixed = checked
                }
            }

            BackgroundItem {
                onClicked: showDurationTimepicker()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: durationButton.height

                    ValueButton {
                        id: durationButton
                        anchors.centerIn: parent
                        label: qsTr("Duration") + ": "
                        value: helpers.formatTimerDuration(getDurationInMilliseconds())
                        width: parent.width
                        onClicked: showDurationTimepicker()
                    }
                }
            }

            BackgroundItem {
                // At least one minute
                visible: getDurationInMilliseconds() > 60 * 1000
                onClicked: showBreakDurationTimepicker()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: breakDurationButton.height

                    ValueButton {
                        id: breakDurationButton
                        anchors.centerIn: parent
                        label: qsTr("Break") + ": "
                        value: helpers.formatTimerDuration(breakDurationInMilliseconds)
                        width: parent.width
                        onClicked: showBreakDurationTimepicker()
                    }
                }
            }
            BackgroundItem {
                // At least one minute
                visible: breakDurationInMilliseconds > 60 * 1000
                onClicked: showNetDurationTimepicker()

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: getNetDurationInMilliseconds() > 0 ? Theme.secondaryHighlightColor : "red"
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: netDurationButton.height

                    ValueButton {
                        id: netDurationButton
                        anchors.centerIn: parent
                        label: qsTr("Net duration")+": "
                        value: helpers.formatTimerDuration(getNetDurationInMilliseconds())
                        width: parent.width
                        onClicked: showNetDurationTimepicker()
                    }
                }
            }

            ComboBox {
                id: projectCombo
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Project")
                description: qsTr("Add or edit projects in settings")
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
                    if (projectComboInitialized) {
                        var selectedValue = modelSource.get(currentIndex).value
                        appState.currentProjectId = modelSource.get(currentIndex).id
                        var lastUsed = db.getLastUsedInput(appState.currentProjectId)

                        if (lastUsed['taskId'] && lastUsed['taskId'] !== '') {
                            appState.currentTaskId = lastUsed['taskId']
                        }

                        if (lastUsed['description'] && lastUsed['description'] !== '') {
                            descriptionTextArea.text = lastUsed['description']
                        }
                    }
                    projectComboInitialized = true
                    taskCombo.init()
                }

                function init() {
                    var projects = appState.data.projects
                    if (projects.length === 0) {
                        var id = db.insertInitialProject(Theme.secondaryHighlightColor);
                        if (id) {
                            //TODO: Try to get rid of this kind of code
                            settings.setDefaultProjectId(id)
                            appState.data.projects = db.getProjects()
                            projects = appState.data.projects
                        }
                    }

                    for (var i = 0; i < projects.length; i++) {
                        modelSource.set(i, {
                                       'id': projects[i].id,
                                       'name': projects[i].name,
                                       'labelColor': projects[i].labelColor
                                        })
                    }
                    _updating = false

                    for (var i = 0; i < modelSource.count; i++) {
                        if (modelSource.get(i).id === appState.currentProjectId) {
                            currentIndex = i
                            break
                        }
                    }
                }
            }

            ListModel {
                id: modelSource
            }

            // Task ComboBox
            ComboBox {
                id: taskCombo
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Task")
                description: qsTr("Add or edit tasks in project settings")
                menu: ContextMenu {
                    Repeater {
                        id: repeat
                        width: parent.width
                        model: taskModelSource
                        delegate: MenuItem {
                            text: model.name
                            font.bold: true
                        }
                    }
                }

                onCurrentItemChanged: {
                    if (currentIndex !== -1) {
                        var selectedValue = taskModelSource.get(currentIndex).value
                        appState.currentTaskId = taskModelSource.get(currentIndex).id

                        if (appState.currentTaskId > 0) {
                            var lastUsed = db.getLastUsedInput(appState.currentProjectId)

                            if (lastUsed['taskId'] && lastUsed['taskId'] !== '') {
                                appState.currentTaskId = lastUsed['taskId']
                            }

                            if (lastUsed['description'] && lastUsed['description'] !== '') {
                                descriptionTextArea.text = lastUsed['description']
                            }
                        }
                    }
                }

                function deleteAll() {
                    // @TODO: Does not work
                    for (var i = 0; i < taskModelSource.length; i++) {
                        taskModelSource.delete(i)
                    }
                }

                function init(deselect) {
                    var tasks = db.getTasks(appState.currentProjectId)
                    for (var i = 0; i < tasks.length; i++) {
                        taskModelSource.set(i, {
                            'id': tasks[i].id,
                            'name': tasks[i].name
                        })
                    }

                    taskModelSource.set(tasks.length, {
                        'id': '0',
                        'name': qsTr("No task defined"),
                        'enabled': false
                    })

                    _updating = false

                    currentIndex = 1
                    currentItem = null

                    if (appState.currentTaskId) {
                        for (var i = 0; i < taskModelSource.count; i++) {
                            if (taskModelSource.get(i).id === appState.currentTaskId) {
                                currentIndex = i
                                break
                            }
                        }
                    }
                }
            }

            ListModel {
                id: taskModelSource
            }

            TextField {
                id: descriptionTextArea
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-enter-close"
                EnterKey.onClicked: focus = false
                placeholderText: qsTr("Enter an optional description")
                onClicked: {
                    selectAll()
                }
            }

            Item {
                width: parent.width
                height: 10
            }

            Component.onCompleted: {
                if(!editMode && !fromTimer) {
                    var brk = settings.getDefaultBreakDuration()
                    if (brk > 0) {
                        // DefaultBreakDuration got saved as hours for some stupid reason
                        breakDurationInMilliseconds = helpers.hoursToMilliseconds(brk)
                    }
                } else if (fromTimer) {
                    breakDurationInMilliseconds = breakTimer.getTotalDurationInMilliseconds()
                    startMoment = moment(appState.timerStartTime)
                    endMoment = moment()

                    // Add default break duration if settings allows and no break recorded
                    // Also only add it if it is less than the duration
                    // DefaultBreakDuration got saved as hours for some stupid reason
                    var defaultBreakDurInMs = helpers.hoursToMilliseconds(settings.getDefaultBreakDuration())
                    if (!breakDurationInMilliseconds && settings.getDefaultBreakInTimer() && defaultBreakDurInMs < getDurationInMilliseconds()) {
                        breakDurationInMilliseconds = defaultBreakDurInMs
                    }
                } else if (editMode && hourRow) {
                    // breakDuration was saved as hours
                    breakDurationInMilliseconds = helpers.hoursToMilliseconds(hourRow.breakDuration)
                    // For legacy reasons date and times are saved separately
                    startMoment = moment(hourRow.date + " " + hourRow.startTime)
                    // @TODO: This might not be very smart
                    // For legacy reasons durations were saved as hours
                    endMoment = moment(startMoment).add(hourRow.duration, "hours")
                    descriptionTextArea.text = hourRow.description
                    appState.currentProjectId = hourRow.project
                    appState.currentTaskId = hourRow.taskId
                }

                var endFixed = settings.getEndTimeStaysFixed()
                if (endFixed === "yes") {
                    fixedSwitch.checked = true
                } else if (endFixed === "no") {
                    fixedSwitch.checked = false
                }

                var nowByDefault = settings.getEndsNowByDefault()
                if (nowByDefault === "yes") {
                    timeSwitch.checked = true
                } else if(nowByDefault === "no") {
                    timeSwitch.checked = false
                }

                projectCombo.init()
            }
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            saveHours()
            firstPage.refreshState()
        }

        if(fromCover) {
            appWindow.deactivate()
        }
    }

    Banner {
        id: banner
    }
}
