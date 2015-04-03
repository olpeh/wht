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

Page {
    id: projectPage
    property QtObject dataContainer: null
    property variant project: {'name':qsTr('Project was not found'), 'labelColor': Theme.secondaryHighlightColor};

    onStatusChanged: {

        // Data are refreshed each time the page is activated.
        // Otherwise, they may not be up to date if changes have occurred for the displayed project.
        if (projectPage.status === PageStatus.Activating) {
            getHours();
        }
    }

    Component.onCompleted: {
        project = getProject(defaultProjectId);
        getHours();
    }
    function getHours() {
        //Update hours view after adding or deleting hours
        summaryModel.set(0,{"hours": DB.getHoursDay(0, project.id).toString().toHHMM(), "hoursLast": DB.getHoursDay(1, project.id).toString().toHHMM()});
        summaryModel.set(1,{"hours": DB.getHoursWeek(0, project.id).toString().toHHMM(), "hoursLast": DB.getHoursWeek(1, project.id).toString().toHHMM()});
        summaryModel.set(2,{"hours": DB.getHoursMonth(0, project.id).toString().toHHMM(), "hoursLast": DB.getHoursMonth(1, project.id).toString().toHHMM()});
        summaryModel.set(3,{"hours": DB.getHoursYear(0, project.id).toString().toHHMM(), "hoursLast": DB.getHoursAll(project.id).toString().toHHMM()});
    }

    function getProject(projectId) {
        for (var i = 0; i < projects.length; i++) {
            if (projects[i].id === projectId)
                return projects[i];
        }
        return {'name':qsTr('Project was not found'), 'labelColor': Theme.secondaryHighlightColor};
    }

    property int projectAmount: projects.length
    onProjectAmountChanged: { setProjects() }
    function setProjects() {
        for (var i = 0; i < projects.length; i++) {
            modelSource.set(i, {
                           'id': projects[i].id,
                           'name': projects[i].name,
                           'labelColor': projects[i].labelColor
                            })
        }
        projectCombo._updating = false
        for (var i = 0; i < modelSource.count; i++) {
            if (modelSource.get(i).id === defaultProjectId) {
                projectCombo.currentIndex = i
                break
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        ListModel {
            id: summaryModel
            ListElement {
                hours: "0"
                hoursLast: "0"
            }
            ListElement {
                hours: "0"
                hoursLast: "0"
            }
            ListElement {
                hours: "0"
                hoursLast: "0"
            }
            ListElement {
                hours: "0"
                hoursLast: "0"
            }
            function section(index) {
                if (section["text"] === undefined) {
                    section.text = [
                        qsTr("Today"),
                        qsTr("This week"),
                        qsTr("This month"),
                        qsTr("This year"),
                        qsTr("Yesterday"),
                        qsTr("Last week"),
                        qsTr("Last month"),
                        qsTr("All")
                    ]
                }
                return section.text[index]
            }
        }
        SilicaListView {
            id: listView
            header: PageHeader { title: qsTr("Hours for") + " " +project.name }
            anchors.fill: parent
            model: summaryModel
            delegate: Item {
                width: listView.width
                height: 140 + Theme.paddingLarge
                BackgroundItem {
                    width: listView.width/2
                    height: 140
                    Rectangle {
                        anchors {
                             rightMargin: Theme.paddingLarge
                        }
                        color: Theme.rgba(project.labelColor, Theme.highlightBackgroundOpacity)
                        radius: 10.0
                        width: listView.width/2-1.5*Theme.paddingLarge
                        height: 140
                        x: Theme.paddingLarge
                        Label {
                            y: Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: listView.model.section(index +4)
                        }
                        Label {
                            y: 3 * Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.hoursLast
                            font.bold: true
                        }
                    }
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: dataContainer, section: listView.model.section(index +4), projectId: project.id})
                    }
                }
                BackgroundItem {
                    width: listView.width/2
                    height: 140
                    x: listView.width/2
                    Rectangle {
                        color: Theme.rgba(project.labelColor, Theme.highlightBackgroundOpacity)
                        radius: 10.0
                        width: listView.width/2-1.5*Theme.paddingLarge
                        height: 140
                        x: 0.5*Theme.paddingLarge
                        Label {
                            y: Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: listView.model.section(index)
                        }
                        Label {
                            y:3 * Theme.paddingLarge
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: model.hours
                            font.bold: true
                        }
                    }
                    onClicked: pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: dataContainer, section: listView.model.section(index), projectId: project.id})
                }
            }
        }

        ComboBox {
            id: projectCombo
            y: 110 + 4*140 + 4*Theme.paddingLarge
            label: qsTr("Selected project")
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
                project = getProject(modelSource.get(currentIndex).id)
                getHours()
            }
            Component.onCompleted: {
                projectPage.setProjects();
            }
        }
        ListModel {
            id: modelSource
        }
    }
}


