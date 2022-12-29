import QtQuick 6.4
import Backend 1.0

import "SerialSettings"
import "TelnetSettings"
import "TestSettings"

SettingsUi {

    id: settings_menu
    property var old_settings: ({})
    property var old_interface: ({})

    /*******************************************************************
     * EVENT
     ******************************************************************/
    Component.onCompleted: {
        Logger.log_debug("SettingsUi Completed")
        set_interface(interfaceComboBox.displayText)
    }

    /*******************************************************************
     * EVENT
     ******************************************************************/
    interfaceComboBox.onActivated:
    {
        set_interface(interfaceComboBox.displayText)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
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

        switch(interface_name)
        {
        case "Serial":
            telnetSettings.visible = false;
            serialSettings.visible = true;
            testSettings.visible = false;
            break;
        case "Telnet":
            telnetSettings.visible = true;
            serialSettings.visible = false;
            testSettings.visible = false;
            break;
        case "Test":
            telnetSettings.visible = false;
            serialSettings.visible = false;
            testSettings.visible = true;
            break

        default:
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
            return false
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(interface_name, settings)
    {
        var ui = get_interface_by_name(interface_name)

        if(ui !== undefined)
        {
            return ui.set_settings(settings);
        }
        else
        {
            Logger.log_error("Invalid Configuration....")
            return false
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
