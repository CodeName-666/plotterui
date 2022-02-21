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
    let value_to_check = used_backend_interface;

    if(!isNaN(interface_type))
    {
        if(interface_type <= (BACKEND_INTERFACES.length -1))
        {
            ret = (value_to_check === BACKEND_INTERFACES[interface_type])
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

    application_handle = applicationHandle
    backend_events = createBackendEventObject()
    if(used_backend_interface === BACKEND_INTERFACES[BACKEND_SIMULATOR])
    {
        Simulator.setup(application_handle, backend_events);
    }
    else if(used_backend_interface === BACKEND_INTERFACES[PYTHON_BACKEND])
    {
        if (python_backend_object !== undefined)
        {
            Provider.setup(python_backend_object, backend_events)
        }
    }
    else
    {

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
        Logger.log_debug("Create Event Object - Events Created");
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
