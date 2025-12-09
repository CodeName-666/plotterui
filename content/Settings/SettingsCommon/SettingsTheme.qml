pragma Singleton
import QtQuick 6.4

QtObject {
    id: theme

    // Color Palette
    readonly property color cardBackground: "#ffffff"
    readonly property color settingsBackground: "#f5f5f5"
    readonly property color interfaceBackground: "#fafafa"
    readonly property color borderColor: "#d0d0d0"
    readonly property color borderColorLight: "#e0e0e0"
    readonly property color textPrimary: "#333333"
    readonly property color textSecondary: "#5c5c5c"
    readonly property color textLabel: "#444444"
    readonly property color errorColor: "#d32f2f"
    readonly property color errorBackground: "#ffebee"
    readonly property color successColor: "#388e3c"
    readonly property color highlightColor: "#2196f3"

    // Spacing
    readonly property QtObject spacing: QtObject {
        readonly property int small: 5
        readonly property int medium: 10
        readonly property int large: 16
    }

    // Component Heights
    readonly property QtObject heights: QtObject {
        readonly property int input: 36
        readonly property int button: 36
        readonly property int combobox: 36
        readonly property int smallInput: 30
    }

    // Border Radius
    readonly property QtObject radius: QtObject {
        readonly property int small: 4
        readonly property int medium: 6
        readonly property int large: 8
    }

    // Font Sizes
    readonly property QtObject fontSize: QtObject {
        readonly property int small: 12
        readonly property int medium: 14
        readonly property int large: 16
        readonly property int title: 20
    }

    // Margins
    readonly property QtObject margins: QtObject {
        readonly property int small: 8
        readonly property int medium: 12
        readonly property int large: 16
    }
}
