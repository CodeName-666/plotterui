import QtQuick 6.4
import QtQuick.Window 2.15
import QtQuick.Controls 6.4
import QtQuick.Timeline 1.0
import QtCharts 2.3
import QtQuick.Layouts 1.15
import "Footer"
import "MainMenu"
import "ChartWindow"
import "Settings"
import "Toolbar"
import "Models"



ApplicationWindow {

    id: applicationWindow

    objectName: "applicationWindow"
    width: Constants.width
    height: Constants.height
    color: Constants.backgroundColor
    title: qsTr(Constants.title)
    visible: true

    property alias settings: settings
    property alias settingsPopup: settingsPopup
    property alias toolbar: toolbar
    property alias chartWindow: chartWindow
    property alias connectButton: connectButton

    menuBar: MainMenu {
        id: toolbar
        settingsButton.onTriggered: settingsPopup.open()
    }

    contentData: [

        ChartWindow {
           id: chartWindow
           objectName: "chartWindow"
           anchors.fill: parent

        }
    ]


    Drawer {
        id: drawer

        y: toolbar.height
        width: applicationWindow.width / 3
        height: applicationWindow.height - toolbar.height

        modal: true
        interactive: true
        position: 0.0
        visible: false

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            Settings {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }

            Button
            {
                id: connectButton
                Layout.fillWidth: true
                text: "Connect"
                height: 50
            }
        }
    }

    Popup {
        id: settingsPopup
        width: parent.width * 0.5
        height: parent.height * 0.6
        anchors.centerIn: parent
        modal: true
        focus: true
        contentItem : Settings {
            id: settings
            anchors.fill: parent

        }

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    }

    footer:  Footer{
        anchors.right: parent.right
        anchors.rightMargin: 0
    }

}
