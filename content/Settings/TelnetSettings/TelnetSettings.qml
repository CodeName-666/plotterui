import QtQuick 6.4
import QtQuick.Controls 6.4

TelnetSettingsUi {


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_settings()
    {
        return  {
                 "ip": ipInput.text,
                 "port": parseInt(portInput.text)
                }
    }


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(settings)
    {
       ipInput.text = settings["ip"];
       portInput.text = settings["port"];
    }
}
