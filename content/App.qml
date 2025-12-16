import QtQuick 6.4
import Common 1.0
import Backend 1.0
import PlotterUi 1.0
import "FloatingWindows"


AppUi {
    id: appRoot
    objectName: "appRoot"

    property var appController: null
    property var simulatorBackend: null


    connectButton.onClicked:
    {
        Logger.log_info("App: Connect button clicked")
        if(Validators.isValid(appController))
        {
            appController.connect()
        }
        else
        {
            Logger.log_error("App: appController is null - cannot connect")
        }
    }

    Component.onCompleted: {
        Logger.log_info("App: Component.onCompleted - Initializing application")
        appController = App.create()
        Logger.log_debug("App: appController created, initial current_interface: " + appController.current_interface)

        // Set appRoot reference in chartWindow for test functions
        if (chartWindow) {
            chartWindow.appRoot = appRoot
            Logger.log_debug("App: Set chartWindow.appRoot reference")
        }

        if(typeof Backend !== 'undefined')
        {
            Logger.log_info("App: Using Backend interface");
            appController.setup(appRoot, Backend);
        }
        else
        {
            Logger.log_info("App: Using Simulator backend");
            simulatorBackend = new Simulator.Simulator()
            appController.setup(appRoot, simulatorBackend);
        }
        connectSignals();

        // Set initial interface from ControlsCard ComboBox
        if(navDrawer && navDrawer.sourceCombo && navDrawer.sourceCombo.currentText) {
            appController.current_interface = navDrawer.sourceCombo.currentText
            Logger.log_info("App: Set initial current_interface to: " + appController.current_interface)
        }

        Logger.log_info("App: Initialization completed");
    }

    Component.onDestruction: {
        Logger.log_info("App: Component.onDestruction - Cleaning up")
        disconnectSignals()
        Logger.log_info("App: Cleanup completed")
    }


    function connectSignals() {
        Logger.log_debug("App: connect_signals called")

        if(Validators.isValid(settings) && Validators.isValid(settings.okButton))
        {
            settings.okButton.clicked.connect(acceptSettings)
            Logger.log_debug("App: Connected settings OK button")
        }
        if(Validators.isValid(settings) && Validators.isValid(settings.cancelButton))
        {
            settings.cancelButton.clicked.connect(cancelSettings)
            Logger.log_debug("App: Connected settings Cancel button")
        }

        if(Validators.isValid(appController) && Validators.isValidFunction(appController.events))
        {
            var events = appController.events()
            if(Validators.isValid(events)) {
                // Connect com_port_update if both signal and handler exist
                if(Validators.isValid(events.com_port_update) &&
                   Validators.isValid(settings) &&
                   Validators.isValidFunction(settings.updateComPorts)) {
                    events.com_port_update.connect(settings.updateComPorts)
                    Logger.log_debug("App: Connected com_port_update signal")
                }

                // Connect ui_setup if both signal and handler exist
                if(Validators.isValid(events.ui_setup) &&
                   Validators.isValid(settings) &&
                   Validators.isValidFunction(settings.setup)) {
                    events.ui_setup.connect(settings.setup)
                    Logger.log_debug("App: Connected ui_setup signal")
                }

                // Connect status_message if it exists
                if(Validators.isValid(events.status_message))
                    events.status_message.connect(showStatusMessage)

                Logger.log_debug("App: Backend event signals connection completed")
            }
        }

        /*******************************************************************
         * SETTINGS INITIALIZATION STRATEGY:
         *
         * The settings are initialized through multiple mechanisms to ensure
         * robustness across different backend scenarios:
         *
         * 1. PRIMARY: Event-based (lines 69-79)
         *    - Backend emits ui_setup signal with configuration
         *    - Connected via events.ui_setup.connect(settings.setup)
         *    - This is the preferred method for real backend
         *
         * 2. FALLBACK A: Direct config pull (below)
         *    - Used if ui_setup signal was missed or not emitted yet
         *    - Directly calls Backend.get_ui_config() to retrieve config
         *    - Ensures UI is initialized even if timing issues occur
         *
         * 3. FALLBACK B: Simulator mode (below)
         *    - Used when running without real backend
         *    - Manually sets up Test interface for development/testing
         ******************************************************************/

        // Fallback A: pull UI config directly if signal was missed
        if(typeof Backend !== 'undefined' && Validators.isValidFunction(Backend.get_ui_config))
        {
            Logger.log_debug("App: [FALLBACK A] Pulling UI config from Backend")
            var cfg = Backend.get_ui_config()
            if(Validators.isValid(cfg) && Validators.isValid(cfg.interfaces))
            {
                Logger.log_info("App: Setting up interfaces from Backend config: " + JSON.stringify(cfg.interfaces))
                settings.setup(cfg)
            }
        }
        // Fallback B: Simulator mode with Test interface
        else if(Validators.isValid(simulatorBackend))
        {
            Logger.log_info("App: [FALLBACK B] Setting up Simulator with Test interface")
            settings.setup({"interfaces": ["Test"]})
        }
    }

    function disconnectSignals() {
        Logger.log_debug("App: disconnect_signals called")

        if(Validators.isValid(settings) && Validators.isValid(settings.okButton))
        {
            settings.okButton.clicked.disconnect(acceptSettings)
            Logger.log_debug("App: Disconnected settings OK button")
        }
        if(Validators.isValid(settings) && Validators.isValid(settings.cancelButton))
        {
            settings.cancelButton.clicked.disconnect(cancelSettings)
            Logger.log_debug("App: Disconnected settings Cancel button")
        }

        if(Validators.isValid(appController) && Validators.isValidFunction(appController.events))
        {
            var events = appController.events()
            if(Validators.isValid(events)) {
                events.com_port_update.disconnect(settings.updateComPorts)
                events.ui_setup.disconnect(settings.setup)
                if(Validators.isValid(events.status_message))
                    events.status_message.disconnect(showStatusMessage)
                Logger.log_debug("App: Disconnected backend event signals")
            }
        }
    }

    function showStatusMessage(level, message)
    {
        if(footer && footer.showStatus)
            footer.showStatus(level, message)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function acceptSettings()
    {
        var currentInterface = settings.interfaceComboBox.currentText
        Logger.log_debug("App: acceptSettings for interface: " + currentInterface)

        var cSettings = settings.getSettings(currentInterface);

        Logger.log_info("App: Accepting settings for " + currentInterface + ": " + JSON.stringify(cSettings));

        if(appController !== null)
        {
            appController.setSettings(currentInterface, cSettings);
        }
        else
        {
            Logger.log_error("App: Cannot accept settings - appController is null")
        }
        settingsPopup.close();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function cancelSettings()
    {
        Logger.log_info("App: Cancelling settings - restoring previous values");
        settings.restoreSettings();
        settingsPopup.close();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function openSettings()
    {
        Logger.log_debug("App: Opening settings dialog")
        settings.backupSettings();
        settingsPopup.open();
    }

    /*******************************************************************
     * FUNCTION - Returns the application controller instance
     ******************************************************************/
    function getAppController()
    {
        return appController
    }

    /*******************************************************************
     * FLOATING WINDOWS CONTAINER
     ******************************************************************/
    Item {
        id: floatingWindowsContainer
        anchors.fill: parent
        z: 100  // Above chart window but below dialogs

        // Container for dynamically created floating windows
        property var activeWindows: ({})
    }

    /*******************************************************************
     * FUNCTION - Create floating chart window
     ******************************************************************/
    function createFloatingWindow(chartId, chartType, title, x, y, width, height) {
        Logger.log_info("App: Creating floating window - ID: " + chartId + ", Type: " + chartType)

        // Create window via backend
        if (WindowManager && WindowManager.createWindow) {
            var success = WindowManager.createWindow(chartId)
            if (!success) {
                Logger.log_error("App: Failed to create window in backend: " + chartId)
                return null
            }
        }

        // Create QML component (use relative path from content/)
        var component = Qt.createComponent("FloatingWindows/FloatingChartWindow.qml")

        if (component.status === Component.Error) {
            Logger.log_error("App: Error creating floating window component: " + component.errorString())
            return null
        }

        var window = component.createObject(floatingWindowsContainer, {
            "chartId": chartId,
            "chartType": chartType,
            "chartTitle": title,
            "x": x || 100,
            "y": y || 100,
            "width": width || 800,
            "height": height || 600
        })

        // Pass central chart line model to the window's chart renderer after creation
        if (window && window.chartRenderer) {
            window.chartRenderer.chartLineModel = chartWindow.chartLineModel
            Logger.log_debug("App: Passed central chartLineModel to floating window " + chartId)
        } else {
            // Chart renderer not ready yet - set it when loaded
            Qt.callLater(function() {
                if (window && window.chartRenderer) {
                    window.chartRenderer.chartLineModel = chartWindow.chartLineModel
                    Logger.log_debug("App: Passed central chartLineModel to floating window " + chartId + " (delayed)")
                }
            })
        }

        if (window === null) {
            Logger.log_error("App: Failed to create floating window object")
            return null
        }

        floatingWindowsContainer.activeWindows[chartId] = window
        Logger.log_info("App: Floating window created successfully: " + chartId)

        return window
    }

    /*******************************************************************
     * FUNCTION - Remove floating chart window
     ******************************************************************/
    function removeFloatingWindow(chartId) {
        Logger.log_info("App: Removing floating window: " + chartId)

        // Remove all chart lines belonging to this window from the central model
        if (chartWindow && chartWindow.chartLineModel) {
            chartWindow.chartLineModel.removeLinesByChart(chartId)
            Logger.log_debug("App: Removed all lines for chart " + chartId + " from central model")
        }

        var window = floatingWindowsContainer.activeWindows[chartId]
        if (window) {
            window.destroy()
            delete floatingWindowsContainer.activeWindows[chartId]
        }

        if (WindowManager && WindowManager.removeWindow) {
            WindowManager.removeWindow(chartId)
        }
    }

    /*******************************************************************
     * KEYBOARD SHORTCUTS - Floating Windows
     ******************************************************************/
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            // Create a new floating XY chart window
            var timestamp = Date.now()
            var chartId = "float_xy_" + timestamp
            createFloatingWindow(chartId, "xy_line", "XY Chart " + timestamp, 100, 100, 800, 600)
        }
    }

    Shortcut {
        sequence: "F11"
        onActivated: {
            // Test: Create sample 2D floating window with test data
            Logger.log_info("App: F11 pressed - Creating test 2D floating window")

            // Find ChartWindow and call its test function
            var chartWindow = findChartWindow()
            if (chartWindow && chartWindow.testFloatingWindow) {
                chartWindow.testFloatingWindow()
            } else {
                // Fallback: create simple window
                var timestamp = Date.now()
                var chartId = "test_2d_" + timestamp
                createFloatingWindow(chartId, "xy_line", "Test 2D Chart", 150, 150, 700, 500)
            }
        }
    }

    Shortcut {
        sequence: "F12"
        onActivated: {
            // Test: Create sample 3D floating window with test data
            Logger.log_info("App: F12 pressed - Creating test 3D floating window")

            // Find ChartWindow and call its test function
            var chartWindow = findChartWindow()
            if (chartWindow && chartWindow.test3DFloatingWindow) {
                chartWindow.test3DFloatingWindow()
            } else {
                // Fallback: create simple 3D window
                var timestamp = Date.now()
                var chartId = "test_3d_" + timestamp
                createFloatingWindow(chartId, "xyz_scatter", "Test 3D Chart", 200, 100, 800, 600)
            }
        }
    }

    /**
     * Helper function to find ChartWindow instance in the component hierarchy
     */
    function findChartWindow() {
        // Try to access chartWindow property directly if it exists
        if (appRoot.chartWindow !== undefined) {
            return appRoot.chartWindow
        }

        // Fallback: use findChild to search by objectName
        var chartWin = appRoot.findChild("chartWindow")
        if (chartWin) {
            return chartWin
        }

        return null
    }
}
