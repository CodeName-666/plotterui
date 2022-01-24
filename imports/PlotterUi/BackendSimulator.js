.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts


var application_handle = undefined
var update_timer = undefined
var setup_done = false

var current_settings = undefined
var current_interface = undefined

var signal_list = []




function setup(application)
{
    application_handle = application;
    setup_done = true;
    update_timer = new Timer(10,true, true, backend_simulator_loop);
    log_error("SIMULATOR setup done");

    create_line("Test");

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

function Timer(interval, repeat = false, start = false, callback = undefined) {
    if(setup_done)
    {
        var cTimer = Qt.createQmlObject(' import QtQuick 2.15; Timer {}', application_handle);
        cTimer.interval = interval;
        cTimer.repeat = repeat

        if(callback !== undefined)
        {
            cTimer.triggered.connect(callback);
        }

        if(start)
        {
            cTimer.start()
        }

        return cTimer;
    }
    return None;
}


function backend_simulator_loop()
{
    switch(current_interface)
    {
       case "Serial" :
           backend_simulator_serial_loop();
           break;
       case "Telnet":
           backend_simulator_telnet_loop();
           break;
       case "Test":
           backend_simulator_test_loop();
           break;
       default:
           log_error("Invalid interface");
           break;
    }

    log_error("backend_simulator_loop running...");
}

var serial_counter = 0;
function backend_simulator_serial_loop()
{
    log_error("Serial_Loop - " + serial_counter++);
}

var telnet_counter = 0;
function backend_simulator_telnet_loop()
{
     log_error("Telnet_Loop - " + telnet_counter++);
}

var test_counter = 0;
function backend_simulator_test_loop()
{
    log_error("Test_Loop - " + test_counter++);
}


function create_line(name)
{
    var chartUi = application_handle.chartWindow;
    var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,name,chartUi.xAxis,chartUi.yAxis);
    return line;
}


function log_error(err_msg)
{
    //console.log(err_msg)
}
