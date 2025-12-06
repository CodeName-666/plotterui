.pragma library
.import QtQuick 6.6 as QtQuick

var backendEvents = null

function create_backend_events() {
    var component = Qt.createComponent(Qt.resolvedUrl("../Backend/BackendEvents.qml"))
    if (component.status === QtQuick.Component.Ready) {
        var obj = component.createObject(Qt.application)
        if (obj === null) {
            console.error("BackendEvents object could not be created")
        }
        return obj
    } else if (component.status === QtQuick.Component.Error) {
        console.error("BackendEvents component error:", component.errorString())
    } else {
        console.error("BackendEvents component not ready:", component.status)
    }
    return null
}

function get_backend_events() {
    if (backendEvents === null) {
        backendEvents = create_backend_events()
    }
    return backendEvents
}

function reset_backend_events() {
    if (backendEvents !== null) {
        backendEvents.destroy()
        backendEvents = null
    }
}
