.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml

var current_settings = undefined
var current_interface = undefined
var application_handle = undefined
var signal_list = []
var setup_done = false
var update_timer = undefined


function setup(application)
{
    application_handle = application;
    setup_done = true;
    log_error("SIMULATOR setup done");
    update_timer = createTimer();
}

function set_settings(type, settings)
{
    current_settings = settings
    current_interface = type

    return true
}



function get_settings()
{

}

function get_interface()
{


}

function createTimer() {
    if(setup_done)
    {
        var cTimer = Qt.createQmlObject(' import QtQuick 2.15; Timer {}', application_handle);
        return cTimer;
    }
    return None;
}


function log_error(err_msg)
{
    console.log(err_msg)
}
