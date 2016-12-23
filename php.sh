ALGORITHM=PHP
WORKERS=17
GRAPH=input/
RESULT=result/
SOURCE=2
NODES=6000000
SNAPSHOT=1
TERMTHRESH=0.001
BUFMSG=10000
PORTION=1
CKINTERVAL=-1
FAULTTIME=-1
FAILEDWORKERNUM=1
CASCADING=0
./maiter --runner=$ALGORITHM --workers=$WORKERS --graph_dir=$GRAPH --result_dir=$RESULT --php_source=$SOURCE --num_nodes=$NODES --snapshot_interval=$SNAPSHOT --portion=$PORTION --termcheck_threshold=$TERMTHRESH --bufmsg=$BUFMSG --ck_interval=$CKINTERVAL --fault_time=$FAULTTIME --failed_worker_num=$FAILEDWORKERNUM --cascading=$CASCADING --v=1 > log
