#!/bin/bash
#PBS -l nodes=4:ppn=128
#PBS -l walltime=03:59:00
#PBS -A 2022_205
#PBS -m a

set -x

# Set buffer to be sure there is no overlap with previous run
sleep 5

# 1. SETTINGS
# -----------

# 1a. Runtime settings
# --------------------
RUNNAME={runname}
RSTART={rstart} # 2021071200
NHOURS={nhours} # 120
TIMESTEP=300

YYYY=`echo $RSTART | cut -c1-4`
MM=`echo $RSTART | cut -c5-6`
DD=`echo $RSTART | cut -c7-8`
HH=`echo $RSTART | cut -c9-10`
NSTOP=$((NHOURS*3600/TIMESTEP))
LEVELS=$(echo $(seq -f %2g, 1 1 46))
NFRHIS=$((3600/TIMESTEP))
LINC=.T. # If false watch out for output handling after run

MASTER=/dodrio/scratch/projects/starting_2022_075/accord/pack/test43t2_iimpi/bin/MASTERODB

# 1b. Environment settings
# ------------------------
export PYTHONPATH=""
export OMP_NUM_THREADS=1
NPROC=$((PBS_NP/OMP_NUM_THREADS))

module swap cluster/dodrio/cpu_milan
module load iimpi/2022a imkl/2022.1.0 vsc-mympirun
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/dodrio/scratch/projects/starting_2022_075/accord/software/iimpi2022a/lib64
ulimit -s unlimited
ulimit -c unlimited

export OMP_STACKSIZE="$((4/OMP_NUM_THREADS))G"
export KMP_STACKSIZE="$((4/OMP_NUM_THREADS))G"
#export KMP_MONITOR_STACKSIZE=1G

export MPL_MBX_SIZE=2048000000
export I_MPI_ADJUST_GATHERV=3   # necessary on hortense, otherwise hangs forever in calculation of spectral norms !?

export DR_HOOK=1
export DR_HOOK_IGNORE_SIGNALS=8   # FPEs in acraneb, acraneb2
#export DR_HOOK_SILENT=1
#export DR_HOOK_OPT=prof

export EC_PROFILE_HEAP=0
export EC_MPI_ATEXIT=0

# 1c. Directory settings
# ----------------------

# directories
BASEDIR=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations
COUPLINGDIR=${BASEDIR}/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/prep/coupling
NAMEDIR=${BASEDIR}/name
WORKDIR=${BASEDIR}/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/work
SAVEDIR=${BASEDIR}/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/output

# namelists
NAM001=$NAMEDIR/name.e001.CY43T2.DYDOCASE.long.level03
NAMSFX=$NAMEDIR/EXSEG1.nam.plus
NAMFAREP=$NAMEDIR/name.FAreplace
NAMFAREPSFX=$NAMEDIR/name.FAreplace.sfx

# 2. EXECUTION
# ------------

# go to workdir
mkdir -p ${WORKDIR}
cd ${WORKDIR}
rm -f *

# 2a. Coupling files
# ------------------

scp ${COUPLINGDIR}/${YYYY}/${MM}/* .

# 2b. Initial files (FAreplace)
# -----------------------------

rsync -l ELSCFABOFALBC000 ICMSHABOFINIT

# 2c. Run the model
# -----------------

# Bring master
ln -sf ${MASTER} MASTER

# Create namelist file
cat $NAM001 |grep -v '^!'|sed -e "s/!.*//" \
-e "s/{nproc}/${NPROC}/g" \
-e "s/{timestep}/${TIMESTEP}/g" \
-e "s/{nstop}/${NSTOP}/g" \
-e "s/{nfrhis}/${NFRHIS}/g" \
-e "s/{linc}/${LINC}/g" > fort.4
cp $NAMSFX ./EXSEG1.nam

# RUN!
mympirun -h $((128/OMP_NUM_THREADS)) ./MASTER > log.out 2>log.err

# Check if final output is present
HHHH=$(printf "%04d" $NHOURS)

if [ ! -f "${WORKDIR}/ICMSHABOF+${HHHH}" ] || [ ! -f "${WORKDIR}/ICMSHABOF+${HHHH}.sfx" ]
then # run has failed
exit 1
fi

# 2d. Save output
# ---------------

if [ ! -d ${SAVEDIR}/${YYYY}/${MM} ]
then
mkdir -p ${SAVEDIR}/${YYYY}/${MM}
fi

# Copy output from workdir to savedir
cp ICMSHABOF* ${SAVEDIR}/${YYYY}/${MM}/
cp fort.4 ${SAVEDIR}/${YYYY}/${MM}/
cp log* ${SAVEDIR}/${YYYY}/${MM}/
cp NODE* ${SAVEDIR}/${YYYY}/${MM}/
cp ifs* ${SAVEDIR}/${YYYY}/${MM}/

# Delete workdir
rm -rv $WORKDIR
