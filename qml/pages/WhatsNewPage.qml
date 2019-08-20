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
import "../md.js" as MD

Dialog {
    id: page
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    property string changeLogText: "Error fetching changelog"

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.PaddingLarge

            DialogHeader {
                acceptText: qsTr("Ok")
                cancelText: qsTr("Ok")
            }

            PageHeader {
                title: qsTr("App updated to %1-%2").arg(appVersion).arg(appBuildNum)
            }

            SectionHeader { text: qsTr("What's new?") }

            Text {
                font.pixelSize: 0
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                textFormat: Text.RichText
                text: changeLogText
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }
        }
    }

    Component.onCompleted: {
        var xhr = new XMLHttpRequest
        xhr.open("GET", "../CHANGELOG.md")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                changeLogText = MD.md2html(xhr.responseText)
            }
        }
        xhr.send()
    }
}
