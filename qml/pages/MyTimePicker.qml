/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: timePickerDialog
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    canAccept: validateCanAccept()
    property int hourMode
    property string timeText: timePicker._formatTime()

    property variant momentObj: moment()
    property int durationInMilliseconds: -1

    function validateCanAccept () {
        if (durationInMilliseconds !== -1) {
            return helpers.momentAsMillisecons(momentObj) < durationInMilliseconds
        }
        return true
    }

    Column {
        spacing: 10
        anchors.fill: parent

        DialogHeader {
            acceptText: timePicker.timeText
        }
        TimePicker {
            id: timePicker
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item {
            width: parent.width
            height: 40 * Theme.pixelRatio
        }
        Text {
            id: warningText
            visible: !canAccept
            font.pointSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            wrapMode: Text.WordWrap
            width: root.width
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            text: qsTr("Break can not be longer than the duration!")
        }
    }

    onOpened: {
        timePicker.hour = momentObj.hours()
        timePicker.minute = momentObj.minutes()
        timePicker.hourMode = hourMode
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            momentObj = moment(timePicker.time)
        }
    }
}
