import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database

Page {
    id: actionListListPage

    SilicaListView {
        id: actionListList
        anchors.fill: parent

        header: Column {
            width: parent.width
            id: actionListListHeaderColumn

            PageHeader {
                title: "Action lists"
            }

            TextField {
                id: newActionListTextField
                width: parent.width
                placeholderText: qsTr("New list")
                label: qsTr("New list")
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: {
                    Database.createActionList(text)
                    text = ''
                    reloadActionListList()
                }
            }
        }

        RemorsePopup {
            id: actionListListRemorse
        }

        model: ListModel {
            id: actionListListModel
        }

        delegate: ListItem {
            id: actionListListItem
            width: parent.width
            menu: actionMenu

            Label {
                id: actionListListNameLabel
                width: parent.width
                x: Theme.paddingLarge
                text: action_list_name
                color: Theme.highlightColor
            }
            onClicked: {
                selected_action_list = action_list_id
                pageStack.push(Qt.resolvedUrl("ActionList.qml"))
            }

            ContextMenu {
                id: actionMenu

                MenuItem {
                    text: qsTr("Delete")
                    onClicked: {
                        remorseAction("Deleting", function(){
                            Database.deleteActionList(action_list_id)
                            reloadActionListList()
                        }, 6000)
                    }
                }

                MenuItem {
                    text: qsTr("Edit")
                    onClicked: {
                        selected_action_list = action_list_id
                        pageStack.push(Qt.resolvedUrl("ActionListsEdit.qml"))
                    }
                }
            }
        }
    }

    function wipeActionListList() {
        actionListListModel.clear()
    }

    function addActionList(action_list) {
        actionListListModel.append({action_list_id: action_list.id,
                                    action_list_name: action_list.name})
    }

    function reloadActionListList() {
        wipeActionListList()
        Database.getActionLists(addActionList)
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            reloadActionListList()
        }
    }
}
