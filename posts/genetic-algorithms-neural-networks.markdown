---
title: Training neural networks: back-propagation vs. genetic algorithms
published: 2014-03-09T07:02:21Z
categories: Computer Science,Mathematics
tags: artificial intelligence,back propagation,genetic algorithm,neural network
---

One of the most endemic problem of using back propagation in training artificial neural networks is that the algorithm does not guarantee finding a global minimum i.e. a network whose weights produce the lowest classification error among all possible combinations and values of weights. This is because back propagation treats learning as an optimization problem, and uses [gradient descent](http://en.wikipedia.org/wiki/Gradient_descent "Gradient descent") to (hopefully) approximate the best solution. But gradient descent has inherent limitations that prevent this from happening. 

![Gradient descent stuck at local minima](https://static.thinkingandcomputing.com/2014/03/bprop.png)

Referring to the figure above, if the starting point for gradient descent was chosen inappropriately, more iterations of the algorithm will only make it approach a local minimum, never reaching the global one.

Therefore, back propagation is only a local optimization algorithm. To genuinely find the best neural network, one would have to use a global optimization algorithm, one that has the potential to traverse the entire search space, while remaining time-efficient.

One of the algorithms vaunted for this property is genetic algorithm (GA). It attempts to apply the principles of natural selection on a population of candidates, performing sporadic random mutation, crossing over values from stronger parents to produce child generations and eliminating weak candidates. In the case of neural networks, the output error can act as a measure of candidate strength. The assumption is that if two parents are "strong", or producing low error, the child generated using a mixture of traits from each parent should also be strong, perhaps even stronger. This allows GA to fine-tune its search space, focusing only on regions likely to have minima. 

![Example of crossover operation in genetic algorithm](https://static.thinkingandcomputing.com/2014/03/crossover.png)

In the picture above, each bit in the child text is taken randomly from a parent, resulting in a mixture of features thus laying out new directions for search based on intuition. 

However, GA is not the panacea when it comes to mathematical optimization. The assumption of children being roughly as efficient as their parents does not always hold. Consider the proof-of-work used in the Bitcoin protocol: finding an input to the SHA-256 function for which the output is lower than a specified target. Genetic optimization cannot be applied to accelerate the process because of the avalanche effect. The SHA-265 function is simply too nonlinear for GA to optimize. Two parent inputs whose corresponding outputs are close to the target, when crossed, will more often than not result in children with seemingly random outputs.

Similarly, a formidable problem surfaces when GA is used to train neural networks. Due to their unique structure, neural networks may not retain their performance when undergone the cross-over operation. Two networks may have different internal structures, but still give identical outputs. See illustration below: 

![Two neural networks](https://static.thinkingandcomputing.com/2014/03/nn.png)

The two networks are essentially mirror reflections of each other, hence produce the same output. But if the cross-over operation is applied, the behavior of the resulting neural network will deviate significantly from that of the parents. Since GA is unaware of the internal structures of the two networks, it will combine weights belonging to nodes of different roles. Hence two superior networks of different structure, when crossed, may result in offspring performing poorly.

The crux of the problem lies in the encoding method for neural networks. Network weights are generally stored based on a fixed indexing scheme: nodes are numbered sequentially, laterally regardless of their significance and impact on the next layer. This causes GA to confuse nodes of different roles. Until an intelligent approach to determine nodes of similar roles is devised and the corresponding role-based encoding method used, the efficacy of GA in training neural networks will be much limited. The method must give the same encoded result for both network A and B above, since they are, after all, functionally identical networks.
