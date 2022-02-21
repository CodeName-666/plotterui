.pragma library
.import QtQuick 2.15 as Quick
.import "BackendSimulator.js" as Simulator
.import "BackendProvider.js" as Provider
.import "BackendLogger.js" as Logger
.import "Setup.js" as Setup


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_interface() {
    var interface
    if (Setup.is_interface(Setup.PYTHON_BACKEND)) {
        interface = Provider
    } else if (Setup.is_interface(Setup.BACKEND_SIMULATOR)) {
        interface = Simulator
    } else {
        Logger.log_error("GET INTERACE: Invalid Interface")
        interface = undefined
    }
    return interface
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function events() {
    return Setup.getBackendEvents()
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(interface_type, settings) {
    return get_interface().set_settings(interface_type, settings)
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type) {
    return get_interface().get_settings(interface_type)
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function settings_valid() {
    return get_interface().settings_valid()
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function connect() {
    if (settings_valid()) {
        get_interface().connect()
    } else {
        log_error("invalid settings")
    }
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_connected() {
    return get_interface().is_connect();
}


function set_plot_area(area) {
    get_interface().set_plot_area();
}
