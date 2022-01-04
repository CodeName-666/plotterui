import QtQuick 2.12
import QtQuick.Controls 2.15

Item {
    id: telnet_settings
    property alias ipInput: ipInput
    property alias portInput: portInput

    Rectangle {
        id: telnet_settings_background
        color: "#b5b0a7"
        border.color: "#b39b72"
        anchors.fill: parent

        property int textWidth: ipText.width > portText ? ipText.width : portText.width

        Column {
            id: column
            anchors.fill: parent
            spacing: 10

            Rectangle {
                height: 30
                color: "#cb1919"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 0
                anchors.rightMargin: 0

                Row {
                    id: row
                    anchors.fill: parent
                    layoutDirection: Qt.LeftToRight
                    spacing: 10

                    Text {
                        text: "Hello World"
                        height: parent.height
                        width: 100
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    TextField {

                        text: "Input IP"
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        height: parent.height
                        width: 300
                    }
                }
            }

            Rectangle {
                height: 50
                color: "#cb1919"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 0
                anchors.rightMargin: 0
            }
        }

        //        Grid {
        //            id: grid
        //            anchors.fill: parent
        //            verticalItemAlignment: Grid.AlignVCenter
        //            horizontalItemAlignment: Grid.AlignHCenter
        //            bottomPadding: 5
        //            rightPadding: 5
        //            leftPadding: 5
        //            topPadding: 5
        //            spacing: 5
        //            rows: 5
        //            columns: 2

        //            Text {
        //                id: ipText
        //                implicitWidth: telnet_settings_background.textWidth
        //                text: qsTr("URL/IP:")
        //            }

        //            Rectangle {
        //                id: rectangle
        //                color: "#e1dfdd"
        //                border.color: "#b39b72"
        //                border.width: 2
        //                width: 200
        //                height: 50
        //                TextInput {
        //                    id: ipInput
        //                    width: 135
        //                    anchors.right: parent.right
        //                    horizontalAlignment: Text.AlignRight
        //                }
        //            }

        //            Text {
        //                id: portText
        //                implicitWidth: telnet_settings_background.textWidth
        //                text: qsTr("Port:")
        //            }

        //            Rectangle {
        //                color: "#e1dfdd"
        //                height: 50
        //                border.color: "#b39b72"
        //                border.width: 2

        //                TextInput {
        //                    id: portInput
        //                    width: 135
        //                    horizontalAlignment: Text.AlignRight
        //                    anchors.centerIn: parent
        //                }
        //            }
        //        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:5}D{i:6}D{i:4}D{i:3}D{i:7}D{i:2}D{i:1}
}
##^##*/

