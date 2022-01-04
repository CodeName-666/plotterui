import QtQuick 2.15
import QtQuick.Controls 2.15



TelnetSettingsUi {



    function getSettings()
    {
        var telnet_settings ={"type": 'TELNET',
                              "url": ipText.text,
                              "port": parseInt(portInput.text),
                              }

        return telnet_settings
     }
}

