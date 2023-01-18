.pragma library
.import QtQuick 6.4 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.3 as QuickCharts
.import "BackendLogger.js" as Logger



var backend = undefined

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function setup(python_backend, events) {

   if(python_backend !== undefined)
    {
        backend = python_backend;
        connect_signals(events);

        backend.log_info("Setup Done");
        backend.backend_setup_done = true ;
    } else {
        /* TBD */
    }
}

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function connect_signals(events) {

    backend.new_graph.connect(events.newGraph);
    backend.scrollRight.connect(events.scrollRight);
    backend.ui_setup.connect(events.uiSetup);
    backend.com_port_update.connect(events.com_port_update);

}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(interface_type, settings) {
    backend.set_settings(interface_type, settings)

}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type) {
    return backend.get_settings()
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function settings_valid() {
    return backend.settings_valid();
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
 function add_graph(name, graph) {
    backend.add_graph(name, graph);
}


/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function set_plot_area(area) {
    backend.plot_area = area
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_axis(xAxis, yAxis) {
    backend.xAxis = xAxis;
    backend.yAxis = yAxis;
}



/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_error(msg) {
    backend.log_error(msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_warning(msg) {
    backend.log_warning(msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_info(msg) {
    backend.log_info(msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_debug(msg) {
    backend.log_debug(msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_stack(stack) {
    backend.log_qml_stack(stack)
}


function ui_setup_status(status) {
    backend.ui_setup_done = status
}
