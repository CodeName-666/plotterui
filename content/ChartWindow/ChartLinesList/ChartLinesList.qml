import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import Common 1.0

ChartLinesListUi {
    id: root

    // Signals
    signal lineVisibilityToggled(string uniqueId, bool visible)
    signal lineSelected(string uniqueId)

    // Connect visibility button clicks
    listView.delegate: Item {
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

                // Data ID badge
                Rectangle {
                    width: idLabel.width + 12
                    height: 20
                    radius: 3
                    color: "#555555"
                    Layout.alignment: Qt.AlignVCenter

                    Label {
                        id: idLabel
                        anchors.centerIn: parent
                        text: "ID:" + model.dataId
                        color: "#cccccc"
                        font.pixelSize: 10
                    }
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
                        text: model.visible ? "\u{1F441}" : "\u{1F441}\u{FE0F}"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: model.visible ? "#ffffff" : "#666666"
                    }

                    onClicked: {
                        Logger.log_debug("ChartLinesList: Toggling visibility for " + model.uniqueId)
                        root.lineVisibilityToggled(model.uniqueId, !model.visible)
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                z: -1

                onClicked: {
                    Logger.log_debug("ChartLinesList: Line selected: " + model.uniqueId)
                    root.lineSelected(model.uniqueId)
                }
            }
        }
    }
}
