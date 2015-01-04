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
    id: settingsPage
    property QtObject dataContainer: null

    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height
        //contentHeight: column.y + column.height
        Column {
            id: column

            spacing: 20
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            PageHeader {
                title: "Settings"
            }
            RemorseItem { id: remorse }
            SectionHeader { text: "General" }
            Text {
                font.pointSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: "More settings to come"
            }


            SectionHeader { text: "DANGER ZONE!" }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 250
                height: 75
                ValueButton {
                    id: resetButton
                    anchors.centerIn: parent
                    label: "Reset database"
                    width: parent.width
                    onClicked: remorse.execute(settingsPage,"Deleting database", function() {console.log("Resetting database"); settingsPage.dataContainer.resetDatabase();})
                }
            }
            Text {
                id: warningText
                font.pointSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: "Warning: You will loose all your hours data if you reset the database!"
            }

        }
    }
}










