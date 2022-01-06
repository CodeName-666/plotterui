import QtQuick 2.15

ListModel
{
    id: parity_bits_model
    ListElement {
        val: "None"
        name: "Keine"
    }
    ListElement {
        val: "EVEN"
        name: "Gerade"
    }
    ListElement {
        val: "ODD"
        name: "Ungerade"
    }
   // ListElement {
   //     name: "MARK"
   // }
   // ListElement {
   //     name: "SPACE"
   // }
}

