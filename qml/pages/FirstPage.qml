/*
Copyright (C) 2017 Olavi Haapala.
<harbourwht@gmail.com>
Twitter: @0lpeh
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
//import QtFeedback 5.0

Page {
    id: root
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    // TODO: Try to get rid of this
    // Temporary hack before using more reactive ways of doing things
    function refreshState() {
        // these should not be Refreshed - rest of the state is dynamic
        var arguments = appState.arguments ? appState.arguments : {
                                                 "startFromCommandLine": startFromCommandLine,
                                                 "stopFromCommandLine": stopFromCommandLine
                                             }
        var currentProjectId = appState.currentProjectId !== undefined ? appState.currentProjectId : settings.getDefaultProjectId()
        var currentTaskId = appState.currentTaskId
        var versionCheckDone = appState.versionCheckDone

        appState = {
            "versionCheckDone": versionCheckDone,
            "arguments": arguments,
            "timerRunning": timer.isRunning(),
            "timerDuration": timer.getActualDurationInMilliseconds(breakTimer),
            "timerStartTime": timer.getStartTime(),
            "breakTimerRunning": breakTimer.isRunning(),
            "breakTimerDuration": breakTimer.getDurationInMilliseconds(),
            "breakTimerTotalDuration": breakTimer.getTotalDurationInMilliseconds(),
            "breakStartTime": breakTimer.getStartTime(),
            "currentProjectId": currentProjectId,
            "currentTaskId": currentTaskId,
            "data":{
                "projects": db.getProjects(),
                "yesterday": db.getDurationForPeriod("day", 1),
                "today": db.getDurationForPeriod("day"),
                "lastWeek": db.getDurationForPeriod("week", 1),
                "thisWeek": db.getDurationForPeriod("week"),
                "lastMonth": db.getDurationForPeriod("month", 1),
                "thisMonth": db.getDurationForPeriod("month"),
                "all": db.getDurationForPeriod("all"),
                "thisYear": db.getDurationForPeriod("year")
            }
        }

        // TODO: Is this ok?
        setHours()
    }

    //TODO: Why is this here?
    function resetDatabase() {
        db.resetDatabase()
        for (var i = 0; i < summaryModel.length; i++) {
            summaryModel[i].hours = "0"
        }
    }

    function setHours() {
        //Update hours view and cover
        summaryModel.set(0,{ "hours": appState.data.yesterday.toString().toHHMM() })
        summaryModel.set(1,{ "hours": appState.data.today.toString().toHHMM() })
        summaryModel.set(2,{ "hours": appState.data.lastWeek.toString().toHHMM() })
        summaryModel.set(3,{ "hours": appState.data.thisWeek.toString().toHHMM() })
        summaryModel.set(4,{ "hours": appState.data.lastMonth.toString().toHHMM() })
        summaryModel.set(5,{ "hours": appState.data.thisMonth.toString().toHHMM() })
        summaryModel.set(6,{ "hours": appState.data.all.toString().toHHMM() })
        summaryModel.set(7,{ "hours": appState.data.thisYear.toString().toHHMM() })
    }

    function addHoursManually(fromCover) {
        if (fromCover === undefined) {
            fromCover = false
        }

        pageStack.push(Qt.resolvedUrl("Add.qml"), { fromCover: fromCover })
    }

    function startBreakTimer() {
        breakTimer.start()
        refreshState()
    }

    function stopBreakTimer() {
        breakTimer.stop()
        refreshState()
    }

    function startTimer(date) {
        Log.debug(date)
        if (date !== undefined) {
            timer.start(date)
        } else {
            timer.start()
        }
        refreshState()
    }

    function stopTimer(fromCover){
        if (fromCover === undefined) {
            fromCover = false
        }

        if(appState.breakTimerRunning) {
            stopBreakTimer()
        }

        if (appState.arguments.stopFromCommandLine) {
            var startMoment = moment(appState.timerStartTime)
            var endMoment = moment()
            var timerDurationInHours = helpers.millisecondsToHours(appState.timerDuration)
            var breakDuration = helpers.millisecondsToHours(appState.breakTimerDuration)
            if (breakDuration === 0 && settings.getDefaultBreakInTimer()) {
                Log.debug("No break recorded, let's see if we should add a break...")
                var defaultBreakInHours = settings.getDefaultBreakDuration()
                Log.debug("Default break was " + defaultBreakInHours + " and current duration is: " + timerDurationInHours)
                if (defaultBreakInHours < timerDurationInHours) {
                    Log.debug("Default break is less than current duration, so let's add it as the break")
                    breakDuration = defaultBreakInHours
                }
            }

            var values = {
                "date": startMoment.format("YYYY-MM-DD"),
                "startTime": startMoment.format("HH:mm"),
                "endTime": endMoment.format("HH:mm"),
                // For legacy reasons
                "duration": timerDurationInHours,
                "project": settings.getDefaultProjectId(),
                "description": "Automatically saved from command line",
                // For legacy reasons
                "breakDuration": breakDuration,
                "taskId": "0"
            };

            Log.info("Trying to save automatically: " + JSON.stringify(values));

            if(db.saveHourRow(values)) {
                // Try to avoid saving multiple times etc.
                stopFromCommandLine = false
                firstPage.refreshState()
            } else {
                banner.notify("Error when saving!")
            }
        } else {
            if (fromCover && pageStack.depth > 1) {
                pageStack.replaceAbove(appWindow.firstPage,Qt.resolvedUrl("../pages/Add.qml"), { fromTimer: true, fromCover: fromCover })
            } else {
                pageStack.push(Qt.resolvedUrl("Add.qml"), { fromTimer: true, fromCover: fromCover })
            }
        }

        timer.stop()
        breakTimer.clear()
        refreshState()
    }

    SilicaFlickable {
        id: flickable
        width: parent.width
        height: parent.height

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"), {dataContainer: root})
                }
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Settings.qml"), {dataContainer: root})
                }
            }

            MenuItem {
                text: qsTr("Add Hours")
                onClicked: {
                    addHoursManually()
                }
            }
        }

        ListModel {
            id: summaryModel

            function section(index) {
                if (section["text"] === undefined) {
                    section.text = [
                        qsTr("Yesterday"),
                        qsTr("Today"),
                        qsTr("Last week"),
                        qsTr("This week"),
                        qsTr("Last month"),
                        qsTr("This month"),
                        qsTr("All"),
                        qsTr("This year"),
                    ]
                }
                return section.text[index]
            }
        }

        SilicaGridView {
            id: grid
            property PageHeader pageHeader
            anchors.fill: parent
            model: summaryModel
            snapMode: GridView.SnapToRow
            header: PageHeader {
                id: pageHeader
                title: "Working Hours Tracker"
                Component.onCompleted: grid.pageHeader = pageHeader
            }
            cellWidth: {
                if (root.orientation == Orientation.PortraitInverted || root.orientation == Orientation.Portrait)
                    root.width / 2
                else
                    root.width / 4
            }
            cellHeight: {
                if (root.orientation == Orientation.PortraitInverted || root.orientation == Orientation.Portrait)
                    (root.height / 5) - pageHeader.height / 5
                else
                    (root.height / 3) - pageHeader.height / 3
            }

            delegate: Item {
                width: grid.cellWidth
                height: grid.cellHeight

                BackgroundItem {
                    anchors {
                        fill: parent
                        margins: Theme.paddingMedium
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Theme.secondaryHighlightColor
                        radius: Theme.paddingMedium
                        width: parent.width
                        height: parent.height

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -Theme.paddingLarge
                            text: summaryModel.section(index)
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: Theme.paddingLarge
                            text: model.hours
                            font.bold: true
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: summaryModel.section(index)})
                    }
                }
            }
        }

        BackgroundItem {
            id: timerControl
            visible: !appState.timerRunning
            height: grid.cellHeight
            width: parent.width
            anchors.bottom: grid.bottom

            Rectangle {
                color: Theme.secondaryHighlightColor
                radius: Theme.paddingMedium
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium

                Label {
                    id: timerText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Timer is not running")
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Click to start")
                    font.bold: true
                }
            }

            onClicked: startTimer()
        }

        Item {
            id: timerItem
            visible: appState.timerRunning
            height: timerControl.height
            width: parent.width
            anchors.bottom: grid.bottom

            BackgroundItem {
                width: timerItem.width / 3
                height: parent.height

                Rectangle {
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    anchors.fill: parent
                    anchors.margins: Theme.paddingMedium



                    Label {
                        id: breakDurationNow
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: Theme.paddingMedium
                        text: appState.breakTimerRunning ?
                                  helpers.formatTimerDuration(appState.breakTimerDuration) :
                                  helpers.formatTimerDuration(appState.breakTimerTotalDuration)
                    }

                    Image {
                        id: pauseImage
                        source: appState.breakTimerRunning ? "image://theme/icon-cover-play" : "image://theme/icon-cover-pause"
                        anchors.centerIn: parent
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - this.height - Theme.paddingMedium
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("Break")
                    }
                }

                onClicked: {
                    if(!appState.breakTimerRunning) {
                        startBreakTimer()
                    }
                    else {
                        stopBreakTimer()
                    }
                }
            }

            BackgroundItem {
                width: timerItem.width / 3
                height: timerControl.height
                x: timerItem.width / 3

                Rectangle {
                    opacity: appState.breakTimerRunning ? 0.5 : 1
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    anchors.fill: parent
                    anchors.margins: Theme.paddingMedium

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: Theme.paddingMedium
                        color: Theme.primaryColor
                        id: durationNow
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        text: appState.timerRunning ? helpers.formatTimerDuration(appState.timerDuration) : ""
                    }

                    Image {
                        id: stopImage
                        source: "image://theme/icon-cover-cancel"
                        anchors.centerIn: parent
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - this.height - Theme.paddingMedium
                        color: Theme.primaryColor
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("Stop")
                    }
                }

                onClicked: {
                    if(!appState.breakTimerRunning) {
                        //buttonBuzz.play()
                        stopTimer()
                    }
                }
            }

            BackgroundItem {
                width: timerItem.width / 3
                height: timerControl.height
                x: 2 * timerItem.width / 3

                function openTimeDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                    hourMode: (DateTime.TwentyFourHours),
                                    hour: moment(appState.timerStartTime).format("H"),
                                    minute: moment(appState.timerStartTime).format("mm"),
                                 })

                    dialog.accepted.connect(function() {
                        // Assume current day (for now)
                        var date = new Date()
                        date.setHours(dialog.hour)
                        date.setMinutes(dialog.minute)
                        // dialog.time cannot be used since it has the day and year wrong
                        startTimer(date)
                    })
                }

                Rectangle {
                    opacity: appState.breakTimerRunning ? 0.5 : 1
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    anchors.fill: parent
                    anchors.margins: Theme.paddingMedium

                    Label {
                        y: Theme.paddingMedium
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("Started")
                    }

                    Label {
                        anchors.centerIn: parent
                        id: startedAt
                        color: Theme.secondaryColor
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        text: moment(appState.timerStartTime).format("H:mm")
                    }

                    Label {
                        y: parent.height - this.height - Theme.paddingMedium
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("Adjust")
                    }
                }

                onClicked: {
                    if (!appState.breakTimerRunning) {
                        openTimeDialog()
                    }
                }
            }
        }

        Timer {
            interval: 60000
            running: appState.timerRunning || appState.breakTimerRunning
            repeat: true
            onTriggered: refreshState()
        }

        Banner {
            id: banner
        }
    }

    onStatusChanged: {
        refreshState()

        if (root.status === PageStatus.Active && !appState.versionCheckDone) {
            var lastVersionUsed = settings.getLastVersionUsed()
            var current = appVersion + "-" + appBuildNum

            if (lastVersionUsed !== current) {
                Log.info("App updated")
                pageStack.push(Qt.resolvedUrl("WhatsNewPage.qml"))
            }

            settings.setLastVersionUsed(current)
            appState.versionCheckDone = true
        }

        if (root.status === PageStatus.Active && appState.versionCheckDone) {
            if (appState.data.projects.length > 1 && pageStack._currentContainer.attachedContainer == null) {
                pageStack.pushAttached(Qt.resolvedUrl("ProjectPage.qml"), {dataContainer: root}, PageStackAction.Immediate)
            }

            // TODO: Why is this here?
            if(appState.timerRunning && appState.arguments.stopFromCommandLine) {
                banner.notify(qsTr("Timer stopped by command line argument"))
                stopTimer()
                pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: root, section: qsTr("Today")})
            }
        }
    }

    Component.onCompleted: {
        // Set the initial state
        refreshState()

        if (appState.data.projects.length === 0) {
            var id = db.insertInitialProject(Theme.secondaryHighlightColor)
            if (id) {
                //TODO: Try to get rid of this kind of code
                settings.setDefaultProjectId(id)
                refreshState()
            }
        }


        if (appState.arguments.startFromCommandLine && !appState.timerRunning) {
            // Start timer from command line
            banner.notify(qsTr("Timer started by command line argument"))
            startTimer()
        } else if (settings.getTimerAutoStart() && !appState.timerRunning) {
            // Automatically start timer if allowed in settings
            banner.notify(qsTr("Timer was autostarted"))
            startTimer()
        }
    }
}


