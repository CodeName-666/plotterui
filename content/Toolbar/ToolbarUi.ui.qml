import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.11

import PlotterUi 1.0
import DataModels.SerialDataModels 1.0
import Common 1.0


ToolBar {

    property alias startButton: startButton
    property alias stopButton: stopButton
    property alias settingsButton: settingsButton

    width: Constants.width
    height: 40

    RowLayout {
        id: rlayout
        anchors.fill: parent
        spacing: 0

        Button {
            id: startButton
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            text: qsTr("Start")
        }

        Button {
            id: stopButton
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
            text: qsTr("Stop")
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

        ToolButton {
            id: settingsButton
            Layout.preferredHeight: parent.height
            text: qsTr("Settings")
        }
    }
}



