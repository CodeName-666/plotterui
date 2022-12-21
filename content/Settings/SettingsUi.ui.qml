import QtQuick 6.4
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.11
import QtQuick.Controls 6.4

import Models 1.0

Item {
    id: settings_menu

    implicitWidth: 400
    implicitHeight: 400

    property alias interfaceComboBox: interfaceComboBox
    property alias telnetSettings: telnetSettings
    property alias serialSettings: serialSettings
    property alias okButton: okButton
    property alias cancleButton: cancleButton
    property alias testSettings: testSettings

    property var old_settings: ({})
    property var old_interface: ({})

    Text {
        text: qsTr("Settings:")
        anchors.left: parent.left
        anchors.top: parent.top
        font.bold: true
        font.pointSize: 13
        anchors.leftMargin: 10
        anchors.topMargin: 10
    }

    Text {
        id: text1
        text: qsTr("Connection Type:")
        anchors.left: parent.left
        anchors.right: interfaceComboBox.left
        anchors.top: interfaceComboBox.top
        anchors.bottom: interfaceComboBox.bottom
        font.pixelSize: 12
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.leftMargin: 10
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.rightMargin: 6
    }

    ComboBox {
        id: interfaceComboBox
        width: 143
        height: 23
        //        textRole: "name"
        //        valueRole: "val"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 44
        anchors.topMargin: 40
        //model: ["Serial", "Telnet", "Test"]
    }

    SerialSettingsUi {
        id: serialSettings
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: interfaceComboBox.bottom
        anchors.bottom: okButton.top
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        visible: true
    }

    TelnetSettingsUi {
        id: telnetSettings
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: interfaceComboBox.bottom
        anchors.bottom: okButton.top
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        visible: false
    }

    TestSettings {
        id: testSettings
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: interfaceComboBox.bottom
        anchors.bottom: okButton.top
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        visible: false
    }

    Button {
        id: okButton
        width: 79
        height: 23
        text: qsTr("OK")
        anchors.right: cancleButton.left
        anchors.bottom: parent.bottom
        anchors.rightMargin: 6
        anchors.bottomMargin: 16
    }

    Button {
        id: cancleButton
        width: 100
        height: 23
        text: qsTr("Cancle")
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.66;height:480;width:640}D{i:1}D{i:2}D{i:3}D{i:4}
D{i:5}D{i:6}D{i:7}D{i:8}
}
##^##*/

