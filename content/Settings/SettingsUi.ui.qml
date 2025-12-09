import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 6.4
import SettingsCommon 1.0

Rectangle {
    id: settings_menu
    implicitWidth: 720
    implicitHeight: 580
    radius: SettingsTheme.radius.extraLarge
    color: SettingsTheme.settingsBackground
    border.color: SettingsTheme.borderColor
    border.width: 1

    property alias okButton: okButton
    property alias cancelButton: cancelButton
    property alias savePresetButton: savePresetButton
    property alias loadPresetButton: loadPresetButton
    property alias tabBar: tabBar
    property alias serialLoader: serialLoader
    property alias telnetLoader: telnetLoader
    property alias mqttLoader: mqttLoader
    property alias testLoader: testLoader
    property alias titleText: titleText

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: SettingsTheme.margins.large
        anchors.leftMargin: SettingsTheme.margins.large
        anchors.rightMargin: SettingsTheme.margins.large
        anchors.bottomMargin: SettingsTheme.margins.large
        spacing: SettingsTheme.spacing.large

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: SettingsTheme.spacing.medium

            Text {
                id: titleText
                text: qsTr("Connection Settings")
                font.bold: true
                font.pixelSize: SettingsTheme.fontSize.title
                color: SettingsTheme.textPrimary
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }

            Button {
                id: loadPresetButton
                text: qsTr("Load Preset")
                icon.name: "document-open"
                Layout.preferredHeight: SettingsTheme.heights.smallInput
                Layout.preferredWidth: 120
            }

            Button {
                id: savePresetButton
                text: qsTr("Save Preset")
                icon.name: "document-save"
                Layout.preferredHeight: SettingsTheme.heights.smallInput
                Layout.preferredWidth: 120
            }
        }

        // Tab Bar
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 4

            TabButton {
                text: qsTr("Serial")
                height: 40
                font.pixelSize: SettingsTheme.fontSize.medium
            }
            TabButton {
                text: qsTr("Telnet")
                height: 40
                font.pixelSize: SettingsTheme.fontSize.medium
            }
            TabButton {
                text: qsTr("MQTT")
                height: 40
                font.pixelSize: SettingsTheme.fontSize.medium
            }
            TabButton {
                text: qsTr("Test")
                height: 40
                font.pixelSize: SettingsTheme.fontSize.medium
            }
        }

        // Content Area with StackLayout
        Rectangle {
            id: contentCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: SettingsTheme.radius.large
            color: SettingsTheme.cardBackground
            border.color: SettingsTheme.borderColorLight
            border.width: 1

            StackLayout {
                anchors.fill: parent
                anchors.margins: 0
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
