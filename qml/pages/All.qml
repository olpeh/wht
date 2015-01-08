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
    property string section: ""

    function getAllHours(){
        if (dataContainer != null && section != ""){
            console.log(section)
            if (section === "Today")
                var allHours = all.dataContainer.getAllToday();
            else if(section === "This week")
                var allHours = all.dataContainer.getAllThisWeek();
            else if (section === "This month")
                var allHours = all.dataContainer.getAllThisMonth();
            else if (section === "This year")
                var allHours = all.dataContainer.getAllThisYear();
            else if (section === "All")
                var allHours = all.dataContainer.getAll();

            else{
                console.log("Unknown section");
                var allHours = [];
            }

            //console.log(allHours);
            //uid,date,duration,project,description
            for (var i = 0; i < allHours.length; i++) {
                hoursModel.set(i, {
                               'uid': allHours[i].uid,
                               'date': allHours[i].date,
                               'startTime': allHours[i].startTime,
                               'endTime': allHours[i].endTime,
                               'duration': allHours[i].duration,
                               'project' : allHours[i].project,
                               'description': allHours[i].description,
                               'breakDuration': allHours[i].breakDuration })
            }
        }
    }

    function updateView() {
        getAllHours();
    }

    Component.onCompleted: {
        getAllHours();
    }
    SilicaListView {
        id: listView
        header: PageHeader {
            title: section
        }
        spacing: Theme.paddingLarge +10
        anchors.fill: parent
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
            width: ListView.view.width
            height: menuOpen ? contextMenu.height + contentItem.childrenRect.height: contentItem.childrenRect.height

            BackgroundItem {
                id: contentItem
                width: parent.width

                Label {
                    id: date
                    text: model.date
                    font{
                        bold: true
                        pixelSize: Theme.fontSizeMedium
                    }
                    anchors {
                        left: parent.left
                        leftMargin: Theme.paddingMedium
                    }
                }
                Label {
                    id: times
                    text: model.startTime + "-" + model.endTime
                    font{
                        bold: true
                        pixelSize: Theme.fontSizeMedium
                    }
                    anchors {
                        left: date.right
                        leftMargin: Theme.paddingMedium
                        baseline: date.baseline
                    }
                }
                Label {
                    id: duration
                    property double netDur : model.duration - model.breakDuration
                    text: netDur + "h"
                    font{
                        bold: true
                        pixelSize: Theme.fontSizeMedium
                    }
                    anchors {
                        left: times.right
                        leftMargin: Theme.paddingMedium
                        baseline: date.baseline
                    }
                }
                Label {
                    id: breakDuration
                    visible: model.breakDuration > 0
                    text: "(" + model.breakDuration + "h break)"
                    font{
                        pixelSize: Theme.fontSizeExtraSmall
                    }
                    anchors {
                        left: duration.right
                        leftMargin: Theme.paddingMedium
                        baseline: date.baseline
                    }
                }
                Label {
                    id: project
                    text: "Project: " + model.project
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors {
                        top: duration.bottom
                        left: parent.left
                        leftMargin: Theme.paddingMedium
                    }
                }
                Label {
                    id: description
                    text: "Description: " + model.description
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Fade
                    anchors {
                        top: project.bottom
                        left: parent.left
                        leftMargin: Theme.paddingMedium
                    }
                }

                onClicked: {
                    console.log("Clikkaus")
                    var splitted = model.startTime.split(":");
                    console.log(splitted);
                    var startSelectedHour = splitted[0];
                    var startSelectedMinute = splitted[1];
                    var endSplitted = model.endTime.split(":");
                    console.log(endSplitted);
                    var endSelectedHour = endSplitted[0];
                    var endSelectedMinute = endSplitted[1];
                    pageStack.push(Qt.resolvedUrl("Add.qml"), {dataContainer: dataContainer, uid: model.uid, selectedDate: model.date, startSelectedMinute:startSelectedMinute, startSelectedHour:startSelectedHour,
                                                     endSelectedHour:endSelectedHour, endSelectedMinute:endSelectedMinute, duration:model.duration, description: model.description, project: model.project,
                                                     dateText: model.date, breakDuration: model.breakDuration, editMode: all})

                }
                onPressAndHold: {
                    console.log("Press and hold")
                    if (!contextMenu)
                        contextMenu = contextMenuComponent.createObject(listView)
                    contextMenu.show(myListItem)
                }
            }
            RemorseItem { id: remorse }
            function remove() {
                var idx = index
                console.log(index)
                console.log(model.uid)
                remorse.execute(myListItem, "Deleting", function() { all.dataContainer.remove(model.uid); hoursModel.remove(idx); all.dataContainer.getHours();} )

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


