#!/bin/bash

#Menu system for launching appropriate scripts based on user choice
source qm.variables

#Fix to automatically export ports on computer.
os=$(uname)
if [ "$os" = "PowerChain" ]; then
	touch .qm_export_ports
fi

docker run -it --rm -v $(pwd)/$line:/${PWD##*/} -w /${PWD##*/} $dockerImage lib/menu.sh $@

if [ -f .nodename ]; then
	nodename=$(cat .nodename)
	rm -f .nodename
	cd $nodename
	./start.sh	$@
fi
