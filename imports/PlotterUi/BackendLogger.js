.pragma library

var interface = undefined;

/*******************************************************************
 * INTERNAL FUNCTION
 ******************************************************************/
function setup(logger_interface) {
    interface = logger_interface
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


function log_internal(type, msg) {
    console.log("INTERNAL LOG: " + type + " - " + msg);
}

function log_messages(type, msg)
{
    if(interface !== undefined)
    {
        switch(type) {
            case 'ERROR':
                interface.log_error(msg);
            break;
            case 'WARNING':
                interface.log_warning(msg);
            break;
            case 'INFO':
                interface.log_info(msg);
            break;
            case 'DEBUG':
                interface.log_debug(msg);
            break;
        }
    } else {
        log_internal(type,msg);
    }
}
