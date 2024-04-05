.pragma library
.import QtQuick 6.6 as QtQuick
.import "../Common/Constants.js" as Constants


var app = undefined


function create()
{
    if(app === undefined)
    {
        app = new AppClass()
    }
    else
    {
        //Already created...
    }

    return app
}


function get_app()
{
    return app
}

class AppClass {

    constructor()
    {
        this.ui_handle = undefined
        this.used_backend_interface = undefined
        this.backend_tx_events = undefined
        this.backend_rx_events = undefined
    }

    setup(app_handle,backend_interface)
    {
        this.ui_handle = app_handle
        this.used_backend_interface = backend_interface
        this.backend_tx_events = this.create_component(Constants.TX_SIGNAL_PATH)
        this.backend_rx_events = this.create_component(Constants.RX_SIGNAL_PATH)
        this.connect()
    }

    create_component(path_to_component) {
        var events = undefined;
        var component = Qt.createComponent(path_to_component);
        if (component.status === QtQuick.Component.Ready) {
            events = component.createObject(this.ui_handle);
            if (!events) {
                console.error("Fehler: Objekt konnte nicht erstellt werden für", path_to_component);
            }
        } else if (component.status === QtQuick.Component.Error) {
            console.error("Fehler beim Laden der Komponente:", component.errorString());
        } else {
            console.error("Undefinierter Status beim Laden der Komponente:", path_to_component);
        }
        return events;
    }

    connect()
    {


    }
}




