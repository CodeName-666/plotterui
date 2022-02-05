.pragma library
.import "BackendSimulator.js" as Simulator.import "BackendProvider.js" as Provider.import "Setup.js" as Setup

function get_interface() {
    var interface
    if (Setup.is_interface(Setup.PYTHON_BACKEND)) {
        interface = Provider
    } else if (Setup.is_interface(Setup.BACKEND_SIMULATOR)) {
        interface = Simulator
    } else {
        log_error("Invalid Interface")
        interface = undefined
    }
    return interface
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
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
        log_error("invalid settings")
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
function log_error(msg) {
    var interface = get_interface();
    if(interface !== undefined)
    {
        interface.log_error(msg);
    }else {
        console.log(msg);
    }
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_warning(msg) {
    var interface = get_interface();
    if(interface !== undefined)
    {
        interface.log_warning(msg);
    }else {
        console.log(msg);
    }
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_info(msg) {
    var interface = get_interface();
    if(interface !== undefined)
    {
        interface.log_info(msg);
    }else {
        console.log(msg);
    }
}


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_debug(msg) {
    var interface = get_interface();
    if(interface !== undefined)
    {
        interface.log_debug(msg);
    }else {
        console.log(msg);
    }
}
