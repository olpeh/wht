/*
Copyright (C) 2015 Olavi Haapala.
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
import "../config.js" as DB

Page {
    id: projectPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    property QtObject dataContainer: null
    property variant project: {'name':qsTr('Project was not found'), 'labelColor': Theme.secondaryHighlightColor}
    property int projectAmount: projects.length

    function getHours() {
        //Update hours
        summaryModel.set(0,{"hours": db.getDurationForPeriod("day", 1, project.id).toString().toHHMM() })
        summaryModel.set(1,{"hours": db.getDurationForPeriod("day", 0, project.id).toString().toHHMM() })
        summaryModel.set(2,{"hours": db.getDurationForPeriod("week", 1, project.id).toString().toHHMM() })
        summaryModel.set(3,{"hours": db.getDurationForPeriod("week", 0, project.id).toString().toHHMM() })
        summaryModel.set(4,{"hours": db.getDurationForPeriod("month", 1, project.id).toString().toHHMM() })
        summaryModel.set(5,{"hours": db.getDurationForPeriod("month", 0, project.id).toString().toHHMM() })
        summaryModel.set(6,{"hours": db.getDurationForPeriod("all", 0, project.id).toString().toHHMM() })
        summaryModel.set(7,{"hours": db.getDurationForPeriod("year", 0, project.id).toString().toHHMM() })
    }

    function getProject(projectId) {
        var found = projects.findById(projectId)
        if(found) {
            return found
        }
        return {'name':qsTr('Project was not found'), 'labelColor': Theme.secondaryHighlightColor}
    }

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

        height: projectPage.height - projectCombo.height
        width: parent.width
        header: PageHeader {
            id: pageHeader
            title: qsTr("Hours for") + " " +project.name
            Component.onCompleted: grid.pageHeader = pageHeader
        }
        cellWidth: {
            if (projectPage.orientation == Orientation.PortraitInverted || projectPage.orientation == Orientation.Portrait)
                projectPage.width / 2
            else
                projectPage.width / 4
        }
        cellHeight: {
            if (projectPage.orientation == Orientation.PortraitInverted || projectPage.orientation == Orientation.Portrait)
                (projectPage.height / 5) - pageHeader.height / 5
            else
                (projectPage.height / 3) - pageHeader.height / 3
        }

        model: summaryModel
        snapMode: GridView.SnapToRow
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
                    pageStack.push(Qt.resolvedUrl("All.qml"), {dataContainer: dataContainer, section: summaryModel.section(index), projectId: project.id})
                }
            }
        }
    }

    ListModel {
        id: modelSource
    }

    ComboBox {
        id: projectCombo
        anchors.bottom: projectPage.bottom
        anchors.margins: Theme.paddingLarge
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
            projectPage.setProjects()
        }
    }

    onStatusChanged: {
        // Data is refreshed each time the page is activated.
        // Otherwise, they may not be up to date if changes have occurred for the displayed project.
        if (projectPage.status === PageStatus.Activating) {
            getHours()
        }
    }

    onProjectAmountChanged: { setProjects() }

    Component.onCompleted: {
        project = getProject(defaultProjectId)
        getHours()
    }
}
