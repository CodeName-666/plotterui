import QtQuick 2.15
import PlotterUi 1.0

SettingsUi {

    /*Signal decleartion*/
    comboBox.onActivated: onComboBoxActivationChanged()
    okButton.onClicked:  onOkButtonClicked()
    cancleButton.onClicked: onCancleButtonClicked()

    /*Signal Handling Implementations*/
    function onComboBoxActivationChanged()
    {

           if( comboBox.displayText == "Serial" )
           {
               telnetSettings.visible = false;
               serialSettings.visible = true;
           }
           else if(comboBox.displayText == "Telnet")
           {
               telnetSettings.visible = true;
               serialSettings.visible = false;
           }
           else
           {
               console.log("SettingsUi: Invalid Settingsoption...")
           }
       }


    function onOkButtonClicked()
    {
        var config = 0;
        var res;
        if(comboBox.currentText == "Telnet")
        {
            config = telnetSettings;
            res = applicationWindow.setSettings(config.getSettings());
        }
        else if(comboBox.currentText == "Serial")
        {
            config = serialSettings;
            res = applicationWindow.setSettings(config.getSettings());
        }
        else
        {
            //Error Invalid Index - Error Handling needed
        }

        if(res === true)
        {
            applicationWindow.acceptSettings();
        }
        else
        {
            console.log("Settings Invalid...")
        }
    }

    function onCancleButtonClicked()
    {
        applicationWindow.cancleSettings()
    }

    function updateComPorts(new_com_ports)
    {
       serialSettings.com_ports = new_com_ports
    }
}
