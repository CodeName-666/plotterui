.pragma library
.import QtQuick 6.4 as Quick
.import "../Backend/BackendLogger.js" as Logger
.import "../Backend/Python/BackendProvider.js" as Provider
.import "../Backend/Simulator/BackendSimulator.js" as Simulator


const UNKOWN_INTERFACE = 0;
const PYTHON_BACKEND = 1;
const BACKEND_SIMULATOR = 2;
var BACKEND_INTERFACES = ["UNKOWN", "PYTHON_BACKEND", "BACKEND_SIMULATOR"];

var application_handle = undefined
var used_backend_interface = undefined
var backend_events = undefined

var qml_start_up_done = false   //true == DONE/ false == NOT DONE
var path_to_backend_events = "../Backend/BackendEvents.qml"

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
        }
    }
    else
    {
        for (let i = 0; i < BACKEND_INTERFACES.length; i++)
        {
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
    var ret = BACKEND_INTERFACES[UNKOWN_INTERFACE]
    if(!isNaN(use_backend))
    {
        ret = BACKEND_INTERFACES[use_backend];
    }
    else
    {
        console.log(BACKEND_INTERFACES.length)
        for (let i = 0; i < BACKEND_INTERFACES.length; i++)
        {
            if(use_backend === BACKEND_INTERFACES[i])
            {
                ret = BACKEND_INTERFACES[i]
            }
        }
    }
    return ret
}

/**
 * @brief Apps Setup
 * @param {String} use_backend Backend which has to be used, @see BACKEND_INTERFACES
 * @param {Object} applicationHandle QML main object of this project (this-Object).
 * @pram {Object}  python_backend_object Python class which was set in the python setup and provides all neede interfaces between python and qml.
 *
 * This function is the general init function of the Java Script files. It gets all needed
 * objects and also does some setup on the correct backend
 *
 */
function app_setup(use_backend, applicationHandle, python_backend_object = undefined)
{
    used_backend_interface = get_backend_interface(use_backend);
    qml_start_up_done = true;

    // Store appliction handle internal.
    application_handle = applicationHandle;

    // Create BackendEvents QML object to provide alle needed Signals for the APP
    backend_events = create_backend_event_object();

    // Connect the BackendEvent "setupConfig" with the internal setupConfig Slot
    // Depandent on the used interface the Signal SetupConfig can be triggered from 
    // the Simulator or from the Python Backend directly to set all needed configurations.
    backend_events.ui_setup.connect(ui_setup)

    if(is_interface(BACKEND_SIMULATOR))
    {
        Simulator.internal_setup(application_handle, backend_events);
    }
    else if(is_interface(PYTHON_BACKEND))
    {
        if (python_backend_object !== undefined)
        {
            Provider.internal_setup(python_backend_object, backend_events);
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
function create_backend_event_object() {

    var events = undefined
    var component = Qt.createComponent(path_to_backend_events);
    if(component.status === Quick.Component.Ready)
    {

        events = component.createObject(application_handle)
        Logger.log_debug("Create Event Object - Events Created", create_backend_event_object);
    }
    else if(component.status === Quick.Component.Error)
    {
        Logger.log_error("Create Event Object - Events Created");
    }
    else
    {
        Logger.log_debug("")
    }
    return events
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_backend_events() {
    return backend_events;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function ui_setup(ui_settings) {

    let ret = application_handle.settings.setup(ui_settings)
    let status = false

    if(ret === true) 
        status = true
    
    if(is_interface(BACKEND_SIMULATOR)) {
        Simulator.ui_setup_status(status)
    }else if(is_interface(PYTHON_BACKEND)) {
        Provider.ui_setup_status(status)
   }

}
