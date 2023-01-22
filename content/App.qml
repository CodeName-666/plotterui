import QtQuick 6.4
import Common 1.0
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
            App.setup("PYTHON_BACKEND", this, Backend);
        }
        else
        {
            Logger.setup(Simulator,false);
            Logger.log_debug("App Simulatort Init");
            App.setup("BACKEND_SIMULATOR", this);
        }
        connect_signals();


        Logger.log_debug("App Completed");
      }


    function connect_signals() {
        settings.okButton.clicked.connect(accept_settings)
        settings.cancleButton.clicked.connect(cancle_settings)


        toolbar.settingsButton.triggered.connect(open_settings)

        BackendInterface.events().com_port_update.connect(settings.update_com_ports)
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function accept_settings()
    {
        var cSettings =settings.get_settings(settings.interfaceComboBox.currentText);

        Logger.log_info("Accept Setting " + cSettings);

        BackendInterface.set_settings(settings.interfaceComboBox.currentText,cSettings);
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
