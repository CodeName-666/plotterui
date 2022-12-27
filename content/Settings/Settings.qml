import QtQuick 6.4
import Backend 1.0

import "SerialSettings"
import "TelnetSettings"
import "TestSettings"

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

    function get_interface_by_name(interface_name)
    {
        switch(interface_name)
        {
        case "Serial":
            return serialSettings;
        case "Telnet":
            return telnetSettings;
        case "Test":
            return testSettings;
        default:
            return undefined

        }
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
    function get_settings(interface_name)
    {
        var ui = get_interface_by_name(interface_name);

        if (ui !== undefined)
        {
            return ui.get_settings()
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
    function set_settings(interface_name, settings)
    {
        if(interface_name === "Telnet")
        {
            return telnetSettings.set_settings(settings);
        }
        else if (interface_name === "Serial")
        {
            return serialSettings.set_settings(settings);
        }
        else if (interface_name === "Test")
        {
            return testSettings.set_settings(settings);
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
        //var serial_config = settings["serial"];
        //var data_size_model = serial_config["dataBits"];
        //var parity_bits_model = serial_config["parityBits"];
        //var stop_bits_model = serial_config["stopBits"];
        // Set DATA of Serial settings data Models
        //serialSettings.dataSizeComboBox.model = data_size_model;
        //serialSettings.parityComboBox.model = parity_bits_model;
        //serialSettings.stopBitsCombo.model = stop_bits_model;

        Logger.log_debug("Settings Setup")
        return true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
