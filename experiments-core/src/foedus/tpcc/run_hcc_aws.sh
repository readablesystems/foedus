#!/bin/bash

loggers_per_node=2
volatile_pool_size=32
snapshot_pool_size=1
reducer_buffer_size=2
duration_micro=10000000
max_thread_per_node=32
sys_numa_nodes=2
log_buffer_mb=1024
machine_name="AWS EC2 m4.16xlarge Instance"
machine_shortname="aws"
. yihe_runs_hcc.sh

python3 /home/ubuntu/send_email.py --exp "FOEDUS-MOCC" mocc-1w-results.txt mocc-4w-results.txt mocc-0w-results.txt mocc_results.txt

sudo shutdown -h now
