import QtQuick 6.4


StatusIndicatorUi {
    enum Status {
        OFF,
        CONNECTED,
        DISCONNECTED,
        WAITING
    }

    function set_status(status) {
        switch(status)
        {
        case Status.OFF:
            indicator.color = "grey";
            break;
        case Status.CONNECTED:
            indicator.color = "green";
            break;

        case Status.DISCONNECTED:
            indicator.color = "red";
            break;

        case Status.WAITING:
            indicator.color = "yellow";
            break;
        default:
            indicator.color = "grey";
            Logger.log_error("Invalid inidcator stauts set");
            break;

        }
    }
}
