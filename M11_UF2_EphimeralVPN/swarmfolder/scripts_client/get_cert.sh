#!/usr/bin/env bash
IP=192.168.1.117
PORT=2222
ssh -p $PORT -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -o 'loglevel=ERROR' "sjo@$IP"
