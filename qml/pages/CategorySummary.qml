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
    id: summary
    ListModel {
        id: hoursModel
    }
    property QtObject dataContainer: null
    property string section: ""
    property double categoryDuration: 0
    property double categoryPrice: 0
    property int categoryWorkdays: 0
    property int categoryEntries: 0

    function initializeContent(){
        hoursModel.set(0, {
                       'header': "Total " + section,
                       'duration': "Duration: " + (categoryDuration).toFixed(2),
                       'days': "Workdays: " + categoryWorkdays,
                       'entries': "Entries: " + categoryEntries,
                       'price': categoryPrice
        })
        if(dataContainer){
            // get hours sorted by projects
            var allHours = dataContainer.getAllHours("project")
            var lastDate = "";
            var lastProject = {};
            var projectDuration = 0;
            var projectPrice = 0;
            var projectWorkdays = 0;
            var projectEntries = 0;
            var counter = 1;
            for (var i = 0; i < allHours.length; i++) {
                var project = dataContainer.getProject(allHours[i].project);

                var netDuration = allHours[i].duration - allHours[i].breakDuration;
                projectDuration+= netDuration;
                if (project.hourlyRate)
                    projectPrice += project.hourlyRate * netDuration;
                if(allHours[i].date!==lastDate){
                    projectWorkdays+=1;
                    lastDate = allHours[i].date;
                }
                projectEntries+=1;
                if(i && project !== lastProject){
                    hoursModel.set(counter, {
                                       'header': project.name,
                                       'duration': "Duration: " + projectDuration,
                                       'days': "Workdays: " + projectWorkdays,
                                       'entries': "Entries: " + projectEntries,
                                       'price': projectPrice,
                                       'labelColor': project.labelColor
                    })
                    counter ++;
                    projectDuration = 0;
                    projectPrice = 0;
                    projectWorkdays = 0;
                    projectEntries = 0;
                    lastProject = project;
                }
                if(i === 0)
                    lastProject = project;
            }
        }
    }

    Component.onCompleted: {
        console.log("Now im attached..");
        initializeContent();
    }
    SilicaListView {
        id: listView
        header: PageHeader {
            title: "Summary for " + section
        }
        /*PullDownMenu {
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
        }*/
        spacing: Theme.paddingLarge
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingLarge
        quickScroll: true
        model: hoursModel
        VerticalScrollDecorator {}
        ViewPlaceholder {
                    enabled: listView.count == 0
                    text: "Something went wrong"
        }
        delegate: Item {
            id: myListItem
            width: ListView.view.width

            height: model.price > 0 ? 210 : 180
            Rectangle {
                anchors.fill: parent
                color: model.labelColor ? Theme.rgba(model.labelColor, Theme.highlightBackgroundOpacity) : Theme.rgba(Theme.secondaryHighlightColor, Theme.highlightBackgroundOpacity)
                Column {
                    id: column
                    width: parent.width
                    x: Theme.paddingMedium
                    y: Theme.paddingMedium
                    Label {
                        text: model.header
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold : true
                    }
                    Label {
                        text: model.duration
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                    }
                    Label {
                        text: model.days
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                    }
                    Label {
                        text: model.entries
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                    }
                    Label {
                        visible: model.price > 0
                        font{
                            pixelSize: Theme.fontSizeSmall
                        }
                        text: model.price.toFixed(2) + "€"
                    }
                }
            }
        }
    }
}
