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
        settings.okButton.clicked.connect(accept_settings)
        settings.cancleButton.clicked.connect(cancle_settings)


        toolbar.settingsButton.triggered.connect(open_settings)

        if(appController !== null && appController.events() !== undefined)
        {
            appController.events().com_port_update.connect(settings.update_com_ports)
        }
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
