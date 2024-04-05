.pragma library
.import "../ConfluenceUi/App.js" as App


function teamChanged(new_team)
{
    App.get_app().backend_tx_events.teamChanged(new_team);
}


function loadData(data)
{
    App.get_app().backend_tx_events.loadData(data);
}


function reloadData(data)
{
    App.get_app().backend_tx_events.reloadData(data);
}


function showProfile(name)
{
    App.get_app().backend_tx_events.showProfile(name);
}
