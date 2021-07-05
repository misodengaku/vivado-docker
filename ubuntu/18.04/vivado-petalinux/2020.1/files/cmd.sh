#!/bin/bash

vncserver -geometry ${GEOMETRY} :0
#export DISPLAY=$HOSTNAME:0
/opt/Xilinx/Vivado/2020.1/bin/vivado
