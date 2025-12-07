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
            setInterface(interfaceComboBox.currentText)
        }
    }

    /*******************************************************************
     * EVENT
     ******************************************************************/
    interfaceComboBox.onActivated:
    {
        setInterface(interfaceComboBox.currentText)
    }

    settingsLoader.onLoaded: applyStoredSettings()

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function canonicalInterfaceName(interface_name) {
        if(!interface_name)
            return ""
        if(_componentTemplates[interface_name])
            return interface_name
        return ""
    }

    function getInterfaceTemplate(interface_name)
    {
        var canonical = canonicalInterfaceName(interface_name)
        if(canonical !== "")
            return _componentTemplates[canonical]
        return undefined
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setInterface(interface_name)
    {
        Logger.log_debug("Settings: set_interface called with: " + interface_name)

        if(interface_name === undefined || interface_name === null || interface_name === "")
        {
            Logger.log_warning("SettingsUi: Empty interface selection ignored")
            return
        }

        if(currentInterfaceName !== "" && interface_name !== currentInterfaceName)
        {
            Logger.log_debug("Settings: Saving settings for previous interface: " + currentInterfaceName)
            getSettings(currentInterfaceName)
        }

        var template = getInterfaceTemplate(interface_name)
        if(template === undefined)
        {
            Logger.log_error("SettingsUi: Invalid Settingsoption for interface: " + interface_name)
            return
        }

        currentInterfaceName = interface_name
        currentCanonicalInterface = canonicalInterfaceName(interface_name)
        Logger.log_info("Settings: Switching to interface: " + interface_name + " (canonical: " + currentCanonicalInterface + ")")

        if(interfaceComboBox.currentText !== interface_name)
        {
            var idx = interfaceComboBox.model.indexOf(interface_name)
            if(idx >= 0)
                interfaceComboBox.currentIndex = idx
        }

        settingsLoader.sourceComponent = template
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function backupSettings()
    {
        if(interfaceComboBox.currentText !== "")
        {
            old_interface = interfaceComboBox.currentText
            old_settings = getSettings(interfaceComboBox.currentText);
        }
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
        if(settingsLoader.item && settingsLoader.item.com_ports !== undefined)
            settingsLoader.item.com_ports = new_com_ports
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function restoreSettings()
    {
        if(old_interface !== undefined && old_interface !== null)
        {
            setInterface(old_interface);
            if(old_settings)
                setSettings(old_interface, old_settings);
        }
    }


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function getSettings(interface_name)
    {
        Logger.log_debug("Settings: get_settings called for: " + interface_name)

        if(!interface_name)
        {
            Logger.log_warning("Settings: get_settings - interface_name is empty")
            return false
        }

        if(interface_name === currentInterfaceName)
        {
            var active = settingsLoader.item
            if(active && typeof active.getSettings === "function")
            {
                _storedSettings[interface_name] = active.getSettings()
                Logger.log_debug("Settings: Retrieved settings from active UI for: " + interface_name)
            }
        }

        if(_storedSettings[interface_name] !== undefined)
        {
            Logger.log_info("Settings: Returning stored settings for: " + interface_name)
            return _storedSettings[interface_name]
        }

        Logger.log_error("Settings: Invalid Configuration for interface: " + interface_name)
        return false
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setSettings(interface_name, settings)
    {
        Logger.log_debug("Settings: set_settings called for: " + interface_name)

        if(!interface_name)
        {
            Logger.log_warning("Settings: set_settings - interface_name is empty")
            return false
        }

        _storedSettings[interface_name] = settings
        Logger.log_info("Settings: Stored settings for interface: " + interface_name + " - " + JSON.stringify(settings))

        if(interface_name === currentInterfaceName)
        {
            var active = settingsLoader.item
            if(active && typeof active.setSettings === "function")
            {
                Logger.log_debug("Settings: Applying settings to active UI for: " + interface_name)
                active.setSettings(settings);
            }
        }
        return true
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function applyStoredSettings()
    {
        if(currentInterfaceName === "")
            return
        var active = settingsLoader.item
        var stored = _storedSettings[currentInterfaceName]
        if(active && stored && typeof active.setSettings === "function")
        {
            active.setSettings(stored)
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setup(settings) {
        Logger.log_info("Settings: setup called with: " + JSON.stringify(settings))

        // Settings for available interfaces
        var interface_model = settings["interfaces"];
        Logger.log_debug("Settings: Available interfaces: " + JSON.stringify(interface_model))

        interfaceComboBox.model = interface_model;
        if(interface_model.length > 0)
        {
            interfaceComboBox.currentIndex = 0
            Logger.log_debug("Settings: Setting initial interface to: " + interfaceComboBox.currentText)
            setInterface(interfaceComboBox.currentText)
        }
        else
        {
            Logger.log_warning("Settings: No interfaces available in model")
        }

        Logger.log_debug("Settings Setup completed")
        return true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
