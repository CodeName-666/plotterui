import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import DataModels.SerialDataModels 1.0
import Common 1.0
import Backend 1.0
import "components"
import "ChartWindow/ConnectionManager"

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
    property bool testSectionExpanded: true

    // Connection Manager Dialog (unified, shared component)
    ConnectionManagerDialog {
        id: connectionManagerDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
    }

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
        ListElement { section: "TEST"; title: "Test 2D"; iconName: "test2d" }
        ListElement { section: "TEST"; title: "Test 2D X/Y"; iconName: "testxy" }
        ListElement { section: "TEST"; title: "Test XY"; iconName: "testxy" }
        ListElement { section: "TEST"; title: "Test 3D"; iconName: "test3d" }
        ListElement { section: "APPLICATION"; title: "About"; iconName: "info" }
        ListElement { section: "APPLICATION"; title: "Quit"; iconName: "exit" }
    }

    ListModel {
        id: connectionsListModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
        spacing: 12

        // Connections Section (Collapsible)
        Rectangle {
            id: connectionsSection
            Layout.fillWidth: true
            Layout.preferredHeight: connectionsExpanded ?
                (connectionsSectionContent.implicitHeight + connectionsSectionHeader.height + 24) :
                (connectionsSectionHeader.height + 16)
            Layout.minimumHeight: connectionsSectionHeader.height + 16
            radius: 8
            color: "#f8f8f8"
            border.color: "#d0d0d0"
            border.width: 1

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.bottomMargin: 8
                spacing: 12

                // Header with Expand/Collapse button and Add button
                RowLayout {
                    id: connectionsSectionHeader
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 10

                    Button {
                        id: expandCollapseButton
                        text: connectionsExpanded ? "▼" : "▶"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 32
                        font.pixelSize: 11

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
                        id: manageConnectionsButton
                        text: "⚙"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 32
                        font.pixelSize: 16
                        font.bold: true

                        onClicked: {
                            connectionManagerDialog.open()
                        }

                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Manage Connections")
                        ToolTip.delay: 500

                        background: Rectangle {
                            radius: 4
                            color: {
                                if (manageConnectionsButton.pressed) return "#1565c0"
                                if (manageConnectionsButton.hovered) return "#1976d2"
                                return "#2196f3"
                            }
                            border.color: "#1565c0"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: manageConnectionsButton.text
                            font: manageConnectionsButton.font
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: addConnectionButton
                        text: "+"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 32
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

        // TEST Section (Collapsible)
        Rectangle {
            id: testSection
            Layout.fillWidth: true
            Layout.preferredHeight: testSectionExpanded ?
                (testSectionContent.implicitHeight + testSectionHeader.height + 24) :
                (testSectionHeader.height + 16)
            Layout.minimumHeight: testSectionHeader.height + 16
            radius: 8
            color: "#f8f8f8"
            border.color: "#d0d0d0"
            border.width: 1

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.bottomMargin: 8
                spacing: 12

                // Header with Expand/Collapse button
                RowLayout {
                    id: testSectionHeader
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 10

                    Button {
                        id: testExpandCollapseButton
                        text: testSectionExpanded ? "▼" : "▶"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 32
                        font.pixelSize: 11

                        onClicked: {
                            testSectionExpanded = !testSectionExpanded
                            Logger.log_debug("NavDrawer: Test section " +
                                (testSectionExpanded ? "expanded" : "collapsed"))
                        }

                        background: Rectangle {
                            radius: 4
                            color: testExpandCollapseButton.pressed ? "#e0e0e0" :
                                   testExpandCollapseButton.hovered ? "#eeeeee" : "transparent"
                            border.color: "#d0d0d0"
                            border.width: 1
                        }
                    }

                    Label {
                        text: qsTr("TEST")
                        font.bold: true
                        font.pixelSize: 14
                        color: "#444"
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Test Items (only visible when expanded)
                ColumnLayout {
                    id: testSectionContent
                    Layout.fillWidth: true
                    visible: testSectionExpanded
                    opacity: testSectionExpanded ? 1.0 : 0.0
                    spacing: 6

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    ListView {
                        id: testList
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                        spacing: 4
                        model: navModel ? navModel : []
                        clip: true
                        interactive: false

                        delegate: Rectangle {
                            id: testMenuItem
                            width: ListView.view.width
                            height: section === "TEST" ? 44 : 0
                            visible: section === "TEST"
                            color: {
                                if (ListView.isCurrentItem) return "#2196f3"
                                if (testMenuItemMouseArea.containsMouse) return "#e3f2fd"
                                return "transparent"
                            }
                            border.color: ListView.isCurrentItem ? "#1976d2" : "transparent"
                            border.width: ListView.isCurrentItem ? 1 : 0
                            radius: 6

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8
                                spacing: 12

                                Label {
                                    text: "\u25A0"
                                    visible: iconName !== ""
                                    color: ListView.isCurrentItem ? "white" : "#555"
                                    font.pixelSize: 14
                                }
                                Label {
                                    text: title
                                    color: ListView.isCurrentItem ? "white" : "#222"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: testMenuItemMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Logger.log_debug("NavDrawer: Test menu item clicked: " + title)
                                    testList.currentIndex = index

                                    // Handle test actions
                                    if (title === "Test 2D") {
                                        testFloatingWindow2D()
                                    } else if (title === "Test 2D X/Y") {
                                        testFloatingWindow2DXY()
                                    } else if (title === "Test XY") {
                                        testFloatingWindowXY()
                                    } else if (title === "Test 3D") {
                                        testFloatingWindow3D()
                                    }

                                    navDrawer.close()
                                }
                            }
                        }
                    }
                }
            }
        }

        // Spacer to push APPLICATION section to bottom
        Item {
            Layout.fillHeight: true
        }

        // APPLICATION Section (About & Quit at bottom)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            // APPLICATION Section Container
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: applicationSectionContent.implicitHeight + 24
                radius: 8
                color: "#f8f8f8"
                border.color: "#d0d0d0"
                border.width: 1

                ColumnLayout {
                    id: applicationSectionContent
                    anchors.fill: parent
                    anchors.topMargin: 12
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.bottomMargin: 12
                    spacing: 8

                    // APPLICATION Section Header
                    Label {
                        text: qsTr("APPLICATION")
                        color: "#7a7a7a"
                        font.pixelSize: 11
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4
                    }

                    ListView {
                        id: applicationList
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                        spacing: 4
                        model: navModel ? navModel : []
                        clip: true
                        interactive: false

                        delegate: Rectangle {
                            id: menuItem
                            width: ListView.view.width
                            height: section === "APPLICATION" ? 44 : 0
                            visible: section === "APPLICATION"
                        color: {
                            if (ListView.isCurrentItem) return "#2196f3"
                            if (menuItemMouseArea.containsMouse) return "#e3f2fd"
                            return "transparent"
                        }
                        border.color: ListView.isCurrentItem ? "#1976d2" : "transparent"
                        border.width: ListView.isCurrentItem ? 1 : 0
                        radius: 6

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            spacing: 12

                            Label {
                                text: "\u25A0"
                                visible: iconName !== ""
                                color: ListView.isCurrentItem ? "white" : "#555"
                                font.pixelSize: 14
                            }
                            Label {
                                text: title
                                color: ListView.isCurrentItem ? "white" : "#222"
                                font.pixelSize: 14
                                font.weight: Font.Medium
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
                                applicationList.currentIndex = index

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
        }

        // Global Settings Button
        Button {
            id: navSettingsButton
            text: qsTr("⚙ Settings")
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.topMargin: 4

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
                radius: 8
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
                font.pixelSize: 14
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Add Connection Dialog
    AddConnectionDialog {
        id: addConnectionDialog
        parent: Overlay.overlay
        anchors.centerIn: parent

        onConnectionCreated: function(connectionId) {
            Logger.log_info("NavDrawer: New connection created: " + connectionId)
            updateConnectionsList()
        }
    }

    // About Dialog
    Dialog {
        id: aboutDialog
        parent: Overlay.overlay
        anchors.centerIn: parent

        title: qsTr("About Plotter")
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
        Logger.log_debug("NavDrawer: Opening settings via unified ConnectionManagerDialog for connection " + connectionId)
        navDrawer.close()
        connectionManagerDialog.openAndEditConnection(connectionId)
    }

    function testFloatingWindow2D() {
        Logger.log_info("NavDrawer: Triggering Test 2D floating window")

        // Try to find ChartWindow to call its test function
        if (window && window.chartWindow && window.chartWindow.testFloatingWindow) {
            window.chartWindow.testFloatingWindow()
        } else {
            Logger.log_error("NavDrawer: Cannot find chartWindow.testFloatingWindow function")
        }
    }

    function testFloatingWindow3D() {
        Logger.log_info("NavDrawer: Triggering Test 3D floating window")

        // Try to find ChartWindow to call its test function
        if (window && window.chartWindow && window.chartWindow.test3DFloatingWindow) {
            window.chartWindow.test3DFloatingWindow()
        } else {
            Logger.log_error("NavDrawer: Cannot find chartWindow.test3DFloatingWindow function")
        }
    }

    function testFloatingWindow2DXY() {
        Logger.log_info("NavDrawer: Triggering Test 2D X/Y floating window")

        // Try to find ChartWindow to call its test function
        if (window && window.chartWindow && window.chartWindow.testFloatingWindowXYMulti) {
            window.chartWindow.testFloatingWindowXYMulti()
        } else {
            Logger.log_error("NavDrawer: Cannot find chartWindow.testFloatingWindowXYMulti function")
        }
    }

    function testFloatingWindowXY() {
        Logger.log_info("NavDrawer: Triggering Test XY floating window")

        // Try to find ChartWindow to call its test function
        if (window && window.chartWindow && window.chartWindow.testFloatingWindowXY) {
            window.chartWindow.testFloatingWindowXY()
        } else {
            Logger.log_error("NavDrawer: Cannot find chartWindow.testFloatingWindowXY function")
        }
    }
}
