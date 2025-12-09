import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import Backend 1.0

Rectangle {
    id: connectionCard

    // Properties
    property string connectionId: ""
    property string interfaceType: ""
    property string displayName: ""
    property string status: "disconnected"  // disconnected, connecting, connected
    property var connectionSettings: ({})

    // Signals
    signal startClicked(string connectionId)
    signal stopClicked(string connectionId)
    signal settingsClicked(string connectionId, string interfaceType)
    signal deleteClicked(string connectionId)

    // Styling
    radius: 6
    color: mouseArea.containsMouse ? "#fafafa" : "#f4f4f4"
    border.color: status === "connected" ? "#4caf50" : "#d0d0d0"
    border.width: status === "connected" ? 2 : 1

    implicitHeight: contentLayout.implicitHeight + 16
    implicitWidth: parent ? parent.width : 300

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: {
            // Allow clicks to propagate to buttons
            mouse.accepted = false
        }
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Status Indicator
        Rectangle {
            id: statusIndicator
            Layout.alignment: Qt.AlignVCenter
            width: 12
            height: 12
            radius: 6
            color: {
                switch(status) {
                    case "connected": return "#4caf50"  // Green
                    case "connecting": return "#ff9800" // Orange
                    case "disconnected":
                    default: return "#bdbdbd"           // Gray
                }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            // Pulsing animation for connecting state
            SequentialAnimation on opacity {
                running: status === "connecting"
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 600 }
                NumberAnimation { to: 1.0; duration: 600 }
            }
        }

        // Connection Info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Label {
                id: nameLabel
                text: displayName
                font.bold: true
                font.pixelSize: 13
                color: "#222"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                id: typeLabel
                text: interfaceType
                font.pixelSize: 10
                color: "#666"
                visible: interfaceType !== ""
            }
        }

        // Action Buttons
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            // Start/Stop Button
            Button {
                id: actionButton
                text: {
                    switch(status) {
                        case "connected": return qsTr("Stop")
                        case "connecting": return qsTr("...")
                        case "disconnected":
                        default: return qsTr("Start")
                    }
                }
                enabled: status !== "connecting"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 28

                onClicked: {
                    if (status === "connected") {
                        stopClicked(connectionId)
                    } else {
                        startClicked(connectionId)
                    }
                }

                background: Rectangle {
                    radius: 4
                    color: {
                        if (!actionButton.enabled) return "#e0e0e0"
                        if (actionButton.pressed) return status === "connected" ? "#d32f2f" : "#1976d2"
                        if (actionButton.hovered) return status === "connected" ? "#e53935" : "#2196f3"
                        return status === "connected" ? "#f44336" : "#2196f3"
                    }
                    border.color: {
                        if (!actionButton.enabled) return "#bdbdbd"
                        return status === "connected" ? "#c62828" : "#1565c0"
                    }
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }

                contentItem: Text {
                    text: actionButton.text
                    font: actionButton.font
                    color: actionButton.enabled ? "white" : "#999"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Settings Button
            Button {
                id: settingsButton
                text: "⚙"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 28
                font.pixelSize: 14

                onClicked: {
                    settingsClicked(connectionId, interfaceType)
                }

                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
                ToolTip.delay: 500
            }

            // Delete Button (only visible when disconnected)
            Button {
                id: deleteButton
                text: "🗑"
                visible: status === "disconnected"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 28
                font.pixelSize: 14

                onClicked: {
                    deleteConfirmDialog.open()
                }

                ToolTip.visible: hovered
                ToolTip.text: qsTr("Delete")
                ToolTip.delay: 500

                background: Rectangle {
                    radius: 4
                    color: {
                        if (deleteButton.pressed) return "#c62828"
                        if (deleteButton.hovered) return "#e53935"
                        return "transparent"
                    }
                    border.color: deleteButton.hovered ? "#c62828" : "#d0d0d0"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    Dialog {
        id: deleteConfirmDialog
        title: qsTr("Delete Connection")
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        width: 300
        height: 150

        contentItem: ColumnLayout {
            spacing: 12
            anchors.fill: parent
            anchors.margins: 16

            Label {
                text: qsTr("Are you sure you want to delete this connection?")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                text: displayName
                font.bold: true
                color: "#f44336"
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }
        }

        onAccepted: {
            deleteClicked(connectionId)
        }
    }

    Component.onCompleted: {
        Logger.log_debug("ConnectionCard created: " + connectionId + " (" + displayName + ")")
    }
}
