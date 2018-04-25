#!/bin/bash

FRAMEWORK=$1
ENVARG=$2

# TODO: better usage and help

if [[ "$FRAMEWORK" == "" || "$ENVARG" == "" ]]; then
  echo "Error: we need two arguments!"
  exit 1
fi

# get DOMAIN and SPLICEHDFS from ENVARG
DOMAIN=$(dcos config show core.dcos_url)
SPLICEHDFS=""
ORIGENV=$DOMAIN
if [[ "$ENVARG" == "d" || "$ENVARG" == "dev" ]]; then
  DOMAIN="us-east-1.splicemachine-dev.io"
  SPLICEHDFS="splicehdfs03"
  if (( $VERBOSE )); then echo "switching to dev env $DOMAIN"; fi
elif [[ "$ENVARG" == "q" || "$ENVARG" == "qa" ]]; then
  DOMAIN="us-east-1.splicemachine-qa.io"
  SPLICEHDFS="splicehdfs02"
  if (( $VERBOSE )); then echo "switching to qa env $DOMAIN"; fi
elif [[ "$ENVARG" == "p" || "$ENVARG" == "prod" || "$ENVARG" == "production" ]]; then
  DOMAIN="us-east-1.splicemachine.io"
  SPLICEHDFS="splicehdfs01"
  if (( $VERBOSE )); then echo "switching to prod env $DOMAIN"; fi
else
  echo "Error: environment $ENVARG not recognized"
  exit 2
fi

# ====

# TODO: generate these lists automagicaly from dcos api

# TODO: complete the looping and make these vars
#declare -i COUNT=0
#declare -a PODS
#declare -a NAMES
#declare -a IPS
# PODS => dcos splicedb --name=$FRAMEWORK pods list
# COUNT++

# TODO: implement getPods
# getPods() {
#   local framework=$1
#}

# TODO: implement getNameFromTask
# getNameFromTask() {
#  local task=$1
# dcos ... task exec -ti $task bash -c hostname
# }

# get framework_id from framework
# e.g. dcos service | grep "murraysaccount-tpch1g10g100g-a0fb840a0b-spark" | awk '{print $8}'
getFrameworkId() {
  dcos service | grep "$FRAMEWORK-spark" | awk '{print $8}'
}

pods=( "hmaster-0" "hmaster-1" "hregion-0" "hregion-1" "hregion-2" "hregion-3" "zookeeper-0" "zookeeper-1" "zookeeper-2")
#pods=( "hmaster-0" "hmaster-1")
names=( "hmaster-0-node.${FRAMEWORK}.mesos" \
	"hmaster-1-node.${FRAMEWORK}.mesos" \
	"hregion-0-node.${FRAMEWORK}.mesos" \
	"hregion-1-node.${FRAMEWORK}.mesos" \
	"hregion-2-node.${FRAMEWORK}.mesos" \
	"hregion-3-node.${FRAMEWORK}.mesos" \
	"data-0-node.${SPLICEHDFS}.mesos" \
	"data-1-node.${SPLICEHDFS}.mesos" \
	"data-2-node.${SPLICEHDFS}.mesos" \
	"data-3-node.${SPLICEHDFS}.mesos" )

#echo "Debug: pod-0 ${pods[0]} names-0 ${names[0]}"

# =====
# Subroutines

findTask() {
  local pod=$1
  #echo "task-for-$pod"
  dcos splicedb --name=$FRAMEWORK pods info $pod | \
  jq -r '.[0].status.taskId.value'
}

fetchIpFromTask() {
  local name=$1
  local task=$2

  #echo "debug: fetching name $name from task $task" 
  local ip=$(dcos task exec -ti $task bash -c "host $name" | awk '{print $4}')

  # TODO: put ip in IPS[num]  
  echo $ip
}

pushDNS() {
  local task=$1
  local file=$2

  echo push DNS $file to $task
  #cat $file | dcos task exec -i $task bash -c "cat >> /etc/hosts"
}

# ====
# Main

DNS="./temp-DNS.txt"

#touch $DNS
#if [[ ! -f $DNS ]]; then
#  echo Error: problem making temp file $DNS
#  exit 2
#fi

hmasterTask=$(findTask ${pods[0]})

echo "found hmasterTask $hmasterTask"

if [[ ! -f $DNS ]]; then
  # loop through pods getting dns
  declare -i i=0
  for name in ${names[@]}; do
    echo "get ip for name ${names[$i]} using $hmasterTask"
    ip=$(fetchIpFromTask ${names[$i]} $hmasterTask | sed -e "s///g")
    echo -e "$ip\t\t${names[$i]}"  >> $DNS
    let i++
  done
fi

echo DNS made
cat $DNS
echo -e "\n"

if [[ ! $SPARKONLY ]]; then
  # loop through pods, pushing DNS to tasks
  for pod in ${pods[@]}; do
    #echo "push dns to pod ${pod[0]}"
    task=$(findTask $pod)
    echo pushing $DNS on $pod via task $task
    pushDNS $task $DNS
  done
fi

# TODO: now loop spark
# e.g. curl -v -skSL -X GET -H "Content-Type:application/json"  
# "https://us-east-1.splicemachine-dev.io/mesos/tasks | \
# jq -er '.tasks[] | select(.framework_id=="5a9b24cc-8d57-46cd-88d7-c9927ff1ea35-0031") | \
#  select(.state=="TASK_RUNNING") | .id'

HEADER="-skSL -X GET -H \"Content-Type:application/json\""
frameworkId=$(getFrameworkId $FRAMEWORK)

for spark in $( curl ${HEADER} https://${DOMAIN}/mesos/tasks | jq -er --arg FRAME "$frameworkId" '.tasks[] | select(.framework_id==$FRAME) | select(.state=="TASK_RUNNING") | .id' ); do 
   echo pushing $DNS to spark-task $spark
   pushDNS $spark $DNS
done


if [[ ! $SPARKONLY ]]; then
  echo cleanup $DNS
  rm $DNS
fi
