#!/bin/bash

RUNNAME=$1
RSTART=$2
NHOURS=$3

SRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/src
RUNSRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/src
LOGDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/log
TEMPLATE=${SRCDIR}/prep_${RUNNAME}.sh

mkdir -p ${RUNSRCDIR}

sed -e s/{runname}/$RUNNAME/g -e s/{rstart}/$RSTART/g -e s/{nhours}/$NHOURS/g $TEMPLATE > ${RUNSRCDIR}/prep_${RUNNAME}_${RSTART}_${NHOURS}

qsub -e ${LOGDIR}/log_prep.err -o ${LOGDIR}/log_prep.out -N prep_${RUNNAME} ${RUNSRCDIR}/prep_${RUNNAME}_${RSTART}_${NHOURS}
