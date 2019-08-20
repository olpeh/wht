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
    id: summary
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    property QtObject dataContainer: null
    property string section: ""
    property double categoryDuration: 0
    property double categoryPrice: 0
    property int categoryWorkdays: 0
    property int categoryEntries: 0

    Component.onCompleted: {
        initializeContent()
    }

    function initializeContent() {
        var defColor = String(Theme.secondaryHighlightColor)
        hoursModel.append({
                       'header': qsTr("Total") +": " + section,
                       'duration': qsTr("Duration")+": " + (categoryDuration).toString().toHHMM(),
                       'days': qsTr("Workdays") + ": " + categoryWorkdays,
                       'entries': qsTr("Entries") + ": " + categoryEntries,
                       'price': categoryPrice,
                       'labelColor': defColor,
        })

        if (dataContainer) {
            // get hours sorted by projects
            var allHours = dataContainer.getHoursForSection("project")
            myWorker.sendMessage({ 'type': 'categorySummary', 'allHours': allHours, 'projects': appState.data.projects })
        }
    }

    WorkerScript {
        id: myWorker
        source: "../worker.js"
        onMessage: {
            busyIndicator.running = false
            if (messageObject.status === 'ok') {
                hoursModel.append(messageObject.data)
            }
        }
    }

    ListModel {
        id: hoursModel
    }

    SilicaListView {
        id: listView
        model: hoursModel
        spacing: Theme.paddingLarge
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingLarge
        quickScroll: true
        header: PageHeader {
            title: qsTr("Summary for") + ": " + section
        }

        VerticalScrollDecorator {}

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
            width: ListView.view.width
            height: contentItem.childrenRect.height + Theme.paddingLarge

            Rectangle {
                id: contentItem
                width: parent.width
                height: column.height + Theme.paddingLarge
                color:  {
                    if (model.labelColor) {
                        Theme.rgba(model.labelColor, Theme.highlightBackgroundOpacity)
                    }
                    else {
                        Theme.rgba(Theme.secondaryHighlightColor, Theme.highlightBackgroundOpacity)

                    }
                }

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
                        text: model.price.toFixed(2) + " " + settings.getCurrencyString()
                    }
                }
            }
        }
    }
}
