.pragma library
.import QtQuick 2.15 as Quick
.import QtQml 2.15 as Qml
.import QtCharts 2.15 as QuickCharts
.import "Random.js" as Random


var application_handle = undefined

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function setup(app_handle) {
    application_handle = app_handle

    console.log("App INIT " + application_handle)
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function create_graph(name, color = undefined) {
    console.log("Create New Line")
    var chartUi = application_handle.chartWindow
    var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,
                                          name, chartUi.xAxis, chartUi.yAxis)
    if (color === undefined) {
        color = Random.getRandomInt(0xFFFFFF)
    }

    console.log(typeof line)
    return line
}

/*******************************************************************
 * FUNCTION
 ******************************************************************/
function get_chart() {
    return application_handle.chartWindow.chart;
}

function get_app() {
    return application_handle
}
