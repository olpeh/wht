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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QSettings>
#include <QQuickWindow>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QDebug>
#include <QFileInfo>
#include <QStandardPaths>
#include <QCommandLineParser>

#include "Logger.h"
#include "Database.h"
#include "SettingsClass.h"
#include "Launcher.h"
#include "Exporter.h"

int main(int argc, char *argv[])
{
    // Make sure the logger is initialized
    Logger::instance();

    Database database;
    Settings settings;
    Launcher launcher;
    Exporter exporter;

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-workinghourstracker");
    QCoreApplication::setApplicationName("harbour-workinghourstracker");

    QQuickWindow::setDefaultAlphaBuffer(true);
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    view->rootContext()->setContextProperty("appVersion", APP_VERSION);
    view->rootContext()->setContextProperty("appBuildNum", APP_BUILDNUM);
    qDebug() << "Version:" << APP_VERSION << "-" << APP_BUILDNUM << QDateTime::currentDateTime().toString();

    QCommandLineParser parser;

    // Starting the timer (--start)
    QCommandLineOption startTimerOption("start", QCoreApplication::translate("main", "Start the timer"));
    parser.addOption(startTimerOption);

    // Stopping the timer (--stop)
    QCommandLineOption stopTimerOption("stop", QCoreApplication::translate("main", "Stop the timer"));
    parser.addOption(stopTimerOption);

    // An option select the project with (-p [projectId])
    // Only useful when stopping the timer
    QCommandLineOption selectProjectOption(QStringList() << "p" << "project",
            QCoreApplication::translate("main", "Select project by id."),
            QCoreApplication::translate("main", "project"));
    parser.addOption(selectProjectOption);

    // An option select the task with (-t [taskId])
    // Only useful when stopping the timer
    QCommandLineOption selectTaskOption(QStringList() << "t" << "task",
            QCoreApplication::translate("main", "Select task by id."),
            QCoreApplication::translate("main", "task"));
    parser.addOption(selectTaskOption);

    // An option to set the description (-d [description])
    // Only useful when stopping the timer
    QCommandLineOption setDescriptionOption(QStringList() << "d" << "description",
            QCoreApplication::translate("main", "Set description"),
            QCoreApplication::translate("main", "description"));
    parser.addOption(setDescriptionOption);

    // Process the actual command line arguments given by the user
    parser.process(*app);
    bool isStartCommand = parser.isSet(startTimerOption);
    bool isStopCommand = parser.isSet(stopTimerOption);
    QString selectedProject = parser.value(selectProjectOption);
    QString selectedTask = parser.value(selectTaskOption);
    QString setDescription = parser.value(setDescriptionOption);
    qDebug() << isStartCommand;
    qDebug() << isStopCommand;
    qDebug() << selectedProject;
    qDebug() << selectedTask;
    qDebug() << setDescription;

    view->rootContext()->setContextProperty("startFromCommandLine", isStartCommand);
    view->rootContext()->setContextProperty("stopFromCommandLine", isStopCommand);

    view->rootContext()->setContextProperty("db", &database);
    view->rootContext()->setContextProperty("settings", &settings);
    view->rootContext()->setContextProperty("launcher", &launcher);
    view->rootContext()->setContextProperty("exporter", &exporter);

    view->rootContext()->setContextProperty("Log", &Logger::instance());
    view->rootContext()->setContextProperty("documentsLocation",QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));

    view->setSource(SailfishApp::pathTo("qml/harbour-workinghourstracker.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);

    view->show();
    return app->exec();
}
