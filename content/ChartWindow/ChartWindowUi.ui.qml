import QtQuick 6.4
import QtCharts 2.3
import QtQuick.Layouts 1.11
import QtQuick.Controls 6.4
import "ZoomButtons"

Item {
    property alias chart: chart
    property alias xAxis: xAxis
    property alias yAxis: yAxis
    property alias title: chart.title

    ChartView {
        id: chart
        title: "Top-5 car brand shares in Finland"
        objectName: "chart"
        anchors.fill: parent
        legend.alignment: Qt.AlignBottom
        antialiasing: true
        theme: ChartView.ChartThemeDark

        MouseArea {
            id: chartMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
        }

        ZoomButtons {
            id: zoomY
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 30
            anchors.topMargin: 30
            anchors.rightMargin: 21

            height: 100
            width: 125
        }

        ZoomButtons {
            id: zoomX
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.rightMargin: 30

            height: 100
            width: 125

        }

        ValueAxis {
            id: xAxis
            min: 0
            max: 10
        }

        ValueAxis {
            id: yAxis
            min: 0
            max: 10
        }
    }
}

/*
MouseArea {
     anchors.fill: parent
     onWheel: {
         // Vergrößern oder Verkleinern des Intervalls, wenn das Mausrad gedreht wird
         if (wheel.angleDelta.y > 0) {
             xAxis.interval *= 0.5 // Verkleinern des Intervalls um 50%
             yAxis.interval *= 0.5
         } else {
             xAxis.interval *= 2 // Vergrößern des Intervalls um 100%
             yAxis.interval *= 2
         }
     }
 }
}
*/
