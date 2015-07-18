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
    id: summary
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
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
                       'header': qsTr("Total") +": " + section,
                       'duration': qsTr("Duration")+": " + (categoryDuration).toString().toHHMM(),
                       'days': qsTr("Workdays") + ": " + categoryWorkdays,
                       'entries': qsTr("Entries") + ": " + categoryEntries,
                       'price': categoryPrice
        })
        if(dataContainer){
            // get hours sorted by projects
            var allHours = dataContainer.getAllHours("project")
            var lastDate = "";
            var results=[];
            var item ={
                'project': {},
                'projectDuration': 0,
                'projectPrice': 0,
                'projectWorkdays': 0,
                'projectEntries': 0
            }
            for (var i = 0; i < allHours.length; i++) {
                var project = dataContainer.getProject(allHours[i].project);
                if(i === 0) {
                    item.project = project;
                }
                if(project.id !== item.project.id) {
                    results.push(item);
                    item ={
                        'project': project,
                        'projectDuration': 0,
                        'projectPrice': 0,
                        'projectWorkdays': 0,
                        'projectEntries': 0
                    };
                    lastDate = "";
                }
                var netDuration = allHours[i].duration - allHours[i].breakDuration;
                item.projectDuration+= netDuration;
                if (project.hourlyRate)
                    item.projectPrice += project.hourlyRate * netDuration;
                if(allHours[i].date!==lastDate){
                    item.projectWorkdays+=1;
                    lastDate = allHours[i].date;
                }
                item.projectEntries+=1;
            }
            results.push(item);
            if(results.length > 1) {
                for(var j=0; j<results.length; j++) {
                    hoursModel.set(j+1, {
                           'header': results[j].project.name,
                           'duration': qsTr("Duration") + ": " + results[j].projectDuration.toString().toHHMM(),
                           'days': qsTr("Workdays") + ": " + results[j].projectWorkdays,
                           'entries': qsTr("Entries") + ": " + results[j].projectEntries,
                           'price': results[j].projectPrice,
                           'labelColor': results[j].project.labelColor
                    })
                }
            }
        }
    }

    Component.onCompleted: {
        initializeContent();
    }
    SilicaListView {
        id: listView
        header: PageHeader {
            title: qsTr("Summary for") + ": " +section
        }

        spacing: Theme.paddingLarge
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingLarge
        quickScroll: true
        model: hoursModel
        VerticalScrollDecorator {}
        ViewPlaceholder {
                    enabled: listView.count == 0
                    text: qsTr("Something went wrong")
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
                        text: model.price.toFixed(2) + " " + currencyString
                    }
                }
            }
        }
    }
}
