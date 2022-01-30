.pragma library
.import "BackendSimulator.js" as Simulator
.import "Setup.js" as Setup


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function set_settings(interface_type, settings)
{
    var res = false
    if(Setup.is_interface(Setup.PYTHON_BACKEND))
    {
       res =  Backend.set_settings(interface_type,settings);
    }
    else if(Setup.is_interface(Setup.BACKEND_SIMULATOR))
    {
        res = Simulator.set_settings(interface_type,settings);
    }
    else
    {

    }
    return res;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_settings(interface_type)
{
    if(Setup.is_interface(Setup.PYTHON_BACKEND))
    {
       return Backend.get_settings(interface_type);
    }
    else if(Setup.is_interface(Setup.BACKEND_SIMULATOR))
    {
        return Simulator.get_settings(interface_type);
    }
    else
    {

    }
    return undefined;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function settings_valid()
{
    var ret = false;
    if(Setup.is_interface(Setup.PYTHON_BACKEND))
    {
        ret = Backend.settings_valid();
    }
    else if(Setup.is_interface(Setup.BACKEND_SIMULATOR))
    {
        ret = Simulator.settings_valid();
    }
    else
    {

    }
    return ret;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function connect()
{
    if(settings_valid())
    {
        if(Setup.is_interface(Setup.PYTHON_BACKEND))
        {
            Backend.connect();
        }
        else if(Setup.is_interface(Setup.BACKEND_INTERFACES))
        {
            Simulator.connect();
        }
        else
        {

        }
    }
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function is_connected()
{
    var res = false;
    if(Setup.is_interface(Setup.PYTHON_BACKEND))
    {
       res =  Backend.is_connect();
    }
    else if(Setup.is_interface(Setup.BACKEND_SIMULATOR))
    {
        res = Simulator.is_connect();
    }
    else
    {

    }
    return res;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function log_error(err_msg)
{
    console.log(err_msg)
}
