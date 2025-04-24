#!/bin/bash

export ZE_FLAT_DEVICE_HIERARCHY=COMPOSITE

# Use all 6 GPUs
if [ $PALS_LOCAL_RANKID -eq 0 ]
then
    AFFINITY_MASK=0.0
elif [ $PALS_LOCAL_RANKID -eq 1 ]
then
    AFFINITY_MASK=1.0
elif [ $PALS_LOCAL_RANKID -eq 2 ]
then
    AFFINITY_MASK=2.0
elif [ $PALS_LOCAL_RANKID -eq 3 ]
then
    AFFINITY_MASK=3.0
elif [ $PALS_LOCAL_RANKID -eq 4 ]
then
    AFFINITY_MASK=4.0
elif [ $PALS_LOCAL_RANKID -eq 5 ]
then
    AFFINITY_MASK=5.0
fi

export ZE_AFFINITY_MASK=$AFFINITY_MASK

# Invoke the main program
$*
