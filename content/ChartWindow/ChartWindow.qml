import QtQuick 6.4
import QtCharts 2.3
import Backend 1.0



ChartWindowUi{

    enum ZoomDir{
        ZOOM_IN,
        ZOOM_OUT
    }
    /*******************************************************************
     * EVENT
     ******************************************************************/
    zoomX.onZoomInButtonClicked: console.log("Zoom In X")
    zoomX.onZoomOutButtonClicked: console.log("Zoom Out X")

    zoomY.onZoomInButtonClicked: console.log("Zoom In Y")
    zoomY.onZoomOutButtonClicked: console.log("Zoom Out Y")

    chartMouseArea.onMouseYChanged: scrollVertical()
    chartMouseArea.onMouseXChanged: scrollHorizontal()
    chartMouseArea.onPressed: scrollButtonClicked()

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

    /*******************************************************************
     * @brief: Scroll Horizontal
     *
     * This function use the as key the left mouse button to identify if
     * it should be scrolled or not.
     *
     * To scrool a pixel need to be provided. To do this, a rectangle (horizontalScrollMask)
     * will be used.
     *
     * Used Events:
     * onPressed: Backup current mouse postion an intialize the horizontalScrollMask with it.
     * onMouseXChanged: Calculate the delta beteen the stored horizontalScrollMask position and the current mouse postion.
     *                  This delta value represents the scrolled pixels.After this calculation, update the
     *                  horizontalScrollMask whit the new position for the next delta calculation.
     *
     ******************************************************************/
    function scrollHorizontal() {
        if ((chartMouseArea.pressedButtons & Qt.LeftButton) === Qt.LeftButton) {
            chart.scrollLeft(chartMouseArea.mouseX - horizontalScrollMask.x)

            horizontalScrollMask.x = chartMouseArea.mouseX
        }
    }

    /*******************************************************************
     * @brief: Scroll Horizontal
     *
     * This function use the as key the left mouse button to identify if
     * it should be scrolled or not.
     *
     * To scrool a pixel need to be provided. To do this, a rectangle (verticalScrollMask)
     * will be used.
     *
     * Used Events:
     * onPressed: Backup current mouse postion an intialize the verticalScrollMask with it.
     * onMouseXChanged: Calculate the delta beteen the stored verticalScrollMask position and the current mouse postion.
     *                  This delta value represents the scrolled pixels.After this calculation, update the
     *                  verticalScrollMask whit the new position for the next delta calculation.
     *
     ******************************************************************/
    function scrollVertical() {
        if ((chartMouseArea.pressedButtons & Qt.LeftButton) === Qt.LeftButton) {
            chart.scrollUp(chartMouseArea.mouseY - verticalScrollMask.y)
            verticalScrollMask.y = chartMouseArea.mouseY
        }
    }

    /*******************************************************************
     * @brief: Scroll Button Clicked
     *
     * This function use the as key the left mouse button to identify if
     * it should be scrolled or not.
     *
     * To scrool a pixel need to be provided. To do this, a rectangle (verticalScrollMask)
     * will be used.
     *
     * Used Events:
     * onPressed: Backup current mouse postion an intialize the verticalScrollMask with it.
     * onMouseXChanged: Calculate the delta beteen the stored verticalScrollMask position and the current mouse postion.
     *                  This delta value represents the scrolled pixels.After this calculation, update the
     *                  verticalScrollMask whit the new position for the next delta calculation.
     *
     ******************************************************************/
    function scrollButtonClicked() {
        if (chartMouseArea.pressedButtons === Qt.LeftButton) {
            horizontalScrollMask.x = chartMouseArea.mouseX
            verticalScrollMask.y = chartMouseArea.mouseY
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setup(settings) {

    }
}


