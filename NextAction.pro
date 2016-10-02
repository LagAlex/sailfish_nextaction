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
TARGET = NextAction

CONFIG += sailfishapp

SOURCES += src/NextAction.cpp

OTHER_FILES += qml/NextAction.qml \
    qml/cover/CoverPage.qml \
    rpm/NextAction.changes.in \
    rpm/NextAction.spec \
    rpm/NextAction.yaml \
    translations/*.ts \
    NextAction.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/NextAction-de.ts

HEADERS +=

DISTFILES += \
    qml/pages/ActionList.qml \
    qml/pages/ActionEdit.qml \
    qml/localdb.js \
    qml/pages/ContextList.qml \
    qml/pages/ContextEdit.qml \
    qml/pages/Navigation.qml \
    qml/pages/ActionLists.qml \
    qml/pages/ActionListsEdit.qml

