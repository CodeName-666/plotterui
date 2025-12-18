pragma Singleton
import QtQuick 6.4

QtObject {
    id: theme

    // Color palette
    readonly property QtObject palette: QtObject {
        readonly property color primary: "#2196f3"
        readonly property color primaryHover: "#1976d2"
        readonly property color primaryPressed: "#1565c0"
        readonly property color primaryBorder: "#1565c0"
        readonly property color accent: "#03dac5"
        readonly property color danger: "#d32f2f"
        readonly property color success: "#388e3c"
        readonly property color warning: "#ffa000"
    }

    readonly property QtObject surfaces: QtObject {
        readonly property color background: "#f5f5f5"
        readonly property color interfaceBackground: "#fafafa"
        readonly property color card: "#ffffff"
        readonly property color muted: "#f0f0f0"
    }

    readonly property QtObject borders: QtObject {
        readonly property color primary: "#c5c5c5"
        readonly property color subtle: "#e0e0e0"
        readonly property color focus: palette.primary
        readonly property color danger: palette.danger
        readonly property color disabled: "#bdbdbd"
    }

    readonly property QtObject text: QtObject {
        readonly property color primary: "#333333"
        readonly property color secondary: "#5c5c5c"
        readonly property color label: "#444444"
        readonly property color contrast: "#ffffff"
        readonly property color disabled: "#777777"
        readonly property color placeholder: "#888888"
    }

    readonly property QtObject states: QtObject {
        readonly property color disabledBackground: "#dcdcdc"
    }

    readonly property QtObject inputs: QtObject {
        readonly property color background: surfaces.card
        readonly property color disabledBackground: surfaces.interfaceBackground
    }

    readonly property QtObject buttons: QtObject {
        readonly property QtObject neutral: QtObject {
            readonly property color background: "#4d4d4d"
            readonly property color hover: "#666666"
            readonly property color pressed: "#555555"
            readonly property color border: "#606060"
            readonly property color text: text.contrast
        }
    }

    readonly property QtObject spacing: QtObject {
        readonly property int small: 8
        readonly property int medium: 12
        readonly property int large: 20
        readonly property int extraLarge: 24
    }

    readonly property QtObject heights: QtObject {
        readonly property int input: 40
        readonly property int button: 40
        readonly property int combobox: 40
        readonly property int smallInput: 32
        readonly property int label: 40
    }

    readonly property QtObject radius: QtObject {
        readonly property int small: 4
        readonly property int medium: 6
        readonly property int large: 8
        readonly property int extraLarge: 10
    }

    readonly property QtObject fontSize: QtObject {
        readonly property int small: 12
        readonly property int medium: 14
        readonly property int large: 16
        readonly property int title: 20
        readonly property int header: 18
        readonly property int button: 13
    }

    readonly property QtObject margins: QtObject {
        readonly property int small: 8
        readonly property int medium: 16
        readonly property int large: 20
        readonly property int extraLarge: 24
    }
}
