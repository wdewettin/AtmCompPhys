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
TEMPLATE=${SRCDIR}/regridding_all.sh

mkdir -p ${RUNSRCDIR}

sed -e s/{runname}/$RUNNAME/g -e s/{rstart}/$RSTART/g -e s/{nhours}/$NHOURS/g -e s/{tstart}/$TSTART/g -e s/{tstop}/$TSTOP/g -e s/{tstep}/$TSTEP/g $TEMPLATE > ${RUNSRCDIR}/regridding_${RUNNAME}_${RSTART}_${NHOURS}_all

qsub -e ${LOGDIR}/log_regridding_all.err -o ${LOGDIR}/log_regridding_all.out -N regridding_${RUNNAME}_all ${RUNSRCDIR}/regridding_${RUNNAME}_${RSTART}_${NHOURS}_all
done
