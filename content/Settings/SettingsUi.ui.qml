import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 6.4

Rectangle {
    id: settings_menu
    implicitWidth: 420
    implicitHeight: 360
    radius: 8
    color: "#f5f5f5"
    border.color: "#d0d0d0"

    property alias interfaceComboBox: interfaceComboBox
    property alias okButton: okButton
    property alias cancleButton: cancleButton
    property alias settingsLoader: settingsLoader

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Text {
            text: qsTr("Connection Settings")
            font.bold: true
            font.pixelSize: 20
            color: "#333333"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: qsTr("Interface")
                font.pixelSize: 14
                color: "#5c5c5c"
            }

            ComboBox {
                id: interfaceComboBox
                Layout.fillWidth: true
                implicitHeight: 34
            }
        }

        Rectangle {
            id: contentCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 6
            color: "#ffffff"
            border.color: "#e0e0e0"

            Loader {
                id: settingsLoader
                anchors.fill: parent
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            Button {
                id: cancleButton
                text: qsTr("Cancel")
                Layout.preferredWidth: 110
            }

            Button {
                id: okButton
                text: qsTr("Apply")
                highlighted: true
                Layout.preferredWidth: 110
            }
        }
    }
}
