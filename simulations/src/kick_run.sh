#!/bin/bash

RUNNAME=$1
RSTART=$2
NHOURS=$3

SRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/src
RUNSRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/src
LOGDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/log
TEMPLATE=${SRCDIR}/run_${RUNNAME}.sh

mkdir -p ${RUNSRCDIR}

sed -e s/{runname}/$RUNNAME/g -e s/{rstart}/$RSTART/g -e s/{nhours}/$NHOURS/g $TEMPLATE > ${RUNSRCDIR}/run_${RUNNAME}_${RSTART}_${NHOURS}

qsub -e ${LOGDIR}/log_run.err -o ${LOGDIR}/log_run.out -N run_${RUNNAME} ${RUNSRCDIR}/run_${RUNNAME}_${RSTART}_${NHOURS}
