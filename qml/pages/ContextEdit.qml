import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database


Dialog {
    id: contextEditPage
    DialogHeader {
        id: header
        dialog: parent
        acceptText: selected_context === -1 ? "Create" : "Edit"
        cancelText: "Back"
    }

    TextField {
        id: name
        width: parent.width
        anchors.top: header.bottom
        label: "context name"
        placeholderText: "context name"
        textMargin: Theme.paddingMedium
    }

    function fillContextData(context) {
        name.text = context.name
    }

    Component.onCompleted: {
        if (selected_context !== -1) {
            Database.getContext(selected_context, fillContextData)
        }
    }

    onAccepted: {
        if (selected_context == -1) {
            Database.createContext(name.text)
        } else {
            Database.updateContext(selected_context, name.text)
        }
    }
}

