import QtQuick 2.15


QtObject {

    /* Chart Signals/Events */

    /**
     * @brief New Graph Event
     *
     */
    signal newGraph(var name, var color);
    /**
     * @brief Scroll Right Event
     */
    signal scrollRight(var pixel);
    /**
     * @brief Com Port Update Event
     */
    signal comPortUpdate(var portList);
    /**
     * @brief Setup Settings Event
     *
     * Event to setup the Settings Ui
     */
    signal setupSettings(var settings)


}
