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

Page {
    id: all
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

    function getProject(projectId) {
        for (var i = 0; i < projects.length; i++) {
            if (projects[i].id === projectId)
                return projects[i];
        }
        return {'name':'Project was not found', 'labelColor': '#00cce7'};
    }

    function getAllHours(sortby){
        if (dataContainer != null && section != ""){
            //console.log(section)
            //console.log(projectId)
            if (section === "Today")
                return all.dataContainer.getAllDay(0, sortby, projectId);
            else if (section === "Yesterday")
                return all.dataContainer.getAllDay(1, sortby, projectId);
            else if(section === "This week")
                return all.dataContainer.getAllWeek(0, sortby, projectId);
            else if(section === "Last week")
                return all.dataContainer.getAllWeek(1, sortby, projectId);
            else if (section === "This month")
                return all.dataContainer.getAllMonth(0, sortby, projectId);
            else if (section === "Last month")
                return all.dataContainer.getAllMonth(1, sortby, projectId);
            else if (section === "This year")
                return all.dataContainer.getAllThisYear(sortby, projectId);
            else if (section === "All")
                return all.dataContainer.getAll(sortby, projectId);
            else{
                console.log("Unknown section");
                return [];
            }
        }
    }

    function updateView() {
        var allHours = getAllHours();
        var lastDate = "";
        for (var i = 0; i < allHours.length; i++) {
            var project = getProject(allHours[i].project);
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
                           'hourlyRate': project.hourlyRate
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

    onStatusChanged: {
        if (all.status === PageStatus.Active && listView.count > 1) {
            if (pageStack._currentContainer.attachedContainer == null) {
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
                text: sortedByProject ? "Sort by date" : "Sort by project"
                onClicked: {
                    sortedByProject = !sortedByProject;
                    if(sortedByProject)
                       getAllHours("project");
                    else
                        getAllHours();
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
                    text: "No items in this category yet"
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
                            text: model.projectName + "   " + netDur +"h"
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
                            text: model.breakDuration > 0 ? model.startTime + " - " + model.endTime + " (" + (model.breakDuration).toFixed(2) + "h break)" : model.startTime + " - " + model.endTime
                        }
                        Label {
                            id: price
                            visible: model.hourlyRate > 0
                            font{
                                pixelSize: Theme.fontSizeSmall
                            }
                            text: (netDur * model.hourlyRate).toFixed(2) + "€"
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
                                       editMode: all
                                   })

                }
                onPressAndHold: {
                    console.log("Press and hold")
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
                console.log(index)
                console.log(model.uid)
                remorse.execute(myListItem, "Deleting", function() { all.dataContainer.remove(model.uid); hoursModel.remove(index); all.dataContainer.getHours();} )

            }
        }
        Component {
           id: contextMenuComponent
           ContextMenu {
               id: menu
               MenuItem {
                   text: "Remove"
                   onClicked: {
                       menu.parent.remove();
                       console.log("Remove clicked!")
                   }
               }
           }
        }
    }
}


