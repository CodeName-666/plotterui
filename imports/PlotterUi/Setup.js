.pragma library
.import QtQuick 2.15 as Quick
.import "BackendSimulator.js" as Simulator
.import "BackendProvider.js" as Provider
.import "BackendLogger.js" as Logger



const UNKOWN_INTERFACE = 0;
const PYTHON_BACKEND = 1;
const BACKEND_SIMULATOR = 2;
var BACKEND_INTERFACES = ["UNKOWN", "PYTHON_BACKEND", "BACKEND_SIMULATOR"];

var application_handle = undefined
var used_backend_interface = undefined
var qml_start_up_done = false   //true == DONE/ false == NOT DONE
var backend_events = undefined

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_interface(interface_type)
{
    let ret = false;
    if(!isNaN(interface_type))
    {
        if(interface_type <= (BACKEND_INTERFACES.length -1))
        {
            ret = (used_backend_interface === BACKEND_INTERFACES[interface_type])
        } else {
            ret = false;
        }
    } else {
        for (let i = 0; i < BACKEND_INTERFACES.length; i++) {
            if(interface_type === BACKEND_INTERFACES[i])
            {
                ret = true;
            }
        }
    }
    return ret;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_backend_interface(use_backend)
{
    if(!isNaN(use_backend))
    {
        return BACKEND_INTERFACES[use_backend];
    }
    else
    {
        for (let i = 0; i < BACKEND_INTERFACES.length; i++) {
            if(use_backend === BACKEND_INTERFACES[i])
            {
                return BACKEND_INTERFACES[i]
            }
        }
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(use_backend, applicationHandle, python_backend_object = undefined)
{
    used_backend_interface = get_backend_interface(use_backend);
    qml_start_up_done = true;

    // Store appliction handle internal.
    application_handle = applicationHandle;
    // Create BackendEvents QML object to provide alle needed Signals for the APP
    backend_events = createBackendEventObject();
    // Connect the BackendEvent "setupConfig" with the internal setupConfig Slot
    // Depandent on the used interface the Signal SetupConfig can be triggered from 
    // the Simulator or from the Python Backend directly to set all needed configurations.
    backend_events.ui_setup.connect(ui_setup)
    if(used_backend_interface === BACKEND_INTERFACES[BACKEND_SIMULATOR])
    {
        Simulator.setup(application_handle, backend_events);
    }
    else if(used_backend_interface === BACKEND_INTERFACES[PYTHON_BACKEND])
    {
        if (python_backend_object !== undefined)
        {
            Provider.setup(python_backend_object, backend_events);
        } else {
            Logger.log_error("Backend invalid");
        }
    }
    else
    {
        Logger.log_error("Invalid interface...");
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function createBackendEventObject() {
    var component = Qt.createComponent("BackendEvents.qml");
    var events = undefined
    if (component.status === Quick.Component.Ready) {
        events = component.createObject(application_handle)
        Logger.log_debug("Create Event Object - Events Created", arguments.callee.name);
    } else {
       Logger.log_error("Create Event Object - Error during Events Creation");
    }
    return events
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function getBackendEvents() {
    return backend_events;
}


function ui_setup(ui_settings) {
    application_handle.settings.setup(ui_settings)
}
