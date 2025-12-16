import QtQuick 6.4
import QtQuick.Controls 6.4
import QtCharts 2.3
import Backend 1.0
import Common 1.0

/**
 * XYChartRenderer.qml
 *
 * 2D Chart renderer for floating windows.
 * Displays XY line charts with full zoom, pan, and scroll functionality.
 *
 * Expected properties from parent FloatingChartWindow:
 * - chartId: Unique identifier for this chart instance
 * - chartTitle: Display name for the chart
 */
Item {
    id: root

    // Public properties that can be set by parent
    property string chartId: ""
    property string chartTitle: "XY Chart"
    property var chartData: null  // Reference to chart data model

    // Chart configuration
    property real initialXMin: 0
    property real initialXMax: 10
    property real initialYMin: 0
    property real initialYMax: 10

    // Internal state
    property var _graphs: ({})  // Dictionary of line series by uniqueId
    property var _chartLineModel: null  // Will be set by backend

    // Chart view component
    ChartView {
        id: chart
        anchors.fill: parent
        antialiasing: true
        backgroundColor: "#1e1e1e"
        legend.visible: true
        legend.alignment: Qt.AlignBottom
        legend.labelColor: "#ffffff"
        legend.font.pixelSize: 11

        theme: ChartView.ChartThemeDark
        animationOptions: ChartView.NoAnimation  // Better performance

        // X Axis
        ValueAxis {
            id: xAxis
            min: root.initialXMin
            max: root.initialXMax
            labelFormat: "%.2f"
            labelsFont.pixelSize: 10
            labelsColor: "#cccccc"
            gridLineColor: "#404040"
            minorGridLineColor: "#2a2a2a"
            titleText: "X"
            titleFont.pixelSize: 11
            titleFont.bold: true
        }

        // Y Axis
        ValueAxis {
            id: yAxis
            min: root.initialYMin
            max: root.initialYMax
            labelFormat: "%.2f"
            labelsFont.pixelSize: 10
            labelsColor: "#cccccc"
            gridLineColor: "#404040"
            minorGridLineColor: "#2a2a2a"
            titleText: "Y"
            titleFont.pixelSize: 11
            titleFont.bold: true
        }

        // Mouse interaction area
        MouseArea {
            id: chartMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true

            // Mouse wheel zoom (centered on cursor)
            onWheel: function(wheel) {
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

            // Pan with left mouse button
            property real lastMouseX: 0
            property real lastMouseY: 0

            onPressed: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    lastMouseX = mouse.x
                    lastMouseY = mouse.y
                }
            }

            onPositionChanged: function(mouse) {
                if (pressedButtons & Qt.LeftButton) {
                    var deltaX = mouse.x - lastMouseX
                    var deltaY = mouse.y - lastMouseY

                    // Convert pixel movement to chart coordinates
                    var plotArea = chart.plotArea
                    var xRange = xAxis.max - xAxis.min
                    var yRange = yAxis.max - yAxis.min

                    var xShift = -(deltaX / plotArea.width) * xRange
                    var yShift = (deltaY / plotArea.height) * yRange

                    xAxis.min += xShift
                    xAxis.max += xShift
                    yAxis.min += yShift
                    yAxis.max += yShift

                    lastMouseX = mouse.x
                    lastMouseY = mouse.y
                }
            }
        }
    }

    // Control panel overlay (top-right corner)
    Rectangle {
        id: controlPanel
        width: 200
        height: controlColumn.height + 20
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        color: "#2d2d2d"
        radius: 6
        opacity: 0.95
        border.color: "#404040"
        border.width: 1

        Column {
            id: controlColumn
            anchors.centerIn: parent
            spacing: 8
            width: parent.width - 20

            Text {
                text: "Chart Controls"
                color: "#ffffff"
                font.pixelSize: 12
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#404040"
            }

            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "+"
                    width: 35
                    height: 28
                    font.pixelSize: 14
                    onClicked: root.zoomIn()
                    ToolTip.text: "Zoom In"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }

                Button {
                    text: "-"
                    width: 35
                    height: 28
                    font.pixelSize: 14
                    onClicked: root.zoomOut()
                    ToolTip.text: "Zoom Out"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }

                Button {
                    text: "↺"
                    width: 35
                    height: 28
                    font.pixelSize: 14
                    onClicked: root.resetZoom()
                    ToolTip.text: "Reset Zoom"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }

                Button {
                    text: "⇲"
                    width: 35
                    height: 28
                    font.pixelSize: 14
                    onClicked: root.fitToData()
                    ToolTip.text: "Fit to Data"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }
            }
        }
    }

    /*******************************************************************
     * PUBLIC FUNCTIONS - Chart Manipulation
     ******************************************************************/

    /**
     * Zoom in by 20%
     */
    function zoomIn() {
        zoomChart(0.8)
    }

    /**
     * Zoom out by 25%
     */
    function zoomOut() {
        zoomChart(1.25)
    }

    /**
     * Zoom both axes by factor (proportional zoom)
     */
    function zoomChart(factor) {
        zoomAxis(xAxis, factor)
        zoomAxis(yAxis, factor)
    }

    /**
     * Zoom single axis by factor
     */
    function zoomAxis(axis, factor) {
        var range = axis.max - axis.min
        var center = (axis.max + axis.min) / 2
        var newRange = range * factor

        axis.min = center - newRange / 2
        axis.max = center + newRange / 2
    }

    /**
     * Reset zoom to initial view
     */
    function resetZoom() {
        xAxis.min = root.initialXMin
        xAxis.max = root.initialXMax
        yAxis.min = root.initialYMin
        yAxis.max = root.initialYMax
    }

    /**
     * Fit zoom to actual data range (with 10% padding)
     */
    function fitToData() {
        var minX = Infinity, maxX = -Infinity
        var minY = Infinity, maxY = -Infinity

        for(var graphId in _graphs) {
            var series = _graphs[graphId]
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
     * PUBLIC FUNCTIONS - Line Management
     ******************************************************************/

    /**
     * Create a new line series
     * @param uniqueId - Unique identifier for the line
     * @param displayName - Display name for the line
     * @param color - Line color (hex string or int)
     * @return LineSeries object
     */
    function createLine(uniqueId, displayName, color) {
        var line = chart.createSeries(ChartView.SeriesTypeLine, displayName, xAxis, yAxis)

        if (color !== undefined) {
            line.color = color
        }

        line.width = 2
        line.useOpenGL = true  // Hardware acceleration

        _graphs[uniqueId] = line

        Logger.log_info("XYChartRenderer: Created line '" + displayName + "' with ID " + uniqueId)
        return line
    }

    /**
     * Remove a line series
     * @param uniqueId - Unique identifier of the line to remove
     */
    function removeLine(uniqueId) {
        if(_graphs[uniqueId]) {
            chart.removeSeries(_graphs[uniqueId])
            delete _graphs[uniqueId]
            Logger.log_info("XYChartRenderer: Removed line " + uniqueId)
        }
    }

    /**
     * Get a line series by ID
     * @param uniqueId - Unique identifier
     * @return LineSeries object or null
     */
    function getLine(uniqueId) {
        return _graphs[uniqueId] || null
    }

    /**
     * Append a single point to a line
     * @param uniqueId - Line identifier
     * @param x - X coordinate
     * @param y - Y coordinate
     */
    function appendPoint(uniqueId, x, y) {
        var series = _graphs[uniqueId]
        if(!series) {
            Logger.log_warning("XYChartRenderer: Line not found: " + uniqueId)
            return
        }

        // Limit maximum points for performance
        var maxPoints = 10000
        if(series.count >= maxPoints) {
            series.removePoints(0, 100)  // Remove oldest 100 points
        }

        series.append(x, y)
    }

    /**
     * Append multiple points at once (BATCH - much faster!)
     * @param uniqueId - Line identifier
     * @param points - Array of [x, y] tuples
     */
    function appendPointsBatch(uniqueId, points) {
        var series = _graphs[uniqueId]
        if(!series) {
            Logger.log_warning("XYChartRenderer: Line not found: " + uniqueId)
            return
        }

        if(!points || points.length === 0) {
            return
        }

        var maxPoints = 10000
        var totalAfterAdd = series.count + points.length

        if(totalAfterAdd > maxPoints) {
            var toRemove = totalAfterAdd - maxPoints
            series.removePoints(0, toRemove)
        }

        // Batch append
        for(var i = 0; i < points.length; i++) {
            series.append(points[i][0], points[i][1])
        }
    }

    /**
     * Clear all points from a line
     * @param uniqueId - Line identifier
     */
    function clearLine(uniqueId) {
        var series = _graphs[uniqueId]
        if(series) {
            series.clear()
        }
    }

    /**
     * Clear all lines
     */
    function clearAll() {
        for(var graphId in _graphs) {
            _graphs[graphId].clear()
        }
    }

    /**
     * Update line properties
     * @param uniqueId - Line identifier
     * @param properties - Object with properties to update (name, color, width, etc.)
     */
    function updateLine(uniqueId, properties) {
        var series = _graphs[uniqueId]
        if(!series) {
            Logger.log_warning("XYChartRenderer: Line not found: " + uniqueId)
            return
        }

        if(properties.name !== undefined) {
            series.name = properties.name
        }
        if(properties.color !== undefined) {
            series.color = properties.color
        }
        if(properties.width !== undefined) {
            series.width = properties.width
        }
        if(properties.visible !== undefined) {
            series.visible = properties.visible
        }
    }

    /*******************************************************************
     * COMPONENT LIFECYCLE
     ******************************************************************/

    Component.onCompleted: {
        Logger.log_info("XYChartRenderer initialized for chart: " + root.chartId)

        // Connect to backend if available
        // Note: App singleton is only available in main window context, not in floating windows
        if(typeof App !== 'undefined') {
            var controller = App.get_app()
            if(controller !== undefined && controller !== null) {
                controller.set_plot_area(chart.plotArea)
                controller.set_axis(xAxis, yAxis)

                // Connect to backend events if available
                var events = controller.events()
                if(events !== undefined && events !== null) {
                    events.append_graph_point.connect(handleGraphPoint)
                    events.append_graph_points_batch.connect(handleGraphPointsBatch)
                }
            }
        } else {
            Logger.log_debug("XYChartRenderer: App singleton not available (floating window context)")
        }
    }

    Component.onDestruction: {
        Logger.log_info("XYChartRenderer destroyed for chart: " + root.chartId)
    }

    /*******************************************************************
     * INTERNAL FUNCTIONS - Backend Event Handlers
     ******************************************************************/

    /**
     * Handle single point from backend
     */
    function handleGraphPoint(uniqueId, point) {
        if(!point) return

        var x = point.x !== undefined ? point.x : (point["x"] !== undefined ? point["x"] : 0)
        var y = point.y !== undefined ? point.y : (point["y"] !== undefined ? point["y"] : 0)

        appendPoint(uniqueId, x, y)
    }

    /**
     * Handle batch points from backend
     */
    function handleGraphPointsBatch(uniqueId, points) {
        appendPointsBatch(uniqueId, points)
    }
}
