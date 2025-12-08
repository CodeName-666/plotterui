import QtQuick 6.4
import QtQuick.Controls 6.4
import QtQuick.Effects

Item {
    id: root

    property alias icon: iconText.text
    property alias backgroundColor: background.color
    property alias iconColor: iconText.color
    property int buttonSize: 56

    signal clicked()

    width: buttonSize
    height: buttonSize

    Button {
        id: fabButton
        anchors.fill: parent

        background: Rectangle {
            id: background
            color: "#007AFF"
            radius: fabButton.width / 2

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#80000000"
                shadowHorizontalOffset: 0
                shadowVerticalOffset: fabButton.pressed ? 2 : 4
                shadowBlur: fabButton.pressed ? 0.4 : 0.6
                shadowScale: 1.0
            }

            // Ripple effect on press
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#ffffff"
                opacity: fabButton.pressed ? 0.2 : (fabButton.hovered ? 0.1 : 0)

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            // Scale animation on press
            scale: fabButton.pressed ? 0.95 : 1.0

            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }

        contentItem: Text {
            id: iconText
            text: "+"
            font.pixelSize: 32
            font.bold: true
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            root.clicked()
        }
    }
}
