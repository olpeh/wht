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
    canAccept: validateInput()
    property QtObject prev: null
    property bool editMode: false
    property string id: "0"
    property string name: ""
    property double hourlyRate: 0
    property double contractRate: 0
    property double budget: 0
    property double hourBudget: 0
    property string labelColor: ""

    //Simple validator to avoid adding empty projects
    function validateInput() {
        return nameTextArea.text !== ""
    }
    function saveProject() {
        name = nameTextArea.text;
        if (id == "0" && !editMode)
            id = DB.getUniqueId();
        hourlyRate = parseFloat(hourlyRateTextArea.text);
        contractRate = parseFloat(contractRateTextArea.text);
        budget = parseFloat(budgetTextArea.text);
        hourBudget = parseFloat(hourBudgetTextArea.text);
        labelColor = colorIndicator.color;
        DB.setProject(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor);
        console.log(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor);
        if(defaultSwitch.checked) {
            defaultProjectId = id;
            settings.setDefaultProjecId(id);
        }
        page.prev.getProjects();
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

            SectionHeader { text: "Required" }
            TextField{
                id: nameTextArea
                focus: !editMode
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Please enter a name for the project"
            }
            TextSwitch {
                id: defaultSwitch
                checked: false
                text: "Make this the default project"
            }
            Separator {
                width: parent.width
            }
            SectionHeader { text: "Optional" }
            TextField{
                id: hourlyRateTextArea
                focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Hourly rate"
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: "Hourly rate"
            }
            TextField{
                id: contractRateTextArea
                focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Contract rate"
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: "Contract rate"
            }
            TextField{
                id: budgetTextArea
                focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Budget"
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: "Budget"
            }
            TextField{
                id: hourBudgetTextArea
                focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Hour budget"
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhNoPredictiveText
                label: "Hour budget"
            }
            BackgroundItem {
                Rectangle {
                    id: colorIndicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryHighlightColor
                    radius: 10.0
                    width: 315
                    height: 80
                    Label {
                        anchors.centerIn: parent
                        text: "Select label color"
                        font.bold: true
                    }
                }
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                    dialog.accepted.connect(function() {
                        colorIndicator.color = dialog.color
                        labelColor = dialog.color
                    })
                }
            }
            Item {
                width: parent.width
                height: 10
            }
            Component.onCompleted: {
                if (editMode){
                    nameTextArea.text = name;
                    hourlyRateTextArea.text = hourlyRate;
                    contractRateTextArea.text = contractRate;
                    budgetTextArea.text = budget;
                    hourBudgetTextArea.text = hourBudget;
                    colorIndicator.color = labelColor
                }
            }
        }
    }
    onDone: {
            if (result == DialogResult.Accepted) {
                console.log("Save the project!")
                saveProject()
            }
    }
}
