import QtQuick 6.4


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
    signal com_port_update(var portList);
    /**
     * @brief Setup Settings Event
     *
     * Event to setup the Settings Ui
     */
    signal ui_setup(var settings)


}
