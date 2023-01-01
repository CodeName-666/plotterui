

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

    property bool autoRepeat: false
    property int autoRepeatDelay: 300
    property int autoRepeatInterval: 100

    property alias zoomInButton: zoomInButton
    property alias zoomOutButton: zoomOutButton
    signal zoomInButtonClicked()
    signal zoomOutButtonClicked()


    ColumnLayout {
        id: columnLayout

        anchors.fill: parent

        Button {
            id: zoomInButton
            autoRepeat: parent.parent.autoRepeat
            autoRepeatDelay: parent.parent.autoRepeatDelay
            autoRepeatInterval: parent.parent.autoRepeatInterval
            text: "+"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: parent.height / 2
            Layout.fillWidth: true

        }

        Button {
            id: zoomOutButton
            autoRepeat: parent.parent.autoRepeat
            autoRepeatDelay: parent.parent.autoRepeatDelay
            autoRepeatInterval: parent.parent.autoRepeatInterval
            text: "-"
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: parent.height / 2
            Layout.fillWidth: true

        }
    }
}
