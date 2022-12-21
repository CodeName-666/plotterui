import QtQuick 6.4
import PlotterUi 1.0

SettingsUi {

    id: settings_menu

    Component.onCompleted: {
        Logger.log_debug("SettingsUi Completed")
        set_interface(interfaceComboBox.displayText)
    }

    interfaceComboBox.onActivated:
    {
        set_interface(interfaceComboBox.displayText)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
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
            Logger.log_error("SettingsUi: Invalid Settingsoption...")
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function backupSettings()
    {
        old_interface = interfaceComboBox.currentText
        old_settings = get_settings(interfaceComboBox.currentText);
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function updateComPorts(new_com_ports)
    {   
        Logger.log_info("New COM Ports detected:");
        for (let i = 0; i < new_com_ports.length; i++) {
            Logger.log_info("COM-Port: " + new_com_ports[i]);
        }
        serialSettings.comComboBox.model = new_com_ports
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function restoreSettings()
    {
        set_interface(old_interface);
        set_settings(old_interface, old_settings);
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_serial_settings()
    {
        return {
                "port": serialSettings.comComboBox.currentText,
                "baud": parseInt(serialSettings.baudInput.text),
                "size": serialSettings.dataSizeComboBox.currentText,
                "parity": serialSettings.parityComboBox.currentText,
                "stop": serialSettings.stopBitsCombo.currentValue
               }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_telnet_settings()
    {
        return  {
                 "ip": telnetSettings.ipInput.text,
                 "port": parseInt(telnetSettings.portInput.text)
                }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_test_settings()
    {
        var retVal =  {
            "name": qsTr(testSettings.nameInput.text),
            "color": testSettings.colorView.color,
            "type": qsTr(testSettings.typeCombo.currentText)
           }
        return retVal;
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
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
            Logger.log_error("Invalid Configuration....")
            return 0
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_telnet_settings(settings)
    {
       telnetSettings.ipInput.text = settings["ip"];
       telnetSettings.portInput.text = settings["port"];
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_serial_settings(settings)
    {
       set_combobox(serialSettings.comComboBox, settings["port"]);
       set_combobox(serialSettings.dataSizeComboBox,settings["size"]);
       set_combobox(serialSettings.parityComboBox, settings["parity"]);
       set_combobox(serialSettings.stopBitsCombo, settings["stop"]);
       serialSettings.baudInput.text = settings["baud"];
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_test_settings(settings)
    {
        testSettings.nameInput.text = settings["name"];
        testSettings.colorView.color = settings["color"];
        set_combobox(testSettings.typeCombo,settings["type"]);
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
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
            Logger.log_error("Invalid Configuration....")
            return 0
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_combobox(combobox, txt, type = "txt")
    {
         var idx = combobox.find(txt, Qt.MatchExactly);
         interfaceComboBox.currentIndex = idx;
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setup(settings) {
        // Settings for available interfaces
        var interface_model = settings["interfaces"];
        interfaceComboBox.model = interface_model;

        // Get DATA of Serial settings data Models
        var serial_config = settings["serial"];
        var data_size_model = serial_config["dataBits"];
        var parity_bits_model = serial_config["parityBits"];
        var stop_bits_model = serial_config["stopBits"];
        // Set DATA of Serial settings data Models
        serialSettings.dataSizeComboBox.model = data_size_model;
        serialSettings.parityComboBox.model = parity_bits_model;
        serialSettings.stopBitsCombo.model = stop_bits_model;

        Logger.log_debug("Settings Setup")
        return true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
