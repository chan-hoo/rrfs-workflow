#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHrrfs/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u -x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that conduct JEDI EnVar IODA tasks
with FV3 for the specified cycle.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set environment variables.
#
#-----------------------------------------------------------------------
#
case $MACHINE in
#
"WCOSS2")
  ulimit -s unlimited
  ulimit -a
  ncores=$(( NNODES_RUN_JEDIENVAR_IODA*PPN_RUN_JEDIENVAR_IODA ))
  APRUN="mpiexec -n ${ncores} -ppn ${PPN_RUN_JEDIENVAR_IODA}"
  ;;
#
"HERA")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  ;;
#
"JET")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  ;;
#
"ORION")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Prepare files and folders
#
#-----------------------------------------------------------------------
# 
# Create folders for the working path
mkdir -p GSI_diags
mkdir -p obs
mkdir -p geoval

# Create folders under COMOUT
mkdir -p ${COMOUT}/jedienvar_ioda
mkdir -p ${COMOUT}/jedienvar_ioda/anal_gsi
mkdir -p ${COMOUT}/jedienvar_ioda/jedi_obs

# Specify the path of the GSI Analysis working folder
gsidiag_path=${COMIN}

# Copy GSI ncdiag files to COMOUT 
cp ${gsidiag_path}/ncdiag* ${COMOUT}/jedienvar_ioda/anal_gsi/

# Copy only ncdiag first guess files to the workfing folder
cp ${COMOUT}/jedienvar_ioda/anal_gsi/*ges* ${DATA}/GSI_diags
#
#-----------------------------------------------------------------------
#
# Change the ncdiag file name from *.nc4.$DATE to *.$DATE_ensmean.nc4
#
#-----------------------------------------------------------------------
# 
cd ${DATA}/GSI_diags
fl=`ls -1 ncdiag*`

for ifl in $fl
do
  leftpart01=`basename $ifl .$CDATE`
  leftpart02=`basename $leftpart01 .nc`
  flnm=${leftpart02}.${CDATE}_ensmean.nc4
  echo $flnm
  mv $ifl $flnm
done
#
#-----------------------------------------------------------------------
#
# Execute the IODA python script
#
#-----------------------------------------------------------------------
#  
cd ${DATA}

# Specify the IODA python script
IODACDir=/scratch1/BMC/zrtrr/llin/220601_jedi/ioda-bundle_20220530/ioda-bundle/build/bin

# PYIODA library
export PYTHONPATH=/scratch1/BMC/zrtrr/llin/220501_emc_reg_wflow/dr-jedi-ioda/ioda-bundle/build/lib/python3.7/pyioda

# Running the python script
PYTHONEXE=/scratch1/NCEPDEV/da/python/hpc-stack/miniconda3/core/miniconda3/4.6.14/envs/iodaconv/bin/python
${PYTHONEXE} ${IODACDir}/proc_gsi_ncdiag.py -o $DATA/obs -g $DATA/geoval $DATA/GSI_diags
export err=$?
if [ $err -ne 0 ]; then
  err_exit "Call to executable to run No Var Cloud Analysis returned with nonzero exit code."
fi

# Copy IODA obs files to COMOUT
cp ${DATA}/obs/*nc4 ${COMOUT}/jedienvar_ioda/jedi_obs/

#
#-----------------------------------------------------------------------
#
# touch jedienvar_ioda_complete.txt to indicate competion of this task
# 
#-----------------------------------------------------------------------
#
touch ${LOGDIR}/jedienvar_ioda_complete_${CDATE}.txt
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
JEDI EnVAR IODA completed successfully!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

