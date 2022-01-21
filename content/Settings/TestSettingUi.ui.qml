import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

Item {
    implicitHeight: 200
    implicitWidth: 350

    property alias colorDialog: colorDialog
    property alias colorView: colorView
    property alias colorButton: colorButton
    property alias nameInput: nameInput
    property alias typeCombo: typeCombo

    ColorDialog {
        id: colorDialog
        title: "Please choose a color"
    }

    Rectangle {
        anchors.fill: parent
        color: "#b5b0a7"

        ColumnLayout {
            anchors.fill: parent
            anchors.rightMargin: 5
            anchors.leftMargin: 5
            anchors.bottomMargin: 5
            anchors.topMargin: 5
            spacing: 5

            GridLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                columns: 2
                Text {
                    text: "Name:"
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }
                TextField {
                    id: nameInput
                    Layout.fillWidth: true
                }

                Button {
                    id: colorButton
                    text: "Color:"
                    font.bold: true
                }

                Rectangle {
                    id: colorView
                    color: "#00ffffff"
                    Layout.preferredHeight: colorButton.height
                    Layout.fillWidth: true
                }

                Text {
                    text: "Line Type:"
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                ComboBox {
                    id: typeCombo
                    Layout.fillWidth: true
                    model: ["Sinus", "Rectangle", "Line", "Random"]
                }
            }

            Item {
                id: spacer
                Layout.fillWidth: true
                Layout.fillHeight: true
                //Rectangle {
                //    anchors.fill: parent
                //    color: "#ffaaaa"
                //}
            }
        }
    }
}
