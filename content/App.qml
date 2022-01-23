import QtQuick 2.15
import PlotterUi 1.0

AppUi {

    Component.onCompleted: {
        BackendInterface.setup("BACKEND_SIMULATOR", this);
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
        settingsPopup.close();
    }

    function openSettingsMenu()
    {
        settings.backupSettings();
        settingsPopup.open();
    }

   // function updateComPorts()
   // {
   //    var new_ports = backend.get_com_ports();
   //    settings.updateComPorts(new_ports);
   // }
//
//
   // function setSettings(new_settings)
   // {
   //     var res = backend.set_settings(new_settings)
   //     if(res === true)
   //         console.log("Settings updated")
   //     else
   //         console.log("Settings update failed")
   //     return res;
   // }
//
   // function connect()
   // {
   //     var res = backend.connect()
   //     if (res === true)
   //         console.log("Connected")
   //     else
   //         console.log("Cannot connet")
   // }
}
