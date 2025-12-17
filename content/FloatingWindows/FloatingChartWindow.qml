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
import Backend 1.0

Rectangle {
    id: floatingWindow

    // Public properties
    property string chartId: ""
    property string chartTitle: "Chart"
    property string chartType: "xy_line"  // ChartType enum value
    // Reference back to the App root (for centralized remove/cleanup)
    property var appRoot: null
    // Optional: backend connection associated with this window (used for Test charts)
    property string connectionId: ""
    property bool autoDeleteConnectionOnClose: false
    property bool isDocked: false
    property string dockPosition: ""  // "left", "right", "top", "bottom"

    // Expose chart view (which wraps the renderer and provides chart line management)
    property alias chartRenderer: chartLoader.item

    // Window state
    property bool isMinimized: false
    property bool isMaximized: false
    property int zOrder: 0
    property rect restoreGeometry: Qt.rect(100, 100, 800, 600)

    // Drag state
    property bool isDragging: false
    property bool isResizing: false
    property point dragStartPos: Qt.point(0, 0)
    property point windowStartPos: Qt.point(0, 0)

    // Visual feedback during dragging
    property color dragBorderColor: "#0078d4"
    property real dragShadowIntensity: 1.0

    // Docking preview
    property bool showDockingPreview: false
    property string previewDockPosition: ""

    // Performance
    property int dragUpdateThrottle: 8  // ~120fps for smooth dragging
    property var lastDragUpdate: Date.now()

    // Visual properties
    color: "#1e1e1e"
    border.color: isDragging ? dragBorderColor : "#3c3c3c"
    border.width: 2
    radius: 8
    // opacity and scale removed from root to prevent jitter during dragging

    // Default size
    width: 800
    height: 600

    states: [
        State {
            name: "maximized"
            when: floatingWindow.isMaximized
            AnchorChanges {
                target: floatingWindow
                anchors.left: floatingWindow.parent.left
                anchors.right: floatingWindow.parent.right
                anchors.top: floatingWindow.parent.top
                anchors.bottom: floatingWindow.parent.bottom
            }
        },
        State {
            name: "dockedLeft"
            when: floatingWindow.isDocked && floatingWindow.dockPosition === "left"
            AnchorChanges {
                target: floatingWindow
                anchors.left: floatingWindow.parent.left
                anchors.top: floatingWindow.parent.top
                anchors.bottom: floatingWindow.parent.bottom
            }
            PropertyChanges {
                target: floatingWindow
                width: floatingWindow.parent.width / 2
            }
        },
        State {
            name: "dockedRight"
            when: floatingWindow.isDocked && floatingWindow.dockPosition === "right"
            AnchorChanges {
                target: floatingWindow
                anchors.right: floatingWindow.parent.right
                anchors.top: floatingWindow.parent.top
                anchors.bottom: floatingWindow.parent.bottom
            }
            PropertyChanges {
                target: floatingWindow
                width: floatingWindow.parent.width / 2
            }
        },
        State {
            name: "dockedTop"
            when: floatingWindow.isDocked && floatingWindow.dockPosition === "top"
            AnchorChanges {
                target: floatingWindow
                anchors.left: floatingWindow.parent.left
                anchors.right: floatingWindow.parent.right
                anchors.top: floatingWindow.parent.top
            }
            PropertyChanges {
                target: floatingWindow
                height: floatingWindow.parent.height / 2
            }
        },
        State {
            name: "dockedBottom"
            when: floatingWindow.isDocked && floatingWindow.dockPosition === "bottom"
            AnchorChanges {
                target: floatingWindow
                anchors.left: floatingWindow.parent.left
                anchors.right: floatingWindow.parent.right
                anchors.bottom: floatingWindow.parent.bottom
            }
            PropertyChanges {
                target: floatingWindow
                height: floatingWindow.parent.height / 2
            }
        }
    ]

    // Z-order
    z: zOrder

    // Smooth animations for visual feedback
    Behavior on dragBorderColor {
        ColorAnimation { duration: 150 }
    }

    Behavior on dragShadowIntensity {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }

    Behavior on width {
        enabled: !floatingWindow.isDragging && !floatingWindow.isResizing
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Behavior on height {
        enabled: !floatingWindow.isDragging && !floatingWindow.isResizing
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    // Window shadow (optional) - disabled during drag/resize for performance
    layer.enabled: !floatingWindow.isDragging && !floatingWindow.isResizing
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
                cursorShape: (floatingWindow.isDocked || floatingWindow.isMaximized) ? Qt.ArrowCursor : Qt.SizeAllCursor

                property point clickPos: Qt.point(0, 0)
                // Use parent coordinates for deltas. Local mouse coords change while the window moves,
                // which causes jitter/undefined movement when computing deltas from mouse.x/mouse.y.
                property point pressPosInParent: Qt.point(0, 0)

                onPressed: (mouse) => {
                    if (floatingWindow.isDocked || floatingWindow.isMaximized) {
                        return
                    }
                    clickPos = Qt.point(mouse.x, mouse.y)
                    floatingWindow.dragStartPos = clickPos
                    floatingWindow.windowStartPos = Qt.point(floatingWindow.x, floatingWindow.y)
                    pressPosInParent = dragArea.mapToItem(floatingWindow.parent, mouse.x, mouse.y)
                    floatingWindow.isDragging = true

                    // Visual feedback: enhanced shadow only (no scale/opacity to prevent jitter)
                    floatingWindow.dragShadowIntensity = 1.3

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
                        // Throttle für Performance
                        var now = Date.now()
                        if (now - floatingWindow.lastDragUpdate < floatingWindow.dragUpdateThrottle) {
                            return
                        }
                        floatingWindow.lastDragUpdate = now

                        var currentPosInParent = dragArea.mapToItem(floatingWindow.parent, mouse.x, mouse.y)
                        var delta = Qt.point(currentPosInParent.x - pressPosInParent.x,
                                             currentPosInParent.y - pressPosInParent.y)
                        var nextX = floatingWindow.windowStartPos.x + delta.x
                        var nextY = floatingWindow.windowStartPos.y + delta.y

                        if (floatingWindow.parent) {
                            var maxX = Math.max(0, floatingWindow.parent.width - floatingWindow.width)
                            var maxY = Math.max(0, floatingWindow.parent.height - floatingWindow.height)
                            nextX = Math.max(0, Math.min(maxX, nextX))
                            nextY = Math.max(0, Math.min(maxY, nextY))
                        }

                        floatingWindow.x = nextX
                        floatingWindow.y = nextY

                        // Preview für Docking-Zones
                        checkDockingZonesPreview()
                    }
                }

                onReleased: {
                    floatingWindow.isDragging = false

                    // Reset visual feedback
                    floatingWindow.dragShadowIntensity = 1.0
                    floatingWindow.showDockingPreview = false

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
                        if (item.chartType !== undefined) {
                            item.chartType = floatingWindow.chartType
                        }
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
            property point pressPosInParent: Qt.point(0, 0)
            property size startSize: Qt.size(0, 0)

            onPressed: (mouse) => {
                clickPos = Qt.point(mouse.x, mouse.y)
                startSize = Qt.size(floatingWindow.width, floatingWindow.height)
                pressPosInParent = resizeHandle.mapToItem(floatingWindow.parent, mouse.x, mouse.y)
                floatingWindow.isResizing = true
            }

            onPositionChanged: (mouse) => {
                var currentPosInParent = resizeHandle.mapToItem(floatingWindow.parent, mouse.x, mouse.y)
                var delta = Qt.point(currentPosInParent.x - pressPosInParent.x,
                                     currentPosInParent.y - pressPosInParent.y)
                var maxW = floatingWindow.parent ? floatingWindow.parent.width : 1000000
                var maxH = floatingWindow.parent ? floatingWindow.parent.height : 1000000
                var minW = Math.min(400, maxW)
                var minH = Math.min(300, maxH)

                floatingWindow.width = Math.max(minW, Math.min(maxW, startSize.width + delta.x))
                floatingWindow.height = Math.max(minH, Math.min(maxH, startSize.height + delta.y))
                clampToParent()
            }

            onReleased: {
                floatingWindow.isResizing = false

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

    // Docking Zone Preview Overlay
    Rectangle {
        id: dockPreviewOverlay
        color: "#400078d4"
        border.color: "#0078d4"
        border.width: 3
        radius: 4
        visible: floatingWindow.showDockingPreview
        z: -1  // Behind window

        x: {
            if (!parent) return 0
            if (floatingWindow.previewDockPosition === "left") return 0
            if (floatingWindow.previewDockPosition === "right") return parent.width / 2
            return 0
        }

        y: {
            if (!parent) return 0
            if (floatingWindow.previewDockPosition === "top") return 0
            if (floatingWindow.previewDockPosition === "bottom") return parent.height / 2
            return 0
        }

        width: {
            if (!parent) return 0
            if (floatingWindow.previewDockPosition === "left" || floatingWindow.previewDockPosition === "right")
                return parent.width / 2
            return parent.width
        }

        height: {
            if (!parent) return 0
            if (floatingWindow.previewDockPosition === "top" || floatingWindow.previewDockPosition === "bottom")
                return parent.height / 2
            return parent.height
        }

        Behavior on x {
            enabled: !floatingWindow.isDragging
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
        Behavior on y {
            enabled: !floatingWindow.isDragging
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
        Behavior on width {
            enabled: !floatingWindow.isDragging
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
        Behavior on height {
            enabled: !floatingWindow.isDragging
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }

        Text {
            anchors.centerIn: parent
            text: {
                switch(floatingWindow.previewDockPosition) {
                    case "left": return "◀"
                    case "right": return "▶"
                    case "top": return "▲"
                    case "bottom": return "▼"
                    default: return "⊞"
                }
            }
            font.pixelSize: 48
            color: "#0078d4"
            opacity: 0.6
        }
    }

    // Functions
    function clampToParent() {
        if (!parent) return
        if (floatingWindow.isDocked || floatingWindow.isMaximized) return

        if (floatingWindow.width > parent.width) {
            floatingWindow.width = parent.width
        }
        if (floatingWindow.height > parent.height) {
            floatingWindow.height = parent.height
        }

        var maxX = Math.max(0, parent.width - floatingWindow.width)
        var maxY = Math.max(0, parent.height - floatingWindow.height)
        floatingWindow.x = Math.max(0, Math.min(maxX, floatingWindow.x))
        floatingWindow.y = Math.max(0, Math.min(maxY, floatingWindow.y))
    }

    Connections {
        target: floatingWindow.parent
        function onWidthChanged() { clampToParent() }
        function onHeightChanged() { clampToParent() }
    }

    Component.onCompleted: {
        clampToParent()
    }

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

        if (!floatingWindow.isMaximized) {
            floatingWindow.restoreGeometry = Qt.rect(floatingWindow.x, floatingWindow.y, floatingWindow.width, floatingWindow.height)
            floatingWindow.isMaximized = true
        } else {
            floatingWindow.isMaximized = false
            floatingWindow.x = floatingWindow.restoreGeometry.x
            floatingWindow.y = floatingWindow.restoreGeometry.y
            floatingWindow.width = floatingWindow.restoreGeometry.width
            floatingWindow.height = floatingWindow.restoreGeometry.height
            clampToParent()
        }
    }

    function closeWindow() {
        // Delegate to App for consistent cleanup (activeWindows, backend connection, sidebar refresh)
        if (appRoot && typeof appRoot.removeFloatingWindow === "function") {
            appRoot.removeFloatingWindow(floatingWindow.chartId)
            return
        }

        // Fallback (should not normally happen)
        if (chartRenderer && chartRenderer.chartLineModel) {
            chartRenderer.chartLineModel.removeLinesByChart(floatingWindow.chartId)
        }

        if (autoDeleteConnectionOnClose && connectionId && connectionId !== "") {
            try {
                Backend.stop_connection(connectionId)
                Backend.delete_connection(connectionId)
            } catch (e) {}
        }

        if (parent && parent.activeWindows && parent.activeWindows[floatingWindow.chartId]) {
            delete parent.activeWindows[floatingWindow.chartId]
        }

        if (typeof WindowManager !== "undefined" && WindowManager && WindowManager.removeWindow) {
            WindowManager.removeWindow(floatingWindow.chartId)
        }

        floatingWindow.destroy()
    }

    function checkDockingZonesPreview() {
        if (!parent) return

        var dockThreshold = 80
        var parentWidth = parent.width
        var parentHeight = parent.height

        var leftDist = floatingWindow.x
        var rightDist = parentWidth - (floatingWindow.x + floatingWindow.width)
        var topDist = floatingWindow.y
        var bottomDist = parentHeight - (floatingWindow.y + floatingWindow.height)

        var minDist = Math.min(leftDist, rightDist, topDist, bottomDist)

        if (minDist > dockThreshold) {
            floatingWindow.showDockingPreview = false
            floatingWindow.previewDockPosition = ""
            floatingWindow.dragBorderColor = "#0078d4"
            return
        }

        floatingWindow.showDockingPreview = true
        floatingWindow.dragBorderColor = "#00d455"  // Grün für gültige Zone

        if (minDist === leftDist) {
            floatingWindow.previewDockPosition = "left"
        } else if (minDist === rightDist) {
            floatingWindow.previewDockPosition = "right"
        } else if (minDist === topDist) {
            floatingWindow.previewDockPosition = "top"
        } else if (minDist === bottomDist) {
            floatingWindow.previewDockPosition = "bottom"
        }
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

        if (!floatingWindow.isDocked) {
            floatingWindow.restoreGeometry = Qt.rect(floatingWindow.x, floatingWindow.y, floatingWindow.width, floatingWindow.height)
        }

        floatingWindow.isDocked = true
        floatingWindow.dockPosition = edge
        floatingWindow.isMaximized = false

        // Notify windowManager (if available)
        if (typeof windowManager !== 'undefined' && windowManager !== null) {
            var parentWidth = parent.width
            var parentHeight = parent.height
            windowManager.dockWindow(floatingWindow.chartId, edge, parentWidth, parentHeight)
        }
    }

    function undock() {
        floatingWindow.isDocked = false
        floatingWindow.dockPosition = ""
        floatingWindow.x = floatingWindow.restoreGeometry.x
        floatingWindow.y = floatingWindow.restoreGeometry.y
        floatingWindow.width = floatingWindow.restoreGeometry.width
        floatingWindow.height = floatingWindow.restoreGeometry.height
        clampToParent()

        // Notify windowManager (if available)
        if (typeof windowManager !== 'undefined' && windowManager !== null) {
            windowManager.undockWindow(floatingWindow.chartId)
        }
    }

    Component.onDestruction: {
        // Safety: if window got destroyed without going through App.removeFloatingWindow
        if (parent && parent.activeWindows && parent.activeWindows[floatingWindow.chartId]) {
            delete parent.activeWindows[floatingWindow.chartId]
            if (appRoot && appRoot.chartWindow && appRoot.chartWindow.refreshAvailableCharts) {
                appRoot.chartWindow.refreshAvailableCharts()
            }
        }
    }
}
