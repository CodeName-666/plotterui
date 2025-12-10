import QtQuick 6.4
import QtQuick.Dialogs
import Backend 1.0

SettingsUi {
    id: settings_menu

    FileDialog {
        id: saveConfigDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON Config files (*.json)"]
        defaultSuffix: "json"
        currentFolder: "file:///d:/Projekte/Python/Plotter/PlotterApp/config"
        onAccepted: saveConfigToFile(selectedFile)
    }

    FileDialog {
        id: loadConfigDialog
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON Config files (*.json)"]
        currentFolder: "file:///d:/Projekte/Python/Plotter/PlotterApp/config"
        onAccepted: loadConfigFromFile(selectedFile)
    }

    Component.onCompleted: {
        Logger.log_debug("Settings: Component completed")
    }

    onVisibleChanged: {
        if (visible) {
            Logger.log_debug("Settings: Config Management Dialog opened")
        }
    }

    saveConfigButton.onClicked: {
        Logger.log_info("Settings: Save config button clicked")
        saveConfigDialog.open()
    }

    loadConfigButton.onClicked: {
        Logger.log_info("Settings: Load config button clicked")
        loadConfigDialog.open()
    }

    closeButton.onClicked: {
        Logger.log_debug("Settings: Close button clicked")
        settings_menu.visible = false
    }

    function saveConfigToFile(fileUrl) {
        Logger.log_info("Settings: Saving configuration to " + fileUrl)

        // Note: The actual config file is managed by the backend
        // This is a placeholder for future implementation
        Logger.log_warning("Settings: Config save to file not yet implemented - use backend save_settings_to_config()")

        // For now, just save the current config
        Backend.save_settings_to_config()
        Logger.log_info("Settings: Configuration saved to default location")
    }

    function loadConfigFromFile(fileUrl) {
        Logger.log_info("Settings: Loading configuration from " + fileUrl)

        // Note: The actual config file is managed by the backend
        // This is a placeholder for future implementation
        Logger.log_warning("Settings: Config load from file not yet implemented")
        Logger.log_info("Settings: Backend loads config.json automatically on startup")
    }
}
