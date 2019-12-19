#!/bin/bash
set -u
set -e

cd /root/powerchain-maker/
./start_nodemanager.sh $R_PORT $NM_PORT $CURRENT_NODE_IP
