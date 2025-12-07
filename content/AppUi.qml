import QtQuick 6.4
import QtQuick.Window 2.15
import QtQuick.Controls 6.4
import QtQuick.Timeline 1.0
import QtCharts 2.3
import QtQuick.Layouts 1.15
import Common 1.0
import DataModels.SerialDataModels 1.0
import "Footer"
import "MainMenu"
import "ChartWindow"
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

    property alias settingsPopup: settingsPopup
    property alias settings: settings
    property alias chartWindow: chartWindow
    property alias connectButton: navDrawer.startButton
    property alias toolbar: topToolbar

    menuBar: MainMenu {
        id: menuBar
        settingsButton.onTriggered: settingsPopup.open()
    }

    header: Toolbar {
        id: topToolbar
        anchors.left: parent.left
        anchors.right: parent.right
        onMenuRequested: navDrawer.open()
    }

    Item {
        id: mainArea
        anchors {
            top: topToolbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Footer {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        ChartWindow {
            id: chartWindow
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: footer.top
                margins: 6
            }
            objectName: "chartWindow"
        }
    }

    NavDrawer {
        id: navDrawer
        window: applicationWindow
        appController: appController
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
