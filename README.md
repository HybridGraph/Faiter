
# Faiter
Faiter is a fault-tolerant framework for asynchronous iterative computations in cloud environments.

## 1. Introduction
Faiter is a prototype system with simple yet efficient fault-tolerance components for distributed asynchronous iterative computation  engines. Many well-known algorithms are iterative in nature, like PageRank, Penalized Hitting Probability (PHP), and Katz Metric.  Asynchronous  computation model can significantly improve the performance of these algorithms in distributed environments. However, it is challenging  to recover from failures in such a model, since a typical checkpointing based appoach requires many expensive synchronization barriers 
that largely offset the gains of asynchronous computations. 

The built-in fault-tolerant component in Faiter utilizes data on surviving machines to recover data on failed machines, rather than  checkpoints. Additionally, a novel asynchronous checkpointing method is introduced to further boost the recovery efficiency at the price  of nearly zero overhead. Faiter provides simple APIs to facilitate tolerating failures for asynchronous computations. Also, Faiter  performs load balancing on recovery by re-assigning lost data onto multiple machines. 

The Faiter project started at UMASS Amherst in 2015. Faiter is a C++ framework implemented on top of [Maiter](https://code.google.com/archive/p/maiter/). For more details, please refer to our paper [A Fault-Tolerant Framework for Asynchronous
Iterative Computations in Cloud Environments](http://dl.acm.org/citation.cfm?id=2987552) ([Zhigang Wang](https://sites.google.com/site/wzg1210/) and [Lixin Gao](http://www-unix.ecs.umass.edu/~lgao/) et al.). 
 

## 2. Quick Start
Before running Faiter, you need to download [faiter.tar.gz](https://github.com/HybridGraph/Faiter/blob/master/faiter.tar.gz) and deploy it. You can click [here](https://code.google.com/archive/p/maiter/wikis/Guidance.wiki) for help.

PageRank and PHP, are provided as two example algorithms. Before running them, you need to split input data into multiple partitions and assign partitions onto different machines. Click [here](https://code.google.com/archive/p/maiter/wikis/Guidance.wiki) to know how to prepare input data. 

Taking PageRank as example, you can specify the following parameters in "pr.sh" to run it.  
`ALGORITHM=Pagerank  
WORKERS=?  
GRAPH=?  
RESULT=?  
NODES=?  
SNAPSHOT=?  
TERMTHRESH=?  
BUFMSG=?  
PORTION=?  
CKINTERVAL=?  
FAULTTIME=?  
VERTEXNUM=?  
FAILEDWORKERNUM=?  
CASCADING=?`  

Specifically, `CKINTERVAL` indicates the interval between two consecutive asynchronous checkpoints (milliseconds). `CKINTERVAL=-1` means disabling checkpointing. `FAULTTIME` specifies when a failure happens and `FAILEDWORKERNUM` tells the system how many machines will be marked as failed workers. Similarly, `-1` means no failure happens. When `CASCADING=1`, cascading failures will be simulated. When running PHP in `php.sh`, another parameter `SOURCE` is required to set the source vertex id.  

## 3. Programming Guide
Users can also implement their own algorithms.  

### 3.1 Compiling Requirements
* CMake  
* OpenMPI  
* Python  
* gcc/g++
* Protocol Buffers 

### 3.2 Programming on Faiter   
Users can implement their own algorithms by learning built-in examples. Specifically, you first need to create your own `xx.cc` file in the `src/example` directory. After finishing your coding work, add the name of your `xx.cc` file into the CMakeLists.txt file in the same directory.

### 3.3 Building and Running 
Type `build` to run the build.sh shell script in the top level directory of Faiter. Run your algorithm as PageRank but replace the `ALGORITHM` parameter with your algorithm name.

## 4. Contact  
If you encounter any problem with Faiter, please feel free to contact wangzhiganglab@gmail.com.
