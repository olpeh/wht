
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
#include "SettingsClass.h"
#include "Launcher.h"
#include "Exporter.h"


int main(int argc, char *argv[])
{
    Settings settings;
    Launcher launcher;
    Exporter exporter;
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-workinghourstracker");
    QQuickWindow::setDefaultAlphaBuffer(true);
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("settings", &settings);
    view->rootContext()->setContextProperty("launcher", &launcher);
    view->rootContext()->setContextProperty("exporter", &exporter);
    view->setSource(SailfishApp::pathTo("qml/harbour-workinghourstracker.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();
    return app->exec();
}
