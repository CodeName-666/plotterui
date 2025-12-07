import QtQuick 6.4
import Common 1.0
import Backend 1.0
import PlotterUi 1.0


AppUi {
    id: appRoot

    property var appController: null
    property var simulatorBackend: null


    connectButton.onClicked:
    {
        if(appController !== null)
        {
            appController.connect()
        }
    }

    Component.onCompleted: {
        appController = App.create()

        if(typeof Backend !== 'undefined')
        {
            Logger.log_debug("App Backend Init");
            appController.setup(appRoot, Backend);
        }
        else
        {
            Logger.log_debug("App Simulator Init");
            simulatorBackend = new Simulator.Simulator()
            appController.setup(appRoot, simulatorBackend);
        }
        connect_signals();


        Logger.log_debug("App Completed");
      }


    function connect_signals() {
        if(settings && settings.okButton)
            settings.okButton.clicked.connect(accept_settings)
        if(settings && settings.cancleButton)
            settings.cancleButton.clicked.connect(cancle_settings)

        if(appController !== null && appController.events() !== undefined)
        {
            var events = appController.events()
            events.com_port_update.connect(settings.update_com_ports)
            events.ui_setup.connect(settings.setup)
            if(events.status_message)
                events.status_message.connect(show_status_message)
        }

        // Fallback: pull UI config directly if signal was missed
        if(typeof Backend !== 'undefined' && Backend.get_ui_config)
        {
            var cfg = Backend.get_ui_config()
            if(cfg && cfg.interfaces)
                settings.setup(cfg)
        }
        // Fallback for Simulator: manually setup with Test interface
        else if(simulatorBackend !== null)
        {
            settings.setup({"interfaces": ["Test"]})
        }
    }

    function show_status_message(level, message)
    {
        if(footer && footer.showStatus)
            footer.showStatus(level, message)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function accept_settings()
    {
        var cSettings =settings.get_settings(settings.interfaceComboBox.currentText);

        Logger.log_info("Accept Setting " + cSettings);

        if(appController !== null)
        {
            appController.set_settings(settings.interfaceComboBox.currentText,cSettings);
        }
        settingsPopup.close();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function cancle_settings()
    {
        Logger.log_info("cancel settings");
        settings.restore_settings();
        settingsPopup.close();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function open_settings()
    {
        settings.backup_settings();
        settingsPopup.open();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setConfig()
    {

    }
}
