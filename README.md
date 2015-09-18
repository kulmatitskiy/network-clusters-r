# network-clusters-r

## Problem

These scripts implement an ad-hoc procedure for maximizing a certain kind of objective function over the space of *final set partitions*.

Suppose there is a set of N elements and a set of G groups, where the groups are labels from 1 to G. A *partition vector* <img src="http://mathurl.com/nl8wvqs.png"> describes group memberships, so <img src="http://mathurl.com/q7a6699.png"> means "element i belongs to group k".

The algorithm is concerned with the maximization of 

<img src="http://mathurl.com/o5d8xov.png">

where 
- <img src="http://mathurl.com/qxavufp.png"> is a partition vector on a set of N elements with some fixed maximum number of groups;
- <img src="http://mathurl.com/qc8yemm.png"> is a symmetric _objective matrix_, where each off-diagonal element <img src="http://mathurl.com/oo2pdnq.png"> represents the gain or loss resulting from putting i and j in the same group.

Think about the search space: it has <img src="http://mathurl.com/o8q3w48.png"> non-equivalent partitions. (Two partitions are equivalent when one of them is a relabelling of the other one.) For example, with 50 nodes and 4 groups the search space has (4^50)/4! ≈ 5.28 · 10^28 partitions, clearly enough to make direct enumeration infeasible in practice. There is no exact feasible algorithm for the optimization problem, and only approximate algorithms are available in practice.

Here I offer a solution that closely resembles the Steepest Descent algorithm for Euclidean search spaces. Given an arbitrary starting partition, I found a comparatively cheap procedure to arrive at a "local maximum" partition from that starting point. I define a _local maximum_ as any partition whose objective value can not be further improved by switching some node to another group. By continuing sequential trials of random starting points, we will obtain a number of local maxima and use this sample to select a partition with the largest objective value. The whole algorithm is thus analogous to the _random start steepest descent_ procedure.

Solution of the general optimization problem for Q becomes useful in the following more specific problems in data analysis.

## Applications in Network Clustering

### Example 1. Maximum Likelihood

Consider a non-directed random network with adjacency matrix X, where each element X_ij is a binary random variable. Suppose the nodes are divides into groups that we do not observe, say <img src="http://mathurl.com/nl8wvqs.png">, but we know that edge probabilities depend on these groups as follows:

<img src="http://mathurl.com/p9hdfwq.png">

Suppose also that edge variables are all independent of each other, and that our model contains no additional unknown parameters. Our task is to "estimate" <img src="http://mathurl.com/nl8wvqs.png">, i.e., to recover the unknown groups using only the observed connections <img src="http://mathurl.com/paunmrx.png"> between network nodes.

Then the log-likelihood function boils down to

<img src="http://mathurl.com/novk74s.png">

where

<img src="http://mathurl.com/nt5e68k.png">

so likelihood maximization is equivalent to maximizing Q(g), allowing us to use the steepest ascent algorithm.

### Example 2. Network Modularity

Again consider a non-directed random network as before, but this time suppose that there is a "*null model*" that defines independent edge probabilities *in absence of any groups*:

<img src="http://mathurl.com/q6l32zt.png">

Now suppose that we *do* have groups, which are unknown, and we observe connections <img src="http://mathurl.com/paunmrx.png"> between network nodes that were generated in presence of groups under some model other than the null model. An ad-hoc approach to recovering these groups works by maximizing *Modularity* function:

<img src="http://mathurl.com/p7os7ht.png">

which is the difference between the observed number of within-group links and their expected number under the null model.

