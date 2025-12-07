import QtQuick 6.6

QtObject {
    // Backend -> QML signals (mirror of backend.py emits)
    signal newGraph(var name, var color)
    signal append_graph_point(var name, var point)
    signal scrollRight(var pixel)
    signal com_port_update(var portList)
    signal ui_setup(var settings)
    signal status_message(var level, var message)
}
