.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "BackendLogger.js" as Logger

const ERROR = 40
const WARNING = 30
const INFO = 20
const DEBUG = 10
const NOTSET = 0

var levelToName = {
    ERROR: 'ERROR',
    WARNING: 'WARNING',
    INFO: 'INFO',
    DEBUG: 'DEBUG',
    NOTSET: 'NOTSET',
}

var nameToLevel = {
    'ERROR': ERROR,
    'WARNING': WARNING,
    'INFO': INFO,
    'DEBUG': DEBUG,
    'NOTSET': NOTSET,
}



//--- Simulator Setup ----
var application_handle = undefined
var backend_events = undefined
var update_timer = undefined // Cycle Timer (equal Thread) as Mainloop for the Chart
var setup_done_status = false // Setup flag to verify is setup was done
var log_level = NOTSET

//--- UI/Backend parameter
var current_settings = undefined
var current_interface = undefined

var signal_list = {} // Dictionary of demo signals/Lines in the chart
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

var connection_interfaces = [{
                                 "val": "SERIAL",
                                 "name": "Serial"
                             }, {
                                 "val": "TELNET",
                                 "name": "Telnet"
                             }, {
                                 "val": "TEST",
                                 "name": "Test"
                             }]

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(app, events, logger_level = NOTSET) {
    application_handle = app;
    setup_done_status = true
    connect_events(events);
 
    log_level = logger_level
    Logger.log_debug("SIMULATOR setup done")

}

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function connect_events( events) {
    backend_events = events

}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(type, settings) {
    current_settings = settings
    current_interface = type
    return true
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function connect() {
    if(!is_connected())
    {
        Logger.log_debug("Connect to interface: " + current_interface)
        switch (current_interface) {
            case "Test":
                if (settings_valid()) {
                    connected = true;
                    create_demo_lines();
                    update_timer = new Timer(10, true, true, backend_simulator_loop)
                }
                break
            case "Serial":
            case "Telnet":
            default:
                Logger.log_warning("No simulation avalilable")
                break
        }
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

        var cTimer = Qt.createQmlObject(' import QtQuick 2.15; Timer {}',application_handle);

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
                Logger.log_error("Invalid interface")
                break
        }
    }
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
function backend_simulator_test_loop() {




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
 * FUNCTION SLOT
 ******************************************************************/
function log_error(msg) {
    console.log("- ERROR - " + msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_warning(msg) {
    console.log("- WARNING - " + msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_info(msg) {
    console.log("- INFO - " + msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_debug(msg) {
    console.log("- DEBUG - " + msg);
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function create_demo_lines() {

    DEMO_LINE_CONFIG.append( )


    for (let i = 0; i < DEMO_LINE_CONFIG.length; i++) {
        let s = DEMO_LINE_CONFIG[i]
        backend_events.newGraph(s["name"], s["color"])
    }

    if (settings_valid()) {
        backend_events.newGraph(current_settings["name"],current_settings["color"])
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
 * FUNCTION SLOT
 ******************************************************************/
function add_graph(name, graph) {
    Logger.log_debug("Add Graph: Name = " + name)
    signal_list[name] = graph
}

