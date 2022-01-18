import QtQuick 2.15
import QtQuick.Controls 2.15

TestSettingUi {

    colorDialog.onAccepted: {
        colorView.color = colorDialog.color;
        colorDialog.close();
    }

    colorDialog.onRejected: colorDialog.close();

    colorButton.onClicked: colorDialog.open();



}
