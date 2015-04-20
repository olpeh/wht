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

    // Email validator
    function validEmail(email) {
        if (email === "")
            return true;
        var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
        return re.test(email);
    }

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height
        Column {
            id: column
            spacing: 20
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            PageHeader {
                title: qsTr("Settings")
            }
            RemorseItem { id: remorse }
            SectionHeader { text: qsTr("Projects") }
            BackgroundItem {
                height: 100
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
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
                        text: countHours(defaultDuration) + ":" + countMinutes(defaultDuration);
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
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
                        text: countHours(defaultBreakDuration) + ":" + countMinutes(defaultBreakDuration);
                    }
                }
                onClicked: defaultBreakDurationButton.openTimeDialog()
            }

            SectionHeader { text: qsTr("Adding hours") }
            TextSwitch {
                id: timeSwitch
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
                checked: true
                text: qsTr("Endtime stays fixed by default.")
                description: qsTr("Starttime will flex if duration is changed.")
                onCheckedChanged: {
                    fixedSwitch.text = checked ? qsTr("Endtime stays fixed by default.") : qsTr("Starttime stays fixed by default.")
                    fixedSwitch.description = checked ? qsTr("Starttime will flex if duration is changed.") : qsTr("Endtime will flex if duration is changed.")
                    if(checked)
                        settings.setEndTimeStaysFixed("yes")
                    else
                        settings.setEndTimeStaysFixed("no")
                }
            }
            SectionHeader { text: qsTr("Startup options") }
            TextSwitch {
                id: autoStartSwitch
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
            SectionHeader { text: qsTr("Set currency") }
            TextField{
                id: currencyTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    if(currencyTextArea.text.length > 3) {
                        banner.notify(qsTr("Currency string too long!"))
                        currencyTextArea.text = settings.getCurrencyString()
                    }
                    focus = false
                }
                width: parent.width
                placeholderText: qsTr("Set currency string")
                label: qsTr("Currency string")
                onFocusChanged: {
                    settings.setCurrencyString(currencyTextArea.text);
                    currencyString = currencyTextArea.text;
                }
            }
            SectionHeader { text: qsTr("Email reports") }
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
                text: qsTr("These email addresses will be automatically filled in when selecting to send a report by email.") + " "
                + qsTr("No emails will be sent automatically.") + " "
                + qsTr("You can also decide to fill them in manually when sending a report.") +" "
                + qsTr("This is just for making it faster.")
            }
            TextField{
                id: toTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                }
                width: parent.width
                placeholderText: qsTr("Set default to address")
                label: qsTr("Default to address")
                onFocusChanged: {
                    if(!validEmail(toTextArea.text)) {
                        banner.notify(qsTr("Invalid to email address!"))
                        toTextArea.text = settings.getToAddress()
                    }
                    settings.setToAddress(toTextArea.text);
                }
            }
            TextField{
                id: ccTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                }
                width: parent.width
                placeholderText: qsTr("Set default cc address")
                label: qsTr("Default cc address")
                onFocusChanged: {
                    if(!validEmail(ccTextArea.text)) {
                        banner.notify(qsTr("Invalid cc email address!"))
                        ccTextArea.text = settings.getCcAddress()
                    }
                    else
                        settings.setCcAddress(ccTextArea.text);
                }
            }
            TextField{
                id: bccTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                }
                width: parent.width
                placeholderText: qsTr("Set default bcc address")
                label: qsTr("Default bcc address")
                onFocusChanged: {
                    if(!validEmail(bccTextArea.text)) {
                        banner.notify(qsTr("Invalid bcc email address!"))
                        bccTextArea.text = settings.getBccAddress()
                    }
                    else
                        settings.setBccAddress(bccTextArea.text);
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: dumpLabel
                        anchors.centerIn: parent
                        text: qsTr("Export the whole database")
                    }
                }
                onClicked:{
                    console.log("Dumping the database");
                    var file = exporter.dump();
                    banner.notify(qsTr("Database saved to")+ ": " + file);
                    dumpLabel.text = file;
                    dumpLabel.font.pixelSize = Theme.fontSizeExtraSmall;
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: exportHoursCSV
                        anchors.centerIn: parent
                        text: qsTr("Export hours as CSV")
                    }
                }
                onClicked:{
                    console.log("Exporting hours as CSV");
                    var file = exporter.exportHoursToCSV();
                    exportHoursCSV.text = file
                    banner.notify(qsTr("CSV saved to") +": " + file);
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: exportProjectsCSV
                        anchors.centerIn: parent
                        text: qsTr("Export projects as CSV")
                    }
                }
                onClicked:{
                    console.log("Exporting projects as CSV");
                    var file = exporter.exportProjectsToCSV();
                    exportProjectsCSV.text = file;
                    banner.notify(qsTr("CSV saved to") +": " + file);
                    exportProjectsCSV.font.pixelSize = Theme.fontSizeExtraSmall;
                }
            }

            SectionHeader { text: qsTr("Importing") }
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
                text: qsTr("Here you can import data into Working Hours Tracker.") + " "
                + qsTr("There should become no duplicates due to unique constraints.") + " "
                + qsTr("Duplicate rows are not inserted but fail on insertion.")
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: importHoursCSV
                        anchors.centerIn: parent
                        text: qsTr("Import hours from CSV")
                    }
                }
                onClicked:{
                    console.log("Importing hours from CSV");
                    var filename = "/home/nemo/Documents/workinghours.csv";
                    var resp = exporter.importHoursFromCSV(filename);
                    banner.notify(resp);
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: importProjectsCSV
                        anchors.centerIn: parent
                        text: qsTr("Import projects from CSV")
                    }
                }
                onClicked:{
                    console.log("Importing projects from CSV");
                    var filename = "/home/nemo/Documents/whtProjects.csv";
                    var resp = exporter.importProjectsFromCSV(filename);
                    banner.notify(resp);
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
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false;
                }
                width: parent.width
                placeholderText: qsTr("Full path to .sql file")
                label: qsTr("Full path to .sql file")
            }
            BackgroundItem {
                height: 100
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: importButton
                        anchors.centerIn: parent
                        text: qsTr("Import now!")
                    }
                }
                onClicked:{
                    console.log("Importing: " +dumpImport.text);
                    //var filename = "/home/nemo/Documents/wht.sql";
                    if (dumpImport.text) {
                        var resp = exporter.importDump(dumpImport.text);
                        banner.notify(resp);
                        settingsPage.dataContainer.getHours();
                        projects = settingsPage.dataContainer.getProjects();
                    }
                    else {
                        banner.notify(qsTr("No file path given"))
                    }
                }
            }

            SectionHeader { text: qsTr("Move all hours to default") }
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
                text: qsTr("Move ALL your existing hours to the project which is set as default.")
            }

            BackgroundItem {
                height: 100
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: moveHoursButton
                        anchors.centerIn: parent
                        text: qsTr("Move all to default")
                    }
                }
                onClicked:{
                    if (defaultProjectId !== "")
                        remorse.execute(settingsPage, qsTr("Move all hours to default project"), function() {
                            banner.notify(settingsPage.dataContainer.moveAllHoursTo(defaultProjectId));
                        })
                    else
                       banner.notify(qsTr("No default project set"))
                }
            }
            SectionHeader { text: qsTr("Move by project name in description") }
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
                text: qsTr("Try to move hours to existing projects.") + " "
                + qsTr("Sets correct project if the project name is found in the description.") + " "
                + qsTr("This is only meant to be used if you have used earlier versions of this app and written your project name in the description.") +" "
                + qsTr("This might take a while.")
            }
            BackgroundItem {
                height: 100
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: movingHoursButton
                        anchors.centerIn: parent
                        text: qsTr("Move existing hours")
                    }
                }
                onClicked: {
                    remorse.execute(settingsPage,qsTr("Moving hours to projects in description"), function() {
                         banner.notify(settingsPage.dataContainer.moveAllHoursToProjectByDesc());
                     })
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
                    radius: 10.0
                    width: parent.width - 2*Theme.paddingLarge
                    height: 100
                    Label {
                        id: resetButton
                        anchors.centerIn: parent
                        text: qsTr("Reset database")
                    }
                }
                onClicked: remorse.execute(settingsPage,qsTr("Resetting database"), function() {
                    if (dataContainer != null){
                       settingsPage.dataContainer.resetDatabase();
                       projects = settingsPage.dataContainer.getProjects();
                       pageStack.replace(Qt.resolvedUrl("FirstPage.qml"));
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

        currencyTextArea.text = settings.getCurrencyString();
        toTextArea.text = settings.getToAddress();
        ccTextArea.text = settings.getCcAddress();
        bccTextArea.text = settings.getBccAddress();
        dumpImport.text = "/home/nemo/Documents/wht.sql";
    }
    Banner {
        id: banner
    }
}










