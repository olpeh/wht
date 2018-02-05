import QtQuick 2.0
import Sailfish.Silica 1.0
import QtTest 1.0
import "../qml"
import "./mocks"

MockWorkingHoursTracker {
    SailfishTestCase {
        name: "Sample tests"
        when: windowShown


        function test_addition() {
            compare(2 + 2, 4);
        }

        function test_startTimer() {
            compare(findElementWithId(firstPage, "timerText").text, "Timer is not running");
            compare(findElementWithId(firstPage, "durationNow").text, "");

            var button = findElementWithId(firstPage, "timerControl");
            clickElement(button);

            compare(findElementWithId(firstPage, "durationNow").text, "0h 0min");
        }

        function cleanup() {
            console.log("Cleanup...")
        }
    }
}
