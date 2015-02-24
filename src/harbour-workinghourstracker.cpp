
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

int main(int argc, char *argv[])
{
    Settings settings;
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationName("harbour-workinghourstracker");
    QQuickWindow::setDefaultAlphaBuffer(true);
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->rootContext()->setContextProperty("settings", &settings);
    view->setSource(SailfishApp::pathTo("qml/harbour-workinghourstracker.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();
    return app->exec();
}
