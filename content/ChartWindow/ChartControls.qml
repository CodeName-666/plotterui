import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15

// Compact, modern zoom controls that appear on hover
Rectangle {
    id: root

    // Signals for zoom operations
    signal zoomIn()
    signal zoomOut()
    signal zoomReset()
    signal zoomFit()
    signal zoomYIn()
    signal zoomYOut()

    property bool expanded: false
    property int buttonSize: 32

    color: "#CC2b2b2b"
    radius: 6
    border.color: "#404040"
    border.width: 1

    // Auto-hide on mouse exit
    opacity: mouseArea.containsMouse || expanded ? 1.0 : 0.3

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    // Size follows content so additional buttons are not clipped
    implicitWidth: controlsRow.implicitWidth + 12
    implicitHeight: controlsRow.implicitHeight + 12
    width: implicitWidth
    height: implicitHeight

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }

    RowLayout {
        id: controlsRow
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        // Zoom In
        ToolButton {
            id: zoomInBtn
            text: "+"
            font.pixelSize: 18
            font.bold: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Zoom In (X+Y, Ctrl++)")
            ToolTip.delay: 500

            background: Rectangle {
                color: parent.hovered ? "#404040" : "transparent"
                radius: 4
                border.color: parent.hovered ? "#606060" : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.zoomIn()
        }

        // Zoom Out
        ToolButton {
            id: zoomOutBtn
            text: "−"
            font.pixelSize: 18
            font.bold: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Zoom Out (X+Y, Ctrl+−)")
            ToolTip.delay: 500

            background: Rectangle {
                color: parent.hovered ? "#404040" : "transparent"
                radius: 4
                border.color: parent.hovered ? "#606060" : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.zoomOut()
        }

        // Separator
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: buttonSize - 8
            Layout.alignment: Qt.AlignVCenter
            color: "#404040"
        }

        // Zoom Y In
        ToolButton {
            id: zoomYInBtn
            text: "Y+"
            font.pixelSize: 16
            font.bold: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Zoom In (Y axis)")
            ToolTip.delay: 500

            background: Rectangle {
                color: parent.hovered ? "#404040" : "transparent"
                radius: 4
                border.color: parent.hovered ? "#606060" : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.zoomYIn()
        }

        // Zoom Y Out
        ToolButton {
            id: zoomYOutBtn
            text: "Y-"
            font.pixelSize: 16
            font.bold: true
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Zoom Out (Y axis)")
            ToolTip.delay: 500

            background: Rectangle {
                color: parent.hovered ? "#404040" : "transparent"
                radius: 4
                border.color: parent.hovered ? "#606060" : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.zoomYOut()
        }

        // Separator
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: buttonSize - 8
            Layout.alignment: Qt.AlignVCenter
            color: "#404040"
        }

        // Reset Zoom
        ToolButton {
            id: resetBtn
            text: "⊡"
            font.pixelSize: 16
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Reset Zoom (Ctrl+0)")
            ToolTip.delay: 500

            background: Rectangle {
                color: parent.hovered ? "#404040" : "transparent"
                radius: 4
                border.color: parent.hovered ? "#606060" : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.zoomReset()
        }

        // Fit to View
        ToolButton {
            id: fitBtn
            text: "⛶"
            font.pixelSize: 14
            Layout.preferredWidth: buttonSize
            Layout.preferredHeight: buttonSize

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Fit to View (Ctrl+F)")
            ToolTip.delay: 500

            background: Rectangle {
                color: parent.hovered ? "#404040" : "transparent"
                radius: 4
                border.color: parent.hovered ? "#606060" : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.zoomFit()
        }
    }
}
