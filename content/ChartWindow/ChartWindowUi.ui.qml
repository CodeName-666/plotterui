import QtQuick 6.4
import QtCharts 2.3
import QtQuick.Layouts 1.11
import QtQuick.Controls 6.4

Item {
    property alias chart: chart
    property alias xAxis: xAxis
    property alias yAxis: yAxis
    property alias title: chart.title
    property alias chartMouseArea: chartMouseArea
    property alias horizontalScrollMask: horizontalScrollMask
    property alias verticalScrollMask: verticalScrollMask
    property alias chartControls: chartControls

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
        width: 160
        height: 44
        z: 100
    }
}
