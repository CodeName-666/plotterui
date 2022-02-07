.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "Random.js" as Random

var backend = undefined
var application_handle = undefined


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(python_backend, app_hndl) {

    application_handle = app_hndl;
    if(python_backend !== undefined)
    {
        backend = python_backend;
        backend.log_info("Setup Done");
        backend.setup_done(true);

        backend.onCreateLine.connect(create_line);

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


function create_line(name, color = undefined) {
    console.log("Create New Line")
    var chartUi = application_handle.chartWindow
    var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,
                                          name, chartUi.xAxis, chartUi.yAxis)
    if (color === undefined) {
        color = Random.getRandomInt(0xFFFFFF)
    }

    console.log(typeof line)
    

    backend.add_line(line)
}
