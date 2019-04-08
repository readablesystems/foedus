#!/bin/bash

echo "FOEDUS TPC-C experiments script with HCC for $machine_shortname ($machine_name)"
echo "loggers_per_node=$loggers_per_node, volatile_pool_size=$volatile_pool_size, duration_micro=$duration_micro."
echo "thread_per_node=$max_thread_per_node, numa_nodes=$sys_numa_nodes, snapshot_pool_size=$snapshot_pool_size, reducer_buffer_size=$reducer_buffer_size."

null_log_device=true # Without logging I/O
high_priority=false # To set this to true, you must add "yourname - rtprio 99" to limits.conf
fork_workers=true
hcc_policy=0

for whs in 1 4 0
do
  OUTFILE="mocc-${whs}w-results.txt"
  printf "# Threads" >> $OUTFILE
  for rep in {1..5}
  do
    printf ",MOCC (W${whs}) [T${rep}]" >> $OUTFILE
  done
  for thr in 0 1 2 6 12 16 18 24 32
  do
    if [ $thr -eq 0 ]
    then
      thread_per_node=1
      numa_nodes=1
    else
      thread_per_node=$thr
      numa_nodes=$sys_numa_nodes
    fi

    total_threads=$(($thread_per_node * $numa_nodes))

    if [ $whs -eq 0 ]
    then
      warehouses=$total_threads
    else
      warehouses=$whs
    fi

    printf "\n$total_threads" >> $OUTFILE

    for rep in 1 2 3 4 5
    do
      echo "hcc_policy=$hcc_policy, warehouses=$warehouses, threads=$total_threads, rep=$rep/5..."
      # be careful.
      rm -rf /dev/shm/foedus_tpcc/
      rm -rf /tmp/libfoedus.*
      sleep 0.1 # Linux's release of shared memory has a bit of timelag.
      export CPUPROFILE_FREQUENCY=1 # https://code.google.com/p/gperftools/issues/detail?id=133
      #echo "./tpcc -warehouses=$warehouses -fork_workers=$fork_workers -nvm_folder=/dev/shm -high_priority=$high_priority -null_log_device=$null_log_device -loggers_per_node=$loggers_per_node -thread_per_node=$thread_per_node -numa_nodes=$numa_nodes -log_buffer_mb=$log_buffer_mb -neworder_remote_percent=1 -payment_remote_percent=15 -volatile_pool_size=$volatile_pool_size -snapshot_pool_size=$snapshot_pool_size -reducer_buffer_size=$reducer_buffer_size -duration_micro=$duration_micro -hcc_policy=$hcc_policy"
      xput=$(env CPUPROFILE_FREQUENCY=1 ./tpcc -warehouses=$warehouses -take_snapshot=false -fork_workers=$fork_workers -nvm_folder=/dev/shm -high_priority=$high_priority -null_log_device=$null_log_device -loggers_per_node=$loggers_per_node -thread_per_node=$thread_per_node -numa_nodes=$numa_nodes -log_buffer_mb=$log_buffer_mb -neworder_remote_percent=1 -payment_remote_percent=15 -volatile_pool_size=$volatile_pool_size -snapshot_pool_size=$snapshot_pool_size -reducer_buffer_size=$reducer_buffer_size -duration_micro=$duration_micro -hcc_policy=$hcc_policy | grep 'final result:' | grep -oE '<MTPS>[0-9.]+</MTPS>' | grep -oE '[0-9.]+')
      #xput="${warehouses}.00"
      printf ",$xput" >> $OUTFILE
    done
  done
  printf "\n" >> $OUTFILE
done

join --header -t , -j 1 mocc-1w-results.txt mocc-4w-results.txt > out.txt
join --header -t , -j 1 out.txt mocc-0w-results.txt > mocc_results.txt
rm -f out.txt
