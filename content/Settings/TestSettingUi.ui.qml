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
    height: 300

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
                Layout.columnSpan: 1
                Layout.rowSpan: 1
                Layout.minimumWidth: 0
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

                Text {
                    id: colorText
                    text: "Color:"
                    font.bold: true
                }

                Rectangle {
                    id: colorView
                    color: "#00ffffff"
                    border.width: 2
                    border.color: "#ababab"
                    Layout.preferredHeight: nameInput.height
                    Layout.fillWidth: true
                    MouseArea {
                        id: colorButton
                        anchors.fill: parent
                    }
                }

                Text {
                    text: "Line Type:"
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                ComboBox {
                    id: typeCombo
                    Layout.fillWidth: true
                    model: ["Sinus", "Rectangle", "Ramp", "Line", "Random"]
                }

                Button {
                    visible: false
                    text: "Add"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                }

                Button {
                    visible: false
                    text: "Delete"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    //Layout.fillWidth: true
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
