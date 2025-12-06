import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.11

import PlotterUi 1.0
import Models 1.0
import Common 1.0


ToolBar {

    width: Constants.width
    height: 40

    RowLayout {
        id: rlayout
        anchors.fill: parent
        spacing: 0

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            Text {
                id: startButton
                anchors.fill: parent
                text: qsTr("Start")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                anchors.fill: parent
                radius: 11
                border.color: "#6a5a5a"
                border.width: 2
                color: parent.down ? "#d0d0d0" : "#e0e0e0"
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            Text {
                id: stopButton
                anchors.fill: parent
                anchors.centerIn: parent
                text: qsTr("Stop")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                transformOrigin: Item.Center
                layer.smooth: true
            }

            background: Rectangle {
                anchors.fill: parent
                radius: 11
                border.color: "#6a5a5a"
                border.width: 2
                color: parent.down ? "#d0d0d0" : "#e0e0e0"
            }
        }
        Item {
            Layout.preferredHeight: rlayout.height
            Layout.preferredWidth: sourceText.width + (sourceCombo.width)
            //Layout.fillWidth: true
            Rectangle {
                id: rect
                anchors.fill: parent
                anchors.centerIn: parent
                radius: 11
                border.color: "#6a5a5a"
                border.width: 2
                RowLayout {
                    anchors.fill: parent
                    Text {
                        id: sourceText
                        Layout.preferredHeight: rlayout.height
                        text: qsTr("  SOURCE: ")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: Font.Normal
                        font.bold: true
                        textFormat: Text.PlainText
                    }

                    ComboBox {
                        id: sourceCombo

                        Layout.preferredHeight: rlayout.height - (rect.border.width * 2)
                        model: ConnectionModel {}
                    }
                }
            }
        }
    }
}



