import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: testItem
    width: 500
    height: 150

    Rectangle {
        anchors.fill: parent
        color: "grey"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            GridLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                columns: 2
                Text {

                    text: "text1:"
                    Layout.alignment: Qt.AlignLeft
                }
                TextField {
                    Layout.fillWidth: true
                }

                Text {
                    text: "new text tset"
                }

                TextField {
                    Layout.fillWidth: true
                }
            }

            Item {
                id: spacer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Rectangle {
                    anchors.fill: parent
                    color: "#ffaaaa"
                }
            }

        }
    }
}
