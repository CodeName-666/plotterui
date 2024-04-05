import QtQuick 6.6

QtObject {

    /* Chart Signals/Events */

    signal loadData(string data);
    signal reloadDate(string data);

    signal teamChanged(var new_team);
    signal showProfile(string name);

}
