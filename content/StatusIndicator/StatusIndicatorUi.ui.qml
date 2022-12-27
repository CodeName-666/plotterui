

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 6.3

Item {

    //width: 100
    //height: 100
    property alias indicator: indicator

    Rectangle {
        id: indicator
        radius: 50
        border.color: "#776f6f"
        border.width: 7
        anchors.fill: parent
        z: 0
        clip: false
        color: "grey"
    }
}
