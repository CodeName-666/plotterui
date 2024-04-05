import QtQuick 6.6

QtObject {

    signal loadData(string data);

    signal departmentsLoaded(bool status);
    signal teamsLoaded(bool status);
    signal teamMemberLoaded(bool status);

    signal teamChanged(var new_team);
    signal showProfile(string name);


}
