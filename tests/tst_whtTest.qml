import QtQuick 2.0
import QtTest 1.0
import Sailfish.Silica 1.0


import "../harbour-workinghourstracker/qml/pages"
import "../harbour-workinghourstracker/qml/helpers.js" as HH
import "../harbour-workinghourstracker/qml/config.js" as DB

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

    id: appWindow
    initialPage: Component {
        FirstPage {
            id: firstPage
            Component.onCompleted: appWindow.firstPage = firstPage
        }
    }
    cover: Qt.resolvedUrl("../harbour-workinghourstracker/qml/cover/CoverPage.qml")


    TestCase {
        name: "WorkingHoursTrackerUITest"

        when: windowShown

        function initTestCase() {
                // Initialize the database
                var Log = console;
                DB.initialize();
        }

        function test_menuAction() {
            console.log("Moi")
            return true
        }

        function test_timerNotRunning() {
            compare(timerRunning, false, "Timer should not be running");
        }

        function test_startTimer() {
            // click simulation via signals works just fine, however
            firstPage._timerControl.clicked(null);
            compare(timerRunning, true, "Timer should have been running");
        }
    }

}


