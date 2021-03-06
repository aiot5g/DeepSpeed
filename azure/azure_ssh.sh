#!/bin/bash

config_file=azure_config.json
while getopts 'c:' flag; do
  case "${flag}" in
    c) config_file="${OPTARG}" ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done
shift $(expr $OPTIND - 1)
echo "Using $config_file"

nodeid=$1
cmds=${@:2}
echo $nodeid $cmds
ip_addr=`az vm list-ip-addresses | jq .[${nodeid}].virtualMachine.network.publicIpAddresses[0].ipAddress | sed 's/"//g'`

ssh_private_key=`cat ${config_file} | jq .ssh_private_key | sed 's/"//g'`
if [ $ssh_private_key == "null" ]; then echo 'missing ssh_private_key in config'; exit 1; fi

ssh -i ${ssh_private_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null deepspeed@${ip_addr} ${cmds}
