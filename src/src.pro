TEMPLATE=app

TARGET = harbour-workinghourstracker

CONFIG += sailfishapp

appicons.path = /usr/share/icons/hicolor
appicons.files = appicons/*

INSTALLS += appicons

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += APP_BUILDNUM=\\\"$$RELEASE\\\"

SOURCES += harbour-workinghourstracker.cpp \
    SettingsClass.cpp \
    Launcher.cpp \
    Exporter.cpp \
    Logger.cpp

OTHER_FILES = qml/*.qml \
              qml/cover/*.qml \
              qml/pages/*.qml \
              pages/components/*.qml \
              qml/*.js \
              harbour-workinghourstracker.desktop \
              ../rpm/harbour-workinghourstracker.changes \
              ../rpm/harbour-workinghourstracker.spec \
              ../rpm/harbour-workinghourstracker.yaml \
              appicons/86x86/apps/harbour-workinghourstracker.png \
              appicons/108x108/apps/harbour-workinghourstracker.png \
              appicons/128x128/apps/harbour-workinghourstracker.png \
              appicons/256x256/apps/harbour-workinghourstracker.png

CONFIG += sailfishapp_i18n
TRANSLATIONS += ../translations/harbour-workinghourstracker-fi.ts \
    ../translations/harbour-workinghourstracker-zh_CN.ts \
    ../translations/harbour-workinghourstracker-de.ts \
    ../translations/harbour-workinghourstracker-nl_NL.ts \
    ../translations/harbour-workinghourstracker-es.ts \
    ../translations/harbour-workinghourstracker-ca.ts \
    ../translations/harbour-workinghourstracker-da.ts \
    ../translations/harbour-workinghourstracker-fr.ts \
    ../translations/harbour-workinghourstracker-nb_NO.ts \
    ../translations/harbour-workinghourstracker-pt_BR.ts \
    ../translations/harbour-workinghourstracker-pt_PT.ts \
    ../translations/harbour-workinghourstracker-sv.ts

HEADERS += \
    SettingsClass.h \
    Launcher.h \
    Exporter.h \
    Logger.h

QT += dbus \
   core sql

INCLUDEPATH += $$PWD

