import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15

Item {
    id: mqttSettings

    GridLayout {
        id: form
        columns: 2
        anchors.fill: parent
        columnSpacing: 12
        rowSpacing: 8

        Label { text: qsTr("Host") }
        TextField {
            id: hostInput
            Layout.fillWidth: true
            placeholderText: qsTr("Broker host")
        }

        Label { text: qsTr("Port") }
        TextField {
            id: portInput
            Layout.fillWidth: true
            placeholderText: qsTr("1883")
            inputMethodHints: Qt.ImhDigitsOnly
        }

        Label { text: qsTr("QoS") }
        ComboBox {
            id: qosCombo
            Layout.fillWidth: true
            model: [
                { text: qsTr("QoS 0"), value: 0 },
                { text: qsTr("QoS 1"), value: 1 },
                { text: qsTr("QoS 2"), value: 2 }
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: 0
        }

        Label { text: qsTr("RX Topic") }
        TextField {
            id: rxTopicInput
            Layout.fillWidth: true
            placeholderText: qsTr("topic/in")
        }

        Label { text: qsTr("TX Topic") }
        TextField {
            id: txTopicInput
            Layout.fillWidth: true
            placeholderText: qsTr("topic/out")
        }

        Label { text: qsTr("Client ID") }
        TextField {
            id: clientIdInput
            Layout.fillWidth: true
            placeholderText: qsTr("Client id (optional)")
        }

        Label { text: qsTr("Username") }
        TextField {
            id: usernameInput
            Layout.fillWidth: true
            placeholderText: qsTr("Username")
        }

        Label { text: qsTr("Password") }
        TextField {
            id: passwordInput
            Layout.fillWidth: true
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password
        }

        Label { text: qsTr("Keepalive (s)") }
        TextField {
            id: keepAliveInput
            Layout.fillWidth: true
            placeholderText: qsTr("60")
            inputMethodHints: Qt.ImhDigitsOnly
        }
    }
}
