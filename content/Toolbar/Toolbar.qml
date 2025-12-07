import QtQuick 6.4

ToolbarUi {
    signal connectRequested
    signal settingsRequested

    startButton.onClicked: connectRequested()
    stopButton.onClicked: connectRequested()
    settingsButton.onClicked: settingsRequested()
}
