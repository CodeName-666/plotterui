.pragma library
.import "BackendSimulator.js" as Simulator


const UNKOWN_INTERFACE = 0;
const PYTHON_BACKEND = 1;
const BACKEND_SIMULATOR = 2;
var BACKEND_INTERFACES = ["UNKOWN", "PYTHON_BACKEND", "BACKEND_SIMULATOR"];



var used_backend_interface
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
function setup(use_backend)
{

    used_backend_interface = get_backend_interface(use_backend)
    qml_start_up_done = true;
}

/**************************************************************************
 * FUNCTION: set_settings
 **************************************************************************/
function set_settings(interface_type, settings)
{
    if(used_backend_interface === BACKEND_INTERFACES[PYTHON_BACKEND])
    {

    }
    else if(used_backend_interface === BACKEND_INTERFACES[BACKEND_SIMULATOR])
    {

    }
    else
    {

    }

    if (type === "SERIAL")
    {
        serial_settings = settings
    }
    else if (type === "TELNET")
    {

        telnet_settings = settings
    }
    else
    {
        console.log("INVALID INTERFACE")
    }

}

function connect()
{

}


function log_error(err_msg)
{
    console.log(err_msg)
}
