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
import "pages"
import "helpers.js" as HH

ApplicationWindow
{
    property bool timerRunning : false
    property bool breakTimerRunning: false
    property string startTime: ""
    property string durationNow: "0h 0min"
    property double duration: 0
    property string breakStartTime: ""
    property string breakDurationNow: "0h 0min"
    property double breakDuration: 0
    property string thisWeek: "0"
    property string thisMonth: "0"
    property string today: "0"
    property Item firstPage
    property string defaultProjectId: ""
    property variant projects: []
    property string currencyString: "€"
    readonly property string _APP_VERSION: appVersion
    readonly property string _APP_BUILD_NUMBER: appBuildNum


    id: appWindow
    initialPage: Component {
        FirstPage {
            id: firstPage
            version: _APP_VERSION
            buildNum: _APP_BUILD_NUMBER
            Component.onCompleted: appWindow.firstPage = firstPage
        }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
