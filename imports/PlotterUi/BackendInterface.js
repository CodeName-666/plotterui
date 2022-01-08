.pragma library
.import "BackendSimulator.js" as Simulator


var BACKEND_INTERFACES = ["UNKOWN", "PYTHON_BACKEND", "BACKEND_SIMULATOR"];



var used_backend_interface
var qml_start_up_done = false   //true == DONE/ false == NOT DONE


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



function setup(use_backend)
{

    used_backend_interface = get_backend_interface(use_backend)
    qml_start_up_done = true;
}


function set_settings(settings)
{
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
