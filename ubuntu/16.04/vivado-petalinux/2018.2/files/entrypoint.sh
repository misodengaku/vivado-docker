#!/bin/bash

vncserver -geometry ${GEOMETRY} :0
#export DISPLAY=$HOSTNAME:0
/opt/Xilinx/Vivado/2018.2/bin/vivado
