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
import "../helpers.js" as HH

Page {
    id: settingsPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    property double defaultDuration: 8
    property double defaultBreakDuration: 0
    property bool timerAutoStart : false
    property int roundToNearest: 0
    property bool roundToNearestComboInitialized: false
    property QtObject dataContainer: null

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height

        PullDownMenu {
            MenuItem {
                text: qsTr("View logs")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LogViewer.qml"))
                }
            }
        }


        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            PageHeader {
                title: qsTr("Settings")
            }

            RemorsePopup { id: remorse }

            SectionHeader { text: qsTr("Projects") }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100
                    Label {
                        id: editProjectsButton
                        anchors.centerIn: parent
                        text: qsTr("Edit projects")
                    }
                }

                onClicked: pageStack.push(Qt.resolvedUrl("Projects.qml"))
            }

            SectionHeader { text: qsTr("Default duration") }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: defaultDurationButton
                        anchors.centerIn: parent
                        text: defaultDuration.toString().toHHMM()

                        function openTimeDialog() {
                            var durationHour = HH.countHours(defaultDuration)
                            var durationMinute = HH.countMinutes(defaultDuration)
                            var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                            hourMode: (DateTime.TwentyFourHours),
                                            hour: durationHour,
                                            minute: durationMinute,
                                         })

                            dialog.accepted.connect(function() {
                                defaultDurationButton.text = dialog.timeText
                                durationHour = dialog.hour
                                durationMinute = dialog.minute
                                defaultDuration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                                settings.setDefaultDuration(defaultDuration)
                            })
                        }
                    }
                }
                onClicked: defaultDurationButton.openTimeDialog()
            }

            SectionHeader { text: qsTr("Default break duration") }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: defaultBreakDurationButton
                        anchors.centerIn: parent
                        text: defaultBreakDuration.toString().toHHMM()

                        function openTimeDialog() {
                            var durationHour = HH.countHours(defaultBreakDuration)
                            var durationMinute = HH.countMinutes(defaultBreakDuration)
                            var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                            hourMode: (DateTime.TwentyFourHours),
                                            hour: durationHour,
                                            minute: durationMinute,
                                         })

                            dialog.accepted.connect(function() {
                                defaultBreakDurationButton.text = dialog.timeText
                                durationHour = dialog.hour
                                durationMinute = dialog.minute
                                defaultBreakDuration = (((durationHour)*60 + durationMinute) / 60).toFixed(2)
                                settings.setDefaultBreakDuration(defaultBreakDuration)
                            })
                        }
                    }
                }
                onClicked: defaultBreakDurationButton.openTimeDialog()
            }

            SectionHeader { text: qsTr("Adding hours") }

            TextSwitch {
                id: timeSwitch
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                checked: true
                text: qsTr("Ends now by default")
                description: qsTr("Endtime will be set to now by default.")

                onCheckedChanged: {
                    timeSwitch.text = checked ? qsTr("Ends now by default") : qsTr("Starts now by default")
                    timeSwitch.description = checked ? qsTr("Endtime will be set to now by default.") : qsTr("Starttime will be set to now by default.")
                    if(checked){
                        settings.setEndsNowByDefault("yes")
                    }
                    else {
                        settings.setEndsNowByDefault("no")
                    }
                }
            }

            TextSwitch {
                id: fixedSwitch
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                checked: true
                text: qsTr("Endtime stays fixed by default.")
                description: qsTr("Starttime will flex if duration is changed.")

                onCheckedChanged: {
                    fixedSwitch.text = checked ? qsTr("Endtime stays fixed by default.") : qsTr("Starttime stays fixed by default.")
                    fixedSwitch.description = checked ? qsTr("Starttime will flex if duration is changed.") : qsTr("Endtime will flex if duration is changed.")
                    if(checked) {
                        settings.setEndTimeStaysFixed("yes") // LOL
                    }
                    else {
                        settings.setEndTimeStaysFixed("no") // XD
                    }
                }
            }

            ListModel {
                id: modelSource
                ListElement {
                    key: "Off"
                    value: 0
                }
                ListElement {
                    key: "5 min"
                    value: 5
                }
                ListElement {
                    key: "10 min"
                    value: 10
                }
                ListElement {
                    key: "15 min"
                    value: 15
                }
                ListElement {
                    key: "30 min"
                    value: 30
                }
            }

            ComboBox {
                id: roundingCombo
                anchors.margins: Theme.paddingLarge
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                label: qsTr("Round to nearest")
                description: qsTr("Rounding happens when saving hours")
                menu: ContextMenu {
                    Repeater {
                        width: parent.width
                        model: modelSource
                        delegate: MenuItem {
                            text: model.key
                            font.bold: true
                        }
                    }
                }

                onCurrentItemChanged: {
                    if (roundToNearestComboInitialized) {
                        var selectedValue = modelSource.get(currentIndex).value
                        settings.setRoundToNearest(selectedValue)
                    }
                    roundToNearestComboInitialized = true
                }

                function init() {
                    _updating = false
                    roundToNearest =  settings.getRoundToNearest()

                    for (var i = 0; i < modelSource.count; i++) {
                        if (modelSource.get(i).value == roundToNearest) {
                            currentIndex = i
                            break
                        }
                    }
                }
            }

            SectionHeader { text: qsTr("Timer options") }

            TextSwitch {
                id: autoStartSwitch
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                checked: false
                text: qsTr("Autostart timer on app startup")
                description: qsTr("Timer will get started automatically if not already running.")

                onCheckedChanged: {
                    autoStartSwitch.description = checked ? qsTr("Timer will get started automatically if not already running.") : qsTr("Timer will not get started automatically.")
                    if(checked)
                        settings.setTimerAutoStart(true)
                    else
                        settings.setTimerAutoStart(false)
                }
            }

            TextSwitch {
                id: defaultBreakInTimerSwitch
                checked: true
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Add break when using timer")
                description: qsTr("Default break is added automatically when using timer.")

                onCheckedChanged: {
                    defaultBreakInTimerSwitch.description = checked ? qsTr("Default break is added automatically when using timer. Only added when break is not recorded with the break timer.") : qsTr("Default break is not added automatically when using timer.")
                    settings.setDefaultBreakInTimer(checked)
                }
            }

            SectionHeader { text: qsTr("Set currency") }

            TextField{
                id: currencyTextArea
                focus: false
                width: parent.width
                placeholderText: qsTr("Set currency string")
                label: qsTr("Currency string")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    if(currencyTextArea.text.length > 3) {
                        banner.notify(qsTr("Currency string too long!"))
                        currencyTextArea.text = settings.getCurrencyString()
                    }
                    focus = false
                }

                onFocusChanged: {
                    settings.setCurrencyString(currencyTextArea.text)
                    currencyString = currencyTextArea.text
                }
            }

            SectionHeader { text: qsTr("Email reports") }

            Text {
                font.pixelSize: 0
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("These email addresses will be automatically filled in when selecting to send a report by email.") + " "
                + qsTr("No emails will be sent automatically.") + " "
                + qsTr("You can also decide to fill them in manually when sending a report.") +" "
                + qsTr("This is just for making it faster.")
            }

            TextField{
                id: toTextArea
                focus: false
                width: parent.width
                placeholderText: qsTr("Set default to address")
                label: qsTr("Default to address")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                onFocusChanged: {
                    if(!HH.validEmail(toTextArea.text)) {
                        banner.notify(qsTr("Invalid to email address!"))
                        toTextArea.text = settings.getToAddress()
                    }
                    else {
                        settings.setToAddress(toTextArea.text)
                    }
                }
            }

            TextField{
                id: ccTextArea
                focus: false
                width: parent.width
                placeholderText: qsTr("Set default cc address")
                label: qsTr("Default cc address")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                onFocusChanged: {
                    if(!HH.validEmail(ccTextArea.text)) {
                        banner.notify(qsTr("Invalid cc email address!"))
                        ccTextArea.text = settings.getCcAddress()
                    }
                    else {
                        settings.setCcAddress(ccTextArea.text)
                    }
                }
            }

            TextField{
                id: bccTextArea
                focus: false
                width: parent.width
                placeholderText: qsTr("Set default bcc address")
                label: qsTr("Default bcc address")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false

                onFocusChanged: {
                    if(!HH.validEmail(bccTextArea.text)) {
                        banner.notify(qsTr("Invalid bcc email address!"))
                        bccTextArea.text = settings.getBccAddress()
                    }
                    else {
                        settings.setBccAddress(bccTextArea.text)
                    }
                }
            }

            SectionHeader { text: qsTr("Exporting") }

            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Here you can export your Working Hours data.") + " "
                + qsTr("If you want to import your data to Working Hours Tracker e.g on another device, use the export the whole database button.") +" "
                + qsTr("It will export everything needed to rebuild the database e.g on another device.") +" "
                + qsTr("At the moment you will not be able to import csv files yet. Coming soon.")
            }

            Button {
                text: qsTr("Read more about exporting")
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: {
                  banner.notify(qsTr("Launching external browser"))
                  Qt.openUrlExternally("https://github.com/ojhaapala/wht/blob/master/README.md#exporting")
                }
            }

            BackgroundItem {
                height: 100

                Rectangle {
                    id: dump
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: dumpLabel
                        anchors.centerIn: parent
                        text: qsTr("Export the whole database")
                    }
                }

                onClicked:{
                    var file = exporter.dump()
                    banner.notify(qsTr("Database saved to")+ ": " + file)
                    dumpLabel.text = file
                    dumpLabel.font.pixelSize = Theme.fontSizeExtraSmall
                }
            }

            Rectangle {
                opacity: 0
                width: parent.width
                height: 10
            }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: exportHoursCSV
                        anchors.centerIn: parent
                        text: qsTr("Export hours as CSV")
                    }
                }

                onClicked:{
                    var file = exporter.exportHoursToCSV(db)
                    exportHoursCSV.text = file
                    banner.notify(qsTr("CSV saved to") +": " + file)
                    exportHoursCSV.font.pixelSize = Theme.fontSizeExtraSmall
                }
            }

            Rectangle {
                opacity: 0
                width: parent.width
                height: 10
            }

            BackgroundItem {
                height: 100

                Rectangle {
                    id: projectCSV
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: exportProjectsCSV
                        anchors.centerIn: parent
                        text: qsTr("Export projects as CSV")
                    }
                }

                onClicked: {
                    var file = exporter.exportProjectsToCSV(db)
                    exportProjectsCSV.text = file
                    banner.notify(qsTr("CSV saved to") +": " + file)
                    exportProjectsCSV.font.pixelSize = Theme.fontSizeExtraSmall
                }
            }

            SectionHeader { text: qsTr("Importing") }

            Text {
                font.pixelSize: 0
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Here you can import data into Working Hours Tracker.") + " "
                + qsTr("There should become no duplicates due to unique constraints.") + " "
                + qsTr("Rows are replaced from the imported file in case of entries already in the database.")+ " "
                + qsTr("This makes it possible to update edited rows.")
            }

            Button {
                text: qsTr("Read more about importing")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                  banner.notify(qsTr("Launching external browser"))
                  Qt.openUrlExternally("https://github.com/ojhaapala/wht/blob/master/README.md#exporting")
                }
            }

            /*
            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100
                    Label {
                        id: importHoursCSV
                        anchors.centerIn: parent
                        text: qsTr("Import hours from CSV")
                    }
                }
                onClicked:{
                    console.log("Importing hours from CSV")
                    var resp = exporter.importHoursFromCSV(filename)
                    banner.notify(resp)
                }
            }

            Rectangle {
                opacity: 0
                width: parent.width
                height: 10
            }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: importProjectsCSV
                        anchors.centerIn: parent
                        text: qsTr("Import projects from CSV")
                    }
                }

                onClicked:{
                    console.log("Importing projects from CSV")
                    var resp = exporter.importProjectsFromCSV(filename)
                    banner.notify(resp)
                }
            }

            Rectangle {
                opacity: 0
                width: parent.width
                height: 10
            }
            */

            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text:  qsTr("Import from a .sql dump exported by Working Hours Tracker.") + " "
                + qsTr("Give the full path to the file and then hit the button")
            }

            TextField{
                id: dumpImport
                focus: false
                width: parent.width
                placeholderText: qsTr("Full path to .sql file")
                label: qsTr("Full path to .sql file")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: importButton
                        anchors.centerIn: parent
                        text: qsTr("Import now!")
                    }
                }

                onClicked:{
                    if (dumpImport.text) {
                        remorse.execute(qsTr("Importing") + " " + dumpImport.text, function() {
                            Log.info(qsTr("Trying to import")+": " +dumpImport.text)
                            var resp = exporter.importDump(dumpImport.text)
                            banner.notify(resp)
                            settingsPage.dataContainer.getHours()
                            projects = settingsPage.dataContainer.getProjects()
                        })
                    }

                    else {
                        banner.notify(qsTr("No file path given"))
                    }
                }
            }

            SectionHeader { text: qsTr("DANGER ZONE!") }

            Text {
                id: warningText2
                font.pointSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Please be aware!")
            }

            BackgroundItem {
                height: 100

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingMedium
                    width: parent.width * 0.7
                    height: 100

                    Label {
                        id: resetButton
                        anchors.centerIn: parent
                        text: qsTr("Reset database")
                    }
                }

                onClicked: remorse.execute(qsTr("Resetting database"), function() {
                    if (dataContainer != null){
                       settingsPage.dataContainer.resetDatabase()
                       projects = settingsPage.dataContainer.getProjects()
                       pageStack.replace(Qt.resolvedUrl("FirstPage.qml"))
                    }
                })
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
                text: qsTr("Warning: You will loose all your Working Hours data if you reset the database!")
            }

            Rectangle {
                opacity: 0
                width: parent.width
                height: 10
            }

        }
    }

    Component.onCompleted: {
        var dur = settings.getDefaultDuration()
        if (dur >= 0) {
            defaultDuration = dur
        }

        var brk = settings.getDefaultBreakDuration()
        if (brk >= 0) {
            defaultBreakDuration = brk
        }

        var endFixed = settings.getEndTimeStaysFixed()
        if (endFixed === "yes") {
            fixedSwitch.checked = true
        }
        else if (endFixed === "no") {
            fixedSwitch.checked = false
        }

        var nowByDefault = settings.getEndsNowByDefault()
        if (nowByDefault === "yes") {
            timeSwitch.checked = true
        }
        else if (nowByDefault === "no") {
            timeSwitch.checked = false
        }

        autoStartSwitch.checked = settings.getTimerAutoStart()
        defaultBreakInTimerSwitch.checked = settings.getDefaultBreakInTimer()

        currencyTextArea.text = settings.getCurrencyString()
        toTextArea.text = settings.getToAddress()
        ccTextArea.text = settings.getCcAddress()
        bccTextArea.text = settings.getBccAddress()
        dumpImport.text = documentsLocation + "/wht.sql"
        roundingCombo.init()
    }

    Banner {
        id: banner
    }
}










