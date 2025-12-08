import QtQuick 6.4
import Common 1.0
import Backend 1.0

/**
 * Data model for managing chart lines.
 * Each line represents a data source with unique ID, display name, color, and settings.
 */
ListModel {
    id: chartLineModel

    /**
     * Add a new chart line to the model
     *
     * @param uniqueId - Unique identifier (format: "interface_id", e.g., "Serial_0")
     * @param displayName - User-friendly name for display
     * @param color - Line color (hex string or Qt color)
     * @param interfaceType - Interface type (Serial, MQTT, Telnet, Test)
     * @param dataId - Data ID (0-255) from the protocol
     * @param interfaceSettings - Interface-specific settings object
     * @param seriesRef - Reference to Qt Charts series object
     */
    function addLine(uniqueId, displayName, color, interfaceType, dataId, interfaceSettings, seriesRef) {
        // Check if line already exists
        if (getLineIndex(uniqueId) !== -1) {
            Logger.log_warning("ChartLineModel: Line " + uniqueId + " already exists")
            return false
        }

        append({
            "uniqueId": uniqueId,
            "displayName": displayName,
            "color": color,
            "interfaceType": interfaceType,
            "dataId": dataId,
            "interfaceSettings": interfaceSettings || {},
            "visible": true,
            "seriesRef": seriesRef || null
        })

        Logger.log_info("ChartLineModel: Added line " + uniqueId + " (" + displayName + ")")
        return true
    }

    /**
     * Remove a chart line from the model
     *
     * @param uniqueId - Unique identifier of the line to remove
     */
    function removeLine(uniqueId) {
        var index = getLineIndex(uniqueId)
        if (index === -1) {
            Logger.log_warning("ChartLineModel: Cannot remove - line " + uniqueId + " not found")
            return false
        }

        remove(index)
        Logger.log_info("ChartLineModel: Removed line " + uniqueId)
        return true
    }

    /**
     * Update properties of an existing chart line
     *
     * @param uniqueId - Unique identifier of the line to update
     * @param properties - Object with properties to update (displayName, color, interfaceSettings, etc.)
     */
    function updateLine(uniqueId, properties) {
        var index = getLineIndex(uniqueId)
        if (index === -1) {
            Logger.log_warning("ChartLineModel: Cannot update - line " + uniqueId + " not found")
            return false
        }

        for (var prop in properties) {
            if (properties.hasOwnProperty(prop)) {
                setProperty(index, prop, properties[prop])
            }
        }

        Logger.log_debug("ChartLineModel: Updated line " + uniqueId)
        return true
    }

    /**
     * Get a chart line by unique ID
     *
     * @param uniqueId - Unique identifier of the line
     * @returns Line object or null if not found
     */
    function getLine(uniqueId) {
        var index = getLineIndex(uniqueId)
        if (index === -1) {
            return null
        }
        return get(index)
    }

    /**
     * Get index of a chart line by unique ID
     *
     * @param uniqueId - Unique identifier of the line
     * @returns Index in the model or -1 if not found
     */
    function getLineIndex(uniqueId) {
        for (var i = 0; i < count; i++) {
            if (get(i).uniqueId === uniqueId) {
                return i
            }
        }
        return -1
    }

    /**
     * Get all chart lines as an array
     *
     * @returns Array of all line objects
     */
    function getAllLines() {
        var lines = []
        for (var i = 0; i < count; i++) {
            lines.push(get(i))
        }
        return lines
    }

    /**
     * Toggle visibility of a chart line
     *
     * @param uniqueId - Unique identifier of the line
     * @param visible - New visibility state (optional, toggles if not provided)
     */
    function toggleVisibility(uniqueId, visible) {
        var index = getLineIndex(uniqueId)
        if (index === -1) {
            return false
        }

        var line = get(index)
        var newVisibility = visible !== undefined ? visible : !line.visible

        setProperty(index, "visible", newVisibility)

        // Update series visibility if series reference exists
        if (line.seriesRef) {
            line.seriesRef.visible = newVisibility
        }

        Logger.log_debug("ChartLineModel: Toggled visibility of " + uniqueId + " to " + newVisibility)
        return true
    }

    /**
     * Set series reference for a chart line
     *
     * @param uniqueId - Unique identifier of the line
     * @param seriesRef - Reference to Qt Charts series object
     */
    function setSeriesRef(uniqueId, seriesRef) {
        var index = getLineIndex(uniqueId)
        if (index === -1) {
            return false
        }

        setProperty(index, "seriesRef", seriesRef)
        Logger.log_debug("ChartLineModel: Set series reference for " + uniqueId)
        return true
    }

    /**
     * Clear all chart lines
     */
    function clearAll() {
        Logger.log_info("ChartLineModel: Clearing all lines")
        clear()
    }

    /**
     * Get count of visible lines
     *
     * @returns Number of visible lines
     */
    function getVisibleCount() {
        var visibleCount = 0
        for (var i = 0; i < count; i++) {
            if (get(i).visible) {
                visibleCount++
            }
        }
        return visibleCount
    }

    /**
     * Get lines by interface type
     *
     * @param interfaceType - Interface type to filter by
     * @returns Array of line objects matching the interface
     */
    function getLinesByInterface(interfaceType) {
        var lines = []
        for (var i = 0; i < count; i++) {
            var line = get(i)
            if (line.interfaceType === interfaceType) {
                lines.push(line)
            }
        }
        return lines
    }
}
