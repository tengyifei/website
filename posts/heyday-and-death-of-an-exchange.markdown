---
title: Heyday and death of an exchange
published: 2014-04-05T16:14:54Z
categories: Computer Science,Cryptocurrencies
tags: Bitcoin,data mining
---

<script type="text/javascript">// <![CDATA[
(function($) {
$(document).ready(function() {
	$.ajax({
    url: '//www.google.com/jsapi',
    dataType: 'script',
    cache: true,
    success: function() {
        google.load('visualization', '1', {
            'packages': ['corechart'],
            'callback': drawChart_exchange
        });
    }
});
function drawChart_exchange() {
         var data = google.visualization.arrayToDataTable([
          ['Date', 'Mt.Gox', 'BTC-E', 'Bitfinex', 'Bitstamp', 'BTC China', 'Others'],
['01/06/2012', 81.15, 9.85, 0.00, 1.48, 1.17, 6.36],
['11/06/2012', 83.05, 8.10, 0.00, 3.62, 0.75, 4.49],
['21/06/2012', 78.32, 8.92, 0.00, 6.15, 0.83, 5.78],
['01/07/2012', 80.28, 9.08, 0.00, 2.71, 1.08, 6.85],
['11/07/2012', 90.42, 3.74, 0.00, 2.07, 0.78, 3.00],
['21/07/2012', 91.31, 4.45, 0.00, 2.54, 1.66, 0.03],
['31/07/2012', 89.77, 5.99, 0.00, 2.56, 1.49, 0.19],
['10/08/2012', 90.98, 4.74, 0.00, 2.49, 1.58, 0.20],
['20/08/2012', 90.32, 3.64, 0.00, 3.90, 1.88, 0.26],
['30/08/2012', 89.02, 4.76, 0.00, 4.11, 1.91, 0.20],
['09/09/2012', 85.80, 6.80, 0.00, 5.15, 1.63, 0.62],
['19/09/2012', 83.60, 8.04, 0.00, 5.81, 2.27, 0.28],
['29/09/2012', 83.06, 8.89, 0.00, 6.40, 1.45, 0.20],
['09/10/2012', 84.12, 8.96, 0.00, 5.39, 1.27, 0.26],
['19/10/2012', 86.15, 6.64, 0.00, 5.95, 1.02, 0.24],
['29/10/2012', 78.82, 12.05, 0.00, 7.85, 1.05, 0.23],
['08/11/2012', 79.39, 11.03, 0.00, 6.92, 2.25, 0.42],
['18/11/2012', 79.65, 8.45, 0.00, 9.80, 1.82, 0.28],
['28/11/2012', 80.09, 7.66, 0.00, 9.79, 2.23, 0.23],
['08/12/2012', 83.92, 5.13, 0.00, 8.20, 2.43, 0.32],
['18/12/2012', 80.79, 8.60, 0.00, 8.76, 1.46, 0.38],
['28/12/2012', 83.23, 7.00, 0.00, 7.77, 1.73, 0.26],
['07/01/2013', 84.03, 5.19, 0.00, 8.84, 1.57, 0.37],
['17/01/2013', 85.29, 5.27, 0.00, 6.94, 2.23, 0.28],
['27/01/2013', 85.90, 5.48, 0.00, 6.04, 2.08, 0.49],
['06/02/2013', 86.62, 4.39, 0.00, 6.33, 1.99, 0.68],
['16/02/2013', 83.70, 3.94, 0.00, 7.57, 3.67, 1.11],
['26/02/2013', 83.64, 3.83, 0.00, 7.25, 4.17, 1.12],
['08/03/2013', 82.78, 5.32, 0.00, 5.74, 4.85, 1.31],
['18/03/2013', 80.68, 4.96, 0.00, 7.40, 5.39, 1.57],
['28/03/2013', 74.41, 7.42, 3.93, 6.34, 5.80, 2.11],
['07/04/2013', 72.90, 10.93, 5.43, 6.07, 4.19, 0.47],
['17/04/2013', 70.91, 8.98, 6.29, 7.14, 5.88, 0.81],
['27/04/2013', 68.39, 9.33, 8.93, 7.80, 5.13, 0.42],
['07/05/2013', 69.01, 7.89, 7.53, 9.01, 5.86, 0.69],
['17/05/2013', 61.64, 8.90, 6.64, 14.52, 7.25, 1.05],
['27/05/2013', 61.15, 7.60, 8.17, 15.80, 6.41, 0.87],
['06/06/2013', 60.80, 8.41, 8.24, 14.97, 6.82, 0.77],
['16/06/2013', 63.92, 9.44, 6.13, 13.07, 6.55, 0.88],
['26/06/2013', 55.87, 9.82, 7.50, 19.37, 6.60, 0.83],
['06/07/2013', 53.87, 8.52, 9.06, 19.06, 8.80, 0.69],
['16/07/2013', 49.96, 7.87, 7.33, 23.36, 10.67, 0.81],
['26/07/2013', 51.75, 8.82, 7.17, 20.71, 10.52, 1.03],
['05/08/2013', 46.32, 8.98, 9.38, 27.09, 6.87, 1.36],
['15/08/2013', 46.49, 6.96, 9.34, 26.26, 9.72, 1.23],
['25/08/2013', 43.06, 7.55, 12.07, 26.38, 9.39, 1.55],
['04/09/2013', 41.04, 9.01, 11.22, 29.15, 8.33, 1.25],
['14/09/2013', 34.86, 14.09, 10.32, 32.84, 6.30, 1.58],
['24/09/2013', 41.90, 9.42, 12.07, 27.17, 8.25, 1.19],
['04/10/2013', 26.49, 12.28, 9.92, 28.25, 22.47, 0.59],
['14/10/2013', 25.29, 16.48, 11.33, 22.36, 23.71, 0.82],
['24/10/2013', 22.85, 18.23, 12.81, 21.29, 24.54, 0.28],
['03/11/2013', 22.68, 13.02, 12.23, 20.89, 30.30, 0.89],
['13/11/2013', 21.90, 17.38, 8.50, 18.22, 33.04, 0.96],
['23/11/2013', 20.29, 17.20, 7.05, 16.81, 38.01, 0.64],
['03/12/2013', 17.04, 18.84, 8.27, 16.19, 39.12, 0.55],
['13/12/2013', 16.67, 23.38, 12.55, 20.52, 26.41, 0.47],
['23/12/2013', 22.87, 25.47, 16.26, 23.61, 11.15, 0.65],
['02/01/2014', 17.40, 24.77, 17.97, 24.42, 14.69, 0.76],
['12/01/2014', 18.09, 25.08, 17.23, 26.28, 12.54, 0.78],
['22/01/2014', 14.66, 23.22, 16.85, 27.87, 16.78, 0.62],
['01/02/2014', 22.63, 18.69, 20.17, 29.63, 8.28, 0.60],
['11/02/2014', 39.10, 14.78, 16.20, 21.89, 7.54, 0.50],
['21/02/2014', 41.95, 13.57, 16.01, 21.23, 6.88, 0.37],
['03/03/2014', 0.00, 19.98, 29.00, 36.89, 13.20, 0.94],
['13/03/2014', 0.00, 18.05, 25.40, 40.93, 14.24, 1.38],
['23/03/2014', 0.00, 14.44, 32.29, 40.37, 12.30, 0.59]
        ]);

        var options = {
          title: 'Market share as percentage',
	chartArea:{left:31,top:20,width:"78%",height:"75%"},
          hAxis: {titleTextStyle: {color: '#333'}, maxAlternation:1, showTextEvery:5, slantedText:true, slantedTextAngle:38},
          vAxis: {minValue: 0, viewWindowMode:'maximized'}, isStacked: true
        };
var element = document.getElementById('chart_div_exchange');
if (element!=null){
        var chart = new google.visualization.AreaChart(element);
        chart.draw(data, options);}
      }
	  });})(jQuery);
// ]]></script>

Mt. Gox used to be the largest bitcoin exchange: back in 2012 it handled about 90% of the total transactions in the network. But now the exchange is no more. After filing for bankruptcy in February, Mt. Gox only have a few bleak statements on its website as remnants of its past glory.

I used the trade volume data from major Bitcoin exchanges to plot the following graph. By programmatically summing all trades over a sliding window of 5 days for each exchange, I created a graph as a good reflection of their popularity. It was like performing a post mortem on Mt. Gox, except that the scalpel is data mining.

<div id="chart_div_exchange" style="width: 100%; height: 400px;">
<div style="text-align: center; margin-top: 100px; font-size: 25px; color: #bbb;">Loading chart data...</div>
</div>

The gradual but inevitable disappearance of Mt. Gox can be clearly seen from the volume charts. What used to be the monopolizing party in Bitcoin transaction ended in a wave of panic selling and endless civil lawsuit. By February, Mt. Gox was already operating beyond its limits. As rumors regarding possible insolvency spread, users started to frantically sell Bitcoin to save their investment, causing its price to plunge. This quickly escalated into a vicious cycle as other users, upon witnessing the price drop coupled with low credibility of Mt. Gox, expected it to close down, which prompted more selling. Within days the price of Bitcoin fell to barely $100, while on other exchanges prices were still fluctuating around $600\. Unable to sustain the unprecedented withdrawal, Mt. Gox was forced to shut down its website, hours after the final price dip.

[![Price drops to $100 in 15 days](//static.thinkingandcomputing.com/2014/04/goxchart_s.png)
<tnc-caption>Hyperdeflation</tnc-caption>

However, long before its demise, Mt. Gox had been losing customers steadily. This can be primarily attributed to poor management, loose security measures and rough relationships with banks providing fiat currency withdrawal.

Graph generated using data from [bitcoincharts.com](http://bitcoincharts.com/)
