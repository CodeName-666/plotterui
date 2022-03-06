import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11

import Models 1.0
import PlotterUi 1.0

Item {
    id: serial_settings
    implicitWidth: 215
    implicitHeight: 150
    property var com_ports: []
    property alias comComboBox: comComboBox
    property alias baudInput: baudInput
    property alias dataSizeComboBox: dataSizeComboBox
    property alias parityComboBox: parityComboBox
    property alias stopBitsCombo: stopBitsCombo

    Rectangle {
        color: "#b5b0a7"
        border.color: "#b39b72"
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.bottomMargin: 5
            anchors.topMargin: 5
            spacing: 5

            GridLayout {
                Layout.fillWidth: true
                columns: 2

                Text {
                    id: comText
                    text: qsTr("COM - Port:")
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: comComboBox

                    height: 20
                    //model: ["COM1", "COM2"]
                    Layout.fillWidth: true
                }

                Text {
                    id: baudText

                    text: qsTr("Baudrate:")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                TextField {
                    id: baudInput
                    width: 135
                    height: 12
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                }

                Text {
                    id: dataSizeText
                    Layout.preferredHeight: 25
                    text: qsTr("Datasize:")
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: dataSizeComboBox
                    height: 23
                    textRole: "name"
                    valueRole: "value"
                    Layout.fillWidth: true
                    //model: DataSizeModel {}
                }

                Text {
                    id: parityText
                    text: qsTr("Parity:")
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: parityComboBox
                    Layout.fillWidth: true
                    textRole: "name"
                    valueRole: "value"
                    height: 23
                    //model: ParityBitsModel {}
                }

                Text {
                    id: stopBitsText
                    text: qsTr("Stop-Bits:")
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: stopBitsCombo
                    Layout.fillWidth: true
                    textRole: "name"
                    valueRole: "value"
                    height: 23
                    //model: StopBitsModel {}
                }
            }

            Item {
                id: spacer
                Layout.fillWidth: true
                Layout.fillHeight: true
                //Rectangle {
                //    anchors.fill: parent
                //    color: "#ffaaaa"
                //}
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:4}D{i:5}D{i:6}D{i:7}D{i:8}D{i:9}D{i:11}
D{i:12}D{i:14}D{i:15}D{i:3}D{i:17}D{i:2}D{i:1}
}
##^##*/

