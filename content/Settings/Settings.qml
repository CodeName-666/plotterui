import QtQuick 2.15
import PlotterUi 1.0

SettingsUi {

    id: settings_menu

    Component.onCompleted: {
        comboBox.activated.connect(onComboBoxActivationChanged)
        okButton.clicked.connect(onOkButtonClicked)
        cancleButton.clicked.connect(onCancleButtonClicked)

    }

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
               BackendInterface.logError("SettingsUi: Invalid Settingsoption...")
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
        BackendInterface.set_settings(comboBox.currentText, settings)

        if(res === true)
        {
            applicationWindow.acceptSettings();
        }
        else
        {
            BackendInterface.logError("Settings Invalid...")
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
                "port": serialSettings.comComboBox.currentText,
                "baud": parseInt(serialSettings.baudInput.text),
                "size": serialSettings.dataSizeComboBox.currentValue,
                "parity": serialSettings.parityComboBox.currentValue,
                "stop": serialSettings.stopBitsCombo.currentValue
            }
        return serial_settings
    }

    function get_telnet_settings()
    {
        var telnet_settings = {
                "ip": telnetSettings.ipInput.text,
                "port": parseInt(telnetSettings.portInput.text)
            }
        return telnet_settings
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
            BackendInterface.logError("Invalid Configuration....")
            return 0
        }
    }
}
