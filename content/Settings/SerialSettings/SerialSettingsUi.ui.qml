import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import DataModels.SerialDataModels 1.0
import SettingsCommon 1.0

Item {
    id: serial_settings
    property var com_ports: []
    property alias comComboBox: comComboBox
    property alias baudInput: baudInput
    property alias dataSizeComboBox: dataSizeComboBox
    property alias parityComboBox: parityComboBox
    property alias stopBitsCombo: stopBitsCombo

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SettingsTheme.margins.medium
        spacing: SettingsTheme.spacing.medium

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: SettingsTheme.spacing.medium
            rowSpacing: SettingsTheme.spacing.medium

            Label {
                text: qsTr("COM - Port:")
                font.pixelSize: SettingsTheme.fontSize.medium
                color: SettingsTheme.textLabel
            }

            ComboBox {
                id: comComboBox
                model: serial_settings.com_ports
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.heights.combobox
            }

            Label {
                text: qsTr("Baudrate:")
                font.pixelSize: SettingsTheme.fontSize.medium
                color: SettingsTheme.textLabel
            }

            TextField {
                id: baudInput
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.heights.input
                placeholderText: qsTr("e.g. 9600, 115200")
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label {
                text: qsTr("Datasize:")
                font.pixelSize: SettingsTheme.fontSize.medium
                color: SettingsTheme.textLabel
            }

            ComboBox {
                id: dataSizeComboBox
                textRole: "name"
                valueRole: "value"
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.heights.combobox
                model: DataSizeModel {}
            }

            RowLayout {
                spacing: SettingsTheme.spacing.small

                Label {
                    text: qsTr("Parity:")
                    font.pixelSize: SettingsTheme.fontSize.medium
                    color: SettingsTheme.textLabel
                }

                Label {
                    text: "ⓘ"
                    font.pixelSize: SettingsTheme.fontSize.small
                    color: SettingsTheme.textSecondary

                    MouseArea {
                        id: parityTooltipArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    ToolTip {
                        visible: parityTooltipArea.containsMouse
                        text: qsTr("Error checking method:\nNone: No parity check\nEven: Even number of 1-bits\nOdd: Odd number of 1-bits")
                        delay: 500
                    }
                }
            }

            ComboBox {
                id: parityComboBox
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "value"
                Layout.preferredHeight: SettingsTheme.heights.combobox
                model: ParityBitsModel {}
            }

            Label {
                text: qsTr("Stop-Bits:")
                font.pixelSize: SettingsTheme.fontSize.medium
                color: SettingsTheme.textLabel
            }

            ComboBox {
                id: stopBitsCombo
                Layout.fillWidth: true
                textRole: "name"
                valueRole: "value"
                Layout.preferredHeight: SettingsTheme.heights.combobox
                model: StopBitsModel {}
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
