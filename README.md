
#Faiter
Faiter is a fault-tolerant framework for asynchronous iterative computations in cloud environments.

##1. Introduction
Faiter is a prototype system with simple yet efficient fault-tolerance components for distributed asynchronous iterative computation  engines. Many well-known algorithms are iterative in nature, like PageRank, Penalized Hitting Probability, and Katz Metric. Asynchronous  computation model can significantly improve the performance of these algorithms in distributed environments. However, it is challenging  to recover from failures in such a model, since a typical checkpointing based appoach requires many expensive synchronization barriers 
that largely offset the gains of asynchronous computations. 

The built-in fault-tolerant component in Faiter utilizes data on surviving machines to recover data on failed machines, rather than  checkpoints. Additionally, a novel asynchronous checkpointing method is introduced to further boost the recovery efficiency at the price  of nearly zero overhead. Faiter provides simple APIs to facilitate tolerating failures for asynchronous computations. Also, Faiter  performs load balancing on recovery by re-assigning lost data onto multiple machines. 

The Faiter project started at UMASS Amherst in 2015. Faiter is a C++ framework implemented on top of [Maiter](https://code.google.com/archive/p/maiter/).
 

##2. Quick Start
This section describes how to configurate, compile and then deploy HybridGraph on a cluster consisting of three physical machines running Red Hat Enterprise Linux 6.4 32/64 bit (one master and two slaves/workers, called `master`, `slave1`, and `slave2`). Before that, Apache Hadoop should be installed on the cluster, which is beyond the scope of this document. 

###2.1 Requirements
* Apache hadoop-0.20.2 (distributed storage service)  
* Sun Java JDK 1.6.x or higher version  
Without loss of generality, suppose that HybridGraph is installed in `~/HybridGraph` and Java is installed in `/usr/java/jdk1.6.0_23`.

###2.2 Deploying HybridGraph   
####downloading files on `master`  
`cd ~/`  
`git clone https://github.com/HybridGraph/HybridGraph.git`  
`chmod 777 -R HybridGraph/`

####configuration on `master`  
First, edit `/etc/profile` by typing `sudo vi /etc/profile` and then add the following information:  
`export HybridGraph_HOME=~/HybridGraph`   
`export HybridGraph_CONF_DIR=$HybridGraph_HOME/conf`  
`export PATH=$PATH:$HybridGraph_HOME/bin`  
After that, type `source /etc/profile` in the command line to make changes take effect.  

Second, edit configuration files in `HybridGraph_HOME/conf` as follows:  
* __termite-env.sh:__ setting up the Java path.  
`export JAVA_HOME=/usr/java/jdk1.6.0_23`  
* __termite-site.xml:__ configurating the HybridGraph engine.  
The details are shown in [termite-site.xml](https://github.com/HybridGraph/HybridGraph/blob/master/conf/termite-site.xml).  
In particular, our current implementation uses the read/write throughput of disk reported by the disk benchmarking tool [fio-2.0.13](http://pkgs.fedoraproject.org/repo/pkgs/fio/fio-2.0.13.tar.gz/), and the network throughput reported by the network benchmarking tool [iperf-2.0.5](http://pkgs.fedoraproject.org/repo/pkgs/iperf/iperf-2.0.5.tar.gz/).  
1) random read/write  
`fio -filename=/tmp/data -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=50 -ioengine=psync -bs=16k -size=10G -numjobs=30 -runtime=360 -group_reporting -name=test`  
2) sequential read/write  
`fio -filename=/tmp/data -direct=1 -iodepth 1 -thread -rw=rw -rwmixread=50 -ioengine=psync -bs=16k -size=10G -numjobs=30 -runtime=360 -group_reporting -name=test`  
3) network  
server: `iperf -s -f M -w 48K`  
client: `iperf -c hadoop03 -f M -w 48K`  
* __workers:__ settting up workers of HybridGraph.  
`slave1`  
`slave2`  

####deploying  
Copy configurated files on `master` to `slave1` and `slave2`.  
`scp -r ~/HybridGraph slave1:.`  
`scp -r ~/HybridGraph slave2:.`  

###2.3 Starting HybridGraph  
Type the following commands on `master` to start HybridGraph.  
* __starting HDFS:__  
`start-dfs.sh`  
* __starting HybridGraph after NameNode has left safemode:__  
`start-termite.sh`  
* __stopping HybridGraph:__  
`stop-termite.sh`  

###2.4 Running a Single Source Shortest Path (SSSP) job on `master`  
First, create an input file under input/random_graph on HDFS. Input file should be in format of:  
`source_vertex_id \t target_vertex_id_1:target_vertex_id_2:...`  
An example is given in [random_graph](https://github.com/HybridGraph/dataset/blob/master/random_graph). You can download it and put it onto your HDFS:  
`hadoop dfs -mkdir input`  
`hadoop dfs -put random_graph input/`  
Currently, HybridGraph uses Range (a simple variant of [Range](https://apache.googlesource.com/giraph/+/old-move-to-tlp/src/main/java/org/apache/giraph/graph/partition/RangePartitionerFactory.java) used in Giraph) to partition input graph, in order to preserve the locality of raw graph. As a negative result of that, vertex ids must be numbered consecutively.  

Second, submit the SSSP job with different models for the example graph [random_graph](https://github.com/HybridGraph/dataset/blob/master/random_graph):  
* __SSSP (using b-pull):__  
`termite jar $HybridGraph_HOME/termite-examples-0.1.jar sssp.pull input output 2 50 100000 5 10000 2`  
About arguments:  
[1] input directory on HDFS  
[2] output directory on HDFS  
[3] the number of child processes (tasks)  
[4] the maximum number of supersteps  
[5] the total number of vertices  
[6] the number of VBlocks per task  
[7] the sending threshold  
[8] the source vertex id  
* __SSSP (using hybrid):__  
`termite jar $HybridGraph_HOME/termite-examples-0.1.jar sssp.hybrid input output 2 50 100000 5 10000 10000 10000 2 2`  
About arguments:  
[1] input directory on HDFS  
[2] output directory on HDFS  
[3] the number of child processes (tasks)  
[4] the maximum number of supersteps  
[5] the total number of vertices  
[6] the number of VBlocks per task  
[7] the sending threshold used by b-pull  
[8] the sending threshold used by push  
[9] the receiving buffer size per task used by push  
[10] starting style: 1--push, 2--b-pull  
[11] the source vertex id  

HybridGraph manages graph data on disk as default. Users can tell HybridGraph to keep graph data in memory through `BSPJob.setGraphDataOnDisk(false)`. Currently, the memory version only works for `b-pull`. Please type `termite jar $HybridGraph_HOME/termite-examples-0.1.jar` to list all example algorithms. A chosen algorithm will print usage help when no  arguments is given.  

##3  Building HybridGraph with Apache Ant  
Users can import source code into Eclipse as an existing Java project to modify the core engine of HybridGraph, and then build your  modified version. Before building, you should install Apache Ant 1.7.1 or higher version on your `master`. Suppose the modified version is located in `~/source/HybridGraph`.  You can build it using `~/source/HybridGraph/build.xml` as follows:  
`cd ~/source/HybridGraph`  
`ant`  
Notice that you can build a specified part of HybridGraph as follows:  
1) build the core engine  
`ant core.jar`  
2) build examples  
`ant examples.jar`   

By default, all parts will be built, and you can find `termite-core-0.1.jar` and `termite-examples-0.1.jar` in `~/source/HybridGraph/build` after a successful building. Finally, use the new `termite-core-0.1.jar` to replace the old one in `$HybridGraph_HOME` on the cluster (i.e., `master`, `slave1`, and `slave2`). At anytime, you should guarantee that the  `termite-core-xx.jar` file is unique in `$HybridGraph_HOME`. Otherwise, the starting script described in Section 2.3 may use a wrong file to start the HybridGraph engine.  

##4. Programming Guide
HybridGraph includes some simple graph algorithms to show the usage of its APIs. These algorithms are contained in the `src/examples/hybrid/examples` package and have been packaged into the `termite-examples-0.1.jar` file. Users can implement their own algorithms by learning these examples. After that, as described in Section 3 and Section 2.4, you can build your own algorithm can then run it.
