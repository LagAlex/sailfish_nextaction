import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database

Page {
    id: navigationPage

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge
        PageHeader {
            title: qsTr("Main")
        }
        BackgroundItem {
            Label {
                x: Theme.paddingLarge
                text: qsTr("Actions")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("ActionLists.qml"))
            }
        }
        BackgroundItem {
            Label {
                x: Theme.paddingLarge
                text: qsTr("Contexts")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("ContextList.qml"))
            }
        }

    }

}

