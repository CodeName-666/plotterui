import QtQuick 6.4
import QtCharts 2.3
import Backend 1.0



ChartWindowUi{


    /*******************************************************************
     * EVENT
     ******************************************************************/
    //zoomInButton.onClicked: chart.zoomIn()
    //zoomOutButton.onClicked: chart.zoomOut()

    chartMouseArea.onMouseYChanged: {
        if ((chartMouseArea.pressedButtons & Qt.LeftButton) === Qt.LeftButton) {
            chart.scrollUp(chartMouseArea.mouseY - verticalScrollMask.y)
            verticalScrollMask.y = chartMouseArea.mouseY
        }
    }

    chartMouseArea.onMouseXChanged: {
        if ((chartMouseArea.pressedButtons & Qt.LeftButton) === Qt.LeftButton) {
            chart.scrollLeft(chartMouseArea.mouseX - horizontalScrollMask.x)

            horizontalScrollMask.x = chartMouseArea.mouseX
        }
    }
    chartMouseArea.onPressed: {
        if (chartMouseArea.pressedButtons === Qt.LeftButton) {
            horizontalScrollMask.x = chartMouseArea.mouseX
            verticalScrollMask.y = chartMouseArea.mouseY
        }
    }

    chartMouseArea.onWheel: {
        // Vergrößern oder Verkleinern des Bereichs der Achse, wenn das Mausrad gedreht wird
        if (wheel.angleDelta.y > 0) {
            xAxis.min += 1 // Verkleinern des Bereichs der Achse um 1
            xAxis.max -= 1
            yAxis.min += 1
            yAxis.max -= 1
        } else {
            xAxis.min -= 1 // Vergrößern des Bereichs der Achse um 1
            xAxis.max += 1
            yAxis.min -= 1
            yAxis.max += 1
        }
    }

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


