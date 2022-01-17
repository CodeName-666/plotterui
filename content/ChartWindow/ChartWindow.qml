import QtQuick 2.15
import QtCharts 2.15

ChartWindowUi{


   // property alias lineseries : lineseries;

    property var lineseries;
    property var scaterseries;

    Component.onCompleted:  {

        lineseries = chart.createSeries(ChartView.SeriesTypeLine,"line",xAxis,yAxis)
        scaterseries = chart.createSeries(ChartView.SeriesTypeLine,"scatter",xAxis,yAxis)
    }
/**

    LineSeries {
        id: lineseries
        name: "line1"

    }
*/
    QtObject {
        id: params
        property real m_x: 9;
        property real m_y: 0
        property real xPoint: 0.0
        property real yPoint: 0.0

    }



    Timer {
        id: refreshTimer
        //interval: 1 / 60 * 1000 // 60 Hz
        interval: 100
        running: true
        repeat: true
        onTriggered: {


            params.xPoint = chart.plotArea.width / xAxis.tickCount
            params.yPoint = (xAxis.max - xAxis.min)/ xAxis.tickCount


            params.m_x += params.yPoint;
            params.m_y = Math.random()

            lineseries.append(params.m_x,params.m_y);
            scaterseries.append(params.m_x,params.m_y + 3);

            chart.scrollRight(params.xPoint);
            console.log("max=",xAxis.max," min=", xAxis.min ," delta= ",xAxis.max - xAxis.min , " point= ",params.yPoint)


            //chart.scrollRight(params.m_x);
        }
    }

    //xAsis.onRangeChanged: chart.scroll(min,max)
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
