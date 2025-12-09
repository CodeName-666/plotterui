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

    // Multi-connection support
    property string currentConnectionId: ""  // If set, applies settings to specific connection
    property bool isConnectionSpecific: currentConnectionId !== ""

    Component { id: serialSettingsComponent; SerialSettings { } }
    Component { id: telnetSettingsComponent; TelnetSettings { } }
    Component { id: mqttSettingsComponent; MQTTSettings { } }
    Component { id: testSettingsComponent; TestSettings { } }

    // Update title based on mode
    onIsConnectionSpecificChanged: updateTitle()
    onCurrentConnectionIdChanged: updateTitle()

    function updateTitle() {
        if (isConnectionSpecific && currentConnectionId !== "") {
            var connDetails = Backend.get_connection_details(currentConnectionId)
            if (connDetails && connDetails.name) {
                titleText.text = qsTr("Settings: ") + connDetails.name
            } else {
                titleText.text = qsTr("Connection Settings")
            }
        } else {
            titleText.text = qsTr("Default Templates")
        }
    }

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

    onVisibleChanged: {
        if (visible) {
            Logger.log_debug("Settings: Dialog opened, reloading settings")
            loadSettingsFromBackend()
            updateTitle()
        }
    }

    savePresetButton.onClicked: savePresetDialog.open()
    loadPresetButton.onClicked: loadPresetDialog.open()

    okButton.onClicked: {
        if(validateAllSettings()) {
            saveAllSettings()
            // Reset connection-specific mode
            currentConnectionId = ""
            settings_menu.visible = false
        }
    }

    cancelButton.onClicked: {
        restoreOriginalSettings()
        // Reset connection-specific mode
        currentConnectionId = ""
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

        // Check if we're loading settings for a specific connection
        if (isConnectionSpecific && currentConnectionId !== "") {
            loadConnectionSettings()
            return
        }

        // Otherwise, load default templates
        for(var i = 0; i < interfaceNames.length; i++) {
            var name = interfaceNames[i]
            var config = Backend.get_interface_config(name)

            if(config) {
                settingsData[name] = config
                originalSettings[name] = JSON.parse(JSON.stringify(config))
                setInterfaceSettings(name, config)
                Logger.log_debug("Settings: Loaded default template for " + name)
            } else {
                Logger.log_warning("Settings: No default template for " + name)
            }
        }
    }

    function loadConnectionSettings() {
        Logger.log_info("Settings: Loading settings for connection " + currentConnectionId)

        var connDetails = Backend.get_connection_details(currentConnectionId)
        if (!connDetails || !connDetails.type) {
            Logger.log_error("Settings: Could not get connection details for " + currentConnectionId)
            return
        }

        var interfaceType = connDetails.type
        var connectionSettings = connDetails.settings

        if (connectionSettings) {
            settingsData[interfaceType] = connectionSettings
            originalSettings[interfaceType] = JSON.parse(JSON.stringify(connectionSettings))
            setInterfaceSettings(interfaceType, connectionSettings)
            Logger.log_debug("Settings: Loaded settings for connection " + currentConnectionId)
        } else {
            Logger.log_warning("Settings: No settings found for connection " + currentConnectionId)
        }
    }

    function saveAllSettings() {
        // Check if we're in connection-specific mode
        if(isConnectionSpecific && currentConnectionId !== "") {
            Logger.log_info("Settings: Saving settings for specific connection: " + currentConnectionId)
            saveConnectionSettings()
            return
        }

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

    function saveConnectionSettings() {
        Logger.log_info("Settings: Saving connection-specific settings for " + currentConnectionId)

        // Get connection details to determine interface type
        var connDetails = Backend.get_connection_details(currentConnectionId)
        if(!connDetails || !connDetails.type) {
            Logger.log_error("Settings: Could not get connection details for " + currentConnectionId)
            return
        }

        var interfaceType = connDetails.type
        var settings = getInterfaceSettings(interfaceType)

        if(!settings || settings.valid === false) {
            Logger.log_error("Settings: Invalid settings for connection " + currentConnectionId)
            return
        }

        // Update connection settings via backend
        if(typeof Backend.update_connection_settings === "function") {
            var success = Backend.update_connection_settings(currentConnectionId, settings)
            if(success) {
                Logger.log_info("Settings: Successfully updated connection " + currentConnectionId)
            } else {
                Logger.log_error("Settings: Failed to update connection " + currentConnectionId)
            }
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

    // Multi-connection helper functions
    function selectTabByName(interfaceName) {
        Logger.log_debug("Settings: Selecting tab for interface: " + interfaceName)

        var tabIndex = interfaceNames.indexOf(interfaceName)
        if(tabIndex >= 0 && tabIndex < interfaceNames.length) {
            tabBar.currentIndex = tabIndex
            Logger.log_info("Settings: Selected tab index " + tabIndex + " for " + interfaceName)

            // If in connection-specific mode, load connection settings
            if(isConnectionSpecific && currentConnectionId !== "") {
                loadConnectionSettings()
            }
        } else {
            Logger.log_warning("Settings: Unknown interface name: " + interfaceName)
        }
    }

    function openForConnection(connectionId, interfaceType) {
        Logger.log_info("Settings: Opening for connection " + connectionId + " (" + interfaceType + ")")

        // Set connection-specific mode
        currentConnectionId = connectionId

        // Select appropriate tab
        selectTabByName(interfaceType)

        // Reload settings for this connection
        loadSettingsFromBackend()
    }
}
