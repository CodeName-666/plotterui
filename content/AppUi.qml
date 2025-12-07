import QtQuick 6.4
import QtQuick.Window 2.15
import QtQuick.Controls 6.4
import QtQuick.Timeline 1.0
import QtCharts 2.3
import QtQuick.Layouts 1.15
import "Footer"
import "MainMenu"
import "ChartWindow"
import "Settings"
import "Toolbar"



ApplicationWindow {
    id: applicationWindow
    objectName: "applicationWindow"
    width: Constants.width
    height: Constants.height
    visible: true
    color: Constants.backgroundColor
    title: qsTr(Constants.title)

    property alias settingsPopup: settingsPopup
    property alias settings: settings
    property alias chartWindow: chartWindow
    property alias connectButton: navStartButton
    property alias toolbar: topToolbar

    menuBar: MainMenu {
        id: menuBar
        settingsButton.onTriggered: settingsPopup.open()
    }

    header: Toolbar {
        id: topToolbar
        anchors.left: parent.left
        anchors.right: parent.right
        onMenuRequested: navDrawer.open()
    }

    Drawer {
        id: navDrawer
        width: Math.min(applicationWindow.width * 0.4, 360)
        height: applicationWindow.height
        edge: Qt.LeftEdge
        interactive: true
        modal: true

        ListModel {
            id: navModel
            ListElement { section: "MAIN"; title: "News"; iconName: "newspaper" }
            ListElement { section: "MAIN"; title: "Account"; iconName: "user" }
            ListElement { section: "DATA"; title: "Images"; iconName: "image" }
            ListElement { section: "DATA"; title: "Music"; iconName: "music" }
            ListElement { section: "DATA"; title: "Video"; iconName: "video" }
            ListElement { section: "DATA"; title: "Documents"; iconName: "file" }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 8
            anchors.margins: 12

            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 6
                color: "#f4f4f4"
                border.color: "#d0d0d0"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    Text { text: qsTr("Connection"); font.bold: true; color: "#444" }
                    Button {
                        id: navStartButton
                        text: qsTr("Start")
                        Layout.fillWidth: true
                    }
                    Button {
                        id: navStopButton
                        text: qsTr("Stop")
                        Layout.fillWidth: true
                    }
                    ComboBox {
                        id: navSourceCombo
                        Layout.fillWidth: true
                        model: ConnectionModel {}
                        textRole: "name"
                        valueRole: "val"
                        currentIndex: model && model.count > 0 ? 0 : -1
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
                    anchors.margins: 0
                    spacing: 4
                    ListView {
                        id: navList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        model: navModel ? navModel : []
                        clip: true
                        section.property: "section"
                        section.delegate: Label {
                            text: section
                            color: "#7a7a7a"
                            font.pixelSize: 12
                            font.bold: true
                            padding: 10
                            horizontalAlignment: Text.AlignLeft
                        }
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            color: ListView.isCurrentItem ? "#3b8cc0" : "transparent"
                            border.color: ListView.isCurrentItem ? "#2d6f99" : "transparent"
                            border.width: ListView.isCurrentItem ? 1 : 0
                            radius: 4
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10
                                Label {
                                    text: "\u25A0"
                                    visible: iconName !== ""
                                    color: ListView.isCurrentItem ? "white" : "#444"
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
                                anchors.fill: parent
                                onClicked: {
                                    ListView.view.currentIndex = index
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
                onClicked: settingsPopup.open()
            }
        }
    }

    Item {
        id: mainArea
        anchors {
            top: topToolbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Footer {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        ChartWindow {
            id: chartWindow
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: footer.top
                margins: 6
            }
            objectName: "chartWindow"
        }
    }

    Drawer {
        id: settingsDrawer
        width: Math.min(applicationWindow.width * 0.4, 420)
        height: applicationWindow.height
        interactive: true
        modal: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Settings {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Popup {
        id: settingsPopup
        width: parent.width * 0.55
        height: parent.height * 0.65
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Settings {
            id: settings
            anchors.fill: parent
        }
    }
}
