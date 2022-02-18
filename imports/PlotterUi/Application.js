.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "Random.js" as Random
//.import "BackendInterface.js" as BackendInterface

var application_handle = undefined

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(app_handle) {
    application_handle = app_handle

    BackendInterface.log_info("Application Setup Done")

    //if(application_handle == undefined)
    //    BackendInterface.log_error("ApplicationHandle undefined")
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function create_graph(name, color = undefined) {
    var chartUi = application_handle.chartWindow
    var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,
                                          name, chartUi.xAxis, chartUi.yAxis)
    if (color === undefined) {
        color = Random.getRandomInt(0xFFFFFF)
    }

    //BackendInterface.log_info("Create Graph - Name: " + name + " - Color: " + color);
    return line
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_chart() {
    return application_handle.chartWindow.chart;
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_app() {
    return application_handle
}
