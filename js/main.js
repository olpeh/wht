
$(function () {
    var options = {
        chart: {
           renderTo: 'stats-container',
        },
        title: {
            text: 'Download stats for Working Hours Tracker'
        },
        subtitle: {
            text: 'Source: harbour.jolla.com'
        },
        xAxis: [{
            categories: [],
            crosshair: true
        }],
        yAxis: [{ // Primary yAxis
            labels: {
                format: '{value}',
                style: {
                    color: Highcharts.getOptions().colors[2]
                }
            },
            title: {
                text: 'Amount',
                style: {
                    color: Highcharts.getOptions().colors[2]
                }
            }
        }, { // Secondary yAxis
            gridLineWidth: 0,
            title: {
                text: 'Likes',
                style: {
                    color: Highcharts.getOptions().colors[0]
                }
            },
            labels: {
                format: '{value} likes',
                style: {
                    color: Highcharts.getOptions().colors[0]
                }
            },
            opposite: true
        }],
        series: [
            {
                type: 'spline',
                name: 'Downloads',
                data: []
            },
            {
                type: 'spline',
                name: 'Active installations',
                data: []
            },
            {
                type: 'spline',
                yAxis: 1,
                name: 'Likes',
                data: []
            }
        ]
    };
    $.getJSON('http://vps161572.ovh.net/wht/wht.php', function(data) {
        $.each(data, function(key, value) {
            options.series[0].data.push([value.inserted, parseInt(value.downloads)]);
            options.series[1].data.push([value.inserted, parseInt(value.actives)]);
            options.series[2].data.push([value.inserted, parseInt(value.likes)]);
            options.xAxis[0].categories.push(value.inserted.split(" ")[0]);
        });
        var latest = data.pop()
        $('.stats-summary').html("<b>" + latest.inserted.split(" ")[0]
            + ":</b><ul><li>" + latest.downloads + " downloads</li><li>"
            + latest.actives + " active installations </li><li>"
            + latest.likes + " likes</li><li>"
            + latest.comments + " comments</li></ul>");
        var chart = new Highcharts.Chart(options);
   });
});