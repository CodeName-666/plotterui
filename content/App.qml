import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Timeline 1.0
import QtCharts 2.3
import "../imports/PlotterUi"
import "Footer"
import "MainMenu"
import "ChartWindow"
import "Settings"
import "Toolbar"
import "Models"


ApplicationWindow {

    id: applicationWindow

    objectName: Constants.appObjectName
    width: Constants.width
    height: Constants.height
    color: Constants.backgroundColor
    title: qsTr(Constants.title)
    visible: true


    menuBar: MainMenu {
        id: toolbar
        settingsButton.onTriggered: settingsPopup.open()
    }

    contentData: [

        ChartWindow {
           id: chart
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

        Column {
            anchors.fill: parent
            spacing: 2
            ComboBox {
                id: comComboBox
                height: 50
                textRole: "name"
                valueRole: "val"
                model: ConnectionModel{}
                anchors.left: parent.left
                anchors.right: parent.right

                delegate: ItemDelegate {
                    id: control
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: qsTr(name)

                    contentItem: Text {
                        text: qsTr(control.text)
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Button
            {
                id: connectButton
                text: "Connect"
                height: 50
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: connect()
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

/*=== FUNCTIONAL implementations =========================*/

    function acceptSettings()
    {
        console.log("Accept and updae Setting ");
        settingsPopup.close();
    }

    function cancleSettings()
    {
        console.log("cancel settings");
        settingsPopup.close();
    }

    function updateComPorts()
    {
       var new_ports = backend.get_com_ports();
       settings.updateComPorts(new_ports);
    }


    function setSettings(new_settings)
    {
        var res = backend.set_settings(new_settings)
        if(res === true)
            console.log("Settings updated")
        else
            console.log("Settings update failed")
        return res;
    }

    function connect()
    {
        var res = backend.connect()
        if (res === true)
            console.log("Connected")
        else
            console.log("Cannot connet")
    }
}
