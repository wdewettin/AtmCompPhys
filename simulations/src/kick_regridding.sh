#!/bin/bash

RUNNAME=$1
RSTART=$2
NHOURS=$3
VARNAME=$4
TSTART=$5
TSTOP=$6
TSTEP=$7

SRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/src
RUNSRCDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/src
LOGDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/log
TEMPLATE=${SRCDIR}/regridding.sh

mkdir -p ${RUNSRCDIR}

sed -e s/{runname}/$RUNNAME/g -e s/{rstart}/$RSTART/g -e s/{nhours}/$NHOURS/g -e s/{varname}/$VARNAME/g -e s/{tstart}/$TSTART/g -e s/{tstop}/$TSTOP/g -e s/{tstep}/$TSTEP/g $TEMPLATE > ${RUNSRCDIR}/regridding_${RUNNAME}_${RSTART}_${NHOURS}_${VARNAME}

qsub -e ${LOGDIR}/log_regridding_${VARNAME}.err -o ${LOGDIR}/log_regridding_${VARNAME}.out -N regridding_${RUNNAME} ${RUNSRCDIR}/regridding_${RUNNAME}_${RSTART}_${NHOURS}_${VARNAME}
