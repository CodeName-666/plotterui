import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15

Item {
    id: root

    property alias listView: listView
    property alias headerLabel: headerLabel

    Rectangle {
        anchors.fill: parent
        color: "#2d2d2d"
        border.color: "#4d4d4d"
        border.width: 1
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            // Header
            Label {
                id: headerLabel
                text: qsTr("Chart Lines")
                font.pixelSize: 14
                font.bold: true
                color: "#ffffff"
                Layout.fillWidth: true
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#4d4d4d"
            }

            // List view
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Item {
                    width: listView.width
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        color: mouseArea.containsMouse ? "#3d3d3d" : "#333333"
                        radius: 3
                        border.color: model.visible ? "#4d4d4d" : "#2d2d2d"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            // Color indicator
                            Rectangle {
                                id: colorIndicator
                                width: 20
                                height: 20
                                radius: 10
                                color: model.color
                                border.color: "#ffffff"
                                border.width: 1
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Display name
                            Label {
                                id: nameLabel
                                text: model.displayName
                                color: model.visible ? "#ffffff" : "#888888"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Interface type badge
                            Rectangle {
                                width: typeLabel.width + 12
                                height: 20
                                radius: 3
                                color: "#4d4d4d"
                                Layout.alignment: Qt.AlignVCenter

                                Label {
                                    id: typeLabel
                                    anchors.centerIn: parent
                                    text: model.interfaceType
                                    color: "#aaaaaa"
                                    font.pixelSize: 10
                                }
                            }

                            // Visibility toggle button
                            Button {
                                id: visibilityButton
                                width: 30
                                height: 30
                                Layout.alignment: Qt.AlignVCenter

                                background: Rectangle {
                                    color: visibilityButton.hovered ? "#4d4d4d" : "transparent"
                                    radius: 3
                                }

                                contentItem: Text {
                                    text: model.visible ? "\u{1F441}" : "\u{1F441}\u{FE0F}\u{200D}\u{1F5E8}\u{FE0F}"
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: model.visible ? "#ffffff" : "#666666"
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true

                            onClicked: {
                                // Future: select line for editing
                            }
                        }
                    }
                }

                // Empty state
                Label {
                    anchors.centerIn: parent
                    text: qsTr("No chart lines")
                    color: "#888888"
                    font.pixelSize: 12
                    visible: listView.count === 0
                }
            }
        }
    }
}
