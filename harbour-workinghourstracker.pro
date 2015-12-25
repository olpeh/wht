# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-workinghourstracker

CONFIG += sailfishapp

appicons.path = /usr/share/icons/hicolor

appicons.files = appicons/*

INSTALLS += appicons

SOURCES += src/harbour-workinghourstracker.cpp \
    src/SettingsClass.cpp \
    src/Launcher.cpp \
    src/Exporter.cpp \
    src/Logger.cpp

OTHER_FILES += qml/harbour-workinghourstracker.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-workinghourstracker.spec \
    rpm/harbour-workinghourstracker.yaml \
    appicons/86x86/apps/harbour-workinghourstracker.png \
    appicons/108x108/apps/harbour-workinghourstracker.png \
    appicons/128x128/apps/harbour-workinghourstracker.png \
    appicons/256x256/apps/harbour-workinghourstracker.png \
    translations/*.ts \
    harbour-workinghourstracker.desktop \
    qml/pages/About.qml \
    qml/pages/Add.qml \
    qml/config.js \
    qml/pages/All.qml \
    rpm/harbour-workinghourstracker.changes \
    qml/pages/Settings.qml \
    qml/pages/MyTimePicker.qml \
    qml/pages/Projects.qml \
    qml/pages/AddProject.qml \
    qml/pages/CategorySummary.qml \
    qml/pages/ProjectPage.qml \
    qml/helpers.js \
    qml/pages/HowTo.qml \
    qml/pages/Banner.qml \
    qml/pages/LogViewer.qml \
    qml/worker.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-workinghourstracker-fi.ts \
    translations/harbour-workinghourstracker-zh_CN.ts \
    translations/harbour-workinghourstracker-de.ts \
    translations/harbour-workinghourstracker-nl_NL.ts \
    translations/harbour-workinghourstracker-es.ts \
    translations/harbour-workinghourstracker-ca.ts \
    translations/harbour-workinghourstracker-da.ts \
    translations/harbour-workinghourstracker-fr.ts \
    translations/harbour-workinghourstracker-nb_NO.ts \
    translations/harbour-workinghourstracker-pt_BR.ts \
    translations/harbour-workinghourstracker-pt_PT.ts \
    translations/harbour-workinghourstracker-sv.ts

HEADERS += \
    src/SettingsClass.h \
    src/Launcher.h \
    src/Exporter.h \
    src/Logger.h

QT += dbus \
   core sql
