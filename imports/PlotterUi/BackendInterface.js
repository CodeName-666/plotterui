.pragma library
.import "BackendSimulator.js" as Simulator
.import QtQuick 2.15 as Quick


const UNKOWN_INTERFACE = 0;
const PYTHON_BACKEND = 1;
const BACKEND_SIMULATOR = 2;
var BACKEND_INTERFACES = ["UNKOWN", "PYTHON_BACKEND", "BACKEND_SIMULATOR"];



var used_backend_interface = undefined
var qml_start_up_done = false   //true == DONE/ false == NOT DONE


/**************************************************************************
 * FUNCTION: get_backend_interface
 **************************************************************************/
function get_backend_interface(use_backend)
{
    var x = isNaN(use_backend)
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

/**************************************************************************
 * FUNCTION: setup
 **************************************************************************/
function setup(use_backend, applicationHandle)
{
    used_backend_interface = get_backend_interface(use_backend);
    qml_start_up_done = true;

    if(used_backend_interface === BACKEND_INTERFACES[BACKEND_SIMULATOR])
    {
        Simulator.setup(applicationHandle);
    }
    else
    {

    }



}

/**************************************************************************
 * FUNCTION: set_settings
 **************************************************************************/
function set_settings(interface_type, settings)
{
    var res = false
    if(used_backend_interface === BACKEND_INTERFACES[PYTHON_BACKEND])
    {
       res =  Backend.set_settings(interface_type,settings);
    }
    else if(used_backend_interface === BACKEND_INTERFACES[BACKEND_SIMULATOR])
    {
        res = Simulator.set_settings(interface_type,settings);
    }
    else
    {

    }
    return res;
}


function settings_valid()
{

}

function connect()
{

}


function log_error(err_msg)
{
    console.log(err_msg)
}
