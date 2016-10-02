import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database

Dialog {
    id: actionListEditPage
    DialogHeader {
        id: header
        dialog: parent
        acceptText: qsTr("Edit")
        cancelText: qsTr("Cancel")
    }

    TextField {
        id: name
        width: parent.width
        anchors.top: header.bottom
        label: qsTr("list name")
        placeholderText: qsTr("list name")
        textMargin: Theme.paddingMedium
    }

    function fillActionListData(action_list) {
        name.text = action_list.name
    }

    Component.onCompleted: {
        Database.getActionList(active_action_list, fillActionListData)
    }

    onAccepted: {
        Database.updateActionList(active_action_list, name.text)
    }
}
