---
title: Indiscriminate crossover in genetic algorithm is bad
published: 2014-04-17T12:52:55Z
categories: Computer Science,Mathematics
tags: artificial intelligence,genetic algorithm,Optimization
---

It is quite well-established that the crossover operator in genetic algorithm (GA), albeit vital for opening doors to new search spaces, also suffers from a myriad of problems. [When chromosomes are ordered](http://en.wikipedia.org/wiki/Crossover_(genetic_algorithm)#Crossover_for_Ordered_Chromosomes), crossing over may disrupt existing order thus necessitating additional repairing. In a previous [post](http://www.thinkingandcomputing.com/2014/03/09/genetic-algorithms-neural-networks/ "Training neural networks: back-propagation vs. genetic algorithms"), I also discussed an issue where crossover is possibly detrimental when the chromosome has complex internal structures. This time, I am going to explore another potential source of pitfall, and try to propose a solution.

## The existence of sub-populations

Let's consider the largest counterpart to genetic algorithm: Nature. By the principle of survival of the fittest, life has evolved over eons leading to theoretically a very fit population. But paradoxically, instead of converging to a single optimum where near uniform entities overwhelm our planet (no, humans have yet to fall into this category), earth's life forms are surprisingly diverse. Each specie is exceedingly adept at surviving in their own niche. There is life that thrives at the [boiling heat](http://www.genomenewsnetwork.org/articles/08_03/hottest.shtml) of deep-sea vents, and at [freezing temperatures](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1456908/) around Arctic ice. In the realm of mathematical optimization, those species can be viewed as candidates congregating at various local minima in the search space of the fittest individual. Since in nature combining genomes from disparate species rarely result in viable life form, much less a fitter one, it could be surmised that the crossover operation in genetic algorithm is subject to similar restrictions. When the crossover operation is applied to two highly different candidates, the resulting chromosome could be completely nonsensical, and quickly eliminated after a few generations. This defeats the purpose of crossing over, which attempts to mix features from fit parents to get fitter offspring.

As an example, suppose GA is used to find an optimum of this fitness function:

![f(x,y)=-sin(x)sin(y)](https://static.thinkingandcomputing.com/2014/04/fitnessfunc.png)

This is a two-parameter function, hence GA is locating the highest points in two-dimensional space. Here's the 3D plot:

![3D plot of the search space](https://static.thinkingandcomputing.com/2014/04/3dplot.png)
<tnc-caption>3D plot of the search space</tnc-caption>

And the contour plot:

![Contour plot](https://static.thinkingandcomputing.com/2014/04/contour.png)
<tnc-caption>Contour plot</tnc-caption>

It is apparent that the two optimum points lie in the middle of area 1 and 4 respectively. However, they actually belong to different sub-populations. A crossover operation on points taken from both area 1 and area 4 will result in a point that lies in area 2 or 3, which has low fitness scores. E.g. point [1.5, 4.5] combined with [4.0, 1.0] will either yield [1.5, 1.0] (in area 3) or [4.0, 4.5] (in area 2). This shows that crossover operation on different species, or sub-populations, has the potential to produce low-performing offspring. Crossover done on points from the same sub-population, on the other hand, does not pose this issue. E.g. [0.5, 5.0] combined with [0.8, 5.6] may give [0.5, 5.6], which still has a pretty high fitness score.

In fact, if the population is uniformly distributed over the search space, each crossover operation has 12.5% probability of generating poor offspring from superior parents. This probability soon skyrockets to 50% as the population starts to converge to the two areas of high fitness. _This means that half of the computational effort is wasted evaluating and eliminating poor candidates that shouldn't have been generated in the first place!_

## Curse of dimensionality

The situation quickly deteriorates as the number of dimensions increases. Consider the following scenario: the search space is an N-dimension space and candidates are N-element vectors whose values are to be optimized. The fitness function is set to be:

![fitness function that thwarts crossover operation](https://static.thinkingandcomputing.com/2014/04/fitnessfunc2.png)

where **A<sub>i</sub> **represents the i-th element in the candidate vector **A**. The function evaluates the square difference between components of the vector. Hence the optimal solution is an hyper-ridge where all components have the same value ([1,1,1], [2,2,2] etc.).

Here the crossover operation becomes increasingly an impediment to the progress of search as dimensionality increases. I produced a graph of number of steps required to reach a fairly optimal solution (fitness > -0.1) against number of dimensions:

<div id="chart_div_ga" style="width: 100%; height: 400px;">
<div style="text-align: center; margin-top: 100px; font-size: 25px; color: #bbb;">Loading chart data...</div>
</div>

From the graph, it can be seen that initially pure mutation combine with crossover has the upper hand given the additional diversity it provides, but as number of dimensions increases, crossover became increasingly susceptible to producing inferior offspring. The population is replete with unfit candidates produced by crossing over parents from incompatible sub-population, hence greatly reducing the possibility of any candidate accidentally stumbling upon an optimum solution via mutation.

## A patch to crossover?

Now that it is clear that applying crossover indiscriminately is detrimental to genetic search, is there any way to prevent this, or to regulate crossover? By again looking to nature, from which the inspiration for GA is originally obtained, I could think of a rough idea: clustering. Just like different species in nature never mate, you don't want to apply crossover to candidates from different sub-populations. One way to identify the sub-populations is to run a clustering algorithm on the candidate vectors, possibly putting candidates with small Euclidean distance to one another other into one category, after which crossover is only performed on candidates from the same category. But this introduces more parameters (e.g. cut-off point for distance) into the optimization processes, which necessitates more tuning. A cluster too uniform would be useless since no new elements can ever be introduced by crossing over near identical ones. A cluster too diverse may again pose unnecessary risks of producing individuals of low fitness.

A self-organizing clustering process would be nice. Specifically, instead of pessimistically assuming that objects belonging to different clusters do not play well, it is better to perform a random sampling over the results of crossover applied to candidates from two clusters, thus giving a rough estimate of the two clusters' compatibility with each other. A graph of compatibility relationships can be established, and clusters deemed compatible by experimentation can now be merged into one larger cluster, from which elements will be selected for crossover. This effectively prevents indiscriminate crossover to a large extent, while preserving population diversity.


<script>
    (function($) {
        $(document).ready(function() {
            $.ajax({
                url: 'https://www.google.com/jsapi',
                dataType: 'script',
                cache: true,
                success: function() {
                    google.load('visualization', '1', {
                        'packages': ['corechart'],
                        'callback': drawChart_ga
                    });
                }
            });

            function drawChart_ga() {
                var data = google.visualization.arrayToDataTable([
                    ['No. of generations', 'Pure mutation', 'Mutation and crossover'],
                    [3, 1.5389, 1.0323],
                    [4, 7.1272, 4.3926],
                    [5, 16.2939, 6.7637],
                    [6, 28.6837, 14.163],
                    [7, 43.9577, 17.9678],
                    [8, 61.8785, 31.5875],
                    [9, 82.7208, 40.4289],
                    [10, 105.0521, 63.1757],
                    [11, 134.6292, 86.248],
                    [12, 173.567, 147.4628],
                    [13, 252.837, 306.409],
                    [14, 485.7979, 979.7617],
                    [15, 1440.0362, 4425.6],
                    [16, 6271.737, 27649.39],
                    [17, 29337, 147234.82],
                    [18, 223059.07, 904293.99]
                ]);
                var options = {
                    title: 'Pure mutation vs. with crossover (NB: log scale in y-axis)',
                    chartArea: {
                        left: 50,
                        width: "70%",
                        height: "85%"
                    },
                    hAxis: {
                        title: 'No. of dimensions'
                    },
                    vAxis: {
                        minValue: 0,
                        viewWindowMode: 'maximized',
                        logScale: true
                    },
                };
                var chart = new google.visualization.LineChart(document.getElementById('chart_div_ga'));
                chart.draw(data, options);
            }
        });
    })(jQuery);
</script>
