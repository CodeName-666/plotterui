import QtQuick 2.15
import QtCharts 2.15
import PlotterUi 1.0



ChartWindowUi{


    property var lineseries;


    zoomInButton.onClicked: chart.zoomIn()
    zoomOutButton.onClicked: chart.zoomOut()

    Component.onCompleted:  {

        BackendInterface.events().newGraph.connect(new_graph)
        BackendInterface.events().scrollRight.connect(chart.scrollRight)
        Logger.log_debug("CHARTVIEW Completed");


        lineseries = chart.createSeries(ChartView.SeriesTypeLine,
                                              "name", xAxis, yAxis)
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

        var line = chart.createSeries(ChartView.SeriesTypeLine,
                                              name, xAxis, yAxis)
        if (color === undefined) {
            color = Random.getRandomInt(0xFFFFFF)
        }

        Logger.log_info("Create Graph - Name: " + name + " - Color: " + color);
        return line
    }

    QtObject {
        id: params
        property real m_x: 5;
        property real m_y: 0
        property real xPoint: 0.0
        property real yPoint: 0.0

    }

    property var counter: 0

    Timer {
        id: refreshTimer
        //interval: 1 / 60 * 1000 // 60 Hz
        interval: 1
        running: true
        repeat: true
        onTriggered: {


            params.xPoint = chart.plotArea.width / xAxis.tickCount
            params.yPoint = (xAxis.max - xAxis.min)/ xAxis.tickCount


            //console.log("Y-Point = ", params.yPoint)

            params.m_x += params.yPoint;
            params.m_y = Rand.getRandomArbitrary(0,10)

            console.log("m_x = ",  params.m_x)

            lineseries.append(params.m_x,params.m_y);

            chart.scrollRight(params.xPoint);
            counter ++


        }
    }

    //xAsis.onRangeChanged: chart.scroll(min,max)
}


