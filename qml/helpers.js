String.prototype.toHHMM = function () {
    var dur = parseFloat(this) * 60;
    var hours = (Math.floor(dur / 60)).toFixed(0);
    var minutes = (dur % 60).toFixed(0);
    //if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    return hours+':'+minutes;
}
