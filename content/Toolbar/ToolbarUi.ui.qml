import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.11

import PlotterUi 1.0
import DataModels.SerialDataModels 1.0
import Common 1.0


ToolBar {

    property alias menuButton: menuButton

    width: Constants.width
    height: 40

    RowLayout {
        id: rlayout
        anchors.fill: parent
        spacing: 0

        ToolButton {
            id: menuButton
            Layout.preferredHeight: parent.height
            text: "\u2630" // simple menu glyph
        }
        Label {
            Layout.fillWidth: true
            text: qsTr(Constants.title)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: true
        }
    }
}



