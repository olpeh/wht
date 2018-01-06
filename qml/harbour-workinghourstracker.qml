/*
Copyright (C) 2017 Olavi Haapala.
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
import "date_fns.min.js" as DD

ApplicationWindow {
    property Item firstPage
    property variant dateFns: DD.dateFns
    property variant helpers: HH.helpers
    property variant appState: {
        'versionCheckDone': false,
        'arguments': {
            'startFromCommandLine': startFromCommandLine,
            'stopFromCommandLine': stopFromCommandLine
        },
        'timerRunning': timer.isRunning(),
        'breakTimerRunning': breakTimer.isRunning(),
        'timerDuration': timer.getDurationInMilliseconds(),
        'breakTimerDuration': breakTimer.getDurationInMilliseconds(),
        'data':{
            'projects': db.getProjects(),
            'today': db.getDurationForPeriod("day"),
            'thisWeek': db.getDurationForPeriod("week"),
            'thisMonth': db.getDurationForPeriod("month"),
        }
    }

    id: appWindow
    initialPage: Component {
        FirstPage {
            id: firstPage
            Component.onCompleted: appWindow.firstPage = firstPage
        }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
