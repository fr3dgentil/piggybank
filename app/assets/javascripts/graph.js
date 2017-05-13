$(document).ready(function(){
    // Set up the chart

    var allTables = document.getElementsByClassName("transactions_table");

    tablesNames = [];
    tablesAmounts = []
    for (var i = 0; i < allTables.length; i++) {
        tablesNames.push(allTables[i].children[0].innerHTML);
        tablesAmounts.push(parseFloat(document.getElementsByClassName('big_total')[i].innerHTML.replace('$', '')))
    }

    var chart = new Highcharts.Chart({
        chart: {
            renderTo: 'graph',
            type: 'spline',
            marginRight: 0,
            // marginLeft: 0,
            // plotBorderColor: '#346691',
            // plotBorderWidth: 1

        },
        credits: {
            enabled: false
        },
        navigation: {
            buttonOptions: {
                enabled: false
            }
        },
        legend: {
            enabled: false
        },

        title: {
            text: ''
        },
        subtitle: {
            text: ''
        },
        tooltip: {
            formatter: function () {
                return '<b>$'+this.y.toFixed(2)+'</b>';
            },
            valueDecimals: 2,
            enabled: true
        },
        plotOptions: {
            column: {
                depth: 25
            }
        },
        xAxis: {
            categories: tablesNames
        },
        yAxis: {
            gridLineColor: '#E1E1E1',
            title: {
                text: null
            }
        },
        series: [{
            name: 'Total($)',
            data: tablesAmounts
        }]
    });

});