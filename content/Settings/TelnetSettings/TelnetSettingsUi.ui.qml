import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: telnet_settings
    property alias ipInput: ipInput
    property alias portInput: portInput
    implicitHeight: 120
    implicitWidth: 350

    Rectangle {
        anchors.fill: parent
        color: "#b5b0a7"

        ColumnLayout {
            anchors.fill: parent
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.bottomMargin: 5
            anchors.topMargin: 5
            spacing: 5

            GridLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                columns: 2
                Text {
                    id: ipInput
                    text: "IP-Adress/URL:"
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }
                TextField {
                    Layout.fillWidth: true
                }

                Text {
                    id: portInput
                    text: "Port:"
                    font.bold: true
                }

                TextField {
                    Layout.fillWidth: true
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
    D{i:0;autoSize:true;height:120;width:350}D{i:4}D{i:5}D{i:6}D{i:7}D{i:3}D{i:8}D{i:2}
D{i:1}
}
##^##*/

