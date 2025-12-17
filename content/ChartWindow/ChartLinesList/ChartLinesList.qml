import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import Common 1.0

/**
 * ChartLinesList.qml (Tabbed)
 *
 * Right-side management panel:
 * 1) Charts view: chart lines grouped/labelled by chart
 * 2) Signals view: global signal list (add/remove/assign)
 * 3) Charts view: manage charts (add/remove/rename)
 */
Item {
    id: root

    // Compatibility signals (ChartWindow already listens to these)
    signal lineVisibilityToggled(string lineKey, bool visible)
    signal lineSelected(string lineKey)
    signal collapseToggled()

    // New management requests (handled by ChartWindow)
    signal addSignalRequested()
    signal removeSignalRequested(string uniqueId)
    signal setSignalChartsRequested(string uniqueId, var chartIds)
    signal createChartRequested(string chartType, string chartTitle)
    signal removeChartRequested(string chartId)
    signal renameChartRequested(string chartId, string chartTitle)

    property bool isCollapsed: false
    property var chartLineModel: null
    property var availableCharts: [] // [{chartId, chartTitle, chartType}]

    // Internal models
    ListModel { id: signalsModel }
    ListModel { id: chartsModel }
    ListModel { id: assignChartsModel }

    function _isXYChart(chartType) {
        return chartType === "xy_line" || chartType === "xy_scatter"
    }

    function _refreshSignalsModel() {
        signalsModel.clear()
        if (!root.chartLineModel) return

        var map = ({})
        for (var i = 0; i < root.chartLineModel.count; i++) {
            var line = root.chartLineModel.get(i)
            var key = line.uniqueId
            if (!map[key]) {
                map[key] = {
                    uniqueId: line.uniqueId,
                    lineKey: line.lineKey,
                    displayName: line.displayName,
                    color: line.color,
                    interfaceType: line.interfaceType,
                    dataId: line.dataId,
                    charts: []
                }
            }
            // Do not expose the internal "main" chart in the UI (signals are still tracked)
            if ((line.chartId || "main") !== "main") {
                map[key].charts.push({
                    chartId: line.chartId,
                    chartTitle: line.chartTitle
                })
            }
        }

        var keys = Object.keys(map).sort()
        for (var k = 0; k < keys.length; k++) {
            var item = map[keys[k]]
            signalsModel.append(item)
        }
    }

    function _refreshChartsModel() {
        chartsModel.clear()
        var charts = root.availableCharts || []
        for (var i = 0; i < charts.length; i++) {
            chartsModel.append(charts[i])
        }
    }

    function _countLinesForChart(chartId) {
        if (!root.chartLineModel) return 0
        var c = 0
        for (var i = 0; i < root.chartLineModel.count; i++) {
            if (root.chartLineModel.get(i).chartId === chartId) c++
        }
        return c
    }

    function _isSignalAssignedToChart(uniqueId, chartId) {
        if (!root.chartLineModel) return false
        return root.chartLineModel.hasLineForChart(uniqueId, chartId)
    }

    function _openAssignDialog(uniqueId) {
        assignChartsModel.clear()
        var charts = root.availableCharts || []
        for (var i = 0; i < charts.length; i++) {
            var c = charts[i]
            var chartId = c.chartId
            var chartType = c.chartType
            assignChartsModel.append({
                chartId: chartId,
                chartTitle: c.chartTitle || chartId,
                chartType: chartType || "",
                enabled: chartId === "main" || root._isXYChart(chartType),
                checked: root._isSignalAssignedToChart(uniqueId, chartId)
            })
        }
        assignDialog.uniqueId = uniqueId
        assignDialog.open()
    }

    onChartLineModelChanged: {
        _refreshSignalsModel()
    }

    onAvailableChartsChanged: {
        _refreshChartsModel()
    }

    Connections {
        target: root.chartLineModel
        function onModelChanged() {
            root._refreshSignalsModel()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f8f8f8"
        border.color: "#d0d0d0"
        border.width: 1
        radius: 8

        // Collapsed state - just the button centered
        Button {
            id: collapseButton
            visible: root.isCollapsed
            anchors.centerIn: parent
            width: 40
            height: 40
            text: "◀"
            font.pixelSize: 18
            font.bold: true

            ToolTip.visible: hovered
            ToolTip.text: qsTr("Expand")
            ToolTip.delay: 400

            background: Rectangle {
                color: {
                    if (collapseButton.pressed) return "#1565c0"
                    if (collapseButton.hovered) return "#1976d2"
                    return "#2196f3"
                }
                radius: 6
                border.color: "#1565c0"
                border.width: 1
            }

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.collapseToggled()
        }

        // Expanded state - full layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            visible: !root.isCollapsed

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    text: qsTr("Manage")
                    font.pixelSize: 14
                    font.bold: true
                    color: "#444"
                    Layout.fillWidth: true
                }

                Button {
                    id: headerCollapseButton
                    text: "▶"
                    font.pixelSize: 14
                    font.bold: true
                    width: 32
                    height: 32

                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Collapse")
                    ToolTip.delay: 400

                    background: Rectangle {
                        color: {
                            if (headerCollapseButton.pressed) return "#1565c0"
                            if (headerCollapseButton.hovered) return "#1976d2"
                            return "#2196f3"
                        }
                        radius: 4
                        border.color: "#1565c0"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: root.collapseToggled()
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#d0d0d0" }

            TabBar {
                id: tabBar
                Layout.fillWidth: true

                background: Rectangle {
                    color: "#e8e8e8"
                    radius: 4
                }

                TabButton {
                    text: qsTr("Charts")

                    background: Rectangle {
                        color: {
                            if (parent.checked) return "#2196f3"
                            if (parent.hovered) return "#d0d0d0"
                            return "transparent"
                        }
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        font.bold: parent.checked
                        color: parent.checked ? "white" : "#444"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                TabButton {
                    text: qsTr("Signals")

                    background: Rectangle {
                        color: {
                            if (parent.checked) return "#2196f3"
                            if (parent.hovered) return "#d0d0d0"
                            return "transparent"
                        }
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        font.bold: parent.checked
                        color: parent.checked ? "white" : "#444"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                TabButton {
                    text: qsTr("Manage Charts")

                    background: Rectangle {
                        color: {
                            if (parent.checked) return "#2196f3"
                            if (parent.hovered) return "#d0d0d0"
                            return "transparent"
                        }
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        font.bold: parent.checked
                        color: parent.checked ? "white" : "#444"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabBar.currentIndex

                // ---------------------------------------------------------
                // Tab 1: Chart lines (per chart)
                // ---------------------------------------------------------
                Item {
                    ChartLinesListGrouped {
                        anchors.fill: parent
                        embedded: true
                        chartLineModel: root.chartLineModel

                        onLineVisibilityToggled: function(lineKey, visible) {
                            root.lineVisibilityToggled(lineKey, visible)
                        }
                        onLineSelected: function(lineKey) {
                            root.lineSelected(lineKey)
                        }
                    }
                }

                // ---------------------------------------------------------
                // Tab 2: Signals (global)
                // ---------------------------------------------------------
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                text: qsTr("Add Signal")
                                Layout.preferredHeight: 32

                                background: Rectangle {
                                    color: {
                                        if (parent.pressed) return "#1565c0"
                                        if (parent.hovered) return "#1976d2"
                                        return "#2196f3"
                                    }
                                    radius: 4
                                    border.color: "#1565c0"
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: root.addSignalRequested()
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: qsTr("%1 signals").arg(signalsModel.count)
                                color: "#666"
                                font.pixelSize: 11
                            }
                        }

                        ListView {
                            id: signalsList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: signalsModel

                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                            delegate: Rectangle {
                                width: signalsList.width
                                height: 52
                                radius: 6
                                color: "#ffffff"
                                border.color: "#d0d0d0"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: model.color
                                        border.color: "#ffffff"
                                        border.width: 1
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Label {
                                            text: model.displayName
                                            color: "#222"
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: model.uniqueId + " · " + model.interfaceType + " · ID:" + model.dataId + " · Charts:" + (model.charts ? model.charts.length : 0)
                                            color: "#777"
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Button {
                                        text: qsTr("Assign")
                                        Layout.preferredHeight: 28

                                        background: Rectangle {
                                            color: {
                                                if (parent.pressed) return "#e0e0e0"
                                                if (parent.hovered) return "#eeeeee"
                                                return "#f5f5f5"
                                            }
                                            radius: 4
                                            border.color: "#d0d0d0"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 11
                                            color: "#444"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: root._openAssignDialog(model.uniqueId)
                                    }

                                    Button {
                                        text: qsTr("Edit")
                                        Layout.preferredHeight: 28

                                        background: Rectangle {
                                            color: {
                                                if (parent.pressed) return "#e0e0e0"
                                                if (parent.hovered) return "#eeeeee"
                                                return "#f5f5f5"
                                            }
                                            radius: 4
                                            border.color: "#d0d0d0"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 11
                                            color: "#444"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: root.lineSelected(model.lineKey)
                                    }

                                    Button {
                                        text: qsTr("Remove")
                                        Layout.preferredHeight: 28

                                        background: Rectangle {
                                            color: {
                                                if (parent.pressed) return "#ffb0b0"
                                                if (parent.hovered) return "#ffd6d6"
                                                return "#ffecec"
                                            }
                                            radius: 4
                                            border.color: "#ffaaaa"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 11
                                            color: "#c62828"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: root.removeSignalRequested(model.uniqueId)
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: qsTr("No signals")
                                color: "#999"
                                font.pixelSize: 12
                                visible: signalsList.count === 0
                            }
                        }
                    }
                }

                // ---------------------------------------------------------
                // Tab 3: Charts (global)
                // ---------------------------------------------------------
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                text: qsTr("Add Chart")
                                Layout.preferredHeight: 32

                                background: Rectangle {
                                    color: {
                                        if (parent.pressed) return "#1565c0"
                                        if (parent.hovered) return "#1976d2"
                                        return "#2196f3"
                                    }
                                    radius: 4
                                    border.color: "#1565c0"
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: createChartDialog.open()
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: qsTr("%1 charts").arg(chartsModel.count)
                                color: "#666"
                                font.pixelSize: 11
                            }
                        }

                        ListView {
                            id: chartsList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: chartsModel

                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                            delegate: Rectangle {
                                width: chartsList.width
                                height: 54
                                radius: 6
                                color: "#ffffff"
                                border.color: "#d0d0d0"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Label {
                                            text: model.chartTitle || model.chartId
                                            color: "#222"
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: (model.chartType || "") + " · " + model.chartId + " · Lines:" + root._countLinesForChart(model.chartId)
                                            color: "#777"
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Button {
                                        text: qsTr("Rename")
                                        Layout.preferredHeight: 28

                                        background: Rectangle {
                                            color: {
                                                if (parent.pressed) return "#e0e0e0"
                                                if (parent.hovered) return "#eeeeee"
                                                return "#f5f5f5"
                                            }
                                            radius: 4
                                            border.color: "#d0d0d0"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 11
                                            color: "#444"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            renameChartDialog.chartId = model.chartId
                                            renameChartDialog.titleText = model.chartTitle || model.chartId
                                            renameChartDialog.open()
                                        }
                                    }

                                    Button {
                                        text: qsTr("Remove")
                                        enabled: model.chartId !== "main"
                                        Layout.preferredHeight: 28

                                        background: Rectangle {
                                            color: {
                                                if (!parent.enabled) return "#f0f0f0"
                                                if (parent.pressed) return "#ffb0b0"
                                                if (parent.hovered) return "#ffd6d6"
                                                return "#ffecec"
                                            }
                                            radius: 4
                                            border.color: parent.enabled ? "#ffaaaa" : "#e0e0e0"
                                            border.width: 1
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 11
                                            color: parent.enabled ? "#c62828" : "#999"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: root.removeChartRequested(model.chartId)
                                    }
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: qsTr("No charts")
                                color: "#999"
                                font.pixelSize: 12
                                visible: chartsList.count === 0
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------
    // Assign signal dialog (set charts)
    // ---------------------------------------------------------
    Dialog {
        id: assignDialog
        title: qsTr("Assign Signal")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string uniqueId: ""

        contentItem: Item {
            implicitWidth: 420
            implicitHeight: 360

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Label {
                    text: assignDialog.uniqueId
                    font.pixelSize: 12
                    color: "#222"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#d0d0d0" }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: assignChartsModel
                            delegate: CheckBox {
                                text: model.chartTitle + " (" + model.chartType + ")"
                                enabled: model.enabled
                                checked: model.checked

                                onToggled: {
                                    assignChartsModel.setProperty(index, "checked", checked)
                                }
                            }
                        }
                    }
                }
            }
        }

        onAccepted: {
            var selected = []
            for (var i = 0; i < assignChartsModel.count; i++) {
                var c = assignChartsModel.get(i)
                if (c.checked) selected.push(c.chartId)
            }
            root.setSignalChartsRequested(assignDialog.uniqueId, selected)
        }
    }

    // ---------------------------------------------------------
    // Create chart dialog
    // ---------------------------------------------------------
    Dialog {
        id: createChartDialog
        title: qsTr("Add Chart")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string titleText: ""
        property string chartType: "xy_line"

        contentItem: Item {
            implicitWidth: 420
            implicitHeight: 180

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                TextField {
                    id: newChartTitle
                    Layout.fillWidth: true
                    placeholderText: qsTr("Chart title")
                    text: ""
                }

                ComboBox {
                    id: chartTypeCombo
                    Layout.fillWidth: true
                    model: [
                        {"text":"XY Line", "value":"xy_line"},
                        {"text":"XY Scatter", "value":"xy_scatter"},
                        {"text":"XYZ Scatter", "value":"xyz_scatter"}
                    ]
                    textRole: "text"
                    onCurrentIndexChanged: {
                        var item = model[currentIndex]
                        createChartDialog.chartType = item ? item.value : "xy_line"
                    }
                }
            }
        }

        onAccepted: {
            var title = newChartTitle.text && newChartTitle.text.length > 0 ? newChartTitle.text : ("Chart " + Date.now())
            root.createChartRequested(createChartDialog.chartType, title)
        }
    }

    // ---------------------------------------------------------
    // Rename chart dialog
    // ---------------------------------------------------------
    Dialog {
        id: renameChartDialog
        title: qsTr("Rename Chart")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string chartId: ""
        property string titleText: ""

        contentItem: Item {
            implicitWidth: 420
            implicitHeight: 140

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Label {
                    text: renameChartDialog.chartId
                    color: "#666"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                TextField {
                    id: renameField
                    Layout.fillWidth: true
                    placeholderText: qsTr("New title")
                    text: renameChartDialog.titleText
                }
            }
        }

        onAccepted: {
            var title = renameField.text
            if (!title || title.length === 0) return
            root.renameChartRequested(renameChartDialog.chartId, title)
        }
    }
}
