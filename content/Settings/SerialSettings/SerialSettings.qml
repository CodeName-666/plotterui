import QtQuick 2.15
import QtQuick.Controls 2.15

SerialSettingsUi{


    function getSettings() {
        var serial_settings = {
            "type": 'SERIAL',
            "port": comComboBox.currentText,
            "baud": parseInt(baudInput.text),
            "size": dataSizeComboBox.currentValue,
            "parity": parityComboBox.currentValue,
            "stop": stopBitsCombo.currentValue
        }
        return serial_settings
    }

}
