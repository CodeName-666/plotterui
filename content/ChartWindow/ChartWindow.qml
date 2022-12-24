import QtQuick 6.4
import QtCharts 2.3
import Backend 1.0



ChartWindowUi{

    zoomInButton.onClicked: chart.zoomIn()
    zoomOutButton.onClicked: chart.zoomOut()

    Component.onCompleted:  {

        BackendInterface.events().newGraph.connect(new_graph)
        BackendInterface.events().scrollRight.connect(chart.scrollRight)
        BackendInterface.set_plot_area(chart.plotArea)
        BackendInterface.set_axis(xAxis,yAxis)
        Logger.log_debug("CHARTVIEW Completed");
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
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


    function setup(settings) {

    }
}


