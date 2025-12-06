import QtQuick 6.4
import QtQuick.Controls 6.4

TelnetSettingsUi {


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_settings()
    {
        return  {
                 "host": ipInput.text,
                 "port": parseInt(portInput.text)
                }
    }


    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(settings)
    {
        if(!settings)
            return
        ipInput.text = settings["host"] !== undefined ? settings["host"] : settings["ip"];
        portInput.text = settings["port"] !== undefined ? settings["port"] : "";
    }
}
