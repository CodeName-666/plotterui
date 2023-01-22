.pragma library
.import QtQuick 6.4 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.3 as QuickCharts
.import "BackendLogger.js" as Logger



var python_backend = undefined

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function setup(py_backend, events) {

   if(python_backend !== undefined)
    {
        python_backend = py_backend;
        connect_signals(events);

        python_backend.log_info("Setup Done");
        python_backend.backend_setup_done = true ;
    } else {
        /* TBD */
    }
}

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function connect_signals(events) {

    python_backend.new_graph.connect(events.newGraph);
    python_backend.scrollRight.connect(events.scrollRight);
    python_backend.ui_setup.connect(events.uiSetup);
    python_backend.com_port_update.connect(events.com_port_update);

}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(interface_type, settings) {
    python_backend.set_settings(interface_type, settings)

}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type) {
    return python_backend.get_settings()
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function settings_valid() {
    return python_backend.settings_valid();
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
 function add_graph(name, graph) {
    python_backend.add_graph(name, graph);
}


/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function set_plot_area(area) {
    python_backend.plot_area = area
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_axis(xAxis, yAxis) {
    python_backend.xAxis = xAxis;
    python_backend.yAxis = yAxis;
}

/**
 * @brief 
 * @param {boolean} status 
 */
function ui_setup_status(status) {
    python_backend.ui_setup_done = status
}

/**
 * @brief Log Error Slot
 * @param {String} msg Message which explains the error
 * 
 * Slot to log an error.
 */
function log_error(msg) {
    python_backend.log_error(msg);
}

/**
 * @brief Log Warning Slot
 * @param {String} msg Message which explains the error
 * 
 * Function to log an warning.
 */
function log_warning(msg) {
    python_backend.log_warning(msg);
}

/**
 * @brief Log Info Slot
 * @param {String} msg Message which contains the info
 * 
 * Function to log an info.
 */
function log_info(msg) {
    python_backend.log_info(msg);
}

/**
 * @brief Log Debug Slot
 * @param {String} msg Message which contains the debug message
 * 
 * Function to log an debug.
 */
function log_debug(msg) {
    python_backend.log_debug(msg);
}

/**
 * @brief Logging Stack Sltt
 * @param {String} msg Stack of QML code
 * 
 * Function to log an info.
 */
function log_stack(stack) {
    python_backend.log_qml_stack(stack)
}

