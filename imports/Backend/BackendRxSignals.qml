import QtQuick 6.6

QtObject {
    // Backend -> QML signals (mirror of backend.py emits)
    signal newGraph(var uniqueId, var displayName, var color, var interfaceType)
    signal append_graph_point(var name, var point)
    signal append_graph_points_batch(var uniqueId, var points)
    signal scrollRight(var pixel)
    signal com_port_update(var portList)
    signal ui_setup(var settings)
    signal status_message(var level, var message)
}
