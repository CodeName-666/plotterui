import QtQuick 6.4
import QtQuick.Controls 6.4

TestSettingUi {

    colorDialog.onAccepted: {
        colorView.color = colorDialog.color;
        colorDialog.close();
    }

    colorDialog.onRejected: colorDialog.close();

    colorButton.onClicked: colorDialog.open();
}
