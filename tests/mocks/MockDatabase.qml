import QtQuick 2.0

QtObject {

    property var db;

    function notMocked() {
        console.log("Not mocked (yet)")
    }

    function saveHourRow(values) {
        console.log("GOT: " + values)
    }

    function getDurationForPeriod(period, timeOffset, projectId) {
        return 37.5
    }

    function getHoursForPeriod(period, timeOffset, sorting, projectId) {
        notMocked()
    }

    function getLastUsedInput(projectID, taskID) {
        notMocked()
    }

    function getProjects(){
        return [
            {
                "id": "123",
                "name": "Mock project",
                "hourlyRate": 123,
                "contractRate": 123,
                "budget": 123,
                "hourBudget": 123,
                "labelColor": "red"
            },
            {
                "id": "321",
                "name": "Mock project 2",
                "hourlyRate": 321,
                "contractRate": 321,
                "budget": 321,
                "hourBudget": 321,
                "labelColor": "blue"
            }
        ]
    }

    function insertInitialProject(labelColor){
        notMocked()
    }

    function saveProject(values){
        notMocked()
    }

    function getTasks(projectID){
        notMocked()
    }

    function saveTask(values){
        lolWat()
    }

    function remove(table, id){
        lolWat()
    }

    function resetDatabase(){
        lolWat()
    }
}
