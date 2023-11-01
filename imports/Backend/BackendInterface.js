.pragma library
.import QtQuick 6.4 as Quick
.import "BackendLogger.js" as Logger
.import "./Simulator/BackendSimulator.js" as Simulator
.import "./Python/BackendProvider.js" as Provider
.import "../Common/AppApi.js" as AppApi


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function events() {
    return AppApi.get_backend_events()
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
