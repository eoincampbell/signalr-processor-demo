<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="SignalrProcessorDemo.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>

    <script type="text/javascript" src="/Signalr/Scripts/jquery-1.6.4.js"></script>
    <script type="text/javascript" src="/Signalr/Scripts/jquery.signalR-1.1.0-beta1.js"></script>
    <%--<script type="text/javascript" src="/Scripts/jquery.color.js"></script>--%>
    <%--<script language="javascript" type="text/javascript" src="/Scripts/exporting.js"></script>--%>
    <script language="javascript" type="text/javascript" src="/Signalr/Scripts/HighCharts.1.0.0/highcharts.js"></script>
    <script type="text/javascript" src="/Signalr/signalr/hubs"></script>
        <script type="text/javascript">
            $(function () {
                var ticker = $.connection.processorTicker;

                Highcharts.setOptions({
                    global: {
                        useUTC: false
                    }
                });

                var chart;
                chart = new Highcharts.Chart({
                    chart: {
                        renderTo: 'container',
                        type: 'spline',
                        marginRight: 10
                        //                    ,
                        //                    events: {
                        //                        load: function () {

                        //                            // set up the updating of the chart each second
                        //                            var series = this.series[0];
                        //                            setInterval(function () {
                        //                                var x = (new Date()).getTime(), // current time
                        //                                y = Math.random();
                        //                                series.addPoint([x, y], true, true);
                        //                            }, 1000);
                        //                        }
                        //                    }
                    },
                    title: {
                        text: 'Live CPU Processor Data'
                    },
                    xAxis: {
                        type: 'datetime',
                        tickPixelInterval: 100
                    },
                    yAxis: {
                        title: {
                            text: 'CPU Usage %'
                        },
                        plotLines: [{
                            value: 0,
                            width: 1,
                            color: '#FF0000'
                        }]
                    },
                    tooltip: {
                        formatter: function () {
                            return '<b>' + this.series.name + '</b><br/>' +
                            Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + '<br/>' +
                            Highcharts.numberFormat(this.y, 2);
                        }
                    },
                    legend: {
                        enabled: false
                    },
                    exporting: {
                        enabled: false
                    },
                    series: [{
                        name: 'CPU Usage',
                        color: '#FF0000',
                        data: (function () {
                            // generate an array of random data
                            var data = [],
                            time = (new Date()).getTime(),
                            i;

                            for (i = -19; i <= 0; i++) {
                                data.push({
                                    x: time + i * 1000,
                                    y: 0
                                });
                            }
                            return data;
                        })()
                    }]
                });

                ticker.client.updateCpuUsage = function (percentage) {
                    $("#processorTicker").text("" + percentage + "%");

                    var x = (new Date()).getTime(), // current time
                        y = percentage,
                        series = chart.series[0];

                    series.addPoint([x, y], true, true);
                };

                // Start the connection
                $.connection.hub.start(function () {
                    //alert('Started');
                });

                // Wire up the buttons
                $("#start").click(function () {
                    ticker.server.start();
                });
            });
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    <input type="button" id="start" value="Start Ticker" />
    <br/>
    <span id="processorTicker" style="font-family: Calibri">
        
    </span>
    
    <div id="container" style="min-width: 400px; height: 400px; margin: 0 auto"></div>

    </div>
    </form>
    

    
    </body>
</html>
