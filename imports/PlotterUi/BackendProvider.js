.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "BackendLogger.js" as Logger

var backend = undefined


/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function setup(python_backend) {

   if(python_backend !== undefined)
    {
        backend = python_backend;
        connect_signals();


        backend.log_info("Setup Done");
        backend.setup_done(true);
    } else {
        /* TBD */
    }
}

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function connect_signals( events) {

    backend.new_graph.connect(events.newGraph);
    backend.scroll.connect(events.scroll);

}

/*******************************************************************
 * INTERNAL FUNCTION
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
function set_chart(chart) {
    backend.set_chart(chart)
}


/*******************************************************************
 * SIGNAL SLOT
 ******************************************************************/
function on_new_graph(name, color) {
    var graph = App.create_graph(name,color)
    console.log("add new graph")
    add_graph(name,graph);

}

function set_plot_area(area) {
    backend.plot_area = area
}
