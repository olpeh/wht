/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

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
    id: page

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show previous hours")
                onClicked: pageStack.push(Qt.resolvedUrl("Hours.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Working Hours Tracker")
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Add new item")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Button {
                id: startTime
                property var hour: null
                property var minute: null
                text: "Choose a starting time"

                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                        hour: 07,
                        minute: 00,
                        hourMode: DateTime.TwentyFourHours
                    })
                    dialog.accepted.connect(function() {
                        startTime.text = "Start time: " + dialog.timeText
                        hour = dialog.hour
                        minute = dialog.minute
                        if(endTime.hour != null)
                            durationLabel.text = "Duration: " + (endTime.hour - dialog.hour) + ":" + (endTime.minute - dialog.minute)

                    })
                }
            }
            Button {
                id: endTime
                property var hour: null
                property var minute: null
                text: "Choose an ending time"

                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                        hour: 15,
                        minute: 30,
                        hourMode: DateTime.TwentyFourHours
                    })
                    dialog.accepted.connect(function() {
                        endTime.text = "End time: " + dialog.timeText
                        hour = dialog.hour
                        minute = dialog.minute
                        durationLabel.text = "Duration: " + (dialog.hour - startTime.hour) + ":" + (dialog.minute - startTime.minute)
                        console.log(startTime.hour)
                        console.log(startTime.minute)
                        console.log(endTime.hour)
                        console.log(endTime.minute)
                    })
                }
            }
            Label {
                id: durationLabel
                text: "Duration:"
            }
        }
    }
}


