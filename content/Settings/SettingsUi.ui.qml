import QtQuick 6.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 6.4
import Qt.labs.settings 1.1 as Labs
import SettingsCommon 1.0

Rectangle {
    id: settings_menu
    implicitWidth: 500
    implicitHeight: 300
    radius: SettingsTheme.radius.extraLarge
    color: SettingsTheme.settingsBackground
    border.color: SettingsTheme.borderColor
    border.width: 1

    property alias closeButton: closeButton
    property alias saveConfigButton: saveConfigButton
    property alias loadConfigButton: loadConfigButton
    property alias titleText: titleText
    property var availableControlStyles: ["Fusion", "Basic", "Material", "Universal"]
    property int selectedStyleIndex: 0

    Labs.Settings {
        id: uiSettingsStore
        category: "ui"
        property string controlsStyle: "Fusion"
    }

    function syncControlsStyleSelection() {
        var idx = availableControlStyles.indexOf(uiSettingsStore.controlsStyle)
        selectedStyleIndex = idx >= 0 ? idx : 0
    }

    Component.onCompleted: syncControlsStyleSelection()

    Connections {
        target: uiSettingsStore
        function onControlsStyleChanged() {
            settings_menu.syncControlsStyleSelection()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: SettingsTheme.margins.large
        anchors.leftMargin: SettingsTheme.margins.large
        anchors.rightMargin: SettingsTheme.margins.large
        anchors.bottomMargin: SettingsTheme.margins.large
        spacing: SettingsTheme.spacing.large

        // Header
        Text {
            id: titleText
            text: qsTr("Configuration Settings")
            font.bold: true
            font.pixelSize: SettingsTheme.fontSize.title
            color: SettingsTheme.textPrimary
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        // Info text
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: SettingsTheme.radius.medium
            color: SettingsTheme.cardBackground
            border.color: SettingsTheme.borderColorLight
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    text: qsTr("Configuration Management")
                    font.pixelSize: 14
                    font.bold: true
                    color: SettingsTheme.textPrimary
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Load or save your complete configuration including all connections and their settings.")
                    font.pixelSize: 12
                    color: SettingsTheme.textSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            radius: SettingsTheme.radius.medium
            color: SettingsTheme.cardBackground
            border.color: SettingsTheme.borderColorLight
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SettingsTheme.margins.medium
                spacing: SettingsTheme.spacing.small

                Text {
                    text: qsTr("UI Style")
                    font.pixelSize: SettingsTheme.fontSize.large
                    font.bold: true
                    color: SettingsTheme.textPrimary
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("Choose the Qt Quick Controls style used throughout the application.")
                    font.pixelSize: SettingsTheme.fontSize.medium
                    color: SettingsTheme.textSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                ComboBox {
                    id: controlsStyleCombo
                    Layout.fillWidth: true
                    model: settings_menu.availableControlStyles
                    currentIndex: settings_menu.selectedStyleIndex
                    onActivated: function(index) {
                        if (index < 0 || index >= settings_menu.availableControlStyles.length)
                            return
                        var styleName = settings_menu.availableControlStyles[index]
                        if (uiSettingsStore.controlsStyle !== styleName)
                            uiSettingsStore.controlsStyle = styleName
                        settings_menu.selectedStyleIndex = index
                    }
                }

                Text {
                    text: qsTr("Restart required for style changes to take effect.")
                    font.pixelSize: SettingsTheme.fontSize.small
                    color: SettingsTheme.textSecondary
                    Layout.fillWidth: true
                }
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Action Buttons
        ColumnLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.spacing.medium

            Button {
                id: loadConfigButton
                text: qsTr("📂 Load Configuration")
                icon.name: "document-open"
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.heights.button

                background: Rectangle {
                    color: loadConfigButton.pressed ? "#1565c0" : (loadConfigButton.hovered ? "#1976d2" : "#2196f3")
                    radius: 4
                    border.color: "#1565c0"
                    border.width: 1
                }

                contentItem: Text {
                    text: loadConfigButton.text
                    font.pixelSize: 13
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: saveConfigButton
                text: qsTr("💾 Save Configuration")
                icon.name: "document-save"
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.heights.button

                background: Rectangle {
                    color: saveConfigButton.pressed ? "#1565c0" : (saveConfigButton.hovered ? "#1976d2" : "#2196f3")
                    radius: 4
                    border.color: "#1565c0"
                    border.width: 1
                }

                contentItem: Text {
                    text: saveConfigButton.text
                    font.pixelSize: 13
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: SettingsTheme.borderColor
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            Button {
                id: closeButton
                text: qsTr("Close")
                Layout.fillWidth: true
                Layout.preferredHeight: SettingsTheme.heights.button

                background: Rectangle {
                    color: closeButton.pressed ? "#555555" : (closeButton.hovered ? "#666666" : "#4d4d4d")
                    radius: 4
                    border.color: "#606060"
                    border.width: 1
                }

                contentItem: Text {
                    text: closeButton.text
                    font.pixelSize: 13
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
