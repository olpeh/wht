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
    Banner {
        id: banner
    }
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
        // TODO validate other project properties if used
        return nameTextArea.text !== "" && (hourlyRateTextArea.text === "" || !isNaN(parseFloat(hourlyRateTextArea.text)) || parseFloat(hourlyRateTextArea.text) >=0)
    }
    function saveProject() {
        name = nameTextArea.text;
        if (id == "0" && !editMode)
            id = DB.getUniqueId();
        hourlyRate = parseFloat(hourlyRateTextArea.text) || 0;
        contractRate = 0; //parseFloat(contractRateTextArea.text || 0);
        budget = 0; //parseFloat(budgetTextArea.text || 0);
        hourBudget = 0; //parseFloat(hourBudgetTextArea.text) || 0;
        labelColor = colorIndicator.color;
        DB.setProject(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor);
        //console.log(id, name, hourlyRate, contractRate, budget, hourBudget, labelColor);
        if(defaultSwitch.checked) {
            defaultProjectId = id;
            settings.setDefaultProjecId(id);
        }
        if(prev)
            page.prev.getProjects();
    }

    // Not the best way of doing this but we don't want ; or , in the inputs
    function removeInvalidCharacters(text) {
        var tmp = text
        text = text.split(",").join("")
        text =  text.split(";").join("")
        return text;
    }

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height
        Column {
            id: column
            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Cancel")
            }
            spacing: 20
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.PaddingLarge

            SectionHeader { text: qsTr("Required") }
            TextField{
                id: nameTextArea
                focus: !editMode
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    focus = false
                }
                width: parent.width
                placeholderText: qsTr("Please enter a name for the project")
                onFocusChanged: {
                    nameTextArea.text = removeInvalidCharacters(nameTextArea.text)
                }
            }
            TextSwitch {
                id: defaultSwitch
                checked: false
                text: qsTr("Make this the default project")
            }
            Separator {
                width: parent.width
            }
            SectionHeader { text: qsTr("Optional") }
            TextField{
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
            BackgroundItem {
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
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                    dialog.accepted.connect(function() {
                        colorIndicator.color = Theme.rgba(dialog.color, Theme.highlightBackgroundOpacity)
                        labelColor = dialog.color
                    })
                }
            }
            BackgroundItem {
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
                onClicked: { colorIndicator.color = Theme.rgba(Theme.secondaryHighlightColor, Theme.highlightBackgroundOpacity); labelColor = Theme.secondaryHighlightColor}
            }
            Item {
                width: parent.width
                height: 10
            }
            Component.onCompleted: {
                if (editMode){
                    nameTextArea.text = name;
                    hourlyRateTextArea.text = hourlyRate;
                    //contractRateTextArea.text = contractRate;
                    //budgetTextArea.text = budget;
                    //hourBudgetTextArea.text = hourBudget;
                    colorIndicator.color = Theme.rgba(labelColor, Theme.highlightBackgroundOpacity)
                    if(defaultProjectId === id) {
                        defaultSwitch.visible = false;
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
}
