import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15
import SettingsCommon 1.0

ColumnLayout {
    id: validatedField

    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias inputMethodHints: textField.inputMethodHints
    property string errorText: ""
    property bool hasError: errorText !== ""
    property var validator: null

    signal textChanged()
    signal editingFinished()

    spacing: SettingsTheme.spacing.small

    TextField {
        id: textField
        Layout.fillWidth: true
        Layout.preferredHeight: SettingsTheme.heights.input

        background: Rectangle {
            color: textField.enabled ? SettingsTheme.cardBackground : SettingsTheme.interfaceBackground
            border.color: hasError ? SettingsTheme.errorColor :
                         (textField.activeFocus ? SettingsTheme.highlightColor : SettingsTheme.borderColor)
            border.width: textField.activeFocus || hasError ? 2 : 1
            radius: SettingsTheme.radius.small
        }

        onTextChanged: {
            validatedField.textChanged()
            validateInput()
        }

        onEditingFinished: validatedField.editingFinished()
    }

    Label {
        visible: hasError
        text: errorText
        color: SettingsTheme.errorColor
        font.pixelSize: SettingsTheme.fontSize.small
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }

    function validateInput() {
        if(validator && typeof validator === "function") {
            var result = validator(textField.text)
            errorText = result.valid ? "" : result.error
        }
    }
}
