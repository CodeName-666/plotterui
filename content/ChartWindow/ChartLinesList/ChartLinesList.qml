import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import Common 1.0

ChartLinesListUi {
    id: root

    // Signals
    signal lineVisibilityToggled(string uniqueId, bool visible)
    signal lineSelected(string uniqueId)
    signal collapseToggled()

    // Debug: Monitor isCollapsed changes
    onIsCollapsedChanged: {
        console.log("ChartLinesList: isCollapsed changed to: " + isCollapsed)
    }

    // Connect collapse buttons (both centered button when collapsed and header button when expanded)
    collapseButton.onClicked: {
        console.log("ChartLinesList: Collapse button clicked (expand)")
        collapseToggled()
    }

    headerCollapseButton.onClicked: {
        console.log("ChartLinesList: Header collapse button clicked (collapse)")
        collapseToggled()
    }

    // Connect visibility button clicks
    listView.delegate: Item {
        width: listView.width
        height: 40

        Rectangle {
            anchors.fill: parent
            color: mouseArea.containsMouse ? "#e3f2fd" : "transparent"
            radius: 6
            border.color: model.visible ? "#1976d2" : "transparent"
            border.width: model.visible ? 1 : 0

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
                    color: model.visible ? "#222" : "#999"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                // Chart name badge (shows which chart this line belongs to)
                Rectangle {
                    width: chartLabel.width + 12
                    height: 20
                    radius: 3
                    color: "#d0e8ff"
                    Layout.alignment: Qt.AlignVCenter
                    visible: model.chartTitle !== undefined && model.chartTitle !== "Main Chart"

                    Label {
                        id: chartLabel
                        anchors.centerIn: parent
                        text: model.chartTitle || ""
                        color: "#0066cc"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                // Data ID badge
                Rectangle {
                    width: idLabel.width + 12
                    height: 20
                    radius: 3
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignVCenter

                    Label {
                        id: idLabel
                        anchors.centerIn: parent
                        text: "ID:" + model.dataId
                        color: "#555"
                        font.pixelSize: 10
                    }
                }

                // Interface type badge
                Rectangle {
                    width: typeLabel.width + 12
                    height: 20
                    radius: 3
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignVCenter

                    Label {
                        id: typeLabel
                        anchors.centerIn: parent
                        text: model.interfaceType
                        color: "#555"
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
                        color: visibilityButton.hovered ? "#e0e0e0" : "transparent"
                        radius: 3
                    }

                    contentItem: Text {
                        text: model.visible ? "\u{1F441}" : "\u{1F441}\u{FE0F}"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: model.visible ? "#2196f3" : "#999"
                    }

                    onClicked: {
                        console.log("ChartLinesList: Toggling visibility for " + model.uniqueId)
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
                    console.log("ChartLinesList: Line selected: " + model.uniqueId)
                    root.lineSelected(model.uniqueId)
                }
            }
        }
    }
}
