import QtQuick 6.4
import QtQuick.Controls 6.4


SerialSettingsUi {



    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(settings)
    {
       set_combobox(comComboBox, settings["port"]);
       set_combobox(dataSizeComboBox,settings["size"]);
       set_combobox(parityComboBox, settings["parity"]);
       set_combobox(stopBitsCombo, settings["stop"]);

       baudInput.text = settings["baud"];
       return
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_combobox(combobox, txt, type = "txt")
    {
         var idx = combobox.find(txt, Qt.MatchExactly);
         //interfaceComboBox.currentIndex = idx;
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
                "stop": stopBitsCombo.currentValue
               }
    }
}
