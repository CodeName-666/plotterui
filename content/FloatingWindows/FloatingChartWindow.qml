/**
 * FloatingChartWindow.qml
 *
 * Floating, movable, resizable chart window component.
 * Part of the Phase 1 floating multi-chart-type system.
 *
 * Features:
 * - Drag & drop movement
 * - Window chrome (title bar, close/minimize buttons)
 * - Docking to screen edges
 * - Z-order management
 * - Per-window chart type (XY Line, XY Scatter, XYZ Surface, etc.)
 */

import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 6.4
import Qt5Compat.GraphicalEffects
import Common 1.0

Rectangle {
    id: floatingWindow

    // Public properties
    property string chartId: ""
    property string chartTitle: "Chart"
    property string chartType: "xy_line"  // ChartType enum value
    property bool isDocked: false
    property string dockPosition: ""  // "left", "right", "top", "bottom"

    // Expose chart view (which wraps the renderer and provides chart line management)
    property alias chartRenderer: chartLoader.item

    // Window state
    property bool isMinimized: false
    property bool isMaximized: false
    property int zOrder: 0

    // Drag state
    property bool isDragging: false
    property point dragStartPos: Qt.point(0, 0)
    property point windowStartPos: Qt.point(0, 0)

    // Visual properties
    color: "#1e1e1e"
    border.color: isDragging ? "#0078d4" : "#3c3c3c"
    border.width: 2
    radius: 8

    // Default size
    width: 800
    height: 600

    // Z-order
    z: zOrder

    // Window shadow (optional)
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 24
        color: "#80000000"
        transparentBorder: true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Title Bar (Window Chrome)
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#2d2d2d"
            radius: floatingWindow.radius

            // Drag area
            MouseArea {
                id: dragArea
                anchors.fill: parent
                cursorShape: Qt.SizeAllCursor

                property point clickPos: Qt.point(0, 0)

                onPressed: (mouse) => {
                    clickPos = Qt.point(mouse.x, mouse.y)
                    floatingWindow.dragStartPos = clickPos
                    floatingWindow.windowStartPos = Qt.point(floatingWindow.x, floatingWindow.y)
                    floatingWindow.isDragging = true

                    // Bring to front (if windowManager is available)
                    if (typeof windowManager !== 'undefined' && windowManager !== null) {
                        windowManager.bringToFront(floatingWindow.chartId)
                    } else {
                        // Fallback: increase z-order manually
                        floatingWindow.z = 1000 + Date.now() % 1000
                    }
                }

                onPositionChanged: (mouse) => {
                    if (floatingWindow.isDragging && !floatingWindow.isDocked) {
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        floatingWindow.x = floatingWindow.windowStartPos.x + delta.x
                        floatingWindow.y = floatingWindow.windowStartPos.y + delta.y
                    }
                }

                onReleased: {
                    floatingWindow.isDragging = false

                    // Check for docking zones
                    checkDockingZones()

                    // Save window position (if windowManager is available)
                    if (typeof windowManager !== 'undefined' && windowManager !== null) {
                        windowManager.updateWindowPosition(
                            floatingWindow.chartId,
                            floatingWindow.x,
                            floatingWindow.y,
                            floatingWindow.width,
                            floatingWindow.height
                        )
                    }
                }

                onDoubleClicked: {
                    // Toggle maximize
                    toggleMaximize()
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 8

                // Window icon
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    color: "#0078d4"
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: getChartTypeIcon(floatingWindow.chartType)
                        font.pixelSize: 14
                        color: "white"
                    }
                }

                // Title
                Text {
                    Layout.fillWidth: true
                    text: floatingWindow.chartTitle
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                    elide: Text.ElideRight
                }

                // Chart type label
                Text {
                    text: getChartTypeLabel(floatingWindow.chartType)
                    font.pixelSize: 11
                    color: "#808080"
                }

                // Minimize button
                ToolButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    text: "−"
                    font.pixelSize: 16

                    onClicked: {
                        toggleMinimize()
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#3c3c3c" : "transparent"
                        radius: 4
                    }
                }

                // Maximize button
                ToolButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    text: floatingWindow.isMaximized ? "◱" : "□"
                    font.pixelSize: 14

                    onClicked: {
                        toggleMaximize()
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#3c3c3c" : "transparent"
                        radius: 4
                    }
                }

                // Close button
                ToolButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    text: "×"
                    font.pixelSize: 20

                    onClicked: {
                        closeWindow()
                    }

                    background: Rectangle {
                        color: parent.hovered ? "#e81123" : "transparent"
                        radius: 4
                    }
                }
            }
        }

        // Chart content area
        Rectangle {
            id: chartContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252525"
            visible: !floatingWindow.isMinimized

            // Chart renderer will be loaded here dynamically
            Loader {
                id: chartLoader
                anchors.fill: parent
                anchors.margins: 8

                source: getChartRendererQml(floatingWindow.chartType)

                onLoaded: {
                    // Pass properties to the loaded chart view
                    if (item) {
                        item.chartId = floatingWindow.chartId
                        item.chartTitle = floatingWindow.chartTitle
                    }
                }

                onStatusChanged: {
                    if (status === Loader.Error) {
                        console.error("FloatingChartWindow: Failed to load chart renderer:", source)
                    } else if (status === Loader.Ready) {
                        console.log("FloatingChartWindow: Chart renderer loaded successfully")
                    }
                }
            }

            // Placeholder when no chart loaded
            Text {
                anchors.centerIn: parent
                text: "No chart loaded"
                font.pixelSize: 16
                color: "#808080"
                visible: chartLoader.status !== Loader.Ready
            }
        }
    }

    // Resize handles (bottom-right corner)
    Rectangle {
        id: resizeHandle
        width: 16
        height: 16
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        color: "#3c3c3c"
        radius: 2
        visible: !floatingWindow.isMinimized && !floatingWindow.isMaximized && !floatingWindow.isDocked

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor

            property point clickPos: Qt.point(0, 0)
            property size startSize: Qt.size(0, 0)

            onPressed: (mouse) => {
                clickPos = Qt.point(mouse.x, mouse.y)
                startSize = Qt.size(floatingWindow.width, floatingWindow.height)
            }

            onPositionChanged: (mouse) => {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                floatingWindow.width = Math.max(400, startSize.width + delta.x)
                floatingWindow.height = Math.max(300, startSize.height + delta.y)
            }

            onReleased: {
                // Save new size (if windowManager is available)
                if (typeof windowManager !== 'undefined' && windowManager !== null) {
                    windowManager.updateWindowPosition(
                        floatingWindow.chartId,
                        floatingWindow.x,
                        floatingWindow.y,
                        floatingWindow.width,
                        floatingWindow.height
                    )
                }
            }
        }
    }

    // Functions
    function getChartTypeIcon(type) {
        switch(type) {
            case "xy_line": return "📈"
            case "xy_scatter": return "⚬"
            case "xyz_surface": return "🗻"
            case "xyz_scatter": return "⬡"
            case "bar": return "📊"
            case "heatmap": return "🔥"
            default: return "📊"
        }
    }

    function getChartTypeLabel(type) {
        switch(type) {
            case "xy_line": return "XY Line"
            case "xy_scatter": return "XY Scatter"
            case "xyz_surface": return "XYZ Surface"
            case "xyz_scatter": return "XYZ Scatter"
            case "bar": return "Bar Chart"
            case "heatmap": return "Heatmap"
            default: return "Unknown"
        }
    }

    function getChartRendererQml(type) {
        switch(type) {
            case "xy_line":
            case "xy_scatter":
                return "../ChartTypes/XYChartView.qml"
            case "xyz_surface":
            case "xyz_scatter":
                return "../ChartTypes/XYZChartRenderer.qml"
            default:
                return ""
        }
    }

    function toggleMinimize() {
        floatingWindow.isMinimized = !floatingWindow.isMinimized
        if (floatingWindow.isMinimized) {
            floatingWindow.height = titleBar.height
        } else {
            floatingWindow.height = 600  // Restore default height
        }
    }

    function toggleMaximize() {
        if (floatingWindow.isDocked) {
            undock()
        }

        floatingWindow.isMaximized = !floatingWindow.isMaximized

        if (floatingWindow.isMaximized) {
            // Save current geometry
            floatingWindow.windowStartPos = Qt.point(floatingWindow.x, floatingWindow.y)

            // Maximize to parent bounds
            floatingWindow.x = 0
            floatingWindow.y = 0
            floatingWindow.width = parent.width
            floatingWindow.height = parent.height
        } else {
            // Restore
            floatingWindow.x = floatingWindow.windowStartPos.x
            floatingWindow.y = floatingWindow.windowStartPos.y
            floatingWindow.width = 800
            floatingWindow.height = 600
        }
    }

    function closeWindow() {
        // Remove all lines belonging to this chart from the central model
        if (chartRenderer && chartRenderer.chartLineModel) {
            chartRenderer.chartLineModel.removeLinesByChart(floatingWindow.chartId)
            console.log("FloatingChartWindow: Removed all lines for chart " + floatingWindow.chartId)
        }

        // Remove from windowManager (if available)
        if (typeof windowManager !== 'undefined' && windowManager !== null) {
            windowManager.removeWindow(floatingWindow.chartId)
        }

        // Destroy the window
        floatingWindow.destroy()
    }

    function checkDockingZones() {
        if (!parent) return

        var dockThreshold = 50
        var parentWidth = parent.width
        var parentHeight = parent.height

        // Check left edge
        if (floatingWindow.x < dockThreshold) {
            dockToEdge("left")
        }
        // Check right edge
        else if (floatingWindow.x + floatingWindow.width > parentWidth - dockThreshold) {
            dockToEdge("right")
        }
        // Check top edge
        else if (floatingWindow.y < dockThreshold) {
            dockToEdge("top")
        }
        // Check bottom edge
        else if (floatingWindow.y + floatingWindow.height > parentHeight - dockThreshold) {
            dockToEdge("bottom")
        }
    }

    function dockToEdge(edge) {
        if (!parent) return

        floatingWindow.isDocked = true
        floatingWindow.dockPosition = edge

        var parentWidth = parent.width
        var parentHeight = parent.height

        switch(edge) {
            case "left":
                floatingWindow.x = 0
                floatingWindow.y = 0
                floatingWindow.width = parentWidth / 2
                floatingWindow.height = parentHeight
                break
            case "right":
                floatingWindow.x = parentWidth / 2
                floatingWindow.y = 0
                floatingWindow.width = parentWidth / 2
                floatingWindow.height = parentHeight
                break
            case "top":
                floatingWindow.x = 0
                floatingWindow.y = 0
                floatingWindow.width = parentWidth
                floatingWindow.height = parentHeight / 2
                break
            case "bottom":
                floatingWindow.x = 0
                floatingWindow.y = parentHeight / 2
                floatingWindow.width = parentWidth
                floatingWindow.height = parentHeight / 2
                break
        }

        // Notify windowManager (if available)
        if (typeof windowManager !== 'undefined' && windowManager !== null) {
            windowManager.dockWindow(floatingWindow.chartId, edge, parentWidth, parentHeight)
        }
    }

    function undock() {
        floatingWindow.isDocked = false
        floatingWindow.dockPosition = ""
        floatingWindow.width = 800
        floatingWindow.height = 600

        // Notify windowManager (if available)
        if (typeof windowManager !== 'undefined' && windowManager !== null) {
            windowManager.undockWindow(floatingWindow.chartId)
        }
    }
}
