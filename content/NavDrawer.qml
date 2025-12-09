import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import DataModels.SerialDataModels 1.0
import Common 1.0
import Backend 1.0
import "components"

Drawer {
    id: navDrawer
    property var window
    property var settingsPopup

    // Legacy properties for backward compatibility (deprecated - will be removed)
    property alias startButton: dummyButton
    property alias stopButton: dummyButton
    property alias sourceCombo: dummyCombo

    // Dummy components for legacy compatibility
    Button { id: dummyButton; visible: false }
    ComboBox { id: dummyCombo; visible: false }

    // Get appController from App.qml via window reference
    function getAppController() {
        if(window && typeof window.getAppController === "function") {
            return window.getAppController()
        }
        Logger.log_error("NavDrawer: Cannot get appController - window.getAppController not available")
        return null
    }

    width: Math.min((window ? window.width : 800) * 0.4, 360)
    height: window ? window.height : 600
    edge: Qt.LeftEdge
    interactive: true
    modal: true

    // State for connection section collapse
    property bool connectionsExpanded: true

    Component.onCompleted: {
        Logger.log_debug("NavDrawer completed")
        // Load initial connections
        updateConnectionsList()
    }

    onOpened: {
        Logger.log_debug("NavDrawer opened")
        updateConnectionsList()
    }

    onClosed: {
        Logger.log_debug("NavDrawer closed")
    }

    // Connections to Backend signals
    Connections {
        target: Backend

        function onConnections_changed(connections) {
            Logger.log_debug("NavDrawer: Received connections_changed signal")
            updateConnectionsList()
        }

        function onConnection_status_changed(connectionId, status, details) {
            Logger.log_debug("NavDrawer: Connection " + connectionId + " status changed to " + status)
            updateConnectionsList()
        }
    }

    ListModel {
        id: navModel
        ListElement { section: "APPLICATION"; title: "About"; iconName: "info" }
        ListElement { section: "APPLICATION"; title: "Quit"; iconName: "exit" }
    }

    ListModel {
        id: connectionsListModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        anchors.margins: 12

        // Connections Section (Collapsible)
        Rectangle {
            id: connectionsSection
            Layout.fillWidth: true
            Layout.preferredHeight: connectionsExpanded ?
                (connectionsSectionContent.implicitHeight + 16) :
                (connectionsSectionHeader.height + 16)
            radius: 6
            color: "#f4f4f4"
            border.color: "#d0d0d0"
            border.width: 1

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Header with Expand/Collapse button and Add button
                Rectangle {
                    id: connectionsSectionHeader
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Button {
                            id: expandCollapseButton
                            text: connectionsExpanded ? "▼" : "▶"
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 28
                            font.pixelSize: 10

                            onClicked: {
                                connectionsExpanded = !connectionsExpanded
                                Logger.log_debug("NavDrawer: Connections section " +
                                    (connectionsExpanded ? "expanded" : "collapsed"))
                            }

                            background: Rectangle {
                                radius: 4
                                color: expandCollapseButton.pressed ? "#e0e0e0" :
                                       expandCollapseButton.hovered ? "#eeeeee" : "transparent"
                                border.color: "#d0d0d0"
                                border.width: 1
                            }
                        }

                        Label {
                            text: qsTr("Connections") + " (" + connectionsListModel.count + ")"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#444"
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                        }

                        Button {
                            id: addConnectionButton
                            text: "+"
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 28
                            font.pixelSize: 16
                            font.bold: true

                            onClicked: {
                                addConnectionDialog.open()
                            }

                            ToolTip.visible: hovered
                            ToolTip.text: qsTr("Add Connection")
                            ToolTip.delay: 500

                            background: Rectangle {
                                radius: 4
                                color: {
                                    if (addConnectionButton.pressed) return "#1565c0"
                                    if (addConnectionButton.hovered) return "#1976d2"
                                    return "#2196f3"
                                }
                                border.color: "#1565c0"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: addConnectionButton.text
                                font: addConnectionButton.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Connections List (only visible when expanded)
                ColumnLayout {
                    id: connectionsSectionContent
                    Layout.fillWidth: true
                    visible: connectionsExpanded
                    opacity: connectionsExpanded ? 1.0 : 0.0
                    spacing: 6

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(connectionsListView.contentHeight, 300)
                        clip: true

                        ListView {
                            id: connectionsListView
                            model: connectionsListModel
                            spacing: 6
                            interactive: contentHeight > height

                            delegate: ConnectionCard {
                                width: ListView.view.width
                                connectionId: model.id || ""
                                interfaceType: model.type || ""
                                displayName: model.name || ""
                                status: model.status || "disconnected"
                                connectionSettings: model.settings || ({})

                                onStartClicked: function(connId) {
                                    Logger.log_info("NavDrawer: Starting connection: " + connId)
                                    Backend.start_connection(connId)
                                }

                                onStopClicked: function(connId) {
                                    Logger.log_info("NavDrawer: Stopping connection: " + connId)
                                    Backend.stop_connection(connId)
                                }

                                onSettingsClicked: function(connId, ifaceType) {
                                    Logger.log_info("NavDrawer: Opening settings for connection: " + connId)
                                    openSettingsForConnection(connId, ifaceType)
                                }

                                onDeleteClicked: function(connId) {
                                    Logger.log_info("NavDrawer: Deleting connection: " + connId)
                                    Backend.delete_connection(connId)
                                }
                            }
                        }
                    }

                    // Empty State
                    Label {
                        text: qsTr("No connections yet.\nClick '+' to add a new connection.")
                        font.pixelSize: 11
                        color: "#999"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        Layout.bottomMargin: 12
                        visible: connectionsListModel.count === 0
                    }
                }
            }
        }

        // Application Menu
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: "transparent"
            border.color: "#e0e0e0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                ListView {
                    id: navList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 2
                    model: navModel ? navModel : []
                    clip: true

                    section.property: "section"
                    section.delegate: Label {
                        width: ListView.view.width
                        text: section
                        color: "#7a7a7a"
                        font.pixelSize: 11
                        font.bold: true
                        leftPadding: 8
                        topPadding: 8
                        bottomPadding: 4
                        horizontalAlignment: Text.AlignLeft
                    }

                    delegate: Rectangle {
                        id: menuItem
                        width: ListView.view.width
                        height: 40
                        color: {
                            if (ListView.isCurrentItem) return "#3b8cc0"
                            if (menuItemMouseArea.containsMouse) return "#f0f0f0"
                            return "transparent"
                        }
                        border.color: ListView.isCurrentItem ? "#2d6f99" : "transparent"
                        border.width: ListView.isCurrentItem ? 1 : 0
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            anchors.topMargin: 6
                            anchors.bottomMargin: 6
                            spacing: 8

                            Label {
                                text: "\u25A0"
                                visible: iconName !== ""
                                color: ListView.isCurrentItem ? "white" : "#444"
                                font.pixelSize: 12
                            }
                            Label {
                                text: title
                                color: ListView.isCurrentItem ? "white" : "#222"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            id: menuItemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Logger.log_debug("NavDrawer: Menu item clicked: " + title)
                                navList.currentIndex = index

                                // Handle menu actions
                                if (title === "About") {
                                    aboutDialog.open()
                                } else if (title === "Quit") {
                                    if (window) {
                                        window.close()
                                    }
                                }

                                navDrawer.close()
                            }
                        }
                    }
                }
            }
        }

        // Global Settings Button
        Button {
            id: navSettingsButton
            text: qsTr("⚙ Settings")
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            onClicked: {
                Logger.log_info("NavDrawer: Settings button clicked")
                if(settingsPopup) {
                    navDrawer.close()  // Close drawer when opening settings
                    settingsPopup.open()
                } else {
                    Logger.log_error("NavDrawer: settingsPopup is null")
                }
            }

            background: Rectangle {
                radius: 6
                color: {
                    if (navSettingsButton.pressed) return "#1565c0"
                    if (navSettingsButton.hovered) return "#1976d2"
                    return "#2196f3"
                }
                border.color: "#1565c0"
                border.width: 1
            }

            contentItem: Text {
                text: navSettingsButton.text
                font: navSettingsButton.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Add Connection Dialog
    AddConnectionDialog {
        id: addConnectionDialog

        onConnectionCreated: function(connectionId) {
            Logger.log_info("NavDrawer: New connection created: " + connectionId)
            updateConnectionsList()
        }
    }

    // Connection Settings Dialog (dynamically created)
    property var connectionSettingsDialog: null

    // About Dialog
    Dialog {
        id: aboutDialog
        title: qsTr("About Plotter")
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Ok

        width: 400
        height: 300

        background: Rectangle {
            color: "#2d2d2d"
            border.color: "#4d4d4d"
            border.width: 1
            radius: 8
        }

        contentItem: ColumnLayout {
            spacing: 16
            anchors.fill: parent
            anchors.margins: 20

            Label {
                text: qsTr("Plotter Application")
                font.pixelSize: 24
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Version 1.0")
                font.pixelSize: 14
                color: "#cccccc"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#4d4d4d"
            }

            Label {
                text: qsTr("A multi-interface data plotting application supporting Serial, Telnet, MQTT, and Test interfaces.")
                font.pixelSize: 12
                color: "#aaaaaa"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillHeight: true
            }

            Label {
                text: qsTr("© 2025 Plotter Project")
                font.pixelSize: 10
                color: "#888888"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Helper Functions
    function updateConnectionsList() {
        Logger.log_debug("NavDrawer: Updating connections list")

        var connections = Backend.get_connections()
        Logger.log_debug("NavDrawer: Got " + connections.length + " connections from backend")

        connectionsListModel.clear()

        for (var i = 0; i < connections.length; i++) {
            var conn = connections[i]
            connectionsListModel.append({
                id: conn.id,
                type: conn.type,
                name: conn.name,
                status: conn.status,
                settings: conn.settings
            })
        }

        Logger.log_debug("NavDrawer: Connections list updated with " + connectionsListModel.count + " items")
    }

    function openSettingsForConnection(connectionId, interfaceType) {
        Logger.log_debug("NavDrawer: Opening settings for connection " + connectionId + " (" + interfaceType + ")")

        // Get connection details
        var details = Backend.get_connection_details(connectionId)
        if (!details || !details.name) {
            Logger.log_error("NavDrawer: Could not get connection details for " + connectionId)
            return
        }

        // Create dialog if not exists, or destroy and recreate for fresh state
        if (connectionSettingsDialog !== null) {
            connectionSettingsDialog.destroy()
            connectionSettingsDialog = null
        }

        // Create dialog dynamically
        var component = Qt.createComponent("components/ConnectionSettingsDialog.qml")

        // Component.Ready = 1, Component.Error = 3
        if (component.status === 1) {
            connectionSettingsDialog = component.createObject(navDrawer, {
                "connectionId": connectionId,
                "interfaceType": interfaceType,
                "connectionName": details.name
            })

            if (connectionSettingsDialog !== null) {
                Logger.log_debug("NavDrawer: ConnectionSettingsDialog created successfully")
                navDrawer.close()
                connectionSettingsDialog.open()
            } else {
                Logger.log_error("NavDrawer: Failed to create ConnectionSettingsDialog instance")
            }
        } else if (component.status === 3) {
            Logger.log_error("NavDrawer: Error loading ConnectionSettingsDialog: " + component.errorString())
        } else {
            Logger.log_warning("NavDrawer: Component not ready yet, status: " + component.status)
        }
    }
}
