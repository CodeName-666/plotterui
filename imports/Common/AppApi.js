.pragma library
.import QtQuick 6.4 as Quick
.import "../Backend/BackendLogger.js" as Logger
.import "../Backend/Python/BackendProvider.js" as Provider
.import "../Backend/Simulator/BackendSimulator.js" as Simulator
.import "../Backend/BackendSetup.js" as Setup


var application_handle = undefined
var used_backend_interface = undefined
var backend_events = undefined

var path_to_backend_events = "../Backend/BackendEvents.qml"



/**
 * @brief Get Interface
 *
 * @return Returns the correct interface which has to be used.
 * Possible Interfaces are:
 * - Provider: Interface to Python Backend
 * - Simulator: Interface to QML Simulater
 * - Undefined: Unknown setup called, therefore undefined
 */
function get_interface() {
    var interface
    if (is_interface(Setup.PYTHON_BACKEND)) {
        interface = Provider
    } else if (is_interface(Setup.BACKEND_SIMULATOR)) {
        interface = Simulator
    } else {
        Logger.log_error("GET INTERFACE: Invalid Interface")
        interface = undefined
    }
    return interface
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_interface(interface_type)
{
    let ret = false;
    if(!isNaN(interface_type))
    {
        if(interface_type <= (Setup.INTERFACES.length -1))
        {
            ret = (used_backend_interface === Setup.INTERFACES[interface_type])
        }
    }
    else
    {
        for (let i = 0; i < Setup.INTERFACES.length; i++)
        {
            if(interface_type === Setup.INTERFACES[i])
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
    var ret = Setup.INTERFACES[Setup.UNKOWN_INTERFACE]
    if(!isNaN(use_backend))
    {
        ret = Setup.INTERFACES[use_backend];
    }
    else
    {
        for (let i = 0; i < Setup.INTERFACES.length; i++)
        {
            if(use_backend === Setup.INTERFACES[i])
            {
                ret = Setup.INTERFACES[i]
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

    if(is_interface(Setup.BACKEND_SIMULATOR))
    {
        Simulator.internal_setup(application_handle, backend_events);
    }
    else if(is_interface(Setup.PYTHON_BACKEND))
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
