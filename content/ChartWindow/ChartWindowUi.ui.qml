import QtQuick 6.4
import QtCharts 2.3
import QtQuick.Layouts 1.11
import QtQuick.Controls 6.4

Item {
    property alias chart: chart
    property alias xAxis: xAxis
    property alias yAxis: yAxis
    property alias zoomInButton: zoomInButton
    property alias zoomOutButton: zoomOutButton
    property alias title: chart.title

    ChartView {
        id: chart
        title: "Top-5 car brand shares in Finland"
        objectName: "chart"
        anchors.fill: parent
        legend.alignment: Qt.AlignBottom
        antialiasing: true
        theme: ChartView.ChartThemeDark

        ColumnLayout {

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 21
            anchors.rightMargin: 21
            Button {
                id: zoomInButton
                text: "+"
                Layout.preferredHeight: 100
                Layout.preferredWidth: chart.width * 1 / 10
            }

            Button {
                id: zoomOutButton
                text: "-"
                Layout.preferredHeight: chart.height * 1 / 10
                Layout.preferredWidth: chart.width * 1 / 10
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

