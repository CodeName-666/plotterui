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
    property alias startButton: controlsCard.startButton
    property alias stopButton: controlsCard.stopButton
    property alias sourceCombo: controlsCard.sourceCombo

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

    Component.onCompleted: {
        Logger.log_debug("NavDrawer completed")
    }

    onOpened: {
        Logger.log_debug("NavDrawer opened")
    }

    onClosed: {
        Logger.log_debug("NavDrawer closed")
    }

    ListModel {
        id: navModel
        ListElement { section: "APPLICATION"; title: "About"; iconName: "info" }
        ListElement { section: "APPLICATION"; title: "Quit"; iconName: "exit" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        anchors.margins: 12

        ControlsCard {
            id: controlsCard
            Layout.fillWidth: true
            appController: navDrawer.getAppController()
            onInterfaceChanged: function(iface) {
                Logger.log_debug("NavDrawer: Interface changed to: " + iface)
                var controller = navDrawer.getAppController()
                if(controller)
                {
                    controller.current_interface = iface
                    Logger.log_info("NavDrawer: Set current_interface to: " + iface)
                }
                else
                {
                    Logger.log_warning("NavDrawer: Cannot set interface - appController is null")
                }
            }
        }

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

        Button {
            id: navSettingsButton
            text: qsTr("Settings")
            Layout.fillWidth: true
            onClicked: {
                Logger.log_info("NavDrawer: Settings button clicked")
                if(settingsPopup)
                {
                    settingsPopup.open()
                }
                else
                {
                    Logger.log_error("NavDrawer: settingsPopup is null")
                }
            }
        }
    }

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
}
