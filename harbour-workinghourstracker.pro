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

SOURCES += src/harbour-workinghourstracker.cpp \
    src/settings.cpp

OTHER_FILES += qml/harbour-workinghourstracker.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-workinghourstracker.spec \
    rpm/harbour-workinghourstracker.yaml \
    translations/*.ts \
    harbour-workinghourstracker.desktop \
    qml/pages/About.qml \
    qml/pages/Add.qml \
    qml/config.js \
    qml/pages/All.qml \
    qml/pages/Timer.qml \
    rpm/harbour-workinghourstracker.changes \
    qml/pages/Settings.qml \
    qml/pages/MyTimePicker.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-workinghourstracker-de.ts

HEADERS += \
    src/settings.h

