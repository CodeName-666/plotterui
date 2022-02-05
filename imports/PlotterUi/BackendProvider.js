.pragma library

var backend = undefined


function setup(python_backend) {
    backend = python_backend
    backend.setu_done();
}


function is_valid()
{
    return (backend != undefined)
}

function set_settings(interface_type,settings)
{
    if(is_valid())
    {
        backend.set_settings(interface_type, settings);
    }
}


function get_settings(interface_type)
{
    if(is_valid())
    {
        return backend.get_settings();
    }
}

function settings_valid() {

}

function log_error(msg) {
    if(is_valid())
    {
        backend.log_error(msg);
    }
}

function log_warning(msg) {
    if(is_valid())
    {
        backend.log_warning(msg);
    }
}

function log_info(msg) {
    if(is_valid()) {
        backend.log_info(msg)
    }
}

function log_debug(msg) {
    if(is_valid()) {
        backend.log_debug(msg)
    }
}

