import QtQuick 6.4
import QtQuick.Controls 6.4
import QtCharts 2.3
import Backend 1.0
import Common 1.0

/**
 * TimeSeriesRenderer.qml
 *
 * Time Series Chart renderer for floating windows.
 * Displays Y values cyclically over time with automatic time axis management.
 * Perfect for monitoring single data streams in real-time.
 *
 * Features:
 * - Automatic time axis (X) management
 * - Configurable time window (default: 60 seconds)
 * - Auto-scrolling as new data arrives
 * - Multiple lines/signals supported
 * - Zoom and pan functionality
 *
 * Expected properties from parent FloatingChartWindow:
 * - chartId: Unique identifier for this chart instance
 * - chartTitle: Display name for the chart
 */
Item {
    id: root

    // Public properties that can be set by parent
    property string chartId: ""
    property string chartTitle: "Time Series"
    property var chartData: null  // Reference to chart data model

    // Time Series specific configuration
    property real timeWindow: 60.0  // Time window in seconds (default: 60s)
    property bool autoScroll: true  // Auto-scroll as new data arrives
    property bool autoScaleY: true  // Auto-scale Y axis to fit data
    property real initialYMin: 0
    property real initialYMax: 10

    // Internal state
    property var _graphs: ({})  // Dictionary of line series by uniqueId
    property var _chartLineModel: null
    property bool _backendConnected: false
    property var _backendEvents: null
    property real _currentTime: 0  // Current time position (in seconds)
    property real _startTime: 0    // Start time of visible window

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

        // Time Axis (X)
        ValueAxis {
            id: timeAxis
            min: 0
            max: root.timeWindow
            labelFormat: "%.1f s"
            labelsFont.pixelSize: 10
            labelsColor: "#cccccc"
            gridLineColor: "#404040"
            minorGridLineColor: "#2a2a2a"
            titleText: "Time (s)"
            titleFont.pixelSize: 11
            titleFont.bold: true
        }

        // Value Axis (Y)
        ValueAxis {
            id: valueAxis
            min: root.initialYMin
            max: root.initialYMax
            labelFormat: "%.2f"
            labelsFont.pixelSize: 10
            labelsColor: "#cccccc"
            gridLineColor: "#404040"
            minorGridLineColor: "#2a2a2a"
            titleText: "Value"
            titleFont.pixelSize: 11
            titleFont.bold: true
        }

        // Mouse interaction area
        MouseArea {
            id: chartMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true

            property real lastMouseX: 0
            property real lastMouseY: 0
            property bool isPanning: false

            // Mouse wheel zoom
            onWheel: function(wheel) {
                var factor = wheel.angleDelta.y > 0 ? 0.9 : 1.1
                zoomChart(factor)
            }

            // Pan on left mouse drag
            onPressed: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    lastMouseX = mouse.x
                    lastMouseY = mouse.y
                    isPanning = true
                    root.autoScroll = false  // Disable auto-scroll when panning
                }
            }

            onReleased: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    isPanning = false
                }
            }

            onPositionChanged: function(mouse) {
                if (isPanning && mouse.buttons & Qt.LeftButton) {
                    var dx = mouse.x - lastMouseX
                    var dy = mouse.y - lastMouseY
                    pan(dx, dy)
                    lastMouseX = mouse.x
                    lastMouseY = mouse.y
                }
            }
        }
    }

    // Control buttons overlay
    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 5
        z: 100

        Button {
            text: "Reset"
            width: 60
            height: 30
            onClicked: resetZoom()
        }

        Button {
            text: autoScroll ? "⏸" : "▶"
            width: 40
            height: 30
            onClicked: toggleAutoScroll()
            ToolTip.visible: hovered
            ToolTip.text: autoScroll ? "Pause auto-scroll" : "Resume auto-scroll"
        }

        Button {
            text: "Fit"
            width: 50
            height: 30
            onClicked: fitToData()
        }
    }

    // Component initialization
    Component.onCompleted: {
        connectToBackend()
        console.log("TimeSeriesRenderer initialized for chart:", chartId)
    }

    Component.onDestruction: {
        disconnectFromBackend()
    }

    // ========== PUBLIC API ==========

    /**
     * Create a new data line
     */
    function createLine(uniqueId, displayName, color, interfaceType, dataId) {
        if (_graphs[uniqueId]) {
            console.warn("Line already exists:", uniqueId)
            return null
        }

        // Create new line series
        var series = chart.createSeries(ChartView.SeriesTypeLine, displayName, timeAxis, valueAxis)
        series.color = color || Qt.rgba(Math.random(), Math.random(), Math.random(), 1)
        series.width = 2
        series.useOpenGL = false

        _graphs[uniqueId] = {
            series: series,
            displayName: displayName,
            color: series.color,
            visible: true,
            pointCount: 0,
            lastTime: 0
        }

        console.log("Created time series line:", uniqueId, displayName)
        return series
    }

    /**
     * Append a single point to a line (with timestamp)
     */
    function appendPoint(uniqueId, timestamp, value) {
        var graph = _graphs[uniqueId]
        if (!graph || !graph.visible) {
            return
        }

        var series = graph.series

        // Update current time tracking
        if (timestamp > _currentTime) {
            _currentTime = timestamp
        }

        // Auto-scroll: adjust time window
        if (autoScroll && timestamp > timeAxis.max) {
            var windowSize = timeAxis.max - timeAxis.min
            timeAxis.min = timestamp - windowSize
            timeAxis.max = timestamp
        }

        // Add point
        series.append(timestamp, value)
        graph.pointCount++
        graph.lastTime = timestamp

        // Limit points to prevent performance issues (keep last 10000 points)
        if (graph.pointCount > 10000) {
            series.removePoints(0, 100)
            graph.pointCount -= 100
        }

        // Auto-scale Y axis if enabled
        if (autoScaleY) {
            updateYAxisRange()
        }
    }

    /**
     * Append points in batch (optimized)
     */
    function appendPointsBatch(uniqueId, points) {
        if (!points || points.length === 0) {
            return
        }

        var graph = _graphs[uniqueId]
        if (!graph || !graph.visible) {
            return
        }

        var series = graph.series

        for (var i = 0; i < points.length; i++) {
            var point = points[i]
            var timestamp = point[0]
            var value = point[1]

            // Update current time
            if (timestamp > _currentTime) {
                _currentTime = timestamp
            }

            series.append(timestamp, value)
            graph.pointCount++
            graph.lastTime = timestamp
        }

        // Auto-scroll
        if (autoScroll && _currentTime > timeAxis.max) {
            var windowSize = timeAxis.max - timeAxis.min
            timeAxis.min = _currentTime - windowSize
            timeAxis.max = _currentTime
        }

        // Limit points
        if (graph.pointCount > 10000) {
            var removeCount = Math.min(100, graph.pointCount - 10000)
            series.removePoints(0, removeCount)
            graph.pointCount -= removeCount
        }

        // Auto-scale Y
        if (autoScaleY) {
            updateYAxisRange()
        }
    }

    /**
     * Remove a data line
     */
    function removeLine(uniqueId) {
        var graph = _graphs[uniqueId]
        if (!graph) {
            return false
        }

        chart.removeSeries(graph.series)
        delete _graphs[uniqueId]
        console.log("Removed time series line:", uniqueId)
        return true
    }

    /**
     * Clear all points from a line
     */
    function clearLine(uniqueId) {
        var graph = _graphs[uniqueId]
        if (!graph) {
            return
        }

        graph.series.removePoints(0, graph.series.count)
        graph.pointCount = 0
        graph.lastTime = 0
    }

    /**
     * Clear all lines
     */
    function clearAll() {
        for (var uniqueId in _graphs) {
            clearLine(uniqueId)
        }
    }

    /**
     * Toggle line visibility
     */
    function toggleLineVisibility(uniqueId, visible) {
        var graph = _graphs[uniqueId]
        if (!graph) {
            return
        }

        graph.visible = visible
        graph.series.visible = visible
    }

    /**
     * Get a line by uniqueId
     */
    function getLine(uniqueId) {
        return _graphs[uniqueId] || null
    }

    // ========== ZOOM AND PAN FUNCTIONS ==========

    function zoomChart(factor) {
        var timeRange = timeAxis.max - timeAxis.min
        var valueRange = valueAxis.max - valueAxis.min

        var newTimeRange = timeRange * factor
        var newValueRange = valueRange * factor

        var timeCenter = (timeAxis.max + timeAxis.min) / 2
        var valueCenter = (valueAxis.max + valueAxis.min) / 2

        timeAxis.min = timeCenter - newTimeRange / 2
        timeAxis.max = timeCenter + newTimeRange / 2
        valueAxis.min = valueCenter - newValueRange / 2
        valueAxis.max = valueCenter + newValueRange / 2

        root.autoScroll = false  // Disable auto-scroll when zooming
    }

    function pan(dx, dy) {
        var plotArea = chart.plotArea
        var timeRange = timeAxis.max - timeAxis.min
        var valueRange = valueAxis.max - valueAxis.min

        var timeShift = -(dx / plotArea.width) * timeRange
        var valueShift = (dy / plotArea.height) * valueRange

        timeAxis.min += timeShift
        timeAxis.max += timeShift
        valueAxis.min += valueShift
        valueAxis.max += valueShift
    }

    function resetZoom() {
        timeAxis.min = 0
        timeAxis.max = root.timeWindow
        valueAxis.min = root.initialYMin
        valueAxis.max = root.initialYMax
        root.autoScroll = true
        root.autoScaleY = true
    }

    function fitToData() {
        var minY = Infinity
        var maxY = -Infinity
        var minT = Infinity
        var maxT = -Infinity

        for (var uniqueId in _graphs) {
            var graph = _graphs[uniqueId]
            if (!graph || !graph.visible) continue

            var series = graph.series
            for (var i = 0; i < series.count; i++) {
                var point = series.at(i)
                minT = Math.min(minT, point.x)
                maxT = Math.max(maxT, point.x)
                minY = Math.min(minY, point.y)
                maxY = Math.max(maxY, point.y)
            }
        }

        if (minT !== Infinity && maxT !== -Infinity) {
            var timeMargin = (maxT - minT) * 0.05
            timeAxis.min = minT - timeMargin
            timeAxis.max = maxT + timeMargin
        }

        if (minY !== Infinity && maxY !== -Infinity) {
            var valueMargin = (maxY - minY) * 0.1
            valueAxis.min = minY - valueMargin
            valueAxis.max = maxY + valueMargin
        }

        root.autoScroll = false
        root.autoScaleY = false
    }

    function toggleAutoScroll() {
        root.autoScroll = !root.autoScroll
        if (root.autoScroll) {
            // Jump to latest data
            var windowSize = timeAxis.max - timeAxis.min
            timeAxis.min = _currentTime - windowSize
            timeAxis.max = _currentTime
        }
    }

    function updateYAxisRange() {
        var minY = Infinity
        var maxY = -Infinity

        for (var uniqueId in _graphs) {
            var graph = _graphs[uniqueId]
            if (!graph || !graph.visible) continue

            var series = graph.series
            for (var i = 0; i < series.count; i++) {
                var point = series.at(i)
                // Only consider points in visible time window
                if (point.x >= timeAxis.min && point.x <= timeAxis.max) {
                    minY = Math.min(minY, point.y)
                    maxY = Math.max(maxY, point.y)
                }
            }
        }

        if (minY !== Infinity && maxY !== -Infinity) {
            var margin = (maxY - minY) * 0.1
            valueAxis.min = minY - margin
            valueAxis.max = maxY + margin
        }
    }

    // ========== BACKEND CONNECTION ==========

    function connectToBackend() {
        if (_backendConnected) {
            console.warn("Already connected to backend")
            return
        }

        try {
            // Get backend event handler
            var appController = App.get_app()
            if (!appController || !appController.events) {
                console.warn("Backend events not available yet")
                return
            }

            _backendEvents = appController.events()

            // Connect to data point signals
            _backendEvents.append_graph_point.connect(handleGraphPoint)
            _backendEvents.append_graph_points_batch.connect(handleGraphPointsBatch)

            _backendConnected = true
            console.log("TimeSeriesRenderer connected to backend for chart:", chartId)
        } catch (e) {
            console.error("Failed to connect to backend:", e)
        }
    }

    function disconnectFromBackend() {
        if (!_backendConnected || !_backendEvents) {
            return
        }

        try {
            _backendEvents.append_graph_point.disconnect(handleGraphPoint)
            _backendEvents.append_graph_points_batch.disconnect(handleGraphPointsBatch)
            _backendConnected = false
            console.log("TimeSeriesRenderer disconnected from backend")
        } catch (e) {
            console.error("Failed to disconnect from backend:", e)
        }
    }

    function handleGraphPoint(targetChartId, uniqueId, x, y) {
        if (targetChartId !== chartId) {
            return  // Not for this chart
        }

        appendPoint(uniqueId, x, y)
    }

    function handleGraphPointsBatch(targetChartId, uniqueId, points) {
        if (targetChartId !== chartId) {
            return  // Not for this chart
        }

        appendPointsBatch(uniqueId, points)
    }
}
