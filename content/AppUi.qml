import QtQuick 6.4
import QtQuick.Window 2.15
import QtQuick.Controls 6.4
import QtQuick.Timeline 1.0
import QtCharts 2.3
import QtQuick.Layouts 1.15
import Common 1.0
import DataModels.SerialDataModels 1.0
import "Footer"
import "ChartWindow"
import "ChartWindow/ChartLinesList"
import "ChartWindow/FloatingActionButton"
import "Settings" as SettingsViews
import "Toolbar"
import "."
ApplicationWindow {
    id: applicationWindow
    objectName: "applicationWindow"
    width: Constants.width
    height: Constants.height
    visible: true
    color: Constants.backgroundColor
    title: qsTr(Constants.title)

    // Note: appController property is defined in App.qml which inherits from AppUi
    // We declare it here so NavDrawer can reference it
    property var appController

    property alias settingsPopup: settingsPopup
    property alias settings: settings
    property alias chartWindow: chartWindow
    property alias chartWorkspace: chartWorkspace
    property alias floatingWindowsContainer: floatingWindowsContainer
    property alias connectButton: navDrawer.startButton
    property alias toolbar: topToolbar

    header: Toolbar {
        id: topToolbar
        onMenuRequested: navDrawer.open()
    }

    // State for chart lines list
    property bool chartLinesListCollapsed: false
    property int chartLinesListWidth: 280
    property int chartLinesListCollapsedWidth: 50

    Item {
        id: mainArea
        anchors.fill: parent

        // Split area: chart workspace (left) + manager sidebar (right)
        Item {
            id: splitArea
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: footer.top
            }

            RowLayout {
                id: splitLayout
                anchors.fill: parent
                spacing: 10

                // Workspace area for charts/floating windows (excludes right-side manager panel)
                Item {
                    id: chartWorkspace
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    z: 0

                    Rectangle {
                        anchors.fill: parent
                        color: Constants.backgroundColor

                        // Optional: Add a welcome message or placeholder
                        Text {
                            anchors.centerIn: parent
                            text: "Open the menu to create charts or manage connections"
                            font.pixelSize: 16
                            color: "#808080"
                            opacity: 0.5
                        }
                    }

                    // Container for dynamically created floating windows
                    Item {
                        id: floatingWindowsContainer
                        anchors.fill: parent
                        z: 10
                        clip: true

                        property var activeWindows: ({})
                    }
                }

                // Charts Manager - right side panel (collapsible, management tabs)
                ChartsManager {
                    id: chartLinesList
                    Layout.preferredWidth: chartLinesListCollapsed ? chartLinesListCollapsedWidth : chartLinesListWidth
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    Layout.rightMargin: 10
                    // Always stay visible above any chart content (including shadows/layers)
                    z: 10000

                    isCollapsed: chartLinesListCollapsed
                    chartLineModel: chartWindow.chartLineModel
                    signalModel: chartWindow.signalModel
                    messageModel: chartWindow.messageModel
                    availableCharts: chartWindow.availableCharts

                    onCollapseToggled: {
                        chartLinesListCollapsed = !chartLinesListCollapsed
                    }

                    onLineVisibilityToggled: function(lineKey, visible) {
                        if (chartWindow && chartWindow.chartLineModel) {
                            chartWindow.chartLineModel.toggleVisibility(lineKey, visible)
                        }
                    }

                    onLineSelected: function(lineKey) {
                        if (chartWindow) {
                            var line = chartWindow.chartLineModel.getLineByKey(lineKey)
                            if (line && chartWindow.editChartLineDialog) {
                                chartWindow.editChartLineDialog.loadChartLine(lineKey, line.uniqueId, line.displayName, line.color, line.interfaceType, line.dataId, line.chartTitle)
                                chartWindow.editChartLineDialog.open()
                            }
                        }
                    }

                    onAddSignalRequested: {
                        if (chartWindow && chartWindow.addChartLineDialog) {
                            chartWindow.addChartLineDialog.open()
                        }
                    }

                    onRemoveSignalRequested: function(uniqueId) {
                        if (chartWindow && chartWindow.removeSignal) {
                            chartWindow.removeSignal(uniqueId)
                        }
                    }

                    onSetSignalChartsRequested: function(uniqueId, chartIds) {
                        if (chartWindow && chartWindow.setSignalCharts) {
                            chartWindow.setSignalCharts(uniqueId, chartIds)
                        }
                    }

                    onCreateChartRequested: function(chartType, chartTitle) {
                        if (chartWindow && chartWindow.createManagedChart) {
                            chartWindow.createManagedChart(chartType, chartTitle)
                        }
                    }

                    onRemoveChartRequested: function(chartId) {
                        if (chartWindow && chartWindow.removeManagedChart) {
                            chartWindow.removeManagedChart(chartId)
                        }
                    }

                    onRenameChartRequested: function(chartId, chartTitle) {
                        if (chartWindow && chartWindow.renameManagedChart) {
                            chartWindow.renameManagedChart(chartId, chartTitle)
                        }
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        // Floating Action Button - bottom-right corner (adjusts position based on panel state)
        FloatingActionButton {
            id: fabButton
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.rightMargin: chartLinesListCollapsed ? (chartLinesListCollapsedWidth + 20) : (chartLinesListWidth + 30)
            anchors.bottomMargin: 20
            z: 110

            onClicked: {
                if (chartWindow && chartWindow.addChartLineDialog) {
                    chartWindow.addChartLineDialog.open()
                }
            }

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Footer {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        // ChartWindow - kept for test functions and data model but hidden
        ChartWindow {
            id: chartWindow
            visible: false
            width: 0
            height: 0
            objectName: "chartWindow"
        }
    }

    NavDrawer {
        id: navDrawer
        window: applicationWindow
        settingsPopup: settingsPopup
    }

    Drawer {
        id: settingsDrawer
        width: Math.min(applicationWindow.width * 0.4, 420)
        height: applicationWindow.height
        interactive: true
        modal: true

        contentItem: Item {
            SettingsViews.Settings {
                Layout.fillWidth: true
                Layout.fillHeight: true            }
        }
    }

    Popup {
        id: settingsPopup
        width: parent.width * 0.55
        height: parent.height * 0.65
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        contentItem: SettingsViews.Settings {
            id: settings
        }
    }
}
