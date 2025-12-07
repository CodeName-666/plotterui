import QtQuick 6.4
import Backend 1.0

import "SerialSettings"
import "TelnetSettings"
import "MQTTSettings"
import "TestSettings"

SettingsUi {

    id: settings_menu
    property var old_settings: ({})
    property var old_interface: ({})
    property string currentInterfaceName: ""
    property string currentCanonicalInterface: ""
    readonly property var _interfaceAliases: ({
        "Telnet Client": "Telnet",
        "Telnet Server": "Telnet",
        "CAN": "Test"
    })
    readonly property var _componentTemplates: ({
        "Serial": serialSettingsComponent,
        "Telnet": telnetSettingsComponent,
        "MQTT": mqttSettingsComponent,
        "Test": testSettingsComponent
    })
    property var _storedSettings: ({})

    Component { id: serialSettingsComponent; SerialSettings { } }
    Component { id: telnetSettingsComponent; TelnetSettings { } }
    Component { id: mqttSettingsComponent; MQTTSettings { } }
    Component { id: testSettingsComponent; TestSettings { } }

    /*******************************************************************
     * EVENT
     ******************************************************************/
    Component.onCompleted: {
        Logger.log_debug("SettingsUi Completed")
        if(interfaceComboBox.currentText !== "")
        {
            set_interface(interfaceComboBox.currentText)
        }
    }

    /*******************************************************************
     * EVENT
     ******************************************************************/
    interfaceComboBox.onActivated:
    {
        set_interface(interfaceComboBox.currentText)
    }

    settingsLoader.onLoaded: apply_stored_settings()

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function canonical_interface_name(interface_name) {
        if(!interface_name)
            return ""
        if(_componentTemplates[interface_name])
            return interface_name
        if(_interfaceAliases[interface_name] !== undefined)
            return _interfaceAliases[interface_name]
        return ""
    }

    function get_interface_template(interface_name)
    {
        var canonical = canonical_interface_name(interface_name)
        if(canonical !== "")
            return _componentTemplates[canonical]
        return undefined
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_interface(interface_name)
    {
        if(interface_name === undefined || interface_name === null || interface_name === "")
        {
            Logger.log_warning("SettingsUi: Empty interface selection ignored")
            return
        }

        if(currentInterfaceName !== "" && interface_name !== currentInterfaceName)
        {
            get_settings(currentInterfaceName)
        }

        var template = get_interface_template(interface_name)
        if(template === undefined)
        {
            Logger.log_error("SettingsUi: Invalid Settingsoption...")
            return
        }

        currentInterfaceName = interface_name
        currentCanonicalInterface = canonical_interface_name(interface_name)
        if(interfaceComboBox.currentText !== interface_name)
        {
            var idx = interfaceComboBox.model.indexOf(interface_name)
            if(idx >= 0)
                interfaceComboBox.currentIndex = idx
        }

        settingsLoader.sourceComponent = template

        if(interface_name === "CAN")
        {
            Logger.log_warning("SettingsUi: No dedicated UI for " + interface_name + ", using generic settings")
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function backup_settings()
    {
        if(interfaceComboBox.currentText !== "")
        {
            old_interface = interfaceComboBox.currentText
            old_settings = get_settings(interfaceComboBox.currentText);
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function update_com_ports(new_com_ports)
    {   
        Logger.log_info("New COM Ports detected:");
        for (let i = 0; i < new_com_ports.length; i++) {
            Logger.log_info("COM-Port: " + new_com_ports[i]);
        }
        serialSettings.com_ports = new_com_ports
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function restore_settings()
    {
        if(old_interface !== undefined && old_interface !== null)
        {
            set_interface(old_interface);
            if(old_settings)
                set_settings(old_interface, old_settings);
        }
    }


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_settings(interface_name)
    {
        if(!interface_name)
            return false

        if(interface_name === currentInterfaceName)
        {
            var active = settingsLoader.item
            if(active && typeof active.get_settings === "function")
            {
                _storedSettings[interface_name] = active.get_settings()
            }
        }

        if(_storedSettings[interface_name] !== undefined)
        {
            return _storedSettings[interface_name]
        }

        Logger.log_error("Invalid Configuration....")
        return false
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(interface_name, settings)
    {
        if(!interface_name)
            return false

        _storedSettings[interface_name] = settings

        if(interface_name === currentInterfaceName)
        {
            var active = settingsLoader.item
            if(active && typeof active.set_settings === "function")
            {
                active.set_settings(settings);
            }
        }
        return true
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function apply_stored_settings()
    {
        if(currentInterfaceName === "")
            return
        var active = settingsLoader.item
        var stored = _storedSettings[currentInterfaceName]
        if(active && stored && typeof active.set_settings === "function")
        {
            active.set_settings(stored)
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setup(settings) {
        // Settings for available interfaces
        var interface_model = settings["interfaces"];
        interfaceComboBox.model = interface_model;
        if(interface_model.length > 0)
        {
            interfaceComboBox.currentIndex = 0
            set_interface(interfaceComboBox.currentText)
        }

        // Get DATA of Serial settings data Models
        //var serial_config = settings["serial"];
        //var data_size_model = serial_config["dataBits"];
        //var parity_bits_model = serial_config["parityBits"];
        //var stop_bits_model = serial_config["stopBits"];
        // Set DATA of Serial settings data Models
        //serialSettings.dataSizeComboBox.model = data_size_model;
        //serialSettings.parityComboBox.model = parity_bits_model;s
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
