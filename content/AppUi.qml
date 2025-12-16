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
import "Settings"
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

        // Background area (empty workspace for floating windows)
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: chartLinesList.left
                bottom: footer.top
                rightMargin: 10
            }
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

        // Chart Lines List - right side panel (collapsible, grouped by chart)
        ChartLinesListGrouped {
            id: chartLinesList
            width: chartLinesListCollapsed ? chartLinesListCollapsedWidth : chartLinesListWidth
            anchors.top: parent.top
            anchors.bottom: footer.top
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            anchors.rightMargin: 10
            z: 120

            isCollapsed: chartLinesListCollapsed
            chartLineModel: chartWindow.chartLineModel

            onCollapseToggled: {
                chartLinesListCollapsed = !chartLinesListCollapsed
            }

            onLineVisibilityToggled: function(uniqueId, visible) {
                if (chartWindow && chartWindow.chartLineModel) {
                    chartWindow.chartLineModel.toggleVisibility(uniqueId, visible)
                }
            }

            onLineSelected: function(uniqueId) {
                // Forward to chartWindow's edit dialog
                if (chartWindow) {
                    var line = chartWindow.chartLineModel.getLine(uniqueId)
                    if (line && chartWindow.editChartLineDialog) {
                        chartWindow.editChartLineDialog.loadChartLine(uniqueId, line.displayName, line.color, line.interfaceType, line.dataId)
                        chartWindow.editChartLineDialog.open()
                    }
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Settings {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
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

        Settings {
            id: settings
            anchors.fill: parent
        }
    }
}
