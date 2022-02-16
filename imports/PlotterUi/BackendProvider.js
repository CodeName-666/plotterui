.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "Random.js" as Random
.import "Application.js" as App

var backend = undefined
/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(python_backend) {

   if(python_backend !== undefined)
    {
        backend = python_backend;
        backend.log_info("Setup Done");
        backend.setup_done(true);

        backend.onCreateLine.connect(create_line);
        backend.sendLine.connect(backend.add_line)

    } else {
        /* TBD */
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_valid() {
    return (backend != undefined)
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
 * FUNCTION
 ******************************************************************/
function settings_valid() {
    if(is_valid()) {
        return backend.settings_valid();
    } else {
        return false
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_error(msg) {
    if (is_valid()) {
        backend.log_error(msg)
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_warning(msg) {
    if (is_valid()) {
        backend.log_warning(msg)
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_info(msg) {
    if (is_valid()) {
        backend.log_info(msg)
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_debug(msg) {
    if (is_valid()) {
        backend.log_debug(msg)
    }
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
 function add_graph(name, graph) {
    /*tbd*/ 
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_chart(chart) {
   /*tbd*/
}

