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

Page {
    id: all
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    property QtObject dataContainer: null
    property bool sortedByProject: false
    property string section: ""
    property string projectId: ""
    property variant allHours: []
    property double categoryDuration: 0
    property double categoryPrice: 0
    property int categoryWorkdays: 0
    property int categoryEntries: 0

    function getHoursForSection(sortby){
        var sorting = []
        if (sortby) {
            sorting.push(sortby + " DESC")
        }
        switch (section) {
            case qsTr("Today"):
                return db.getHoursForPeriod("day", 0, sorting, projectId)
            case qsTr("Yesterday"):
                return db.getHoursForPeriod("day", 1, sorting, projectId)
            case qsTr("This week"):
                return db.getHoursForPeriod("week", 0, sorting, projectId)
            case qsTr("Last week"):
                return db.getHoursForPeriod("week", 1, sorting, projectId)
            case qsTr("This month"):
                return db.getHoursForPeriod("month", 0, sorting, projectId)
            case qsTr("Last month"):
                return db.getHoursForPeriod("month", 1, sorting, projectId)
            case qsTr("This year"):
                return db.getHoursForPeriod("year", 0, sorting, projectId)
            case qsTr("All"):
                return db.getHoursForPeriod("all", 1, sorting, projectId)
            default:
                Log.error("Unknown section: " + section)
                return []
        }
    }

    function updateView(hours) {
        if(hours) {
            allHours = hours
        }
        else {
            allHours =  getHoursForSection()
        }
        if (listView.count != 0) {
            hoursModel.clear()
        }

        myWorker.sendMessage({ 'type': 'all', 'allHours': allHours, 'projects': appState.data.projects })
    }

    function createEmailBody(){
        var r = qsTr("Report of working hours") + " " + section + " "

        if (projectId !== ""){
            var pr = getProject(projectId)
            var prname = pr.name
            r += qsTr("for project") +": " + prname
        }
        r += "\n\n"
        for (var i = 0; i < allHours.length; i++) {
            var project = getProject(allHours[i].project)
            var task = project.tasks.findById(allHours[i].taskId)

            var netDuration = allHours[i].duration - allHours[i].breakDuration
            r += "[" + (netDuration).toString().toHHMM() + "] "

            if (projectId === "") {
                r += project.name + " "
            }

            if (task) {
                r += "/ " + task.name + " "
            }

            var d = helpers.formatDate(allHours[i].date)
            r += d + "\n"
            r += allHours[i].description + "\n"
            r += allHours[i].startTime + " - " + allHours[i].endTime

            if(allHours[i].breakDuration) {
                r += " (" + allHours[i].breakDuration + ") "
            }

            if(project.hourlyRate) {
                r += " " + (netDuration * project.hourlyRate).toFixed(2) + " " + settings.getCurrencyString()
            }

            r += "\n\n"
        }
        r += qsTr("Total") + ": " + section + "\n"
        r += qsTr("Duration") + ": " + (categoryDuration).toString().toHHMM() + "\n"
        r += qsTr("Workdays") + ": " + categoryWorkdays + "\n"
        r += qsTr("Entries") + ": " + categoryEntries + "\n"

        if (categoryPrice) {
            r += categoryPrice.toFixed(2) + " " + settings.getCurrencyString() + "\n"
        }

        return r
    }

    function getProject(projectId) {
        var found = appState.data.projects.findById(projectId)
        if(found) {
            return found
        }
        else {
            return {'name':qsTr('Project was not found'), 'labelColor': Theme.secondaryHighlightColor}
        }

    }

    onStatusChanged: {
        if (all.status === PageStatus.Active) {
            updateView()
        }
    }

    WorkerScript {
        id: myWorker
        source: "../worker.js"
        onMessage: {
            busyIndicator.running = false

            if (messageObject.status === 'running') {
                hoursModel.append(messageObject.data)
            }

            else if (messageObject.status === 'done') {
                var data = messageObject.data
                categoryDuration = data.categoryDuration
                categoryPrice = data.categoryPrice
                categoryWorkdays = data.categoryWorkdays
                categoryEntries = data.categoryEntries
                if (all.status === PageStatus.Active && listView.count > 1) {
                    if (pageStack._currentContainer.attachedContainer === null) {
                        pageStack.pushAttached(Qt.resolvedUrl("CategorySummary.qml"), {
                                                   dataContainer: all,
                                                   section: section,
                                                   categoryDuration: categoryDuration,
                                                   categoryPrice: categoryPrice,
                                                   categoryWorkdays: categoryWorkdays,
                                                   categoryEntries: categoryEntries
                                               })
                    }
                }
            }

            else {
                console.log('WTF')
            }
        }
    }

    ListModel {
        id: hoursModel
    }

    SilicaListView {
        id: listView
        spacing: Theme.paddingLarge
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingLarge
        quickScroll: true
        model: hoursModel
        header: PageHeader { title: section }

        PullDownMenu {
            visible: listView.count != 0

            MenuItem {
                text: qsTr("Export as CSV")
                onClicked: {
                    var filename = section.replace(" ", "")

                    if (projectId !== "") {
                        var project = getProject(projectId)
                        filename += project.name.replace(" ", "")
                    }

                    banner.notify(qsTr("Saved to") + ": " + exporter.exportCategoryToCSV(filename, allHours))
                }
            }

            MenuItem {
                text: qsTr("Send report by email")
                onClicked: {
                    var toAddress = settings.getToAddress()
                    var ccAddress = settings.getCcAddress()
                    var bccAddress = settings.getBccAddress()
                    var d = new Date()
                    var da = d.toLocaleDateString()
                    var subject = qsTr("Report of working hours") + " " + section + " "

                    if (projectId !== "") {
                        var pr = getProject(projectId)
                        var prname = pr.name
                        subject += qsTr("for project") +": " + prname
                    }

                    subject += qsTr("Created") + " " + da
                    var body = createEmailBody()
                    banner.notify("Trying to launch email app")
                    launcher.sendEmail(toAddress, ccAddress, bccAddress, subject, body)
                }
            }

            MenuItem {
                visible: projectId === "" && appState.data.projects.length > 1
                text: sortedByProject ? qsTr("Sort by date") : qsTr("Sort by project")
                onClicked: {
                    sortedByProject = !sortedByProject

                    if (sortedByProject) {
                        var hours = getHoursForSection("project")
                        updateView(hours)
                    }
                    else {
                        updateView()
                    }
                }
            }
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: listView.count == 0 && !busyIndicator.running
            text: qsTr("No items in this category yet")
        }

        ViewPlaceholder {
            enabled: busyIndicator.running
            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                size: BusyIndicatorSize.Large
                running: true
            }
        }

        delegate: Item {
            id: myListItem
            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property double netDur: (model.duration - model.breakDuration).toFixed(2)
            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.childrenRect.height: contentItem.childrenRect.height

            BackgroundItem {
                id: contentItem
                width: parent.width
                height: column.height + Theme.paddingLarge

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Add.qml"), {
                                       hourRow: model,
                                       editMode: true
                                   })

                }
                onPressAndHold: {
                    if (!contextMenu) {
                        contextMenu = contextMenuComponent.createObject(listView)
                    }

                    contextMenu.show(myListItem)
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.rgba(model.labelColor, Theme.highlightBackgroundOpacity)

                    Column {
                        id: column
                        width: parent.width
                        x: Theme.paddingMedium
                        y: Theme.paddingMedium

                        Label {
                            id: project
                            text: "[" + netDur.toString().toHHMM() + "]  "
                                  + model.projectName
                                  + (model.taskName !== '' ? " / " + model.taskName : "")
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold : true
                        }

                        Label {
                            id: duration
                            font.pixelSize: Theme.fontSizeMedium
                            text: helpers.formatDate(model.date)
                        }

                        Label {
                            id: task
                            text: model.taskName
                            font.pixelSize: Theme.fontSizeSmall
                            truncationMode: TruncationMode.Fade
                        }

                        Label {
                            id: description
                            text: model.description
                            font.pixelSize: Theme.fontSizeSmall
                            truncationMode: TruncationMode.Fade
                        }

                        Label {
                            id: date
                            font.pixelSize: Theme.fontSizeSmall
                            text: {
                                if (model.breakDuration > 0) {
                                    model.startTime + " - " + model.endTime + " (" + (model.breakDuration).toString().toHHMM() + " break)"
                                }
                                else {
                                    model.startTime + " - " + model.endTime
                                }
                            }
                        }

                        Label {
                            id: price
                            visible: model.hourlyRate > 0
                            font.pixelSize: Theme.fontSizeSmall
                            text: (netDur * model.hourlyRate).toFixed(2) + " " + settings.getCurrencyString()
                        }
                    }

                }
            }

            Item {
                width: parent.width
                height: 10
            }

            RemorsePopup { id: remorse }

            function remove() {
                remorse.execute(qsTr("Removing"), function() {
                    if(db.remove("hours", model.uid)) {
                        hoursModel.remove(index)
                        firstPage.refreshState()
                    }
                    else {
                        banner.notify("Removing failed!")
                    }
                })

            }
        }

        Component {
           id: contextMenuComponent

           ContextMenu {
               id: menu

               MenuItem {
                   text: qsTr("Remove")
                   onClicked: {
                       menu.parent.remove()
                   }
               }
           }
        }
    }

    Banner {
        id: banner
    }
}


