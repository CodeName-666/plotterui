

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Item {

    property alias zoomInButton: zoomInButton
    property alias zoomOutButton: zoomOutButton

    ColumnLayout {
        id: columnLayout

        anchors.fill: parent

        Button {
            id: zoomInButton
            text: "+"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: parent.height / 2
            Layout.fillWidth: true
        }

        Button {
            id: zoomOutButton
            text: "-"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: parent.height / 2
            Layout.fillWidth: true
        }
    }
}
