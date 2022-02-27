import QtQuick 2.15
import PlotterUi 1.0

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


        settings.okButton.clicked.connect(acceptSettings)
        settings.cancleButton.clicked.connect(cancleSettings)
        toolbar.settingsButton.triggered.connect(openSettingsMenu)
        Logger.log_debug("App Completed");
      }

    function acceptSettings()
    {
        var cSettings =settings.get_settings(settings.comboBox.currentText);

        Logger.log_info("Accept Setting " + cSettings);

        BackendInterface.set_settings(settings.comboBox.currentText,cSettings);
        settingsPopup.close();
    }

    function cancleSettings()
    {
        Logger.log_info("cancel settings");
        settings.restoreSettings();
        settingsPopup.close();
    }

    function openSettingsMenu()
    {
        settings.backupSettings();
        settingsPopup.open();
    }

    function setConfig()
    {

    }
}
