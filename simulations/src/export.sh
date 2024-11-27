#!/bin/bash
#PBS -l nodes=1:ppn=8
#PBS -l walltime=12:00:00
#PBS -A 2022_205
#PBS -e log.err
#PBS -o log.out
#PBS -m a

module swap cluster/dodrio/cpu_milan
module load vsc-mympirun
module load foss/2022a R/4.2.1-foss-2022a
module load Cartopy/0.20.3-foss-2022a
module load dask/2022.10.0-foss-2022a
module load ecCodes/2.27.0-gompi-2022a
module load netcdf4-python/1.6.1-foss-2022a
module load xarray/2022.6.0-foss-2022a
module load rasterio/1.3.4-foss-2022a
module load rioxarray/0.14.0-foss-2022a

export PYTHONPATH="/dodrio/scratch/users/vsc45263/wout/readFA/src:${PYTHONPATH}"
export OMPI_MCA_btl='^uct,ofi'
export OMPI_MCA_pml='ucx'
export OMPI_MCA_mtl='^ofi'

RUNNAME={runname}
RSTART={rstart}
NHOURS={nhours}

SRCDIR=/dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/src
WORKDIR=/dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/work_export

mkdir -p $WORKDIR
rm -v ${WORKDIR}/*
cd $WORKDIR

cp ${SRCDIR}/export.py .
python3 export.py $RUNNAME $RSTART $NHOURS || exit 1

rm -v ${WORKDIR}/*
cd ${WORKDIR}/..
rmdir $WORKDIR
