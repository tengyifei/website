---
title: Answer range minimum queries using augmented red-black trees
published: 2014-05-22T14:18:28Z
categories: Computer Science,Mathematics
tags: algorithms
featured: true
---

Is learning how algorithms work useful in daily computer programming? Some might argue that this is no longer the case, given the plethora of packaged libraries readily available providing battle-tested algorithm implementations. But I always believe learning to write efficient algorithms is still important, because existing libraries will inevitably fall short of one's needs.

## Background

In the technical analysis on financial markets, a common building block for indicators is the minimum and maximum value of price over various chosen time windows. The _Ultimate Oscillator_, for example, requires information about the maximum and minimum over up to 28 periods. When I was writing code to perform this operation, I initially used the most straight-forward approach: scan the series of prices, and update the min/max values if necessary. While acceptable for a small data set, this method is too slow in practice. I was processing prices generated at one minute intervals, which translates to hundreds of thousands of comparisons per price, and I had to repeat this 1440 times a day, 365 days a year!

This type of operation is generally known as Range Minimum Query (RMQ), i.e. finding the minimum over a given range. There exist algorithms that can solve it with time complexity O(log n), namely segment trees. Unfortunately, most implementations of segment trees online do not support insertion/deletion of values, and thus won't be applicable to my situation. The only way was to devise a custom data structure that is dynamic yet can complete the query in O(log n) time.

I started to look at the different interpretations of segment tree. A segment tree is roughly a structure that represents data ranges, although the details as to how ranges are partitioned vary greatly. [PEGWiki's version](http://wcipeg.com/wiki/Segment_tree) depicts the segment tree as a fully balanced binary tree, where for every parent node with closed range [R<sub>1</sub>, R<sub>2</sub>], the left and right child will correspond to range [R<sub>1</sub>, floor((R<sub>2</sub>-1)/2)] and [floor((R<sub>2</sub>-1)/2)+1, R<sub>2</sub>] respectively. This results in a split at approximately the center of each range.

![Example segment tree. Each node assigned an interval.](https://static.thinkingandcomputing.com/2014/05/segment_tree.png)
<tnc-caption>Example segment tree. Each node assigned an interval.</tnc-caption>

The advantage of this construct is that it can be nicely packed into an array by storing it as the result of a breadth-first-traversal. The index of the left child node is simply that of parent multiplied by two. However, the drawback is that the position and range of nodes cannot be modified once the tree is created.

## Binary search trees as segment trees

Is there another way to achieve this? After thorough deliberation it turns out that the answer is positive. All ordered binary trees i.e. those whose node's key is bigger than those in the left sub-tree and smaller than those in the right sub-tree, actually boasts properties very similar to segment trees. Consider the tree below as an example:

[![Binary search tree with ranges labeled](https://static.thinkingandcomputing.com/2014/05/btree.png)
<tnc-caption>Binary search tree with ranges labeled</tnc-caption>

The interesting effect here is that as one traverses down the tree, the range of keys possible at each sub-tree is repeatedly constrained. There is no requirement for keys belonging to the sub-tree rooted at 9, but all keys within the sub-tree rooted at 3 must fall in the open interval (-∞, 9), due to the sorted nature of binary search trees. Similarly, the range reduces further to (3, 9) for keys under the sub-tree rooted at 6\. We can now see that the lower bound and upper bound corresponding to a particular node can be given as the nearest node above it whose key is smaller/greater than the current node, respectively.

If we were to follow PEGWiki's definition of what constitutes a segment tree, then all binary search trees can be classified as segment trees, since each node can be assigned a precise interval within which all keys in the sub-tree rooted at this node will fall.

## Augmenting red-black trees to perform range minimum query

 With this in mind, modifying an existing balanced binary tree implementation to support range minimum query becomes a trivial task. Suppose each node carries information about the child with minimum value. The logic to get the minimum value in a range can be written as follows:

If the interval corresponding to current node is contained within the given range,

*   Update the global minimum value, incorporating the minimum contained in this node

Otherwise,

*   Let the range be [R<sub>1</sub>, R<sub>2</sub>], and the key of current node be K<sub>c</sub>
*   If K<sub>c</sub> is within [R<sub>1</sub>, R<sub>2</sub>], update the global minimum with the value held by this node
*   If [R<sub>1</sub>, min(R<sub>2</sub>, K<sub>c</sub>)) ≠ ∅, repeat the operation on the interval [R<sub>1</sub>, min(R<sub>2</sub>, K<sub>c</sub>)).
*   If (max(K<sub>c</sub>, R<sub>1</sub>), R<sub>2</sub>] ≠ ∅, repeat the operation on the interval (max(K<sub>c</sub>, R<sub>1</sub>), R<sub>2</sub>].

We can view the step of using minimum value contained in a node as a form of pruning the search tree, since it effectively eliminates any redundant queries. On the other hand, if the interval is not a strict subset of the query range, the "cached" minimum value cannot be used since it may actually refer to a node that is outside of the query range.

Pseudo code:

Evaluate range minimum using augmented RB-tree
```java
void getMin(K start, K end, Entry <k, v>node, K lbound, K rbound) {
    if (lbound >= start && rbound <= end) {
        updateMin(node.min.value);
    } else {
        if (node.key >= start && node.key <= end)
            updateMin(node.value);

        K rsub = null;
        if (node.key < end)
            rsub = node.key;
        else
            rsub = end;
        if (rsub > start)
            if (node.left != null)
                getMin(start, rsub, node.left, lbound, node.key);

        K lsub = null;
        if (node.key > start)
            lsub = node.key;
        else
            lsub = start;
        if (lsub < end)
            if (node.right != null)
                getMin(lsub, end, node.right, node.key, rbound);
    }
}
```

While this may seem straight-forward, the troublesome part remains: how to maintain the minimum value at each node? How to handle situations such as insertion, deletion and tree rotation? I will give a rough explanation below:

### Node insertion/update

Obviously, we will have to update the minimum value cache at the current node. If the node is just inserted, the minimum value will point to the node itself, otherwise it will be re-evaluated based on the node's present value and the minimum value cache of the node's two children. Then, we can recursively traverse the tree upwards, and rectify one of the two situations:

1.  Is the present value smaller than the minimum value contained in the node? If yes, update the minimum value.
2.  Is the node's minimum value referring to the old value, which is now replaced by the present value that is no longer the minimum? If yes, we have to re-evaluate the minimum using the same above-mentioned procedure.

Pseudo code:

```java
while ((curr = curr.parent) != null) {
    if (targetValue < curr.min.value)
        curr.min = target;
    else if (curr.min.equals(target)) {
        curr.min = min(curr, (curr.left != null) ? curr.left.min : null,
                (curr.right != null) ? curr.right.min : null);
    } else
        break;
}
```

###  Node deletion

When a node is removed, we have to re-evaluate all parents' minimum value if they point to that node:

```java
while ((node = node.parent) != null) {
    if (node.min.equals(target)) {
        node.min = min(node, (node.left != null) ? node.left.min : null,
                (node.right != null) ? node.right.min : null);
    } else
        break;
}
```

### Tree rotation

This part is a little bit tricky. But it can be shown that only the minimum value within node P and Q will have to be re-evaluated, and that the correct sequence to update them is to process the parent node first i.e. Q during clockwise rotation and P during anti-clockwise rotation.

![Tree rotation](http://upload.wikimedia.org/wikipedia/commons/2/23/Tree_rotation.png)
<tnc-caption>Tree rotation. Image credit Wikipedia.</tnc-caption>

After switching to the new algorithm, the analysis speed on financial data improved at least by a factor of 100\. This certainly demonstrates how vital a good algorithm can be to a program.
