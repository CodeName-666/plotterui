.pragma library
.import QtQuick 6.4 as Quick
.import "./Simulator/BackendSimulator.js" as Simulator
.import "./Python/BackendProvider.js" as Provider
.import "BackendLogger.js" as Logger
.import "../Common/AppApi.js" as AppApi

/*=================================================================*/
/*=== Internal Used Functions =====================================*/
/*=================================================================*/

/**
 * @brief Get Interface
 *
 * @return Returns the correct interface which has to be used.
 * Possible Interfaces are:
 * - Provider: Interface to Python Backend
 * - Simulator: Interface to QML Simulater
 * - Undefined: Unknown setup called, therefore undefined
 */
function get_interface() {
    var interface
    if (AppApi.is_interface(Setup.PYTHON_BACKEND)) {
        interface = Provider
    } else if (Setup.is_interface(Setup.BACKEND_SIMULATOR)) {
        interface = Simulator
    } else {
        Logger.log_error("GET INTERFACE: Invalid Interface")
        interface = undefined
    }
    return interface
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function events() {
    return AppApi.getBackendEvents()
}



/*=================================================================*/
/*=== Backend Interfaces ==========================================*/
/*=================================================================*/

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
         Logger.log_error("invalid settings")
    }
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_connected() {
    return get_interface().is_connect();
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_plot_area(area) {
    get_interface().set_plot_area(area);
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function add_graph(name,graph) {
    get_interface().add_graph(name, graph);
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_axis(xAxis, yAxis) {
    get_interface().set_axis(xAxis, yAxis)
}
