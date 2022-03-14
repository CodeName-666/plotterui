import QtQuick 2.15
import QtCharts 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.15

Item {
    property alias chart: chart
    property alias xAxis: xAxis
    property alias yAxis: yAxis
    property alias zoomInButton: zoomInButton
    property alias zoomOutButton: zoomOutButton

    ChartView {
        id: chart
        title: "Top-5 car brand shares in Finland"
        objectName: "chart"
        anchors.fill: parent
        legend.alignment: Qt.AlignBottom
        antialiasing: true
        theme: ChartView.ChartThemeDark

        ColumnLayout {
            x: 519
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 21
            anchors.rightMargin: 21
            Button {
                id: zoomInButton
                text: "+"
            }

            Button {
                id: zoomOutButton
                text: "-"
            }
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

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

