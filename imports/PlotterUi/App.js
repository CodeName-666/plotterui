.pragma library
.import QtQuick 6.6 as QtQuick
.import "../Common/Constants.js" as Constants
.import "../Common/AppApi.js" as AppApi


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
        this.backend_events = undefined
        this.current_interface = undefined
    }

    setup(app_handle,backend_interface)
    {
        this.ui_handle = app_handle
        this.used_backend_interface = backend_interface
        this.backend_tx_events = this.create_component(Constants.TX_SIGNAL_PATH)
        this.backend_rx_events = this.create_component(Constants.RX_SIGNAL_PATH)
        this.backend_events = AppApi.get_backend_events()
        this.initialize()
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

    initialize()
    {
        if(this.used_backend_interface !== undefined && this.used_backend_interface !== null)
        {
            if(typeof this.used_backend_interface.setup === "function")
            {
                this.used_backend_interface.setup(this.ui_handle, this.backend_events)
            }
        }
        // reserved for future signal connections between tx/rx events
    }

    events()
    {
        return this.backend_events
    }

    connect()
    {
        if(!this.used_backend_interface)
        {
            console.warn("AppController: No backend available for connect()")
            return false
        }
        if(typeof this.used_backend_interface.connect === "function")
        {
            return this.used_backend_interface.connect()
        }
        if(typeof this.used_backend_interface.connectTo === "function")
        {
            var connection_type = this.current_interface !== undefined ? this.current_interface : ""
            return this.used_backend_interface.connectTo(connection_type)
        }
        console.warn("AppController: Backend does not implement connect/connectTo")
        return false
    }

    set_settings(interface_type, settings)
    {
        this.current_interface = interface_type
        if(this.used_backend_interface && typeof this.used_backend_interface.set_settings === "function")
        {
            return this.used_backend_interface.set_settings(interface_type, settings)
        }
        console.warn("AppController: Backend does not implement set_settings")
        return false
    }

    settings_valid()
    {
        if(this.used_backend_interface && typeof this.used_backend_interface.settings_valid === "function")
        {
            return this.used_backend_interface.settings_valid()
        }
        console.warn("AppController: Backend does not implement settings_valid")
        return false
    }

    set_plot_area(area)
    {
        if(this.used_backend_interface && typeof this.used_backend_interface.set_plot_area === "function")
        {
            this.used_backend_interface.set_plot_area(area)
        }
    }

    set_axis(xAxis, yAxis)
    {
        if(this.used_backend_interface && typeof this.used_backend_interface.set_axis === "function")
        {
            this.used_backend_interface.set_axis(xAxis, yAxis)
        }
    }

    add_graph(name, graph)
    {
        if(this.used_backend_interface && typeof this.used_backend_interface.add_graph === "function")
        {
            this.used_backend_interface.add_graph(name, graph)
        }
    }
}




