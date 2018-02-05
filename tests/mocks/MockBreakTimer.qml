import QtQuick 2.0

QtObject {
    property var startTime
    property int totalDurationInMilliseconds: 0

    function start(newStartTime) {
        startTime = newStartTime ? newStartTime : new Date()
    }

    function getStartTime() {
        return startTime
    }

    function isRunning() {
        return startTime !== undefined
    }

    function getDurationInMilliseconds() {
        return startTime ? new Date() - startTime : 0
    }

    function getTotalDurationInMilliseconds() {
        return totalDurationInMilliseconds
    }

    function stop() {
        var stopTime = new Date();
        totalDurationInMilliseconds += startTime - stopTime
        startTime = undefined
        console.log("MockBreakTimer was stopped at: " + stopTime + " and totalBreakDuration is now " + totalDurationInMilliseconds + " ms");
    }

    function clear() {
        startTime = undefined
        totalDurationInMilliseconds = 0
    }
}
