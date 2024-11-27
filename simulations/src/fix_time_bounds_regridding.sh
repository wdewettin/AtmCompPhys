#!/bin/bash
#PBS -l nodes=1:ppn=32
#PBS -l walltime=08:00:00
#PBS -A 2022_205
#PBS -m a
#PBS -N fixtimebounds
#PBS -o /dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/log/log_fix_time_bounds.out
#PBS -e /dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/log/log_fix_time_bounds.err

module swap cluster/dodrio/cpu_milan
module load xarray
module load netcdf4-python
module load dask

export OMPI_MCA_btl='^uct,ofi'
export OMPI_MCA_pml='ucx'
export OMPI_MCA_mtl='^ofi'

cd /dodrio/scratch/users/vsc45263/wout/CompPhys/simulations/src
python fix_time_bounds_regridding.py
