import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database


Dialog {
    id: actionEditPage
    DialogHeader {
        id: header
        dialog: parent
        acceptText: selected_action === -1 ? "Create" : "Edit"
        cancelText: "Back"
    }

    TextField {
        id: name
        width: parent.width
        anchors.top: header.bottom
        label: "action name"
        placeholderText: "action name"
        textMargin: Theme.paddingMedium
    }

    SilicaListView {
        id: contextsList
        anchors.top: name.bottom
        width: parent.width

        RemorsePopup {
            id: contextsListRemorse
        }

        model: ListModel {
            id: contextListModel
        }

        header: PageHeader {
            title: "Required contexts"
        }

        delegate: ListItem {
            id: contextListItem
            width: parent.width


            Label {
                id: contextNameLabel
                text: context_name
            }



        }
    }

    Button {
        text: qsTr("Edit required contexts")
        onClicked: {

        }
    }

    function fillActionData(action) {
        name.text = action.name
    }

    function addRequiredContext(context) {
        contextListModel.append({context_id: context.id,
                                 context_name: context.name})
    }

    Component.onCompleted: {
        if (selected_action !== -1) {
            Database.getAction(selected_action, fillActionData)
            Database.getRequiredContexts(selected_action, addRequiredContext)
        }
    }

    onAccepted: {
        if (selected_action === -1) {
            Database.createAction(name.text, selected_action_list)
        } else {
            Database.updateAction(selected_action, name.text)
        }
    }
}

