import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database


Page {
    id: actionListPage

    SilicaListView {
        id: actionList
        anchors.fill: parent

        header: Column {
            width: parent.width
            id: actionListHeaderColumn

            PageHeader {
                title: "Next action"
            }

            TextField {
                id: newActionTextField
                width: parent.width
                placeholderText: qsTr("New action")
                label: qsTr("New action")
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: {
                    Database.createAction(text, selected_action_list)
                    text = ''
                    reloadActionList()
                }
            }
        }

        RemorsePopup {
            id: actionListRemorse
        }

        model: ListModel {
            id: actionListModel
        }



        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Clear completed")
                onClicked: {
                    actionListRemorse.execute("Clearing completed", function(){
                        Database.deleteCompletedActions(selected_action_list)
                        reloadActionList()
                    });
                }
            }

            MenuItem {
                text: contexts_enabled ? qsTr("Disable contexts") : qsTr("Enable contexts")
                onClicked: {
                    if (contexts_enabled) {
                        contexts_enabled = false
                        Database.setSetting('contexts_enabled', '0')
                    }
                    else {
                        contexts_enabled = true
                        Database.setSetting('contexts_enabled', '1')
                    }
                    reloadActionList()
                }
            }
        }

        delegate: ListItem {
            id: actionListItem
            width: parent.width
            menu: actionMenu

            // Status switch
            Switch
            {
                id: status_switch
                checked: action_status == 0
                onClicked: {
                    if (checked) {
                        Database.markActionAsNotDone(action_id)
                    } else {
                        Database.markActionAsDone(action_id)
                    }
                    reloadActionList()
                }
            }
            // Label with task name
            Label {
                id: actionNameLabel
                width: parent.width - status_switch.width
                x: Theme.paddingLarge
                text: action_name
                font.strikeout: action_status == 1
                anchors.left: status_switch.right
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.highlightColor
            }
            onClicked: {
                selected_action = action_id
                pageStack.push(Qt.resolvedUrl("ActionEdit.qml"))
            }
            // Context menu
            ContextMenu {
                id: actionMenu

                MenuItem {
                    text: qsTr("Delete")
                    onClicked: {
                        remorseAction("Deleting", function(){
                            Database.deleteAction(action_id)
                            reloadActionList()
                        }, action_status == 0 ? 5000 : 3000)
                    }
                }
            }
        }
    }

    function wipeActionList() {
        actionListModel.clear()
    }

    function addAction(action) {
        actionListModel.append({action_name: action.name,
                                action_id: action.id,
                                action_status: action.status})
    }

    function reloadActionList() {
        wipeActionList()
        if (contexts_enabled) {
            Database.getActions(addAction, selected_action_list, true)
        }
        else {
            Database.getActions(addAction, selected_action_list, false)
        }
    }
    onStatusChanged: {
        if (status == PageStatus.Active)
            reloadActionList()
    }
}
