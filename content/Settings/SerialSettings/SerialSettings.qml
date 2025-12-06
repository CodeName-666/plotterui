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
       set_combobox(comComboBox, settings["port"]);
       set_combobox(dataSizeComboBox, settings["size"]);
       set_combobox(parityComboBox, settings["parity"]);
       set_combobox(stopBitsCombo, settings["stop_bits"] !== undefined ? settings["stop_bits"] : settings["stop"]);

       baudInput.text = settings["baud"] !== undefined ? settings["baud"] : "";
       return
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_combobox(combobox, txt, type = "txt")
    {
         if(txt === undefined || txt === null)
            return
         var idx = combobox.find(txt, Qt.MatchExactly);
         if(idx >= 0)
            combobox.currentIndex = idx;
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_settings()
    {
        return {
                "port": comComboBox.currentText,
                "baud": parseInt(baudInput.text),
                "size": dataSizeComboBox.currentText,
                "parity": parityComboBox.currentText,
                "stop_bits": stopBitsCombo.currentValue !== undefined ? stopBitsCombo.currentValue : stopBitsCombo.currentText
               }
    }
}
