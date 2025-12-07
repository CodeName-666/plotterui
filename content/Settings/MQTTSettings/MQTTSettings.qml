import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.15

MQTTSettingsUi {

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_settings()
    {
        if(typeof hostInput === "undefined" || hostInput === null)
            return {}
        const portVal = parseInt(portInput.text)
        const qosVal = parseInt(qosCombo.currentValue !== undefined ? qosCombo.currentValue : qosCombo.currentText)
        const keepAliveVal = parseInt(keepAliveInput.text)
        return {
            "host": hostInput.text,
            "port": isNaN(portVal) ? 0 : portVal,
            "rx_topic": rxTopicInput.text,
            "tx_topic": txTopicInput.text,
            "client_id": clientIdInput.text,
            "username": usernameInput.text,
            "password": passwordInput.text,
            "qos": isNaN(qosVal) ? 0 : qosVal,
            "keepalive": isNaN(keepAliveVal) ? 60 : keepAliveVal
        }
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(settings)
    {
        if(!settings || typeof hostInput === "undefined" || hostInput === null)
            return
        hostInput.text = settings["host"] !== undefined ? settings["host"] : ""
        portInput.text = settings["port"] !== undefined ? settings["port"] : ""
        rxTopicInput.text = settings["rx_topic"] !== undefined ? settings["rx_topic"] : ""
        txTopicInput.text = settings["tx_topic"] !== undefined ? settings["tx_topic"] : ""
        clientIdInput.text = settings["client_id"] !== undefined ? settings["client_id"] : ""
        usernameInput.text = settings["username"] !== undefined ? settings["username"] : ""
        passwordInput.text = settings["password"] !== undefined ? settings["password"] : ""
        set_combobox(qosCombo, settings["qos"] !== undefined ? settings["qos"] : 0)
        keepAliveInput.text = settings["keepalive"] !== undefined ? settings["keepalive"] : 60
    }

    function set_combobox(combobox, value)
    {
        var idx = combobox.find(value, Qt.MatchExactly)
        if(idx >= 0)
            combobox.currentIndex = idx
    }
}
