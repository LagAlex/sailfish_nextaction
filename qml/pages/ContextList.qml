import QtQuick 2.0
import Sailfish.Silica 1.0
import "../localdb.js" as Database


Page {
    id: contextListPage

    SilicaListView {
        id: contextList
        anchors.fill:  parent

        RemorsePopup {
            id: contextListRemorse
        }

        model: ListModel {
            id: contextListModel
        }

        header: PageHeader {
            title: "Contexts"
        }

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("Create context")
                onClicked: {
                    selected_context = -1
                    pageStack.push(Qt.resolvedUrl("ContextEdit.qml"))
                }
            }
        }

        delegate: ListItem {
            id: contextListItem
            width: parent.width
            menu: contextMenu

            // Status switch
            Switch
            {
                id: status_switch
                checked: context_status == 0
                onClicked: {
                    if (checked) {
                        Database.markContextAsInactive(context_id)
                    } else {
                        Database.markContextAsActive(context_id)
                    }
                    reloadContextList()
                }
            }
            // Label with task name
            Label {
                id: contextNameLabel
                width: parent.width - status_switch.width
                x: Theme.paddingLarge
                text: context_name
                anchors.left: status_switch.right
                anchors.verticalCenter: parent.verticalCenter
                color: context_status == 1 ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {
                selected_context = context_id
                pageStack.push(Qt.resolvedUrl("ContextEdit.qml"))
            }
            // Context menu
            ContextMenu {
                id: contextMenu

                MenuItem {
                    text: qsTr("Delete")
                    onClicked: {
                         remorseAction("Deleting", function(){
                            Database.deleteContext(context_id)
                            reloadContextList()
                        }, context_status == 0 ? 5000 : 3000)
                     }
                 }
             }
        }
    }

    function wipeContextList() {
        contextListModel.clear()
    }

    function addContext(context) {
        contextListModel.append({context_name: context.name,
                                context_id: context.id,
                                context_status: context.status})
    }

    function reloadContextList() {
        wipeContextList()
        Database.getContexts(addContext)

    }

    onStatusChanged: {
        if (status == PageStatus.Active)
            reloadContextList()
    }
}
