

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 6.3
import "Indicator"

Item {
    width: 500
    height: 50

    RowLayout {
        id: row_layout
        anchors.fill: parent
        layoutDirection: Qt.LeftToRight
        layer.enabled: false

        Text {

            text: "hello World"
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Indicator {
            id: indicator
            Layout.preferredHeight: row_layout.height * 0.8
            Layout.preferredWidth: row_layout.height * 0.8
        }
    }
}
