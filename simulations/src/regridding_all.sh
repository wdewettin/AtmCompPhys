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

GRIDDIR=/dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/src/grids
INPUTDIRS=$(ls -d /dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/export/*)

for INPUTDIR in $INPUTDIRS
do
cd $INPUTDIR

# Hard-code timestep!
INPUTFILES=$(ls ${RUNNAME}_${RSTART}_${NHOURS}_*3600.nc)

for INPUTFILE in $INPUTFILES
do
INPUTFILEBASE="${INPUTFILE::-3}"
OUTPUTFILE=${INPUTFILEBASE}_regridded.nc

cdo -v remapcon,${GRIDDIR}/belgium_5km_latlon.txt ${INPUTFILE} ${OUTPUTFILE}

done
done
