import QtQuick 2.12

Item {
    id: telnet_settings
    implicitWidth:  215
    implicitHeight:  150

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
                id: ipText
                text: qsTr("URL/IP:")
            }

            Item {
                width: ipInput.width + 5
                height: ipText.height + 5

                Rectangle {
                    color: "#e1dfdd"
                    border.color: "#b39b72"
                    border.width: 2
                    anchors.fill: parent
                    anchors.centerIn: parent
                    TextInput {
                        id: ipInput
                        width: 135
                        horizontalAlignment: Text.AlignRight
                        anchors.centerIn: parent
                    }
                }
            }

            Text {
                id: portText
                text: qsTr("Port:")
            }

            Item {
                width: portInput.width + 5
                height: portText.height + 5

                Rectangle {
                    color: "#e1dfdd"
                    border.color: "#b39b72"
                    border.width: 2
                    anchors.fill: parent
                    anchors.centerIn: parent
                    TextInput {
                        id: portInput
                        width: 135
                        horizontalAlignment: Text.AlignRight
                        anchors.centerIn: parent
                    }
                }
            }

        }

    }

    function getSettings()
    {
        var telnet_settings ={"type": 'TELNET',
                              "url": ipText.text,
                              "port": parseInt(portInput.text),
                              }

        return telnet_settings
     }
}
