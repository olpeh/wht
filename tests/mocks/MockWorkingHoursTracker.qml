import QtQuick 2.0
import Sailfish.Silica 1.0
import QtTest 1.0
import "../../qml"
import "."

WorkingHoursTracker {
    // Global variables :(
    property bool startFromCommandLine: false;
    property bool stopFromCommandLine: false;
    property string appVersion: "MOCK";
    property string appBuildNum: "0";
    property string documentsLocation: '/home/nemo/Documents'

    // All of these need to be mocked :/
    property MockLogger logger: MockLogger {}
    property MockSettings settings: MockSettings {}
    property MockDatabase db: MockDatabase {}
    property MockWorkTimer timer: MockWorkTimer {}
    property MockBreakTimer breakTimer: MockBreakTimer {}
}
