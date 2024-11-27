#!/bin/bash
#PBS -l nodes=4:ppn=128
#PBS -l walltime=01:00:00
#PBS -A 2022_205
#PBS -m a

set -x

# 1. SETTINGS
# -----------

# 1a. Runtime settings
# --------------------
RUNNAME={runname}
RSTART={rstart} # 2021071200
NHOURS={nhours} # 120

YYYY=`echo $RSTART | cut -c1-4`
MM=`echo $RSTART | cut -c5-6`
DD=`echo $RSTART | cut -c7-8`
HH=`echo $RSTART | cut -c9-10`
LEVELS=$(echo $(seq -f %2g, 1 1 46))

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
COUPLINGDIR=${BASEDIR}/coupling
NAMEDIR=${BASEDIR}/name
WORKDIR=${BASEDIR}/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/prep/work
SAVEDIR=${BASEDIR}/runs/run_${RUNNAME}_${RSTART}_${NHOURS}/prep/coupling

# namelists
NAM927=$NAMEDIR/name.e927
NAM927_SFX=$NAMEDIR/name.e927.sfx
NAM927_LVL=$NAMEDIR/BE40a_l_46l

# data directories and clim files
CLIM_TRG=${BASEDIR}/clim/BE40a_l/Const.Clim.
CLIM_LBC=${BASEDIR}/clim/EUCO25/Const.Clim.
PGDFILE=${BASEDIR}/clim/BE40a_l/PGD.fa
DATADIR_RRTM=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/DYDOCASE/runs/data/RRTM
DATADIR_ECOCLIMAP=/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/PGD-clim-Tier1/climake/data/ecoclimap.covers.param.05

# 2. EXECUTION
# ------------

# go to workdir
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# 2a. Coupling files
# ------------------

# Get coupling files for current month
CPLNR=0
DAY=$DD
HOUR=$HH
ATTEMPT=1

let CPLNRSTOP=10#$NHOURS/3

while [ $CPLNR -le $CPLNRSTOP ]
do
  CPLNR_FORMATTED=$(printf "%03d" $CPLNR)
  HH=$(printf "%02d" $HOUR)
  DD=$(printf "%02d" $DAY)

# 2a.I Prep
# ---------

if [[ ! -f ${WORKDIR}/ELSCFABOFALBC${CPLNR_FORMATTED} && ! -f ${SAVEDIR}/${YYYY}/${MM}/ELSCFABOFALBC${CPLNR_FORMATTED} ]]
then

if [[ ! -d prep ]]
then
mkdir prep
fi

rm prep/*
cd prep

scp ${CLIM_TRG}${MM} const.clim.ABOF
scp ${CLIM_LBC}${MM} Const.Clim

# Bring RRTM files
scp ${DATADIR_RRTM}/RADRRTM .
scp ${DATADIR_RRTM}/RADSRTM .
scp ${DATADIR_RRTM}/MCICA .

### and now we actually run ALADIN:
echo 'echo MONITOR: $* >&2' >monitor.needs
chmod +x monitor.needs
echo $NPROC

# Create namelist file
cat ${NAM927} ${NAM927_LVL} | grep -v '^!' | \
  sed -e "s/!.*//"	\
      -e "s/{nproc}/${NPROC}/g"	\
      -e "s/{domain}/ABOF/g" \
      -e "s/{levels}/${LEVELS}/g"	\
> fort.4

COUPLINGPATH="${COUPLINGDIR}/${YYYY}/${MM}/LBC_EUCO25_${YYYY}${MM}${DD}_${HH}"
ln -sf ${COUPLINGPATH} ICMSHABOFINIT

# Bring executable binary
ln -sf ${MASTER} ./MASTER

# Run
mympirun -h $((128/OMP_NUM_THREADS)) ./MASTER > log.out 2>log.err

mv PFABOFABOF+0000 ../ELSCFABOFALBC${CPLNR_FORMATTED}

cd ..

fi

# 2aII. prepSurf
# --------------

if [[ $CPLNR_FORMATTED = 000 ]]
then

if [[ ! -f ${WORKDIR}/ICMSHABOFINIT.sfx && ! -f ${SAVEDIR}/${YYYY}/${MM}/ICMSHABOFINIT.sfx ]]
then

# Copy INIT-SFX-file from simulations
let SIMNR=10#$DAY*24+10#$HOUR-24
SIMNR_FORMATTED=$(printf "%04d" $SIMNR)
cp /dodrio/scratch/users/vsc45263/DYDOCASE/runs/long/level03/run199101/output/${YYYY}/${MM}/ICMSHABOF+${SIMNR_FORMATTED}.sfx ICMSHABOFINIT.sfx

# Bring data files
scp $PGDFILE Const.Clim.sfx
scp ${DATADIR_ECOCLIMAP}/*.bin .

fi

fi

# 2aIII. update loop variables if there is output
# -----------------------------------------------

if [[ (-f ${WORKDIR}/ICMSHABOFINIT.sfx || -f ${SAVEDIR}/${YYYY}/${MM}/ICMSHABOFINIT.sfx) && (-f ${WORKDIR}/ELSCFABOFALBC${CPLNR_FORMATTED} || -f ${SAVEDIR}/${YYYY}/${MM}/ELSCFABOFALBC${CPLNR_FORMATTED}) ]]
then

echo attempts = $ATTEMPT

((CPLNR++))
let HOUR=10#$HOUR+3

  if [ $HOUR -ge 24 ]
  then
    HOUR=0
    ((DAY++))
  fi

ATTEMPT=1

else
((ATTEMPT++))
fi

# Abort if the number of attempts exceeds ten
if [[ $ATTEMPT -gt 10 ]]
then
exit 1
fi

done

# 2d. Save output
# ---------------

if [ ! -d ${SAVEDIR}/${YYYY}/${MM} ]
then
mkdir -p ${SAVEDIR}/${YYYY}/${MM}
fi

# Copy output from workdir to savedir
cp ELSCFABOFALBC* ICMSHABOFINIT.sfx Const.Clim.sfx ecoclimap* ${SAVEDIR}/${YYYY}/${MM}/

# Delete workdir
rm -rv $WORKDIR

cd /dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/CompPhys/simulations/src
./kick_run.sh $RUNNAME $RSTART $NHOURS
