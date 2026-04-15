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
TARGET = harbour-tarkka

QT += multimedia

images.files = images/*.png
images.path = $$PREFIX/share/$$TARGET/images

CONFIG += sailfishapp

HEADERS += \
    src/cameraconfigs.h

SOURCES += \
    src/cameraconfigs.cpp \
    src/harbour-tarkka.cpp

DISTFILES += qml/harbour-tarkka.qml \
    qml/components/CameraControls.qml \
    qml/components/CameraView.qml \
    qml/components/Label.qml \
    qml/components/MenuUI.qml \
    qml/components/OverlayButton.qml \
    qml/components/UIButton.qml \
    qml/cover/CoverPage.qml \
    qml/components/*.qml \
    qml/pages/*.qml \
    rpm/harbour-tarkka.changes \
    rpm/harbour-tarkka.spec \
    translations/*.ts \
    harbour-tarkka.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

INSTALLS += images
TRANSLATIONS += translations/*.ts
