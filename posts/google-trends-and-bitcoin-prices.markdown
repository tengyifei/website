---
title: Google trends and Bitcoin prices
published: 2014-02-26T13:21:20Z
categories: Computer Science,Cryptocurrencies,Mathematics
tags: Bitcoin,correlation,data mining,Google Trends,search engine
---

Google Trends is a powerful data mining tool with applications ranging from detecting flu outbreaks to predicting fashion. Today I played around with Google Trends, and discovered an interesting correlation between the number of search engine queries on Bitcoin and its price in major exchanges. Not surprisingly, the rise in value in April and November was closely matched with a rise in interest in Bitcoin. But during the second rally, the change in search volume actually _predates_ any change in price by a few days. Maybe this could be exploited to make some form of prediction on Bitcoin prices. 

<div id="chart_div_bitcoin" style="width: 100%; height: 400px;">
<div style="text-align: center; margin-top: 100px; font-size: 25px; color: #bbb;">Loading chart data...</div>
</div>

Data was generated from Google Trends and custom bitcoin trade history.

<script type="text/javascript">(function($) {
	$(document).ready(function() {
		$.ajax({
	    url: '//www.google.com/jsapi',
	    dataType: 'script',
	    cache: true,
	    success: function() {
	        google.load('visualization', '1', {
	            'packages': ['corechart'],
	            'callback': drawChart_bitcoin
	        });
	    }
	});
      function drawChart_bitcoin() {
        var data = google.visualization.arrayToDataTable([
          ['Date', 'Search', 'Price over 4 months average'],
          ['15-Jan-13',4,1.072138941],
['22-Jan-13',4,1.228738014],
['29-Jan-13',5,1.372725977],
['5-Feb-13',5,1.50002322],
['12-Feb-13',3,1.761816789],
['19-Feb-13',5,1.969703472],
['26-Feb-13',7,1.984462424],
['5-Mar-13',9,2.1645508],
['12-Mar-13',10,2.634932663],
['19-Mar-13',15,2.410381284],
['26-Mar-13',23,3.032076471],
['2-Apr-13',37,3.8097094],
['9-Apr-13',70,4.890539245],
['16-Apr-13',38,2.476810257],
['23-Apr-13',23,3.109472441],
['30-Apr-13',21,2.692636086],
['7-May-13',17,2.06283857],
['14-May-13',16,1.929549902],
['21-May-13',14,1.783111111],
['28-May-13',14,1.799674267],
['4-Jun-13',11,1.635346756],
['11-Jun-13',12,1.288766368],
['18-Jun-13',10,1.094278283],
['25-Jun-13',11,1.055900621],
['2-Jul-13',14,0.88994646],
['9-Jul-13',10,0.646685879],
['16-Jul-13',9,0.890660592],
['23-Jul-13',9,0.801886792],
['30-Jul-13',10,0.820625343],
['6-Aug-13',10,0.897196262],
['13-Aug-13',12,0.900789177],
['20-Aug-13',12,0.956130484],
['27-Aug-13',11,1.067961165],
['3-Sep-13',9,1.255626082],
['10-Sep-13',9,1.166380789],
['17-Sep-13',8,1.212207644],
['24-Sep-13',9,1.197727273],
['1-Oct-13',16,1.230900798],
['8-Oct-13',12,1.183789954],
['15-Oct-13',11,1.233560091],
['22-Oct-13',14,1.573898494],
['29-Oct-13',34,1.646046261],
['5-Nov-13',31,1.786263455],
['12-Nov-13',34,2.773684211],
['19-Nov-13',80,3.525010688],
['26-Nov-13',100,5.145308507],
['3-Dec-13',96,5.471264368],
['10-Dec-13',67,2.830817052],
['17-Dec-13',69,2.800387597],
['24-Dec-13',44,1.711505922],
['31-Dec-13',36,1.900703675],
['7-Jan-14',44,2.018476081],
['14-Jan-14',41,1.978286309],
['21-Jan-14',42,1.627467202],
['28-Jan-14',41,1.499836012],
['4-Feb-14',36,1.406431261],
['11-Feb-14',44,1.099068264],
['18-Feb-14',34,1.007407407],
['25-Feb-14',34,0.898529412]]);var options = {
          title: 'Bitcoin price & Bitcoin search index',
		chartArea:{top:20,width:"80%",height:"80%"},
		  series:{0:{targetAxisIndex:0}},
		  series:{1:{targetAxisIndex:1}},
		  vAxes:{0:{},1:{maxValue:'5.0'}}
        };
var element = document.getElementById('chart_div_bitcoin');
if (element!=null){
        var chart = new google.visualization.LineChart(element);
        chart.draw(data, options);}
      }
});})(jQuery);</script>
