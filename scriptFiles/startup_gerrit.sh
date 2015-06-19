#!/bin/bash

FIRST_TIME=$1

if [ $FIRST_TIME -eq 1 ]; then
	java -jar $GERRIT_DOCKER_WAR init --install-plugin singleusergroup --install-plugin replication --install-plugin download-commands --install-plugin reviewnotes --batch -d $GERRIT_ROOT
	java -jar $GERRIT_DOCKER_WAR reindex -d $GERRIT_ROOT
	/home/gerrit2/gerrit/bin/gerrit.sh start
else
	/home/gerrit2/gerrit/bin/gerrit.sh start
fi

sleep infinity
