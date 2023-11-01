.pragma library
.import QtQuick 6.4 as Quick
.import "../Common/Constants.js" as Constants



var qml_start_up_done = false   //true == DONE/ false == NOT DONE


/*******************************************************************
 * FUNCTION
 ******************************************************************/
function ui_setup(ui_settings) {

    let ret = application_handle.settings.setup(ui_settings)
    let status = false

    if(ret === true)
        status = true

    if(is_interface(Setup.BACKEND_SIMULATOR)) {
        Simulator.ui_setup_status(status)
    }else if(is_interface(Setup.PYTHON_BACKEND)) {
        Provider.ui_setup_status(status)
   }

}
