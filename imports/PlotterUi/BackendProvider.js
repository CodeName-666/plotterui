.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
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
function connect_signals( events) {

    backend.new_graph.connect(events.newGraph);
    backend.scrollRight.connect(events.scrollRight);
    backend.ui_setup.connect(events.uiSetup);
    backend.com_port_update.connect(events.comPortUpdate);

}

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function is_valid() {
    return (backend !== undefined)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(interface_type, settings) {
    if (is_valid()) {
        backend.set_settings(interface_type, settings)
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type) {
    if (is_valid()) {
        return backend.get_settings()
    }
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function settings_valid() {
    if(is_valid()) {
        return backend.settings_valid();
    } else {
        return false
    }
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
 function add_graph(name, graph) {
     if (is_valid()) {
         backend.add_graph(name, graph);
     }
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
    if (backend !== undefined)
        backend.log_error(msg);
    else
        console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_warning(msg) {
    if (backend !== undefined)
        backend.log_warning(msg);
    else
        console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_info(msg) {
    if (backend !== undefined)
        backend.log_info(msg);
    else
        console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_debug(msg) {
    if (backend !== undefined)
        backend.log_debug(msg);
    else
        console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_stack(stack) {
    if (backend !== undefined)
        backend.log_qml_stack(stack)
    else
        console.log(stack)
}


function ui_setup_status(status) {
    backend.ui_setup_done = status
}


function testSlot(x) {
    backend.testSlot(x)
}
