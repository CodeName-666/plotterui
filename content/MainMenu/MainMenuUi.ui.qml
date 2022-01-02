import QtQuick 2.15
import QtQuick.Window 2.13
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11


MenuBar {
    property alias aboutButton: aboutButton
    property alias settingsButton: settingsButton
    property alias closeButton: closeButton
    property alias newButton: newButton

    Menu {
        title: qsTr("&File")
        Action {
            id: newButton
            text: qsTr("&New...")
        }
        MenuSeparator {}
        Action {
            id: closeButton
            text: qsTr("&Quit")
        }
    }
    Menu {
        title: qsTr("&Edit")
        Action {
            id: settingsButton
            text: qsTr("&Settings")
        }
    }
    Menu {
        title: qsTr("&Help")
        Action {
            id: aboutButton
            text: qsTr("&About")
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

