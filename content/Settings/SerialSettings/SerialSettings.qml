import QtQuick 6.4
import QtQuick.Controls 6.4


SerialSettingsUi {



    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(settings)
    {
       if(!settings)
           return
       set_combobox(comComboBox, settings["port"], "text");
       set_combobox(dataSizeComboBox, settings["size"], "value");
       set_combobox(parityComboBox, settings["parity"], "value");
       set_combobox(stopBitsCombo, settings["stop_bits"] !== undefined ? settings["stop_bits"] : settings["stop"], "value");

       baudInput.text = settings["baud"] !== undefined ? settings["baud"] : "";
       return
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_combobox(combobox, value, role = "text")
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
    function get_settings()
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
