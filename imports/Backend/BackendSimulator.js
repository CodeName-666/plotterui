.pragma library
.import QtQuick 6.4 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.3 as QuickCharts
.import "BackendLogger.js" as Logger
.import "Simulator.js" as Simulator


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(app, events) {
    Simulator.setup(app,events)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(type, settings) {

    return Simulator.set_settings(type, settings)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function connect() {
    Simulator.connect()
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type) {
    return Simulator.get_settings(interface_type);
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_interface() {
    return Simulator.get_interface()
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function settings_valid() {
   return Simulator.settings_valid()
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_error(msg) {
    Simulator.log_error(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_warning(msg) {
   Simulator.log_warning(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_info(msg) {
   Simulator.log_info(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_debug(msg) {
    Simulator.log_debug(msg)
}
/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_stack(stack) {
    Simulator.log_stack(msg)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_connected()
{
    return Simulator.is_connected();
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function add_graph(name, graph) {
   Simulator.add_graph(name,graph)
}


/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function set_plot_area(area) {
    Simulator.set_plot_area(area)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function set_axis(x_axis, y_axis) {
    Simulator.set_axis(x_axis,y_axis);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function ui_setup_status(status) {
    Simulator.ui_setup_status(status)
}
