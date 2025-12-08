import QtQuick 6.4
import QtCharts 2.3
import QtQuick.Layouts 1.11
import QtQuick.Controls 6.4
import "ChartLinesList"
import "FloatingActionButton"

Item {
    property alias chart: chart
    property alias xAxis: xAxis
    property alias yAxis: yAxis
    property alias title: chart.title
    property alias chartMouseArea: chartMouseArea
    property alias horizontalScrollMask: horizontalScrollMask
    property alias verticalScrollMask: verticalScrollMask
    property alias chartControls: chartControls
    property alias yAxisControls: yAxisControls
    property alias chartLinesList: chartLinesList
    property alias fabButton: fabButton

    ChartView {
        id: chart
        title: "Data Plot"
        objectName: "chart"
        anchors.fill: parent
        legend.alignment: Qt.AlignBottom
        antialiasing: true
        theme: ChartView.ChartThemeDark

        Rectangle {
            color: "transparent"
            width: 1
            height: 1
            id: horizontalScrollMask
            visible: false
        }

        Rectangle {
            color: "transparent"
            width: 1
            height: 1
            id: verticalScrollMask
            visible: false
        }

        MouseArea {
            id: chartMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        ValuesAxis {
            id: xAxis
            min: 0
            max: 10
        }

        ValuesAxis {
            id: yAxis
            min: 0
            max: 10
        }
    }

    // Compact zoom controls - top-right corner, semi-transparent on hover
    ChartControls {
        id: chartControls
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 16
        anchors.rightMargin: 16
        z: 100
    }

    // Dedicated Y-axis zoom buttons on the left near the axis
    Rectangle {
        id: yAxisControls
        signal zoomYIn()
        signal zoomYOut()

        property int buttonSize: 32

        width: buttonSize + 12
        height: buttonSize * 2 + 12
        radius: 6
        color: "#CC2b2b2b"
        border.color: "#404040"
        border.width: 1

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        z: 100

        opacity: yMouseArea.containsMouse ? 1.0 : 0.35
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        MouseArea {
            id: yMouseArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 4

            ToolButton {
                id: yZoomInBtn
                text: "Y+"
                font.pixelSize: 16
                font.bold: true
                Layout.preferredWidth: yAxisControls.buttonSize
                Layout.preferredHeight: yAxisControls.buttonSize

                ToolTip.visible: hovered
                ToolTip.text: qsTr("Zoom In (Y axis)")
                ToolTip.delay: 400

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

                onClicked: yAxisControls.zoomYIn()
            }

            ToolButton {
                id: yZoomOutBtn
                text: "Y-"
                font.pixelSize: 16
                font.bold: true
                Layout.preferredWidth: yAxisControls.buttonSize
                Layout.preferredHeight: yAxisControls.buttonSize

                ToolTip.visible: hovered
                ToolTip.text: qsTr("Zoom Out (Y axis)")
                ToolTip.delay: 400

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

                onClicked: yAxisControls.zoomYOut()
            }
        }
    }

    // Chart Lines List - right side panel
    ChartLinesList {
        id: chartLinesList
        width: 280
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        z: 90
    }

    // Floating Action Button - bottom-right corner
    FloatingActionButton {
        id: fabButton
        anchors.right: chartLinesList.left
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        z: 110
    }
}
