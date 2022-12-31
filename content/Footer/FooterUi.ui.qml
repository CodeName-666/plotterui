import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Layouts 1.11
import "../StatusIndicator"

ToolBar {

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
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height
            Layout.rightMargin: 10

        }
    }
}
