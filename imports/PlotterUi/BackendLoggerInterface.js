.pragma library

const UNDEFINED = 0;
const SIGNLE_INTERFACE = 1;
const INTERFACE_ARRAY = 2;


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
        return SIGNLE_INTERFACE;
    } else {
        if(Array.isArray(interface_list)) {
            return INTERFACE_ARRAY;
        }
    }
    return UNDEFINED;
}


/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_error(msg) {
    log_messages('ERROR',msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_warning(msg) {
    log_messages('WARNING',msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_info(msg) {
    log_messages('INFO',msg);
}

/*******************************************************************
 * FUNCTION SLOT
 ******************************************************************/
function log_debug(msg) {
    log_messages('DEBUG',msg);
}


function log_messages(type, msg)
{
    let isAv = isArray()
    if(isAv === SIGNLE_INTERFACE)
    {  
       print(type,interface,msg);
    } else if(isAv === INTERFACE_ARRAY) {
        for (let i = 0; i < interface_list.length; i++) {
            let output_interface = interface_list[0];
            if(output_interface !== undefined) {
                print(type,output_interface, msg);
            }
        }
    } else {
        internal_error_log('Interface undefined')
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

function internal_error_log(msg) {
    console.log("INTERNAL ERROR: " + msg)
}
