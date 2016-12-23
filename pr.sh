ALGORITHM=Pagerank
WORKERS=3
GRAPH=input/
RESULT=result/
NODES=200000
SNAPSHOT=1
TERMTHRESH=0.001
BUFMSG=10000
PORTION=1
CKINTERVAL=-1
FAULTTIME=-1
VERTEXNUM=100000
FAILEDWORKERNUM=1
CASCADING=0
./maiter --runner=$ALGORITHM --workers=$WORKERS --graph_dir=$GRAPH --result_dir=$RESULT --num_nodes=$NODES --snapshot_interval=$SNAPSHOT --portion=$PORTION --termcheck_threshold=$TERMTHRESH --bufmsg=$BUFMSG --ck_interval=$CKINTERVAL --fault_time=$FAULTTIME --vert_num=$VERTEXNUM --failed_worker_num=$FAILEDWORKERNUM --cascading=$CASCADING --v=1 > log
