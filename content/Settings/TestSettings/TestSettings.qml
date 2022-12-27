import QtQuick 6.4
import QtQuick.Controls 6.4

TestSettingUi {

    colorDialog.onAccepted: {
        colorView.color = colorDialog.color;
        colorDialog.close();
    }

    colorDialog.onRejected: colorDialog.close();

    colorButton.onClicked: colorDialog.open();

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function get_settings()
    {
        var retVal =  {
            "name": qsTr(nameInput.text),
            "color": colorView.color,
            "type": qsTr(typeCombo.currentText)
           }
        return retVal;
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_settings(settings)
    {
        nameInput.text = settings["name"];
        colorView.color = settings["color"];
        set_combobox(testSettings.typeCombo,settings["type"]);
    }

    /*******************************************************************
     * FUNCTION
     ******************************************************************/
    function set_combobox(combobox, txt, type = "txt")
    {
         var idx = combobox.find(txt, Qt.MatchExactly);
         //interfaceComboBox.currentIndex = idx;
    }
}
