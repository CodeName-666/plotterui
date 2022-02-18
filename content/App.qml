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
            Logger.setup([Backend, Simulator])
            Setup.setup("PYTHON_BACKEND", this, Backend);
        }
        else
        {
            Logger.setup(Simulator)
            Setup.setup("BACKEND_SIMULATOR", this);
        }


        settings.okButton.clicked.connect(acceptSettings)
        settings.cancleButton.clicked.connect(cancleSettings)
        toolbar.settingsButton.triggered.connect(openSettingsMenu)
    }

    function acceptSettings()
    {
        console.log("Accept and update Setting ");
        var cSettings =settings.get_settings(settings.comboBox.currentText);
        BackendInterface.set_settings(settings.comboBox.currentText,cSettings);
        settingsPopup.close();
    }

    function cancleSettings()
    {
        console.log("cancel settings");
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
