import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.11
import "../../imports/PlotterUi"

ToolBar {

    width:  Constants.width

    property alias keepAliveStatus: keepAliveStatus
    property alias keepAliveInfoText: keepAliveInfo.text

    RowLayout {
        anchors.fill: parent
        Label {
            id: keepAliveInfo
            Layout.fillHeight: true
            Layout.leftMargin: 10
            text: "Read Only"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            // spacer item
            id: spacer
            Layout.fillWidth: true
            Rectangle {
                anchors.fill: parent
                color: "#ffaaaa"
            } // to visualize the spacer
        }

        StatusIndicator {
            id: keepAliveStatus
            Layout.fillHeight: true
            Layout.rightMargin: 10
        }
    }
}
