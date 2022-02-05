.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "Random.js" as Random

//--- Simulator Setup ----
var application_handle = undefined // Main application object (applicationWindow)
var update_timer = undefined // Cycle Timer (equal Thread) as Mainloop for the Chart
var setup_done_status = false // Setup flag to verify is setup was done

//--- UI/Backend parameter
var current_settings = undefined
var current_interface = undefined

var signal_list = [] // List of demo signals/Lines in the chart
var connected = false

//--- Demo Lines Config ---
var DEMO_LINE_CONFIG = [{
    "name": "DEMO_1",
    "color": 0xffffff,
    "type": "SIN"
},
{
    "name": "DEMO_2",
    "color": 0xffffff,
    "type": "SIN"
}]

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup_done(application) {
    application_handle = application
    setup_done_status = true
    update_timer = new Timer(10, true, true, backend_simulator_loop)
    log_error("SIMULATOR setup done")
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(type, settings) {
    current_settings = settings
    current_interface = type
    log_error(current_interface)
    log_error(current_settings)
    return true
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function connect() {
    switch (current_interface) {
        case "Test":
            if (settings_valid()) {
                connected = true;
                create_demo_lines();
            }
            break
        case "Serial":
        case "Telnet":
        default:
            log_error("no simulation avalilable")
            break
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type) {
    return current_settings
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_interface() {
    return current_interface
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function Timer(interval, repeat = false, start = false, callback = undefined) {
    if (setup_done_status) {
        var cTimer = Qt.createQmlObject(' import QtQuick 2.15; Timer {}',
                                        application_handle)
        cTimer.interval = interval
        cTimer.repeat = repeat

        if (callback !== undefined) {
            cTimer.triggered.connect(callback)
        }

        if (start) {
            cTimer.start()
        }

        return cTimer
    }
    return None
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function backend_simulator_loop() {

    if(is_connected()) {
        switch (current_interface) {
        case "Serial":
            backend_simulator_serial_loop()
            break
        case "Telnet":
            backend_simulator_telnet_loop()
            break
        case "Test":
            backend_simulator_test_loop()
            break
        default:
            log_error("Invalid interface")
            break
        }
    }

    //log_error("backend_simulator_loop running...")
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function backend_simulator_serial_loop() {}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function backend_simulator_telnet_loop() {}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function backend_simulator_test_loop() {}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function create_line(name, color = undefined) {
    var chartUi = application_handle.chartWindow
    var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,
                                          name, chartUi.xAxis, chartUi.yAxis)
    if (color === undefined) {
        color = Random.getRandomInt(0xFFFFFF)
    }
    line.color = color
    return line
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function settings_valid() {
    if (current_settings !== undefined && current_interface !== undefined) {
        return true
    } else {
        return false
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function create_demo_lines() {
    for (var i = 0; i < DEMO_LINE_CONFIG.length; i++) {
        var s = DEMO_LINE_CONFIG[i]
        signal_list[i] = create_line(s["name"], s["color"])
    }

    if (settings_valid()) {
        var last_idx = signal_list.length - 1
        signal_list[last_idx] = create_line(current_settings["name"],
                                            current_settings["color"])
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_connected()
{
    return connected;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_error(msg) {
    console.log(msg)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_warning(msg) {
    console.log(msg)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_info(msg) {
    console.log(msg)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_debug(msg) {
    console.log(msg)
}
