


var application_handle = undefined


function setup(app_handle) {
    application_handle = app_handle
}


function create_graph(name, color = undefined) {
    console.log("Create New Line")
    var chartUi = application_handle.chartWindow
    var line = chartUi.chart.createSeries(QuickCharts.ChartView.SeriesTypeLine,
                                          name, chartUi.xAxis, chartUi.yAxis)
    if (color === undefined) {
        color = Random.getRandomInt(0xFFFFFF)
    }

    console.log(typeof line)
}

function get_chart() {
    return application_handle.chartWindow.chartUi.chart;
}
