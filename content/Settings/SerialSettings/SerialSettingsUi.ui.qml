import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11

import "../Models"
import PlotterUi 1.0

Item {
    id: serial_settings
    implicitWidth: 215
    implicitHeight: 150
    property var com_ports: []

    Rectangle {
        color: "#b5b0a7"
        border.color: "#b39b72"
        anchors.fill: parent

        Grid {
            id: grid
            anchors.fill: parent
            bottomPadding: 5
            rightPadding: 5
            leftPadding: 5
            topPadding: 5
            spacing: 5
            rows: 5
            columns: 2

            Text {
                id: comText
                text: qsTr("COM - Port:")
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                Layout.preferredHeight: comComboBox.height
            }

            ComboBox {
                id: comComboBox
                Layout.preferredHeight: 25
                height: 20
                model: com_ports
            }

            Text {
                id: baudText
                Layout.preferredHeight: 25
                text: qsTr("Baudrate:")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                width: baudInput.width + 5
                height: baudInput.height + 5
                Layout.preferredHeight: 25
                Rectangle {
                    color: "#e1dfdd"
                    border.color: "#b39b72"
                    border.width: 2
                    anchors.fill: parent
                    anchors.centerIn: parent
                    TextInput {
                        id: baudInput
                        width: 135
                        height: 12
                        horizontalAlignment: Text.AlignRight
                        anchors.centerIn: parent
                    }
                }
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
                valueRole: "val"
                Layout.preferredHeight: 25
                model: DataSizeModel {}
            }

            Text {
                id: parityText
                Layout.preferredHeight: 25
                text: qsTr("Parity:")
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: parityComboBox
                Layout.preferredHeight: 25
                textRole: "name"
                valueRole: "val"
                height: 23
                model: ParityBitsModel {}
            }

            Text {
                id: stopBitsText
                Layout.preferredHeight: 25
                text: qsTr("Stop-Bits:")
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: stopBitsCombo
                Layout.preferredHeight: 25
                textRole: "name"
                valueRole: "val"
                height: 23
                model: StopBitsModel {}
            }
        }
    }

    function getSettings() {
        var serial_settings = {
            "type": 'SERIAL',
            "port": comComboBox.currentText,
            "baud": parseInt(baudInput.text),
            "size": dataSizeComboBox.currentValue,
            "parity": parityComboBox.currentValue,
            "stop": stopBitsCombo.currentValue
        }
        return serial_settings
    }
}
