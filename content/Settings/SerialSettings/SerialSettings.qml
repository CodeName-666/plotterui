import QtQuick 6.4
import QtQuick.Controls 6.4


SerialSettingsUi {



    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setSettings(settings)
    {
       if(!settings)
           return
       setCombobox(comComboBox, settings["port"], "text");
       setCombobox(dataSizeComboBox, settings["size"], "value");
       setCombobox(parityComboBox, settings["parity"], "value");
       setCombobox(stopBitsCombo, settings["stop_bits"] !== undefined ? settings["stop_bits"] : settings["stop"], "value");

       baudInput.text = settings["baud"] !== undefined ? settings["baud"] : "";
       return
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setCombobox(combobox, value, role = "text")
    {
         if(value === undefined || value === null)
            return
         var idx = combobox.find(value, Qt.MatchExactly, role);
         if(idx >= 0)
            combobox.currentIndex = idx;
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function getSettings()
    {
        const baud = parseInt(baudInput.text)
        return {
                "port": comComboBox.currentText,
                "baud": isNaN(baud) ? 0 : baud,
                "size": dataSizeComboBox.currentValue !== undefined ? dataSizeComboBox.currentValue : dataSizeComboBox.currentText,
                "parity": parityComboBox.currentValue !== undefined ? parityComboBox.currentValue : parityComboBox.currentText,
                "stop_bits": stopBitsCombo.currentValue !== undefined ? stopBitsCombo.currentValue : stopBitsCombo.currentText
               }
    }
}
