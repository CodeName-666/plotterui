import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick3D 6.4
import Backend 1.0
import Common 1.0
import PlotterUi 1.0

/**
 * XYZChartRenderer.qml
 *
 * 3D Chart renderer for floating windows.
 * Displays XYZ scatter plots with full camera controls (orbit, pan, zoom).
 *
 * Expected properties from parent FloatingChartWindow:
 * - chartId: Unique identifier for this chart instance
 * - chartTitle: Display name for the chart
 */
Item {
    id: root

    // Public properties that can be set by parent
    property string chartId: ""
    property string chartTitle: "3D Chart"
    property var chartData: null  // Reference to chart data model

    // 3D View configuration
    property real initialCameraDistance: 50
    property real initialCameraElevation: 30  // degrees
    property real initialCameraAzimuth: 45    // degrees

    // Current camera state
    property real cameraDistance: initialCameraDistance
    property real cameraElevation: initialCameraElevation
    property real cameraAzimuth: initialCameraAzimuth

    // Axis ranges
    property real xMin: -10
    property real xMax: 10
    property real yMin: -10
    property real yMax: 10
    property real zMin: -10
    property real zMax: 10

    property bool _backendConnected: false
    property var _backendEvents: null

    // Internal state
    property var _scatterPlots: ({})  // Dictionary of scatter plots by uniqueId
    property var _pointModels: ({})   // Dictionary of point arrays by uniqueId

    // 3D View
    View3D {
        id: view3D
        anchors.fill: parent

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: "#1e1e1e"
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        // Main camera
        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(
                cameraDistance * Math.cos(cameraElevation * Math.PI / 180) * Math.cos(cameraAzimuth * Math.PI / 180),
                cameraDistance * Math.sin(cameraElevation * Math.PI / 180),
                cameraDistance * Math.cos(cameraElevation * Math.PI / 180) * Math.sin(cameraAzimuth * Math.PI / 180)
            )

            eulerRotation.x: -cameraElevation
            eulerRotation.y: cameraAzimuth

            clipNear: 1
            clipFar: 1000
            fieldOfView: 60
        }

        // Directional light (main light)
        DirectionalLight {
            eulerRotation.x: -30
            eulerRotation.y: 45
            brightness: 1.0
            castsShadow: false
        }

        // Ambient light
        DirectionalLight {
            eulerRotation.x: 30
            eulerRotation.y: -45
            brightness: 0.3
        }

        // Origin point
        Model {
            source: "#Sphere"
            scale: Qt.vector3d(0.2, 0.2, 0.2)
            position: Qt.vector3d(0, 0, 0)
            materials: PrincipledMaterial {
                baseColor: "#ff0000"
                metalness: 0.5
                roughness: 0.3
            }
        }

        // X Axis (Red)
        Model {
            id: xAxisLine
            source: "#Cylinder"
            position: Qt.vector3d((xMin + xMax) / 2, 0, 0)
            scale: Qt.vector3d(0.05, (xMax - xMin) / 2, 0.05)
            eulerRotation.z: 90
            materials: PrincipledMaterial {
                baseColor: "#ff0000"
                metalness: 0.3
                roughness: 0.5
            }
        }

        // Y Axis (Green)
        Model {
            id: yAxisLine
            source: "#Cylinder"
            position: Qt.vector3d(0, (yMin + yMax) / 2, 0)
            scale: Qt.vector3d(0.05, (yMax - yMin) / 2, 0.05)
            materials: PrincipledMaterial {
                baseColor: "#00ff00"
                metalness: 0.3
                roughness: 0.5
            }
        }

        // Z Axis (Blue)
        Model {
            id: zAxisLine
            source: "#Cylinder"
            position: Qt.vector3d(0, 0, (zMin + zMax) / 2)
            scale: Qt.vector3d(0.05, (zMax - zMin) / 2, 0.05)
            eulerRotation.x: 90
            materials: PrincipledMaterial {
                baseColor: "#0000ff"
                metalness: 0.3
                roughness: 0.5
            }
        }

        // Grid XY Plane (at Z=0)
        Repeater {
            model: 21
            Model {
                source: "#Cylinder"
                property real pos: -10 + index
                position: Qt.vector3d(pos, 0, 0)
                scale: Qt.vector3d(0.01, 10, 0.01)
                eulerRotation.z: 90
                materials: PrincipledMaterial {
                    baseColor: index === 10 ? "#555555" : "#333333"
                    metalness: 0
                    roughness: 1
                }
            }
        }

        Repeater {
            model: 21
            Model {
                source: "#Cylinder"
                property real pos: -10 + index
                position: Qt.vector3d(0, pos, 0)
                scale: Qt.vector3d(0.01, 10, 0.01)
                materials: PrincipledMaterial {
                    baseColor: index === 10 ? "#555555" : "#333333"
                    metalness: 0
                    roughness: 1
                }
            }
        }

        // Container for scatter plot points (will be populated dynamically)
        Node {
            id: scatterPlotContainer
        }

        // Mouse interaction area
        MouseArea {
            id: mouseArea3D
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            hoverEnabled: true

            property real lastMouseX: 0
            property real lastMouseY: 0

            // Mouse wheel zoom
            onWheel: function(wheel) {
                var factor = wheel.angleDelta.y > 0 ? 0.9 : 1.1
                root.cameraDistance = Math.max(5, Math.min(200, root.cameraDistance * factor))
            }

            onPressed: function(mouse) {
                lastMouseX = mouse.x
                lastMouseY = mouse.y
            }

            onPositionChanged: function(mouse) {
                if (pressedButtons & Qt.LeftButton) {
                    // Orbit rotation
                    var deltaX = mouse.x - lastMouseX
                    var deltaY = mouse.y - lastMouseY

                    root.cameraAzimuth += deltaX * 0.5
                    root.cameraElevation = Math.max(-89, Math.min(89, root.cameraElevation - deltaY * 0.5))

                    lastMouseX = mouse.x
                    lastMouseY = mouse.y
                } else if (pressedButtons & Qt.RightButton) {
                    // Pan (not yet fully implemented - requires camera target)
                    lastMouseX = mouse.x
                    lastMouseY = mouse.y
                }
            }
        }
    }

    // Axis labels overlay (2D overlay on top of 3D view)
    Item {
        anchors.fill: parent

        Text {
            text: "X"
            color: "#ff0000"
            font.pixelSize: 16
            font.bold: true
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
        }

        Text {
            text: "Y"
            color: "#00ff00"
            font.pixelSize: 16
            font.bold: true
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
        }

        Text {
            text: "Z"
            color: "#0000ff"
            font.pixelSize: 16
            font.bold: true
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 10
            anchors.topMargin: 10
        }
    }

    // Control panel overlay (top-right corner)
    Rectangle {
        id: controlPanel
        width: 220
        height: controlColumn.height + 20
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        color: "#2d2d2d"
        radius: 6
        opacity: 0.95
        border.color: "#404040"
        border.width: 1
        z: 100

        Column {
            id: controlColumn
            anchors.centerIn: parent
            spacing: 8
            width: parent.width - 20

            Text {
                text: "3D Camera Controls"
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

            // Zoom controls
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "Zoom:"
                    color: "#cccccc"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }

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
                    onClicked: root.resetCamera()
                    ToolTip.text: "Reset Camera"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }
            }

            // View angle presets
            Text {
                text: "View Angle:"
                color: "#cccccc"
                font.pixelSize: 11
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "Front"
                    width: 60
                    height: 28
                    font.pixelSize: 10
                    onClicked: root.setViewFront()
                    ToolTip.text: "Front View (XY)"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }

                Button {
                    text: "Top"
                    width: 60
                    height: 28
                    font.pixelSize: 10
                    onClicked: root.setViewTop()
                    ToolTip.text: "Top View (XZ)"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }

                Button {
                    text: "Side"
                    width: 60
                    height: 28
                    font.pixelSize: 10
                    onClicked: root.setViewSide()
                    ToolTip.text: "Side View (YZ)"
                    ToolTip.visible: hovered
                    ToolTip.delay: 500
                }
            }

            // Orbit controls
            Text {
                text: "Orbit:"
                color: "#cccccc"
                font.pixelSize: 11
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                columns: 3
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Item { width: 35; height: 28 }
                Button {
                    text: "↑"
                    width: 35
                    height: 28
                    onClicked: root.orbitUp()
                }
                Item { width: 35; height: 28 }

                Button {
                    text: "←"
                    width: 35
                    height: 28
                    onClicked: root.orbitLeft()
                }
                Button {
                    text: "⊙"
                    width: 35
                    height: 28
                    onClicked: root.resetCamera()
                    ToolTip.text: "Center"
                    ToolTip.visible: hovered
                }
                Button {
                    text: "→"
                    width: 35
                    height: 28
                    onClicked: root.orbitRight()
                }

                Item { width: 35; height: 28 }
                Button {
                    text: "↓"
                    width: 35
                    height: 28
                    onClicked: root.orbitDown()
                }
                Item { width: 35; height: 28 }
            }

            // Camera info
            Rectangle {
                width: parent.width
                height: 1
                color: "#404040"
            }

            Text {
                text: "Distance: " + root.cameraDistance.toFixed(1)
                color: "#cccccc"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Elevation: " + root.cameraElevation.toFixed(1) + "°"
                color: "#cccccc"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Azimuth: " + root.cameraAzimuth.toFixed(1) + "°"
                color: "#cccccc"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    /*******************************************************************
     * PUBLIC FUNCTIONS - Camera Controls
     ******************************************************************/

    /**
     * Zoom in by 20%
     */
    function zoomIn() {
        root.cameraDistance = Math.max(5, root.cameraDistance * 0.8)
    }

    /**
     * Zoom out by 25%
     */
    function zoomOut() {
        root.cameraDistance = Math.min(200, root.cameraDistance * 1.25)
    }

    /**
     * Reset camera to initial position
     */
    function resetCamera() {
        root.cameraDistance = root.initialCameraDistance
        root.cameraElevation = root.initialCameraElevation
        root.cameraAzimuth = root.initialCameraAzimuth
    }

    /**
     * Orbit camera left (decrease azimuth)
     */
    function orbitLeft() {
        root.cameraAzimuth -= 15
    }

    /**
     * Orbit camera right (increase azimuth)
     */
    function orbitRight() {
        root.cameraAzimuth += 15
    }

    /**
     * Orbit camera up (increase elevation)
     */
    function orbitUp() {
        root.cameraElevation = Math.min(89, root.cameraElevation + 15)
    }

    /**
     * Orbit camera down (decrease elevation)
     */
    function orbitDown() {
        root.cameraElevation = Math.max(-89, root.cameraElevation - 15)
    }

    /**
     * Set camera to front view (looking at XY plane)
     */
    function setViewFront() {
        root.cameraElevation = 0
        root.cameraAzimuth = 0
        root.cameraDistance = 30
    }

    /**
     * Set camera to top view (looking down at XZ plane)
     */
    function setViewTop() {
        root.cameraElevation = 89
        root.cameraAzimuth = 0
        root.cameraDistance = 30
    }

    /**
     * Set camera to side view (looking at YZ plane)
     */
    function setViewSide() {
        root.cameraElevation = 0
        root.cameraAzimuth = 90
        root.cameraDistance = 30
    }

    /*******************************************************************
     * PUBLIC FUNCTIONS - Scatter Plot Management
     ******************************************************************/

    /**
     * Create a new 3D scatter plot
     * @param uniqueId - Unique identifier for the scatter plot
     * @param displayName - Display name for the scatter plot
     * @param color - Point color (hex string)
     * @return Scatter plot container node
     */
    function createScatterPlot(uniqueId, displayName, color) {
        if (_scatterPlots[uniqueId]) {
            Logger.log_warning("XYZChartRenderer: Scatter plot already exists: " + uniqueId)
            return _scatterPlots[uniqueId]
        }

        // Create a container node for this scatter plot
        var component = Qt.createComponent("qrc:/qt/qml/content/ChartTypes/ScatterPlotNode.qml")
        if (component.status !== Component.Ready) {
            // Fallback: create simple Node
            Logger.log_warning("XYZChartRenderer: ScatterPlotNode not found, using fallback")
            var node = Qt.createQmlObject('import QtQuick3D 6.4; Node {}', scatterPlotContainer)
            node.objectName = displayName
            _scatterPlots[uniqueId] = node
            _pointModels[uniqueId] = []
            return node
        }

        var scatterNode = component.createObject(scatterPlotContainer, {
            "objectName": displayName,
            "pointColor": color || "#ffff00"
        })

        _scatterPlots[uniqueId] = scatterNode
        _pointModels[uniqueId] = []

        Logger.log_info("XYZChartRenderer: Created scatter plot '" + displayName + "' with ID " + uniqueId)
        return scatterNode
    }

    /**
     * Append a single 3D point to a scatter plot
     * @param uniqueId - Scatter plot identifier
     * @param x - X coordinate
     * @param y - Y coordinate
     * @param z - Z coordinate
     */
    function appendPoint3D(uniqueId, x, y, z) {
        if (!_scatterPlots[uniqueId]) {
            Logger.log_warning("XYZChartRenderer: Scatter plot not found: " + uniqueId)
            return
        }

        // Create a small sphere for each point
        var component = Qt.createComponent("qrc:/qt/qml/QtQuick3D/Model")
        if (component.status === Component.Ready) {
            var point = component.createObject(_scatterPlots[uniqueId], {
                "source": "#Sphere",
                "position": Qt.vector3d(x, y, z),
                "scale": Qt.vector3d(0.3, 0.3, 0.3)
            })

            // Create material
            var matComponent = Qt.createComponent("qrc:/qt/qml/QtQuick3D/PrincipledMaterial")
            if (matComponent.status === Component.Ready) {
                var material = matComponent.createObject(point, {
                    "baseColor": "#ffff00",
                    "metalness": 0.3,
                    "roughness": 0.5
                })
                point.materials = [material]
            }

            _pointModels[uniqueId].push(point)

            // Limit maximum points for performance
            var maxPoints = 50000
            if (_pointModels[uniqueId].length > maxPoints) {
                var oldPoint = _pointModels[uniqueId].shift()
                oldPoint.destroy()
            }
        }
    }

    /**
     * Append multiple 3D points at once (BATCH - much faster!)
     * @param uniqueId - Scatter plot identifier
     * @param points - Array of [x, y, z] tuples
     */
    function appendPointsBatch3D(uniqueId, points) {
        if (!_scatterPlots[uniqueId]) {
            Logger.log_warning("XYZChartRenderer: Scatter plot not found: " + uniqueId)
            return
        }

        if (!points || points.length === 0) {
            return
        }

        var maxPoints = 50000
        var totalAfterAdd = _pointModels[uniqueId].length + points.length

        // Remove old points if necessary
        if (totalAfterAdd > maxPoints) {
            var toRemove = totalAfterAdd - maxPoints
            for (var i = 0; i < toRemove; i++) {
                var oldPoint = _pointModels[uniqueId].shift()
                if (oldPoint) {
                    oldPoint.destroy()
                }
            }
        }

        // Batch create points (more efficient than individual creation)
        for (var j = 0; j < points.length; j++) {
            var p = points[j]
            appendPoint3D(uniqueId, p[0], p[1], p[2])
        }

        Logger.log_info("XYZChartRenderer: Added " + points.length + " points to scatter plot " + uniqueId)
    }

    /**
     * Clear all points from a scatter plot
     * @param uniqueId - Scatter plot identifier
     */
    function clearPoints(uniqueId) {
        if (!_pointModels[uniqueId]) {
            return
        }

        // Destroy all point models
        for (var i = 0; i < _pointModels[uniqueId].length; i++) {
            _pointModels[uniqueId][i].destroy()
        }
        _pointModels[uniqueId] = []
    }

    /**
     * Remove a scatter plot
     * @param uniqueId - Unique identifier of the scatter plot to remove
     */
    function removeScatterPlot(uniqueId) {
        if (_scatterPlots[uniqueId]) {
            clearPoints(uniqueId)
            _scatterPlots[uniqueId].destroy()
            delete _scatterPlots[uniqueId]
            delete _pointModels[uniqueId]
            Logger.log_info("XYZChartRenderer: Removed scatter plot " + uniqueId)
        }
    }

    /**
     * Clear all scatter plots
     */
    function clearAll() {
        for (var plotId in _scatterPlots) {
            clearPoints(plotId)
        }
    }

    /**
     * Update axis ranges based on data
     * @param minX, maxX, minY, maxY, minZ, maxZ - New axis ranges
     */
    function updateAxisRanges(minX, maxX, minY, maxY, minZ, maxZ) {
        root.xMin = minX
        root.xMax = maxX
        root.yMin = minY
        root.yMax = maxY
        root.zMin = minZ
        root.zMax = maxZ
    }

    /*******************************************************************
     * COMPONENT LIFECYCLE
     ******************************************************************/

    Component.onCompleted: {
        Logger.log_info("XYZChartRenderer initialized for chart: " + root.chartId)
        _tryConnectBackendEvents(40)
    }

    Component.onDestruction: {
        Logger.log_info("XYZChartRenderer destroyed for chart: " + root.chartId)
        _disconnectBackendEvents()

        // Cleanup all scatter plots
        for (var plotId in _scatterPlots) {
            removeScatterPlot(plotId)
        }
    }

    function _tryConnectBackendEvents(attemptsLeft) {
        if (root._backendConnected) {
            return
        }

        var controller = null
        try {
            controller = App.get_app()
        } catch (e) {
            controller = null
        }

        if (!controller || typeof controller.events !== "function") {
            if (attemptsLeft > 0) {
                return Qt.callLater(function() { _tryConnectBackendEvents(attemptsLeft - 1) })
            }
            Logger.log_warning("XYZChartRenderer: Backend controller not available - no live data will be shown")
            return
        }

        var events = controller.events()
        if (!events) {
            if (attemptsLeft > 0) {
                return Qt.callLater(function() { _tryConnectBackendEvents(attemptsLeft - 1) })
            }
            Logger.log_warning("XYZChartRenderer: Backend events not available - no live data will be shown")
            return
        }

        if (events.append_graph_point_3d) {
            events.append_graph_point_3d.connect(handleGraphPoint3D)
        }
        if (events.append_graph_points_batch_3d) {
            events.append_graph_points_batch_3d.connect(handleGraphPointsBatch3D)
        }

        root._backendEvents = events
        root._backendConnected = true
        Logger.log_info("XYZChartRenderer: Connected to backend 3D graph events for chart: " + root.chartId)
    }

    function _disconnectBackendEvents() {
        if (!root._backendEvents) {
            root._backendConnected = false
            return
        }

        try {
            if (root._backendEvents.append_graph_point_3d) {
                root._backendEvents.append_graph_point_3d.disconnect(handleGraphPoint3D)
            }
        } catch (e) {}

        try {
            if (root._backendEvents.append_graph_points_batch_3d) {
                root._backendEvents.append_graph_points_batch_3d.disconnect(handleGraphPointsBatch3D)
            }
        } catch (e) {}

        root._backendConnected = false
        root._backendEvents = null
    }

    /*******************************************************************
     * INTERNAL FUNCTIONS - Backend Event Handlers (TODO)
     ******************************************************************/

    /**
     * Handle single 3D point from backend
     */
    function handleGraphPoint3D(uniqueId, point) {
        if (!root || !point) return

        var x = point.x !== undefined ? point.x : 0
        var y = point.y !== undefined ? point.y : 0
        var z = point.z !== undefined ? point.z : 0

        root.appendPoint3D(uniqueId, x, y, z)
    }

    /**
     * Handle batch 3D points from backend
     */
    function handleGraphPointsBatch3D(uniqueId, points) {
        if (!root) return
        root.appendPointsBatch3D(uniqueId, points)
    }
}
