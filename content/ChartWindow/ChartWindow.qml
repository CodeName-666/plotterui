import QtQuick 6.4
import QtCharts 2.3
import Backend 1.0
import PlotterUi 1.0
import Common 1.0
import "../Models"



ChartWindowUi{
    property var appController: App.get_app()
    property var _graphs: ({})  // Legacy: keeping for backward compatibility during transition
    property var chartLineModel: ChartLineModel {}  // New model-based line management
    property real initialXMin: 0
    property real initialXMax: 10
    property real initialYMin: 0
    property real initialYMax: 10

    /*******************************************************************
     * EVENT - Chart Controls
     ******************************************************************/
    chartControls.onZoomIn: zoomChart(0.8)      // Zoom in 20%
    chartControls.onZoomOut: zoomChart(1.25)    // Zoom out 25%
    chartControls.onZoomReset: resetZoom()
    chartControls.onZoomFit: fitToData()

    /*******************************************************************
     * EVENT - Y-Axis Controls
     ******************************************************************/
    Connections {
        target: yAxisControls
        function onZoomYIn() {
            zoomYAxis(0.8)  // Zoom Y axis in 20%
        }
        function onZoomYOut() {
            zoomYAxis(1.25)  // Zoom Y axis out 25%
        }
    }

    /*******************************************************************
     * EVENT - Mouse Interactions
     ******************************************************************/
    chartMouseArea.onMouseYChanged: scrollVertical()
    chartMouseArea.onMouseXChanged: scrollHorizontal()
    chartMouseArea.onPressed: scrollButtonClicked()

    /*******************************************************************
     * FUNCTION - Zoom chart by factor (proportional zoom)
     ******************************************************************/
    function zoomAxis(axis, factor) {
        var range = axis.max - axis.min
        var center = (axis.max + axis.min) / 2
        var newRange = range * factor

        axis.min = center - newRange / 2
        axis.max = center + newRange / 2
    }

    function zoomChart(factor) {
        zoomAxis(xAxis, factor)
        zoomAxis(yAxis, factor)
    }

    /*******************************************************************
     * FUNCTION - Zoom only Y axis by factor (proportional zoom)
     ******************************************************************/
    function zoomYAxis(factor) {
        zoomAxis(yAxis, factor)
    }

    /*******************************************************************
     * FUNCTION - Reset zoom to initial view
     ******************************************************************/
    function resetZoom() {
        xAxis.min = initialXMin
        xAxis.max = initialXMax
        yAxis.min = initialYMin
        yAxis.max = initialYMax
    }

    /*******************************************************************
     * FUNCTION - Fit zoom to actual data range
     ******************************************************************/
    function fitToData() {
        // Find data bounds across all graphs
        var minX = Infinity, maxX = -Infinity
        var minY = Infinity, maxY = -Infinity

        for(var graphName in _graphs) {
            var series = _graphs[graphName]
            for(var i = 0; i < series.count; i++) {
                var point = series.at(i)
                minX = Math.min(minX, point.x)
                maxX = Math.max(maxX, point.x)
                minY = Math.min(minY, point.y)
                maxY = Math.max(maxY, point.y)
            }
        }

        // Add 10% padding
        if(minX !== Infinity && maxX !== -Infinity) {
            var xPadding = (maxX - minX) * 0.1
            xAxis.min = minX - xPadding
            xAxis.max = maxX + xPadding
        }

        if(minY !== Infinity && maxY !== -Infinity) {
            var yPadding = (maxY - minY) * 0.1
            yAxis.min = minY - yPadding
            yAxis.max = maxY + yPadding
        }
    }

    /*******************************************************************
     * FUNCTION - Mouse wheel zoom (centered on mouse position)
     ******************************************************************/
    chartMouseArea.onWheel: function(wheel) {
        var factor = wheel.angleDelta.y > 0 ? 0.9 : 1.1

        // Calculate mouse position in chart coordinates
        var plotArea = chart.plotArea
        var mouseXRatio = (chartMouseArea.mouseX - plotArea.x) / plotArea.width
        var mouseYRatio = (chartMouseArea.mouseY - plotArea.y) / plotArea.height

        var xRange = xAxis.max - xAxis.min
        var yRange = yAxis.max - yAxis.min

        var mouseXValue = xAxis.min + mouseXRatio * xRange
        var mouseYValue = yAxis.max - mouseYRatio * yRange

        var newXRange = xRange * factor
        var newYRange = yRange * factor

        // Zoom centered on mouse position
        xAxis.min = mouseXValue - mouseXRatio * newXRange
        xAxis.max = mouseXValue + (1 - mouseXRatio) * newXRange
        yAxis.min = mouseYValue - (1 - mouseYRatio) * newYRange
        yAxis.max = mouseYValue + mouseYRatio * newYRange
    }

    Component.onCompleted:  {
        var controller = appController !== undefined && appController !== null ? appController : App.get_app()
        if(controller !== undefined && controller !== null)
        {
            var events = controller.events()
            if(events !== undefined && events !== null)
            {
                events.newGraph.connect(newGraph)
                events.append_graph_point.connect(appendGraphPoint)
                events.scrollRight.connect(chart.scrollRight)
            }
            controller.set_plot_area(chart.plotArea)
            controller.set_axis(xAxis,yAxis)
        }
        Logger.log_debug("CHARTVIEW Completed");
    }

    /*******************************************************************
     * FUNCTION - Create new graph (updated for ID-based system)
     *
     * @param uniqueId - Unique identifier (format: "interface_dataId")
     * @param displayName - User-friendly name
     * @param color - Line color (int or hex string)
     * @param interfaceType - Interface type (Serial, MQTT, etc.)
     ******************************************************************/
    function newGraph(uniqueId, displayName, color, interfaceType) {
        // Extract dataId from uniqueId (format: "interface_dataId")
        var parts = uniqueId.split("_")
        var dataId = parts.length > 1 ? parseInt(parts[1]) : 0

        // Create the chart series
        var graph = createGraph(displayName, color);
        Logger.log_info("New Graph created: ID = " + uniqueId + " | Name = " + displayName + " | Color = " + color);

        // Store in legacy _graphs object (for backward compatibility)
        _graphs[uniqueId] = graph

        // Add to new model
        chartLineModel.addLine(uniqueId, displayName, color, interfaceType, dataId, {}, graph)

        // Register with backend controller
        var controller = appController !== undefined && appController !== null ? appController : App.get_app()
        if(controller !== undefined && controller !== null)
        {
            controller.add_graph(uniqueId, graph);
        }
    }

    /*******************************************************************
     * FUNCTION - Append point to graph (updated for ID-based system)
     *
     * @param uniqueId - Unique identifier of the graph line
     * @param point - Point object with x and y coordinates
     ******************************************************************/
    function appendGraphPoint(uniqueId, point)
    {
        if(!_graphs[uniqueId])
        {
            Logger.log_warning("appendGraphPoint: graph not found for " + uniqueId)
            return
        }
        if(point === undefined)
            return
        var x = point.x !== undefined ? point.x : (point["x"] !== undefined ? point["x"] : 0)
        var y = point.y !== undefined ? point.y : (point["y"] !== undefined ? point["y"] : 0)

        // Check if line is visible before appending
        var line = chartLineModel.getLine(uniqueId)
        if(line && line.visible) {
            _graphs[uniqueId].append(x, y)
        }
    }


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function createGraph(name, color = undefined) {

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
     * @brief: Scroll Vertical
     *
     * This function use the as key the left mouse button to identify if
     * it should be scrolled or not.
     *
     * To scrool a pixel need to be provided. To do this, a rectangle (verticalScrollMask)
     * will be used.
     *
     * Used Events:
     * onPressed: Backup current mouse postion an intialize the verticalScrollMask with it.
     * onMouseYChanged: Calculate the delta beteen the stored verticalScrollMask position and the current mouse postion.
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
