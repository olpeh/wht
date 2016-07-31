
$(function () {
    var options = {
        navigator:  {
            enabled: true
        },
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
        yAxis: [
            {
                labels: {
                    format: '{value}',
                    style: {
                        color: Highcharts.getOptions().colors[0]
                    }
                },
                title: {
                    text: 'Amount',
                    style: {
                        color: Highcharts.getOptions().colors[0]
                    }
                },
                allowDecimals: false
            },
            {
                opposite: false,
                gridLineWidth: 0,
                title: {
                    text: 'Likes',
                    style: {
                        color: 'rgba(63, 191, 63, 0.8)'
                    }
                },
                labels: {
                    format: '{value} likes',
                    style: {
                        color: 'rgba(63, 191, 63, 0.8)'
                    }
                },
                allowDecimals: false,
            },
        ],
        series: [
            {
                type: 'line',
                yAxis: 1,
                name: 'Likes',
                color: 'rgba(63, 191, 63, 0.4)',
                data: [],
                allowDecimals: false,
                step: true,
            },
            {
                type: 'spline',
                name: 'Downloads',
                data: [],
                allowDecimals: false
            },
            {
                type: 'spline',
                name: 'Active installations',
                data: [],
                allowDecimals: false
            }
        ]
    };
    $.getJSON('http://vps161572.ovh.net/wht/wht.php', function(data) {
        $.each(data, function(key, value) {
            var date =  new Date(value.inserted).getTime(); //split(" ")[0];
            options.series[0].data.push([date, parseInt(value.likes)]);
            options.series[1].data.push([date, parseInt(value.downloads)]);
            options.series[2].data.push([date, parseInt(value.actives)]);
        });
        var latest = data.pop()
        $('.stats-summary').html("<b>" + latest.inserted.split(" ")[0]
            + ":</b><ul><li>" + latest.downloads + " downloads</li><li>"
            + latest.actives + " active installations </li><li>"
            + latest.likes + " likes</li><li>"
            + latest.comments + " comments</li></ul>");
        var chart = new Highcharts.StockChart(options);
   });
});