#!/bin/bash

if [ ! -d build ]; then
	mkdir build
	cd build
	cmake ..
	cd ..
fi

cd build/experiments-core/src/foedus/tpcc/
/home/ubuntu/sto/mount_hugepages.sh 102400
./run_hcc_aws.sh
