.pragma library

var com_ports
var backend


function setBackend(backend_obj)
{
    backend = backend_obj
}

function setSettings(new_settings)
{
    var res = backend.set_settings(new_settings)
    if(res === true)
        console.log("Settings updated")
    else
        console.log("Settings update failed")
}


function getComPorts() {
    return com_ports
}


function updateComPorts()
{
  com_ports = backend.get_com_ports();
  console.log("BackendInterface: ComPort update")
}
