import QtQuick 6.4
import QtQuick.Dialogs
import Backend 1.0

import "SerialSettings"
import "TelnetSettings"
import "MQTTSettings"
import "TestSettings"

SettingsUi {
    id: settings_menu

    readonly property var interfaceNames: ["Serial", "Telnet", "MQTT", "Test"]
    readonly property var loaderMap: ({
        "Serial": serialLoader,
        "Telnet": telnetLoader,
        "MQTT": mqttLoader,
        "Test": testLoader
    })

    property var settingsData: ({})
    property var originalSettings: ({})

    Component { id: serialSettingsComponent; SerialSettings { } }
    Component { id: telnetSettingsComponent; TelnetSettings { } }
    Component { id: mqttSettingsComponent; MQTTSettings { } }
    Component { id: testSettingsComponent; TestSettings { } }

    FileDialog {
        id: savePresetDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON files (*.json)"]
        defaultSuffix: "json"
        onAccepted: savePresetToFile(selectedFile)
    }

    FileDialog {
        id: loadPresetDialog
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON files (*.json)"]
        onAccepted: loadPresetFromFile(selectedFile)
    }

    Component.onCompleted: {
        Logger.log_debug("Settings: Component completed")
        initializeLoaders()
        loadSettingsFromBackend()
    }

    savePresetButton.onClicked: savePresetDialog.open()
    loadPresetButton.onClicked: loadPresetDialog.open()

    okButton.onClicked: {
        if(validateAllSettings()) {
            saveAllSettings()
            settings_menu.visible = false
        }
    }

    cancelButton.onClicked: {
        restoreOriginalSettings()
        settings_menu.visible = false
    }

    function initializeLoaders() {
        serialLoader.sourceComponent = serialSettingsComponent
        telnetLoader.sourceComponent = telnetSettingsComponent
        mqttLoader.sourceComponent = mqttSettingsComponent
        testLoader.sourceComponent = testSettingsComponent

        Logger.log_debug("Settings: All loaders initialized")

        connectValidationSignals()
    }

    function connectValidationSignals() {
        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            var loader = loaderMap[name]
            if(loader && loader.item) {
                connectLoaderSignals(loader.item)
            }
        }
        updateOkButtonState()
    }

    function connectLoaderSignals(item) {
        if(!item) return

        var children = findAllChildren(item)
        for(var i = 0; i < children.length; i++) {
            var child = children[i]
            if(child.hasOwnProperty("text") && child.hasOwnProperty("textChanged")) {
                child.textChanged.connect(updateOkButtonState)
            }
            if(child.hasOwnProperty("currentIndex") && child.hasOwnProperty("currentIndexChanged")) {
                child.currentIndexChanged.connect(updateOkButtonState)
            }
            if(child.hasOwnProperty("color") && child.hasOwnProperty("colorChanged")) {
                child.colorChanged.connect(updateOkButtonState)
            }
        }
    }

    function findAllChildren(parent) {
        var allChildren = []
        if(!parent || !parent.hasOwnProperty("children"))
            return allChildren

        for(var i = 0; i < parent.children.length; i++) {
            var child = parent.children[i]
            allChildren.push(child)
            var subChildren = findAllChildren(child)
            allChildren = allChildren.concat(subChildren)
        }
        return allChildren
    }

    function updateOkButtonState() {
        okButton.enabled = validateAllSettings()
    }

    function validateAllSettings() {
        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            var loader = loaderMap[name]

            if(loader && loader.item && typeof loader.item.isValid === "function") {
                if(!loader.item.isValid()) {
                    Logger.log_debug("Settings: Validation failed for " + name)
                    return false
                }
            }
        }
        return true
    }

    function getInterfaceSettings(interfaceName) {
        var loader = loaderMap[interfaceName]
        if(loader && loader.item && typeof loader.item.getSettings === "function") {
            return loader.item.getSettings()
        }
        return null
    }

    function setInterfaceSettings(interfaceName, settings) {
        var loader = loaderMap[interfaceName]
        if(loader && loader.item && typeof loader.item.setSettings === "function") {
            loader.item.setSettings(settings)
            Logger.log_debug("Settings: Applied settings for " + interfaceName)
        }
    }

    function updateComPorts(new_com_ports) {
        Logger.log_info("Settings: New COM Ports detected: " + JSON.stringify(new_com_ports))
        if(serialLoader.item && serialLoader.item.com_ports !== undefined) {
            serialLoader.item.com_ports = new_com_ports
        }
    }

    function loadSettingsFromBackend() {
        Logger.log_info("Settings: Loading settings from backend")

        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            var config = Backend.get_interface_config(name)

            if(config) {
                settingsData[name] = config
                originalSettings[name] = JSON.parse(JSON.stringify(config))
                setInterfaceSettings(name, config)
                Logger.log_debug("Settings: Loaded " + name + " settings from backend")
            } else {
                Logger.log_warning("Settings: No backend config for " + name)
            }
        }
    }

    function saveAllSettings() {
        Logger.log_info("Settings: Saving all settings to backend")

        var allValid = true
        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            var settings = getInterfaceSettings(name)

            if(!settings || settings.valid === false) {
                Logger.log_error("Settings: Invalid settings for " + name)
                allValid = false
                continue
            }

            settingsData[name] = settings
            originalSettings[name] = JSON.parse(JSON.stringify(settings))

            if(typeof Backend.set_settings === "function") {
                Backend.set_settings(name, settings)
                Logger.log_info("Settings: Saved " + name + " settings to backend")
            }
        }

        if(allValid) {
            Backend.save_settings_to_config()
            Logger.log_info("Settings: All settings saved successfully")
        }
    }

    function restoreOriginalSettings() {
        Logger.log_debug("Settings: Restoring original settings")

        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            if(originalSettings[name]) {
                setInterfaceSettings(name, originalSettings[name])
            }
        }
    }

    // Alias for backward compatibility
    function restoreSettings() {
        restoreOriginalSettings()
    }

    function savePresetToFile(fileUrl) {
        Logger.log_info("Settings: Saving preset to " + fileUrl)

        var preset = {}
        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            var settings = getInterfaceSettings(name)
            if(settings) {
                preset[name] = settings
            }
        }

        var success = Backend.save_preset(fileUrl, preset)
        if(success) {
            Logger.log_info("Settings: Preset saved successfully")
        } else {
            Logger.log_error("Settings: Failed to save preset")
        }
    }

    function loadPresetFromFile(fileUrl) {
        Logger.log_info("Settings: Loading preset from " + fileUrl)

        var preset = Backend.load_preset(fileUrl)
        if(!preset) {
            Logger.log_error("Settings: Failed to load preset")
            return
        }

        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            if(preset[name]) {
                setInterfaceSettings(name, preset[name])
                Logger.log_debug("Settings: Loaded " + name + " from preset")
            }
        }

        updateOkButtonState()
        Logger.log_info("Settings: Preset loaded successfully")
    }

    function setup(settings) {
        Logger.log_info("Settings: setup called")
        loadSettingsFromBackend()
        return true
    }
}
