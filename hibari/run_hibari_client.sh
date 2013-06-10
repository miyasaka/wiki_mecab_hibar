#!/bin/sh

HIBARI_HOME=/usr/local/hibari
MNESIA_DIR='"/usr/local/Mnesia/Mnesia.hibariclient@192.168.0.157"'

NODE_NAME='-name hibariclient@192.168.0.157'
ERL_COMMAND='/usr/bin/env erl'
SASL_CONF='/home/miyasaka/project/hibari/elog.config'
#Set path
CWD=`pwd`
IMPORT1="-pz $HIBARI_HOME/lib/inets-5.5.1/ebin -pz $HIBARI_HOME/lib/gmt_util-0.1.6/ebin -pz $HIBARI_HOME/lib/gdss_client-0.1.6/ebin"
IMPORT2="-pz $HIBARI_HOME/lib/cluster_info-0.1.1/ebin -pz $HIBARI_HOME/lib/gdss_brick-0.1.6/ebin"

# -pz $HIBARI_HOME/lib/gmt_util-0.1.5/ebin -pz $HIBARI_HOME/lib/gdss_client-0.1.6/ebin"


COMMAND="$ERL_COMMAND \
         $NODE_NAME \
         -boot start_sasl \
		 -config $SASL_CONF \
         -kernel net_ticktime 20 +K true +A 64 \
		 -setcookie hibari
         -pz $CWD \
  		 -detached \
         $IMPORT1 \
         $IMPORT2 \
         -s hibari_client start"

## running daemons and backgrounds processes
  # -detached \
		 #-mnesia dir $MNESIA_DIR

#COMMAND="$ERL_COMMAND \
#         $NODE_NAME \
#         -boot start_sasl \
#         -kernel net_ticktime 20 +K true +A 64 \
#         -pz $CWD \
#         `find $HIBARI_HOME/lib -name ebin -exec echo \"-pz {}\" \; | xargs echo` \
#         -s hibari_client start"

echo $COMMAND
$COMMAND
