import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import DataModels.SerialDataModels 1.0

Rectangle {
    id: controlsCard
    radius: 6
    color: "#f4f4f4"
    border.color: "#d0d0d0"
    implicitHeight: contentLayout.implicitHeight + 20

    signal interfaceChanged(string iface)
    property alias startButton: startButton
    property alias stopButton: stopButton
    property alias sourceCombo: sourceCombo
    property var appController: null

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: qsTr("Connection")
            font.bold: true
            color: "#444"
            Layout.fillWidth: true
        }
        Button {
            id: startButton
            text: qsTr("Start")
            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }
        Button {
            id: stopButton
            text: qsTr("Stop")
            Layout.fillWidth: true
            Layout.preferredHeight: 36
        }
        ComboBox {
            id: sourceCombo
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            model: ConnectionModel {}
            textRole: "name"
            valueRole: "val"
            currentIndex: model && model.count > 0 ? 0 : -1
            onCurrentIndexChanged: {
                if(sourceCombo.currentText !== undefined) {
                    controlsCard.interfaceChanged(sourceCombo.currentText)

                    // Auto-set default settings for Test interface
                    if(sourceCombo.currentText === "Test") {
                        setDefaultTestSettings()
                    }
                }
            }
            Component.onCompleted: {
                if(sourceCombo.currentText !== undefined) {
                    controlsCard.interfaceChanged(sourceCombo.currentText)

                    // Auto-set default settings for Test interface on startup
                    if(sourceCombo.currentText === "Test") {
                        setDefaultTestSettings()
                    }
                }
            }
        }
    }

    function setDefaultTestSettings() {
        if(appController && typeof appController.set_settings === "function") {
            var defaultTestSettings = {
                "name": "Sinus Test",
                "color": "#ff4444",
                "type": "Sinus"
            }
            appController.set_settings("Test", defaultTestSettings)
        }
    }
}
