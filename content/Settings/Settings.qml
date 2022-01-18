import QtQuick 2.15
import PlotterUi 1.0

SettingsUi {

    id: settings_menu

    comboBox.onActivated:
    {

           if( comboBox.displayText == "Serial" )
           {
               telnetSettings.visible = false;
               serialSettings.visible = true;
               testSettings.visible = false;
           }
           else if(comboBox.displayText == "Telnet")
           {
               telnetSettings.visible = true;
               serialSettings.visible = false;
               testSettings.visible = false;
           }
           else if (comboBox.displayText == "Test")
           {
               telnetSettings.visible = false;
               serialSettings.visible = false;
               testSettings.visible = true;
           }

           else
           {
               BackendInterface.logError("SettingsUi: Invalid Settingsoption...")
           }
       }

    okButton.onClicked:
    {
        var cSettings = 0;
        var res;

        cSettings = get_settings(comboBox.currentText)
        BackendInterface.set_settings(comboBox.currentText, cSettings)

        //if(res === true)
        //{
        //    applicationWindow.acceptSettings();
        //}
        //else
        //{
        //    BackendInterface.logError("Settings Invalid...")
        //}
    }


    cancleButton.onClicked:
    {
        applicationWindow.cancleSettings()
    }

    function backupSettings()
    {
        old_settings = get_settings(comboBox.currentText);
    }

    function updateComPorts(new_com_ports)
    {
       serialSettings.com_ports = new_com_ports
    }


    function get_serial_settings()
    {
        return {
                "port": serialSettings.comComboBox.currentText,
                "baud": parseInt(serialSettings.baudInput.text),
                "size": serialSettings.dataSizeComboBox.currentValue,
                "parity": serialSettings.parityComboBox.currentValue,
                "stop": serialSettings.stopBitsCombo.currentValue
               }

    }

    function get_telnet_settings()
    {
        return  {
                 "ip": telnetSettings.ipInput.text,
                 "port": parseInt(telnetSettings.portInput.text)
                }
    }

    function get_test_settings()
    {
        return {
                "name": qstr(testSettings.nameInput.text),
                "color": testSettings.colorView.color
               }
    }

    function get_settings(combo_box_txt)
    {
        if(combo_box_txt === "Telnet")
        {
            return get_telnet_settings();
        }
        else if (combo_box_txt === "Serial")
        {
            return get_serial_settings();
        }
        else if (combo_box_txt === "Test")
        {
            return get_test_settings();
        }

        else
        {
            BackendInterface.logError("Invalid Configuration....")
            return 0
        }
    }
}
