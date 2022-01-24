import QtQuick 2.15
import PlotterUi 1.0

SettingsUi {

    id: settings_menu

    comboBox.onActivated:
    {
        set_interface(comboBox.displayText)
    }

    function set_interface(interface_name)
    {
        if( interface_name === "Serial" )
        {
            telnetSettings.visible = false;
            serialSettings.visible = true;
            testSettings.visible = false;
        }
        else if(interface_name === "Telnet")
        {
            telnetSettings.visible = true;
            serialSettings.visible = false;
            testSettings.visible = false;
        }
        else if (interface_name === "Test")
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


    function backupSettings()
    {
        old_interface = comboBox.currentText
        old_settings = get_settings(comboBox.currentText);
    }

    function updateComPorts(new_com_ports)
    {
       serialSettings.com_ports = new_com_ports
    }

    function restoreSettings()
    {
        set_interface(old_interface);
        set_settings(old_interface, old_settings);
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
        var retVal =  {
            "name": qsTr(testSettings.nameInput.text),
            "color": testSettings.colorView.color,
            "type": qsTr(testSettings.typeCombo.currentText)
           }

        return retVal;
    }

    function get_settings(interface_name)
    {
        if(interface_name === "Telnet")
        {
            return get_telnet_settings();
        }
        else if (interface_name === "Serial")
        {
            return get_serial_settings();
        }
        else if (interface_name === "Test")
        {
            return get_test_settings();
        }

        else
        {
            BackendInterface.logError("Invalid Configuration....")
            return 0
        }
    }



    function set_telnet_settings(settings)
    {
       telnetSettings.ipInput.text = settings["ip"];
       telnetSettings.portInput.text = settings["port"];
    }

    function set_serial_settings(settings)
    {

       serialSettings.comComboBox.currentText = settings["port"];
       serialSettings.baudInput.text = settings["baud"];
       serialSettings.dataSizeComboBox.currentValue =  settings["size"];
       serialSettings.parityComboBox.currentValue = settings["parity"];
       serialSettings.stopBitsCombo.currentValue = settings["stop"];

    }

    function set_test_settings(settings)
    {
        testSettings.nameInput.text = settings["name"];
        testSettings.colorView.color = settings["color"];
        testSettings.typeCombo.currentText = settings["type"];
    }

    function set_settings(interface_name, settings)
    {
        if(interface_name === "Telnet")
        {
            return set_telnet_settings(settings);
        }
        else if (interface_name === "Serial")
        {
            return set_serial_settings(settings);
        }
        else if (interface_name === "Test")
        {
            return set_test_settings(settings);
        }

        else
        {
            BackendInterface.logError("Invalid Configuration....")
            return 0
        }
    }
}
