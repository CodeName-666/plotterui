import QtQuick 2.15
import QtCharts 2.15
import PlotterUi 1.0


ChartWindowUi{


   // property alias lineseries : lineseries;

    Component.onCompleted:  {

        BackendInterface.events().newGraph.connect(new_graph)
        BackendInterface.events().scrollRight.connect(chart.scrollRight)
        Logger.log_debug("CHARTVIEW Completed");
    }
    
    function new_graph(name, color) {
        var graph = create_graph(name, color);
        Logger.log_debug("New Graph created: Name = " + name + "| Color = " + color );
        BackendInterface.add_graph(name, graph);
    }


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function create_graph(name, color = undefined) {
        var chartUi = application_handle.chartWindow
        var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,
                                              name, chartUi.xAxis, chartUi.yAxis)
        if (color === undefined) {
            color = Random.getRandomInt(0xFFFFFF)
        }

        Logger.log_info("Create Graph - Name: " + name + " - Color: " + color);
        return line
    }

    //QtObject {
    //    id: params
    //    property real m_x: 9;
    //    property real m_y: 0
    //    property real xPoint: 0.0
    //    property real yPoint: 0.0
//
    //}


    //Timer {
    //    id: refreshTimer
    //    //interval: 1 / 60 * 1000 // 60 Hz
    //    interval: 100
    //    running: true
    //    repeat: true
    //    onTriggered: {
//
//
    //        params.xPoint = chart.plotArea.width / xAxis.tickCount
    //        params.yPoint = (xAxis.max - xAxis.min)/ xAxis.tickCount
//
//
    //        params.m_x += params.yPoint;
    //        params.m_y = Math.random()
//
    //        lineseries.append(params.m_x,params.m_y);
    //        scaterseries.append(params.m_x,params.m_y + 3);
//
    //        chart.scrollRight(params.xPoint);
    //        //console.log("max=",xAxis.max," min=", xAxis.min ," delta= ",xAxis.max - xAxis.min , " point= ",params.yPoint)
//
//
    //        //chart.scrollRight(params.m_x);
    //    }
    //}
//
    //xAsis.onRangeChanged: chart.scroll(min,max)
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
