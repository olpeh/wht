import QtQuick 2.0
import Sailfish.Silica 1.0
import QtTest 1.0
import "../qml"

WorkingHoursTracker {
    // All of these need to be mocked :/
    // view->rootContext()->setContextProperty("startFromCommandLine", isStartCommand);
    // view->rootContext()->setContextProperty("stopFromCommandLine", isStopCommand);

    // view->rootContext()->setContextProperty("db", &database);
    // view->rootContext()->setContextProperty("timer", timer);
    // view->rootContext()->setContextProperty("breakTimer", breakTimer);
    // view->rootContext()->setContextProperty("settings", &settings);
    // view->rootContext()->setContextProperty("launcher", &launcher);
    // view->rootContext()->setContextProperty("exporter", &exporter);

    // view->rootContext()->setContextProperty("Log", &Logger::instance());
    // view->rootContext()->setContextProperty("documentsLocation", QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));

    TestCase {
        name: "Sample tests"
        when: windowShown

        function test_addition() {
            compare(2 + 2, 4);
        }
    }
}
