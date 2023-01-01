import QtQuick 6.4
import PlotterUi 1.0
import Backend 1.0


AppUi {


    connectButton.onClicked:
    {
        BackendInterface.connect()
    }

    Component.onCompleted: {
        if(typeof Backend !== 'undefined')
        {
            Logger.setup(Provider,false);
            Logger.log_debug("App Backend Init");
            Setup.setup("PYTHON_BACKEND", this, Backend);
        }
        else
        {
            Logger.setup(Simulator,false);
            Logger.log_debug("App Simulatort Init");
            Setup.setup("BACKEND_SIMULATOR", this);
        }
        connect_signals();


        Logger.log_debug("App Completed");
      }


    function connect_signals() {
        settings.okButton.clicked.connect(acceptSettings)
        settings.cancleButton.clicked.connect(cancleSettings)


        toolbar.settingsButton.triggered.connect(openSettingsMenu)

        BackendInterface.events().comPortUpdate.connect(settings.updateComPorts)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function acceptSettings()
    {
        var cSettings =settings.get_settings(settings.interfaceComboBox.currentText);

        Logger.log_info("Accept Setting " + cSettings);

        BackendInterface.set_settings(settings.interfaceComboBox.currentText,cSettings);
        settingsPopup.close();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function cancleSettings()
    {
        Logger.log_info("cancel settings");
        settings.restoreSettings();
        settingsPopup.close();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function openSettingsMenu()
    {
        settings.backupSettings();
        settingsPopup.open();
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function setConfig()
    {

    }
}
