import QtQuick 2.0

QtObject {
    property var startTime

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

    function getActualDurationInMilliseconds(breakTimer) {
        return getDurationInMilliseconds() - breakTimer.getTotalDurationInMilliseconds()
    }

    function stop() {
        startTime = undefined
        console.log("MockTimer was stopped at: " + new Date());
    }
}
