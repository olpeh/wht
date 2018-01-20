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
    canAccept: validateInput()
    property QtObject prev: null
    property bool editMode: false
    property string projectId
    property string name: ""
    property double hourlyRate: 0
    property double contractRate: 0
    property double budget: 0
    property double hourBudget: 0
    property string labelColor: ""

    //Simple validator to avoid adding empty projects
    function validateInput() {
        // TODO validate other project properties if used
        return nameTextArea.text !== "" && (hourlyRateTextArea.text === "" || !isNaN(parseFloat(hourlyRateTextArea.text)) || parseFloat(hourlyRateTextArea.text) >=0)
    }

    function saveProject() {
        if (taskNameArea.text.length) {
            saveTask(taskNameArea.text)
        }

        name = nameTextArea.text
        hourlyRate = parseFloat(hourlyRateTextArea.text) || 0
        contractRate = 0 //parseFloat(contractRateTextArea.text || 0)
        budget = 0 //parseFloat(budgetTextArea.text || 0)
        hourBudget = 0 //parseFloat(hourBudgetTextArea.text) || 0
        labelColor = colorIndicator.color

        var values = {
            "id": projectId ? projectId : null,
            "name": name,
            "hourlyRate": hourlyRate,
            "contractRate": contractRate,
            "budget": budget,
            "hourBudget": hourBudget,
            "labelColor": colorIndicator.color,
        };

        if (projectId) {
            values.id = projectId
        }

        projectId = db.saveProject(values);
        if (projectId) {
            values.id = projectId
            Log.info("Project saved succesfully: " + JSON.stringify(values))
        } else {
            Log.error("Saving project failed!")
        }


        if(defaultSwitch.checked && projectId) {
            settings.setDefaultProjectId(projectId)
        }

        if(prev) {
            prev.getProjects()
        }
    }

    function getTasks() {
        return db.getTasks(projectId)
    }

    function saveTask(name, taskId) {
        var values = {
            "projectID": projectId,
            "name": name,
        };

        if (taskId) {
            values.id = taskId
        }

        return db.saveTask(values)
    }

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height

        Column {
            id: column
            spacing: 15
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.PaddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }

            TextField {
                id: nameTextArea
                focus: !editMode
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: qsTr("Please enter a name for the project")
                label: qsTr("Project name")
            }

            TextSwitch {
                id: defaultSwitch
                checked: false
                text: qsTr("Make this the default project")
            }

            SectionHeader { text: qsTr("Tasks") }

            Repeater {
                id: repeater
                model: getTasks()

                BackgroundItem {
                    id: contentItem
                    onClicked: {
                        taskLabel.visible = false
                        taskNameEditArea.focus = true
                        taskNameEditArea.text = taskLabel.text
                    }

                    Rectangle {
                        color: colorIndicator.color
                        anchors.fill: parent

                        Label {
                            id: taskLabel
                            y: Theme.paddingLarge
                            x: Theme.paddingLarge
                            text: modelData.name
                            font{
                                bold: true
                                pixelSize: Theme.fontSizeMedium
                            }
                        }

                        TextField {
                            visible: !taskLabel.visible
                            id: taskNameEditArea
                            focus: false
                            y: Theme.paddingMedium
                            EnterKey.iconSource: "image://theme/icon-m-enter-close"
                            width: parent.width
                            EnterKey.onClicked: {
                                focus = false
                                taskLabel.visible = true
                                if (taskNameEditArea.text.length && taskNameEditArea.text !== taskLabel.text) {
                                    saveTask(taskNameEditArea.text, modelData.id)
                                    repeater.model = getTasks()
                                }
                            }
                            onFocusChanged: {
                                if (!taskNameEditArea.focus) {
                                    taskLabel.visible = true
                                    if (taskNameEditArea.text.length && taskNameEditArea.text !== taskLabel.text) {
                                        saveTask(taskNameEditArea.text, modelData.id)
                                        repeater.model = getTasks()
                                    }
                                }
                            }
                        }

                    }
                }
            }

            BackgroundItem {
                id: addTaskItem
                onClicked: {
                    addTaskItem.visible = false
                    taskNameArea.focus = true
                }

                Image {
                    id: addImage
                    source: "image://theme/icon-cover-new"
                    anchors.centerIn: parent
                }
            }

            TextField {
                visible: !addTaskItem.visible
                id: taskNameArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                width: parent.width
                placeholderText: qsTr("Task Name")
                label: qsTr("Task Name")
                EnterKey.onClicked: {
                    focus = false
                    addTaskItem.visible = true

                    if (taskNameArea.text.length) {
                        saveTask(taskNameArea.text)
                        repeater.model = getTasks()
                        text = ''
                    }
                }
            }

            SectionHeader { text: qsTr("Rates") }

            TextField {
                id: hourlyRateTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false //budgetTextArea.focus = true
                }
                width: parent.width
                placeholderText: qsTr("Hourly rate")
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: qsTr("Hourly rate")
                onFocusChanged: hourlyRateTextArea.text = hourlyRateTextArea.text.replace(",",".")
            }

            /* Lets hide these for now...
            TextField{
                id: contractRateTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: hourBudgetTextArea.focus = true
                width: parent.width
                placeholderText: qsTr("Contract rate")
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: qsTr("Contract rate")
            }

            TextField{
                id: budgetTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: qsTr("Budget")
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: qsTr("Budget")
            }

            TextField{
                id: hourBudgetTextArea
                focus: false
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: qsTr("Hour budget")
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: qsTr("Hour budget")
            }*/

            SectionHeader { text: qsTr("Coloring") }

            BackgroundItem {
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                    dialog.accepted.connect(function() {
                        colorIndicator.color = Theme.rgba(dialog.color, Theme.highlightBackgroundOpacity)
                        labelColor = dialog.color
                    })
                }

                Rectangle {
                    id: colorIndicator
                    opacity: 0.6
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.rgba(Theme.secondaryHighlightColor, Theme.highlightBackgroundOpacity)
                    radius: 10.0
                    width: 315
                    height: 80
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Select label color")
                        font.bold: true
                    }
                }
            }

            BackgroundItem {
                onClicked: {
                    colorIndicator.color = Theme.rgba(Theme.secondaryHighlightColor, Theme.highlightBackgroundOpacity)
                    labelColor = Theme.secondaryHighlightColor
                }

                Rectangle {
                    id: colorReset
                    opacity: 0.6
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.rgba(Theme.secondaryHighlightColor, Theme.highlightBackgroundOpacity)
                    radius: 10.0
                    width: 315
                    height: 80
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Reset coloring")
                        font.bold: true
                    }
                }
            }

            Item {
                width: parent.width
                height: 10
            }

            Component.onCompleted: {
                getTasks()
                if (editMode) {
                    nameTextArea.text = name
                    hourlyRateTextArea.text = hourlyRate
                    //contractRateTextArea.text = contractRate
                    //budgetTextArea.text = budget
                    //hourBudgetTextArea.text = hourBudget
                    colorIndicator.color = Theme.rgba(labelColor, Theme.highlightBackgroundOpacity)

                    var defaultProjectId =  settings.getDefaultProjectId()
                    if (defaultProjectId === projectId) {
                        defaultSwitch.visible = false
                    }
                }
            }
        }
    }
    onDone: {
            if (result == DialogResult.Accepted) {
                saveProject()
            }
    }
    Banner {
        id: banner
    }
}
