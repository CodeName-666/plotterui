import QtQuick 6.4
import QtQuick.Controls 6.4
import QtCharts 2.3
import Backend 1.0
import PlotterUi 1.0
import Common 1.0
import "../Models"
import "AddChartLineDialog"
import "EditChartLineDialog"
import "ConnectionManager"



ChartWindowUi{
    id: chartWindow
    objectName: "chartWindow"

    property var appController: App.get_app()
    property var appRoot: null  // Will be set by App.qml on Component.onCompleted
    property var _graphs: ({})  // Legacy: keeping for backward compatibility during transition
    property var chartLineModel: ChartLineModel {}  // New model-based line management
    property real initialXMin: 0
    property real initialXMax: 10
    property real initialYMin: 0
    property real initialYMax: 10

    // Debug: Monitor chartLinesListCollapsed changes
    onChartLinesListCollapsedChanged: {
        Logger.log_debug("ChartWindow: chartLinesListCollapsed changed to: " + chartLinesListCollapsed)
        Logger.log_debug("ChartWindow: chartLinesList.isCollapsed = " + chartLinesList.isCollapsed)
    }

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
     * EVENT - Chart Lines List
     ******************************************************************/
    chartLinesList.listView.model: chartLineModel

    Connections {
        target: chartLinesList
        function onLineVisibilityToggled(uniqueId, visible) {
            Logger.log_info("ChartWindow: Toggle visibility for " + uniqueId + " to " + visible)
            chartLineModel.toggleVisibility(uniqueId, visible)
        }
        function onLineSelected(uniqueId) {
            Logger.log_info("ChartWindow: Line selected: " + uniqueId)
            var line = chartLineModel.getLine(uniqueId)
            if(line) {
                editChartLineDialog.loadChartLine(uniqueId, line.displayName, line.color, line.interfaceType, line.dataId)
                editChartLineDialog.open()
            }
        }
        function onCollapseToggled() {
            Logger.log_debug("ChartWindow: Collapse button clicked")
            Logger.log_debug("ChartWindow: Current state = " + chartLinesListCollapsed)
            chartLinesListCollapsed = !chartLinesListCollapsed
            Logger.log_debug("ChartWindow: New state = " + chartLinesListCollapsed)
            Logger.log_debug("ChartWindow: isCollapsed in UI = " + chartLinesList.isCollapsed)
        }
    }

    /*******************************************************************
     * EVENT - Floating Action Button
     ******************************************************************/
    Connections {
        target: fabButton
        function onClicked() {
            Logger.log_info("ChartWindow: FAB clicked - opening add line dialog")
            addChartLineDialog.open()
        }
    }

    /*******************************************************************
     * EVENT - Backend Connections Changed
     ******************************************************************/
    Connections {
        target: Backend
        function onConnections_changed(connections) {
            Logger.log_debug("ChartWindow: Connections changed - dialog will refresh on next open")
            // No need to do anything here - dialog refreshes on open automatically
        }
    }

    /*******************************************************************
     * COMPONENT - Add Chart Line Dialog
     ******************************************************************/
    AddChartLineDialog {
        id: addChartLineDialog
        parent: Overlay.overlay
        anchors.centerIn: parent

        // Note: These are initial values only - dialog refreshes on open
        availableConnections: getAvailableConnections()
        usedDataIds: getUsedDataIds()

        onAboutToShow: {
            // Refresh connection list when dialog opens
            refreshConnectionsList(getAvailableConnections(), getUsedDataIds())
        }

        onChartLineAdded: function(uniqueId, displayName, lineColor, connectionId, dataId, interfaceSettings) {
            Logger.log_info("ChartWindow: Chart line added via dialog: " + uniqueId)

            // Get connection details to retrieve interface type
            var connDetails = Backend.get_connection_details(connectionId)
            var interfaceType = connDetails ? connDetails.type : "Unknown"

            // Add to model
            var graph = createGraph(displayName, lineColor)
            chartLineModel.addLine(uniqueId, displayName, lineColor, interfaceType, dataId, interfaceSettings, graph, "main", "Main Chart")

            // Register with backend
            var controller = appController !== undefined && appController !== null ? appController : App.get_app()
            if(controller !== undefined && controller !== null) {
                controller.add_graph(uniqueId, graph)
            }

            // Store in legacy _graphs object
            _graphs[uniqueId] = graph

            Logger.log_info("Chart line successfully added: " + displayName)
        }
    }

    /*******************************************************************
     * COMPONENT - Edit Chart Line Dialog
     ******************************************************************/
    EditChartLineDialog {
        id: editChartLineDialog
        parent: Overlay.overlay
        anchors.centerIn: parent

        onChartLineUpdated: function(uniqueId, displayName, lineColor) {
            Logger.log_info("ChartWindow: Chart line updated: " + uniqueId)

            // Update model
            chartLineModel.updateLine(uniqueId, {
                "displayName": displayName,
                "color": lineColor
            })

            // Update series color if it exists
            var line = chartLineModel.getLine(uniqueId)
            if(line && line.seriesRef) {
                line.seriesRef.name = displayName
                line.seriesRef.color = lineColor
            }

            // Update backend
            var controller = appController !== undefined && appController !== null ? appController : App.get_app()
            if(controller !== undefined && controller !== null) {
                controller.update_chart_line(uniqueId, displayName, lineColor.toString())
            }

            Logger.log_info("Chart line successfully updated: " + displayName)
        }

        onChartLineDeleted: function(uniqueId) {
            Logger.log_info("ChartWindow: Chart line deleted: " + uniqueId)
            removeChartLine(uniqueId)
        }
    }

    /*******************************************************************
     * COMPONENT - Connection Manager Dialog
     ******************************************************************/
    ConnectionManagerDialog {
        id: connectionManagerDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
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
                events.append_graph_points_batch.connect(appendGraphPointsBatch)
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
        // If this uniqueId is already assigned to another chart, don't create it on the main chart.
        if (chartLineModel.getLine(uniqueId) !== null) {
            Logger.log_debug("ChartWindow.newGraph: Skipping already-registered line: " + uniqueId)
            return
        }

        // Extract dataId from uniqueId (format: "<connectionId>_<dataId>" - connectionId may contain underscores)
        var parts = uniqueId.split("_")
        var dataId = parts.length > 0 ? parseInt(parts[parts.length - 1]) : 0
        if (isNaN(dataId)) dataId = 0

        // Create the chart series
        var graph = createGraph(displayName, color);
        Logger.log_info("New Graph created: ID = " + uniqueId + " | Name = " + displayName + " | Color = " + color);

        // Store in legacy _graphs object (for backward compatibility)
        _graphs[uniqueId] = graph

        // Add to new model
        chartLineModel.addLine(uniqueId, displayName, color, interfaceType, dataId, {}, graph, "main", "Main Chart")

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
            var line = chartLineModel.getLine(uniqueId)
            if (line && line.chartId !== "main") {
                // This point belongs to another chart (e.g. floating window) which owns the series.
                return
            }
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
            var series = _graphs[uniqueId]

            // Performance: Limit maximum points per series
            var maxPoints = 10000
            if(series.count >= maxPoints) {
                // Remove oldest 100 points when limit reached
                series.removePoints(0, 100)
            }

            series.append(x, y)
        }
    }

    /*******************************************************************
     * FUNCTION - Append multiple points at once (BATCH UPDATE)
     *
     * This is much faster than calling appendGraphPoint multiple times
     * as it reduces QML/JavaScript overhead significantly.
     *
     * @param uniqueId - Unique identifier of the graph line
     * @param points - Array of [x, y] tuples
     ******************************************************************/
    function appendGraphPointsBatch(uniqueId, points)
    {
        if(!_graphs[uniqueId])
        {
            var line = chartLineModel.getLine(uniqueId)
            if (line && line.chartId !== "main") {
                // This batch belongs to another chart (e.g. floating window) which owns the series.
                return
            }
            Logger.log_warning("appendGraphPointsBatch: graph not found for " + uniqueId)
            return
        }
        if(!points || points.length === 0)
            return

        // Check if line is visible before appending
        var line = chartLineModel.getLine(uniqueId)
        if(line && line.visible) {
            var series = _graphs[uniqueId]
            var maxPoints = 10000

            // Check if we need to remove old points
            var totalAfterAdd = series.count + points.length
            if(totalAfterAdd > maxPoints) {
                var toRemove = totalAfterAdd - maxPoints
                series.removePoints(0, toRemove)
            }

            // Batch append - much faster!
            for(var i = 0; i < points.length; i++) {
                var x = points[i][0]
                var y = points[i][1]
                series.append(x, y)
            }
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
     * FUNCTION - Get available connections from backend
     ******************************************************************/
    function getAvailableConnections() {
        // Get available connections from backend
        var connections = Backend.get_connections()
        var availableConnections = []

        for (var i = 0; i < connections.length; i++) {
            var conn = connections[i]
            availableConnections.push({
                "id": conn.id,
                "name": conn.name,
                "type": conn.type,
                "status": conn.status
            })
        }

        Logger.log_debug("ChartWindow: Found " + availableConnections.length + " available connections")
        return availableConnections
    }

    /*******************************************************************
     * FUNCTION - Get list of used data IDs (uniqueId format)
     ******************************************************************/
    function getUsedDataIds() {
        var usedIds = []
        var lines = chartLineModel.getAllLines()
        for(var i = 0; i < lines.length; i++) {
            usedIds.push(lines[i].uniqueId)
        }
        return usedIds
    }

    /*******************************************************************
     * FUNCTION - Remove chart line completely
     ******************************************************************/
    function removeChartLine(uniqueId) {
        Logger.log_info("ChartWindow: Removing chart line: " + uniqueId)

        // Get line from model before removing
        var line = chartLineModel.getLine(uniqueId)

        // Remove series from chart
        if(line && line.seriesRef) {
            chart.removeSeries(line.seriesRef)
            Logger.log_debug("ChartWindow: Removed series from chart: " + uniqueId)
        }

        // Remove from model
        chartLineModel.removeLine(uniqueId)

        // Remove from legacy _graphs object
        if(_graphs[uniqueId]) {
            delete _graphs[uniqueId]
        }

        // Remove from backend
        var controller = appController !== undefined && appController !== null ? appController : App.get_app()
        if(controller !== undefined && controller !== null) {
            controller.remove_chart_line(uniqueId)
        }

        Logger.log_info("Chart line successfully removed: " + uniqueId)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setup(settings) {

    }

    /*******************************************************************
     * FUNCTION - Test Floating Window System
     ******************************************************************/
    function testFloatingWindow() {
        Logger.log_info("ChartWindow: Starting Test 2D flow (backend Test interface -> chart -> signals)")

        // Get App instance to call createFloatingWindow
        var app = chartWindow.appRoot

        // Fallback: Try parent search if appRoot not set
        if (app === null) {
            var p = parent
            while (p !== null) {
                if (p.createFloatingWindow !== undefined) {
                    app = p
                    break
                }
                p = p.parent
            }
        }

        if (app === null || app.createFloatingWindow === undefined) {
            Logger.log_error("ChartWindow: Cannot find App.createFloatingWindow function")
            Logger.log_error("ChartWindow: Please ensure chartWindow.appRoot is set by App.qml")
            return
        }

        Logger.log_debug("ChartWindow: Found app instance, creating test window")

        var timestamp = Date.now()
        var chartId = "test_2d_" + timestamp

        // 1) Create backend communication interface first (Test)
        var testSettings = {
            "type": "Multi",
            "use_timestamp": true,
            "sample_ms": 50
        }

        var connectionId = Backend.create_connection("Test", "Test 2D " + timestamp, testSettings)
        if (!connectionId || connectionId === "") {
            Logger.log_error("ChartWindow: Failed to create Test connection")
            return
        }

        var window = app.createFloatingWindow(
            chartId,
            "xy_line",
            "Test 2D Chart " + timestamp,
            150,
            150,
            700,
            500
        )

        if (window === null) {
            Logger.log_error("ChartWindow: Failed to create floating window")
            return
        }

        // Store connection on window so it can be cleaned up on close
        window.connectionId = connectionId
        window.autoDeleteConnectionOnClose = true

        Logger.log_info("ChartWindow: Floating window created, binding 3 Test signals...")

        function tryInitSignals(attemptsLeft) {
            if (!window || !window.chartRenderer) {
                if (attemptsLeft > 0) return Qt.callLater(function() { tryInitSignals(attemptsLeft - 1) })
                Logger.log_error("ChartWindow: Chart renderer not available (timeout)")
                return
            }

            // Ensure central model is present before creating lines
            if (!window.chartRenderer.chartLineModel) {
                window.chartRenderer.chartLineModel = chartLineModel
            }

            var templates = Backend.get_test_signal_templates ? Backend.get_test_signal_templates() : []
            if (!templates || templates.length === 0) {
                // Fallback if backend doesn't provide templates
                templates = [
                    {"dataId": 0, "displayName": "Sine Wave", "color": "#ff6b6b"},
                    {"dataId": 1, "displayName": "Cosine Wave", "color": "#4ecdc4"},
                    {"dataId": 2, "displayName": "Sine Wave (2x)", "color": "#ffe66d"}
                ]
            }

            for (var i = 0; i < templates.length; i++) {
                var tpl = templates[i]
                var dataId = tpl.dataId
                var uniqueId = connectionId + "_" + dataId
                window.chartRenderer.createLine(uniqueId, tpl.displayName, tpl.color, "Test", dataId)
            }

            // 3) Start the connection after chart + signals exist
            Backend.start_connection(connectionId)
            Logger.log_info("ChartWindow: Test connection started: " + connectionId)
        }

        tryInitSignals(20)
    }

    /**
     * Test function for 3D floating windows
     * Creates a 3D scatter plot with sample data (helix, sphere, random points)
     */
    function test3DFloatingWindow() {
        Logger.log_info("ChartWindow: Testing 3D floating window system")

        // Get App instance to call createFloatingWindow
        var app = chartWindow.appRoot

        // Fallback: Try parent search if appRoot not set
        if (app === null) {
            var p = parent
            while (p !== null) {
                if (p.createFloatingWindow !== undefined) {
                    app = p
                    break
                }
                p = p.parent
            }
        }

        if (app === null || app.createFloatingWindow === undefined) {
            Logger.log_error("ChartWindow: Cannot find App.createFloatingWindow function")
            Logger.log_error("ChartWindow: Please ensure chartWindow.appRoot is set by App.qml")
            return
        }

        Logger.log_debug("ChartWindow: Found app instance, creating 3D test window")

        // Create test 3D floating window
        var timestamp = Date.now()
        var chartId = "test_3d_" + timestamp

        var window = app.createFloatingWindow(
            chartId,
            "xyz_scatter",
            "3D Test Chart " + timestamp,
            200,
            100,
            800,
            600
        )

        if (window === null) {
            Logger.log_error("ChartWindow: Failed to create 3D floating window")
            return
        }

        Logger.log_info("ChartWindow: 3D floating window created, adding test data...")

        // Wait for renderer to be ready
        Qt.callLater(function() {
            if (window.chartRenderer) {
                // Create scatter plots
                window.chartRenderer.createScatterPlot("helix", "Helix", "#ff6b6b")
                window.chartRenderer.createScatterPlot("sphere", "Sphere", "#4ecdc4")
                window.chartRenderer.createScatterPlot("random", "Random Points", "#ffe66d")

                // Generate helix data
                var helixData = []
                for (var t = 0; t < 100; t++) {
                    var angle = t * 0.2
                    helixData.push([
                        Math.cos(angle) * 5,
                        t * 0.2 - 10,
                        Math.sin(angle) * 5
                    ])
                }

                // Generate sphere data (Fibonacci sphere)
                var sphereData = []
                var numPoints = 200
                var goldenRatio = (1 + Math.sqrt(5)) / 2
                for (var i = 0; i < numPoints; i++) {
                    var theta = 2 * Math.PI * i / goldenRatio
                    var phi = Math.acos(1 - 2 * (i + 0.5) / numPoints)
                    var radius = 8
                    sphereData.push([
                        radius * Math.cos(theta) * Math.sin(phi),
                        radius * Math.sin(theta) * Math.sin(phi),
                        radius * Math.cos(phi)
                    ])
                }

                // Generate random scattered points
                var randomData = []
                for (var j = 0; j < 100; j++) {
                    randomData.push([
                        (Math.random() - 0.5) * 20,
                        (Math.random() - 0.5) * 20,
                        (Math.random() - 0.5) * 20
                    ])
                }

                // Add data in batches (fast!)
                window.chartRenderer.appendPointsBatch3D("helix", helixData)
                window.chartRenderer.appendPointsBatch3D("sphere", sphereData)
                window.chartRenderer.appendPointsBatch3D("random", randomData)

                Logger.log_info("ChartWindow: 3D test data added successfully (" +
                    (helixData.length + sphereData.length + randomData.length) + " points)")
            } else {
                Logger.log_error("ChartWindow: 3D chart renderer not available")
            }
        })
    }
}
