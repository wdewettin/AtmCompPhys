#!/bin/bash
#PBS -l nodes=1:ppn=32
#PBS -l walltime=08:00:00
#PBS -A 2022_205
#PBS -m a

module swap cluster/dodrio/cpu_milan
module load CDO/2.0.6-gompi-2022a

export OMPI_MCA_btl='^uct,ofi'
export OMPI_MCA_pml='ucx'
export OMPI_MCA_mtl='^ofi'

RUNNAME={runname}
RSTART={rstart}
NHOURS={nhours}
VARNAME={varname}
TSTART={tstart}
TSTOP={tstop}
TSTEP={tstep}

GRIDDIR=/dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/src/grids
INPUTDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/export/${VARNAME}

cd $INPUTDIR

INPUTFILE=${RUNNAME}_${RSTART}_${NHOURS}_${VARNAME}_${TSTART}_${TSTOP}_${TSTEP}.nc
OUTPUTFILE=${RUNNAME}_${RSTART}_${NHOURS}_${VARNAME}_${TSTART}_${TSTOP}_${TSTEP}_regridded.nc

cdo -v remapcon,${GRIDDIR}/belgium_5km_latlon.txt ${INPUTFILE} ${OUTPUTFILE}
