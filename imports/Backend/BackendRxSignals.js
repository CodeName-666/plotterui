.pragma library
.import "../ConfluenceUi/App.js" as App



function connectDepartmentsLoaded(cSignal) {
     App.get_app().backend_rx_events.departmentsLoaded.connect(cSignal)
}


function connectTeamChanged(cSignal) {
    App.get_app().backend_rx_events.teamChanged.connect(cSignal)
}


function connectLoadData(cSignal) {
    App.get_app().backend_rx_events.loadData.connect(cSignal)
}


function connectTeamsLoaded(cSignal) {
    App.get_app().backend_rx_events.teamsLoaded.connect(cSignal)
}


function connectShowProfile(cSignal)
{
     App.get_app().backend_rx_events.showProfile.connect(cSignal)
}

function getDepartments() {
    return App.get_app().used_backend_interface.getDepartments()
}

function getTeams(department)
{
    return App.get_app().used_backend_interface.getTeams(department)
}


function getTeamMember(new_team)
{
    return App.get_app().used_backend_interface.getTeamMembers(new_team)
}
