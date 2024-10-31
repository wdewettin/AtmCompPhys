#!/bin/bash

RUNSDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs
cd $RUNSDIR
RUNS=$(ls -d *)
for RUNDIR in $RUNS
do 
IFS='_' read -ra RUNDIRPARTS <<< $RUNDIR
RUNNAME=${RUNDIRPARTS[1]}
RSTART=${RUNDIRPARTS[2]}
NHOURS=${RUNDIRPARTS[3]}

SRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/src
RUNSRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/src
LOGDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/log
TEMPLATE=${SRCDIR}/export.sh

mkdir -p ${RUNSRCDIR}

sed -e s/{runname}/$RUNNAME/g -e s/{rstart}/$RSTART/g -e s/{nhours}/$NHOURS/g $TEMPLATE > ${RUNSRCDIR}/export_${RUNNAME}_${RSTART}_${NHOURS}

qsub -e ${LOGDIR}/log_export.err -o ${LOGDIR}/log_export.out -N export_${RUNNAME} ${RUNSRCDIR}/export_${RUNNAME}_${RSTART}_${NHOURS}
done
