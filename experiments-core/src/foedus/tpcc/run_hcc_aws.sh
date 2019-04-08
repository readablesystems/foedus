#!/bin/bash

loggers_per_node=2
volatile_pool_size=16
snapshot_pool_size=1
reducer_buffer_size=2
duration_micro=10000000
max_thread_per_node=32
sys_numa_nodes=2
log_buffer_mb=1024
machine_name="AWS EC2 m4.16xlarge Instance"
machine_shortname="aws"
. yihe_runs_hcc.sh
