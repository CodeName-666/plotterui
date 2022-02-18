.pragma library


var interface = undefined;
var interface_list = undefined;

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function setup(interface_or_list) {
    if (Array.isArray(interface_or_list))  {
        interface_list = interface_or_list
     } else {
        interface = interface_or_list
     }
}

function isArray() {
    if(interface !== undefined) {
        return false;
    } else {
        return true;
    }
}


/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_error(msg) {
    if (is_valid()) {
        backend.log_error(msg)
    }

    console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_warning(msg) {
    if (is_valid()) {
        backend.log_warning(msg)
    }
    console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_info(msg) {
    if (is_valid()) {
        backend.log_info(msg)
    }
    console.log(msg)
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_debug(msg) {
    if (is_valid()) {
        backend.log_debug(msg)
    }
    console.log(msg)
}


function log_messages(type, msg)
{
    if(!isArray())
    {  
       print(type,interface,msg);
    } else {
        for (let i = 0; i < interface_list.length; i++) {
            let output_interface = interface_list[0];
            print(type,output_interface, msg);
        }
    }

}

function print(type,output_interface, msg) {
    switch(type) {
        case 'ERROR':
            output_interface[0].log_error(msg);
        break;
        case 'WARNING':
            output_interface.log_warning(msg);
        break;
        case 'INFO':
            output_interface.log_info(msg);
        break;
        case 'DEBUG':
            output_interface.log_debug(msg);
        break;
    }
}
