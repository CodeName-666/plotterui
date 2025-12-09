import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 6.4
import SettingsCommon 1.0

Rectangle {
    id: settings_menu
    implicitWidth: 680
    implicitHeight: 520
    radius: SettingsTheme.radius.large
    color: SettingsTheme.settingsBackground
    border.color: SettingsTheme.borderColor

    property alias okButton: okButton
    property alias cancelButton: cancelButton
    property alias savePresetButton: savePresetButton
    property alias loadPresetButton: loadPresetButton
    property alias tabBar: tabBar
    property alias serialLoader: serialLoader
    property alias telnetLoader: telnetLoader
    property alias mqttLoader: mqttLoader
    property alias testLoader: testLoader

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SettingsTheme.margins.large
        spacing: SettingsTheme.spacing.large

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.spacing.medium

            Text {
                text: qsTr("Connection Settings")
                font.bold: true
                font.pixelSize: SettingsTheme.fontSize.title
                color: SettingsTheme.textPrimary
                Layout.fillWidth: true
            }

            Button {
                id: loadPresetButton
                text: qsTr("Load Preset")
                icon.name: "document-open"
                Layout.preferredHeight: SettingsTheme.heights.smallInput
            }

            Button {
                id: savePresetButton
                text: qsTr("Save Preset")
                icon.name: "document-save"
                Layout.preferredHeight: SettingsTheme.heights.smallInput
            }
        }

        // Tab Bar
        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton {
                text: qsTr("Serial")
                width: implicitWidth
            }
            TabButton {
                text: qsTr("Telnet")
                width: implicitWidth
            }
            TabButton {
                text: qsTr("MQTT")
                width: implicitWidth
            }
            TabButton {
                text: qsTr("Test")
                width: implicitWidth
            }
        }

        // Content Area with StackLayout
        Rectangle {
            id: contentCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: SettingsTheme.radius.medium
            color: SettingsTheme.cardBackground
            border.color: SettingsTheme.borderColorLight

            StackLayout {
                anchors.fill: parent
                currentIndex: tabBar.currentIndex

                // Serial Settings
                Loader {
                    id: serialLoader
                    asynchronous: false
                }

                // Telnet Settings
                Loader {
                    id: telnetLoader
                    asynchronous: false
                }

                // MQTT Settings
                Loader {
                    id: mqttLoader
                    asynchronous: false
                }

                // Test Settings
                Loader {
                    id: testLoader
                    asynchronous: false
                }
            }
        }

        // Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.spacing.medium

            Item { Layout.fillWidth: true }

            Button {
                id: cancelButton
                text: qsTr("Cancel")
                Layout.preferredWidth: 110
                Layout.preferredHeight: SettingsTheme.heights.button
            }

            Button {
                id: okButton
                text: qsTr("Apply")
                highlighted: true
                Layout.preferredWidth: 110
                Layout.preferredHeight: SettingsTheme.heights.button
            }
        }
    }
}
