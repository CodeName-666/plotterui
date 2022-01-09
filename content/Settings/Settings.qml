import QtQuick 2.15
import PlotterUi 1.0

SettingsUi {

    /******************************************************************
     * Signals and Parameter
     ******************************************************************/
    comboBox.onActivated:   onComboBoxActivationChanged()
    okButton.onClicked:     onOkButtonClicked()
    cancleButton.onClicked: onCancleButtonClicked()

    /******************************************************************
     * Callback: onComboBoxActivationChanged
     ******************************************************************/
    function onComboBoxActivationChanged()
    {

           if( comboBox.displayText == "Serial" )
           {
               telnetSettings.visible = false;
               serialSettings.visible = true;
           }
           else if(comboBox.displayText == "Telnet")
           {
               telnetSettings.visible = true;
               serialSettings.visible = false;
           }
           else
           {
               console.log("SettingsUi: Invalid Settingsoption...")
           }
       }

    /******************************************************************
     * Callback: onOkButtonClicked
     ******************************************************************/
    function onOkButtonClicked()
    {
        var config = 0;
        var res;

        settings = get_settings(comboBox.currentText)
        BackIf.set_settings(comboBox.currentText, settings)

        if(res === true)
        {
            applicationWindow.acceptSettings();
        }
        else
        {
            console.log("Settings Invalid...")
        }
    }

    /******************************************************************
     * Callback: onCancleButtonClicked
     ******************************************************************/
    function onCancleButtonClicked()
    {
        applicationWindow.cancleSettings()
    }

    /******************************************************************
     * METHOD: onCancleButtonClicked
     ******************************************************************/
    function updateComPorts(new_com_ports)
    {
       serialSettings.com_ports = new_com_ports
    }


    function get_serial_settings()
    {
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

    function get_telnet_settings()
    {

    }

    /******************************************************************
     * METHOD: getSettings
     ******************************************************************/
    function get_settings(combo_box_txt)
    {
        if(combo_box_txt === "Telnet")
        {
            return get_telnet_settings()
        }
        else if (combo_box_txt === "Serial")
        {
            return get_serial_settings()
        }
        else
        {
            BackIf.logError("")
            return 0
        }
    }
}
