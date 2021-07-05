#!/bin/bash

if [ -n ${USER_ID+x} -a -n ${GROUP_ID+x} ]; then
    echo usermod -u $USER_ID -d /home/vivado -o -m vivado
    echo groupmod -g $GROUP_ID vivado

    usermod -u $USER_ID -o -d /home/vivado -m vivado
    groupmod -g $GROUP_ID vivado
fi
CMDLINE="$@"
su vivado -c "$CMDLINE"
exit $?
