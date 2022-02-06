.pragma library
.import "BackendSimulator.js" as Simulator
.import "BackendProvider.js" as Provider

const UNKOWN_INTERFACE = 0;
const PYTHON_BACKEND = 1;
const BACKEND_SIMULATOR = 2;
var BACKEND_INTERFACES = ["UNKOWN", "PYTHON_BACKEND", "BACKEND_SIMULATOR"];


var used_backend_interface = undefined
var qml_start_up_done = false   //true == DONE/ false == NOT DONE


function is_interface(interface_type, value = undefined)
{
    var ret = false;

    var value_to_check = used_backend_interface;
    if (value !== undefined)
    {
        value_to_check = value;
    }

    if(!isNaN(use_backend))
    {
        if(interface_type === (BACKEND_INTERFACES.length -1))
        {
            ret = (value === BACKEND_INTERFACES[interface_type])
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

    if(used_backend_interface === BACKEND_INTERFACES[BACKEND_SIMULATOR])
    {
        Simulator.setup_done(applicationHandle);
    }
    else if(used_backend_interface === BACKEND_INTERFACES[PYTHON_BACKEND])
    {
        if (python_backend_object !== 'undefinend')
        {
            Provider.setup(python_backend_object, applicationHandle)
        }
    }
    else
    {

    }
}
