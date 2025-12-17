import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import Common 1.0
import Backend 1.0
import PlotterUi 1.0

/**
 * XYChartView.qml
 *
 * XY chart view for floating windows.
 * This is a simple wrapper around XYChartRenderer.
 * Chart lines are managed centrally in the main window, not per-chart.
 */
Item {
    id: root

    // Public properties (passed from FloatingChartWindow)
    property string chartId: ""
    property string chartTitle: "XY Chart"

    // Chart configuration
    property real initialXMin: 0
    property real initialXMax: 10
    property real initialYMin: 0
    property real initialYMax: 10

    // Reference to the central chart line model (passed from App)
    property var chartLineModel: null

    // Internal reference to the actual renderer (for internal use)
    property var _internalRenderer: chartRenderer

    // XY Chart Renderer - fills entire space
    XYChartRenderer {
        id: chartRenderer
        anchors.fill: parent

        chartId: root.chartId
        chartTitle: root.chartTitle
        initialXMin: root.initialXMin
        initialXMax: root.initialXMax
        initialYMin: root.initialYMin
        initialYMax: root.initialYMax

        // Pass the chart line model reference (if provided)
        _chartLineModel: root.chartLineModel
    }

    /*******************************************************************
     * PUBLIC FUNCTIONS - Chart Line Management
     ******************************************************************/

    /**
     * Create a new line and add it to the central model
     * @param uniqueId - Unique identifier for the line
     * @param displayName - Display name for the line
     * @param color - Line color (hex string)
     * @param interfaceType - Interface type (e.g., "Serial", "TCP")
     * @param dataId - Data stream identifier
     */
    function createLine(uniqueId, displayName, color, interfaceType, dataId) {
        // Create line in renderer
        var lineSeries = root._internalRenderer.createLine(uniqueId, displayName, color)

        // Add to central model if available
        if (root.chartLineModel) {
            // Keep 0 as valid dataId (don't coerce to empty string).
            var safeDataId = (dataId !== undefined && dataId !== null) ? dataId : ""
            root.chartLineModel.addLine(
                uniqueId,
                displayName,
                color,
                interfaceType || "Manual",
                safeDataId,
                {},  // interfaceSettings
                lineSeries,
                root.chartId,      // Chart ID
                root.chartTitle    // Chart Title
            )
        }

        Logger.log_info("XYChartView: Created line '" + displayName + "' with ID " + uniqueId + " for chart " + root.chartId)
        return lineSeries
    }

    /**
     * Remove a line
     * @param uniqueId - Unique identifier of the line to remove
     */
    function removeLine(uniqueId) {
        root._internalRenderer.removeLine(uniqueId)
        if (root.chartLineModel) {
            root.chartLineModel.removeLine(uniqueId)
        }
        Logger.log_info("XYChartView: Removed line " + uniqueId)
    }

    /**
     * Get a line by ID from the central model
     * @param uniqueId - Unique identifier
     * @return Line object from model or null
     */
    function getLine(uniqueId) {
        if (root.chartLineModel) {
            return root.chartLineModel.getLine(uniqueId)
        }
        return null
    }

    /**
     * Append a point to a line
     * @param uniqueId - Line identifier
     * @param x - X coordinate
     * @param y - Y coordinate
     */
    function appendPoint(uniqueId, x, y) {
        root._internalRenderer.appendPoint(uniqueId, x, y)
    }

    /**
     * Append multiple points (batch)
     * @param uniqueId - Line identifier
     * @param points - Array of [x, y] tuples
     */
    function appendPointsBatch(uniqueId, points) {
        root._internalRenderer.appendPointsBatch(uniqueId, points)
    }

    /**
     * Clear all points from a line
     * @param uniqueId - Line identifier
     */
    function clearLine(uniqueId) {
        root._internalRenderer.clearLine(uniqueId)
    }

    /**
     * Clear all lines
     */
    function clearAll() {
        root._internalRenderer.clearAll()
    }

    /**
     * Zoom in
     */
    function zoomIn() {
        root._internalRenderer.zoomIn()
    }

    /**
     * Zoom out
     */
    function zoomOut() {
        root._internalRenderer.zoomOut()
    }

    /**
     * Reset zoom
     */
    function resetZoom() {
        root._internalRenderer.resetZoom()
    }

    /**
     * Fit to data
     */
    function fitToData() {
        root._internalRenderer.fitToData()
    }

    Component.onCompleted: {
        Logger.log_info("XYChartView initialized for chart: " + root.chartId)
    }

    Component.onDestruction: {
        Logger.log_info("XYChartView destroyed for chart: " + root.chartId)
    }
}
