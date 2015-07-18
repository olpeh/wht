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

Page {
    id: all
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    ListModel {
        id: hoursModel
    }

    property QtObject dataContainer: null
    property bool sortedByProject: false
    property string section: ""
    property string projectId: ""
    //for the summary View
    property double categoryDuration: 0
    property double categoryPrice: 0
    property int categoryWorkdays: 0
    property int categoryEntries: 0
    property variant allHours: []

    function getProject(projectId) {
        for (var i = 0; i < projects.length; i++) {
            if (projects[i].id === projectId)
                return projects[i];
        }
        banner.notify(qsTr("Project was not found"))
        return {
            'name':qsTr('Project was not found'),
            'labelColor': Theme.secondaryHighlightColor,
            'error': true
        };
    }

    function getTaskName(project, taskId) {
        if (project.tasks) {
            for (var i = 0; i < project.tasks.length; i++) {
                if (project.tasks[i].id === taskId)
                    return project.tasks[i].name;
            }
        }
        return '';
    }

    function getAllHours(sortby){
        if (dataContainer != null && section != ""){
            //console.log(section)
            //console.log(projectId)
            if (section === qsTr("Today"))
                return all.dataContainer.getAllDay(0, sortby, projectId);
            else if (section === qsTr("Yesterday"))
                return all.dataContainer.getAllDay(1, sortby, projectId);
            else if(section === qsTr("This week"))
                return all.dataContainer.getAllWeek(0, sortby, projectId);
            else if(section === qsTr("Last week"))
                return all.dataContainer.getAllWeek(1, sortby, projectId);
            else if (section === qsTr("This month"))
                return all.dataContainer.getAllMonth(0, sortby, projectId);
            else if (section === qsTr("Last month"))
                return all.dataContainer.getAllMonth(1, sortby, projectId);
            else if (section === qsTr("This year"))
                return all.dataContainer.getAllThisYear(sortby, projectId);
            else if (section === qsTr("All"))
                return all.dataContainer.getAll(sortby, projectId);
            else{
                Log.error("Unknown section: " + section);
                return [];
            }
        }
    }

    function updateView(hours) {
        if(hours)
            allHours = hours;
        else
            allHours =  getAllHours();

        var lastDate = "";
        for (var i = 0; i < allHours.length; i++) {
            var project = getProject(allHours[i].project);
            var taskId = "0"
            if (allHours[i].taskId !== "0")
                taskId = allHours[i].taskId
            var taskName = ""
            if (taskId !=="" && taskId !=="0" && !project.error) {
                taskName = getTaskName(project, allHours[i].taskId)
            }
            hoursModel.set(i, {
                           'uid': allHours[i].uid,
                           'date': allHours[i].date,
                           'startTime': allHours[i].startTime,
                           'endTime': allHours[i].endTime,
                           'duration': allHours[i].duration,
                           'project' : allHours[i].project,
                           'projectName': project.name,
                           'description': allHours[i].description,
                           'breakDuration': allHours[i].breakDuration,
                           'labelColor': project.labelColor,
                           'hourlyRate': project.hourlyRate,
                           'taskId': taskId,
                           'taskName': taskName
            })
            var netDuration = allHours[i].duration - allHours[i].breakDuration;
            categoryDuration+= netDuration;
            if (project.hourlyRate)
                categoryPrice += project.hourlyRate * netDuration;
            if(allHours[i].date!==lastDate){
                categoryWorkdays+=1;
                lastDate = allHours[i].date;
            }
            categoryEntries+=1;
        }
    }

    function formateDate(datestring) {
        var d = new Date(datestring);
        return d.toLocaleDateString();
    }

    function createEmailBody(){
        var r = qsTr("Report of working hours") + " " + section + " ";
        if (projectId !== ""){
            var pr = getProject(projectId);
            var prname = pr.name;
            r += qsTr("for project") +": " + prname;
        }
        r += "\n\n";
        for (var i = 0; i < allHours.length; i++) {
            var project = getProject(allHours[i].project);
            var netDuration = allHours[i].duration - allHours[i].breakDuration;
            r += "[" + (netDuration).toString().toHHMM() + "] ";
            if (projectId === "")
                r += project.name + " ";
            var d = formateDate(allHours[i].date)
            r += d + "\n";
            r += allHours[i].description + "\n";
            r += allHours[i].startTime + " - " + allHours[i].endTime;
            if(allHours[i].breakDuration)
                r += " (" + allHours[i].breakDuration + ") ";
            if(project.hourlyRate) {
                r += " " + (netDuration * project.hourlyRate).toFixed(2) + " " + currencyString;
            }
            r += "\n\n";
        }
        r += qsTr("Total") + ": " + section + "\n";
        r += qsTr("Duration") + ": " + (categoryDuration).toString().toHHMM() + "\n";
        r += qsTr("Workdays") + ": " + categoryWorkdays + "\n";
        r += qsTr("Entries") + ": " + categoryEntries + "\n";
        if (categoryPrice)
            r += categoryPrice.toFixed(2) + " " + currencyString + "\n";

        return r;
    }

    onStatusChanged: {
        if (all.status === PageStatus.Active && listView.count > 1) {
            if (pageStack._currentContainer.attachedContainer === null) {
                pageStack.pushAttached(Qt.resolvedUrl("CategorySummary.qml"), {
                                           dataContainer: all,
                                           section: section,
                                           categoryDuration: categoryDuration,
                                           categoryPrice: categoryPrice,
                                           categoryWorkdays: categoryWorkdays,
                                           categoryEntries: categoryEntries
                                       });
            }
        }
    }

    Component.onCompleted: {
        updateView();
    }
    SilicaListView {
        id: listView
        header: PageHeader {
            title: section
        }
        PullDownMenu {
            visible: listView.count != 0
            MenuItem {
                text: qsTr("Export as CSV")
                onClicked: {
                    var filename = section.replace(" ", "")
                    if(projectId !== "") {
                        var project = getProject(projectId);
                        filename+=project.name.replace(" ", "");
                    }
                    banner.notify(qsTr("Saved to") +": " + exporter.exportCategoryToCSV(filename, allHours));
                }
            }

            MenuItem {
                text: qsTr("Send report by email")
                onClicked: {
                    var toAddress = settings.getToAddress();
                    var ccAddress = settings.getCcAddress();
                    var bccAddress = settings.getBccAddress();
                    var d = new Date();
                    var da = d.toLocaleDateString();
                    var subject = qsTr("Report of working hours") + " " + section + " ";
                    if (projectId !== ""){
                        var pr = getProject(projectId);
                        var prname = pr.name;
                        subject += qsTr("for project") +": " + prname;
                    }
                    subject += qsTr("Created") + " " + da;
                    var body = createEmailBody();
                    banner.notify("Trying to launch email app");
                    launcher.sendEmail(toAddress, ccAddress, bccAddress, subject, body);
                }
            }
            MenuItem {
                visible: projectId === "" && projects.length > 1
                text: sortedByProject ? qsTr("Sort by date") : qsTr("Sort by project")
                onClicked: {
                    sortedByProject = !sortedByProject;
                    if(sortedByProject){
                        var hours = getAllHours("project");
                        updateView(hours);
                    }
                    else
                        updateView();
                }
            }
        }
        spacing: Theme.paddingLarge
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingLarge
        quickScroll: true
        model: hoursModel
        VerticalScrollDecorator {}

        ViewPlaceholder {
                    enabled: listView.count == 0
                    text: qsTr("No items in this category yet")
        }
        delegate: Item {
            id: myListItem
            property Item contextMenu
            property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
            property double netDur : (model.duration - model.breakDuration).toFixed(2)
            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.childrenRect.height: contentItem.childrenRect.height
            BackgroundItem {
                id: contentItem
                width: parent.width
                height: model.hourlyRate > 0 ? 210 : 180
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
                            text: "[" + netDur.toString().toHHMM() + "]  " + model.projectName + "  " + model.taskName
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold : true
                        }
                        Label {
                            id: duration
                            font{
                                pixelSize: Theme.fontSizeMedium
                            }
                            text: formateDate(model.date)
                        }
                        Label {
                            id: description
                            text: model.description
                            font.pixelSize: Theme.fontSizeSmall
                            truncationMode: TruncationMode.Fade
                        }
                        Label {
                            id: date
                            font{
                                pixelSize: Theme.fontSizeSmall
                            }
                            text: model.breakDuration > 0 ? model.startTime + " - " + model.endTime + " (" + (model.breakDuration).toString().toHHMM() + " break)" : model.startTime + " - " + model.endTime
                        }
                        Label {
                            id: price
                            visible: model.hourlyRate > 0
                            font{
                                pixelSize: Theme.fontSizeSmall
                            }
                            text: (netDur * model.hourlyRate).toFixed(2) + " " + currencyString
                        }
                    }

                }

                onClicked: {
                    var splitted = model.startTime.split(":");
                    var startSelectedHour = splitted[0];
                    var startSelectedMinute = splitted[1];
                    var endSplitted = model.endTime.split(":");
                    var endSelectedHour = endSplitted[0];
                    var endSelectedMinute = endSplitted[1];
                    pageStack.push(Qt.resolvedUrl("Add.qml"), {
                                       dataContainer: dataContainer,
                                       uid: model.uid,
                                       selectedDate: model.date,
                                       startSelectedMinute:startSelectedMinute,
                                       startSelectedHour:startSelectedHour,
                                       endSelectedHour:endSelectedHour,
                                       endSelectedMinute:endSelectedMinute,
                                       duration:model.duration,
                                       description: model.description,
                                       project: model.project,
                                       dateText: model.date,
                                       breakDuration: model.breakDuration,
                                       editMode: true,
                                       previousPage: all,
                                       taskId: model.taskId
                                   })

                }
                onPressAndHold: {
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(listView)
                    contextMenu.show(myListItem)
                }
            }
            Item {
                width: parent.width
                height: 10
            }
            RemorseItem { id: remorse }
            function remove() {
                //console.log(index)
                //console.log(model.uid)
                remorse.execute(myListItem, qsTr("Removing"), function() { all.dataContainer.remove(model.uid); hoursModel.remove(index); all.dataContainer.getHours();} )

            }
        }
        Component {
           id: contextMenuComponent
           ContextMenu {
               id: menu
               MenuItem {
                   text: qsTr("Remove")
                   onClicked: {
                       menu.parent.remove();
                   }
               }
           }
        }
    }
    Banner {
        id: banner
    }
}


