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
    id: aboutPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    property QtObject dataContainer: null
    SilicaFlickable{
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingLarge
        contentHeight: column.y + column.height
        PullDownMenu {
            MenuItem {
                text: qsTr("How to use")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("HowTo.qml"))
                }
            }
        }
        Column {
            id: column
            PageHeader {
                title: qsTr("About")
            }
            width: parent.width
            SectionHeader { text: qsTr("General") }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Working Hours Tracker for SailfishOS is a simple working hours tracker to keep track on working hours.")
            }
            Item {
                width: parent.width
                height: Theme.paddingMedium
            }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Your current version and build number: %1-%2").arg(appVersion).arg(appBuildNum);
            }

            SectionHeader { text: qsTr("Usage") }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Read more about how to use this app by accessing the pulley menu or clicking the button below.")
            }
            Button {
              text: qsTr("How to use")
              anchors.horizontalCenter: parent.horizontalCenter
              onClicked: pageStack.push(Qt.resolvedUrl("HowTo.qml"))
            }
            SectionHeader { text: qsTr("Author") }
            Text {
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: "Olavi Haapala"
            }
            Button {
                text: "harbourwht@gmail.com"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                  banner.notify(qsTr("Launching external email app"))
                  Qt.openUrlExternally("mailto:harbourwht@gmail.com")
                }
            }
            Button {
                text: "Twitter: @0lpeh"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://twitter.com/0lpeh")
                }
            }
            Item {
                width: parent.width
                height: 10
            }

            SectionHeader { text: qsTr("Donate") }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Please donate if you like my work. Donations help me to use more time on development.")
            }

            IconButton {
               icon.source: "http://api.flattr.com/button/flattr-badge-large.png"
               anchors.horizontalCenter: parent.horizontalCenter
               scale: 2.2
               onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://flattr.com/submit/auto?user_id=olpe&url=http%3A%2F%2Fgithub.com/ojhaapala/wht")
                }
            }
            Button {
                text: "Paypal EUR"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9HY294XX4EJFW&lc=FI&item_name=Olpe&item_number=Working%20Hours%20Tracker&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")
                }
            }
            Button {
                text: "Paypal USD"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9HY294XX4EJFW&lc=FI&item_name=Olpe&item_number=Working%20Hours%20Tracker&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")
                }
            }
            Item {
                width: parent.width
                height: 10
            }
            SectionHeader { text: "Bitcoin" }
            TextField {
                font.pixelSize: Theme.fontSizeSmall
                id: bitcoinText
                readOnly: true
                focusOnClick: true
                onClicked: {
                    selectAll()
                    copy()
                    banner.notify(qsTr("Copied to clipboard"))
                }
                label: qsTr("Donate to my bitcoin account")
                text: "185QfMcsF4WL1T1ypCdcg5oYbM7XKZMABa"
            }
            SectionHeader { text: qsTr("Source") }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Contributions, bug reports and ideas are welcome. Please report issues in github. Link below.")
            }
            Item {
                width: parent.width
                height: 10
            }
            Button {
                text: qsTr("Issues in GitHub")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://github.com/olpeh/wht/issues")
                }
            }
            Button {
                text: qsTr("Project in GitHub")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://github.com/olpeh/wht")
                }
            }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("In case of issues or bugs please check the logs in settings->View logs and consider sending it to the developer.")
            }
            Item {
                width: parent.width
                height: 10
            }
            SectionHeader { text: qsTr("License") }
            Text {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                width: root.width
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
                text: qsTr("Copyright (C) 2015 Olavi Haapala \nThe source code is licensed under BSD 3-clause.")
            }
            Button {
                text: qsTr("Read the license")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    banner.notify(qsTr("Launching external browser"))
                    Qt.openUrlExternally("https://github.com/olpeh/wht/blob/master/LICENSE.md")
                }
            }
            Item {
                width: parent.width
                height: 10
            }
        }
    }
    Banner {
        id: banner
    }
}










