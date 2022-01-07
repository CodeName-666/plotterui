.pragma library

var used_backend_interface //true == JAVA SCRIPT/ false == PYTHON
var qml_start_up_done = false   //true == DONE/ false == NOT DONE

var serial_settings
var telnet_settings
var used_interface



function setup(use_backend)
{
    used_backend_interface = use_backend;
    qml_start_up_done = true;
}


function set_settings(type, settings)
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
