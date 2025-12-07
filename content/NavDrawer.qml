import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import DataModels.SerialDataModels 1.0
import Common 1.0
import "components"

Drawer {
    id: navDrawer
    property var window
    property var appController
    property var settingsPopup
    property alias startButton: navStartButton
    property alias stopButton: navStopButton
    property alias sourceCombo: navSourceCombo

    width: Math.min((window ? window.width : 800) * 0.4, 360)
    height: window ? window.height : 600
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

        ControlsCard {
            id: controlsCard
            Layout.fillWidth: true
            startButton.onClicked: navStartButton.clicked()
            stopButton.onClicked: navStopButton.clicked()
            onInterfaceChanged: {
                if(appController)
                    appController.current_interface = iface
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
                                navList.currentIndex = index
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
                if(settingsPopup)
                    settingsPopup.open()
            }
        }
    }
}
