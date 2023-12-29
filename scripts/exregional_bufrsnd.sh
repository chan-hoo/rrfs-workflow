#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHdir/source_util_funcs.sh
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

This is the ex-script for the task that runs the bufr-sounding 
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set environment variables.
#
#-----------------------------------------------------------------------
#
case $MACHINE in

  "WCOSS2")
    ncores=$(( NNODES_RUN_BUFRSND*PPN_RUN_BUFRSND))
    APRUNC="mpiexec -n ${ncores} -ppn ${PPN_RUN_BUFRSND}"
    APRUNS="time"
    ;;

  "HERA")
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  "ORION")
    ulimit -s unlimited
    ulimit -a
    export OMP_NUM_THREADS=1
    export OMP_STACKSIZE=1024M
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  "JET")
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  *)
    print_err_msg_exit "\
Run command has not been specified for this machine:
  MACHINE = \"$MACHINE\"
  APRUN = \"$APRUN\""
    ;;

esac
#
#-----------------------------------------------------------------------
#
# Get the cycle date and hour (in formats of yyyymmdd and hh, respectively)
# from cdate.
#
#-----------------------------------------------------------------------
#
yyyymmdd=${PDY:0:8}
yyyy=${PDY:0:4}
mm=${PDY:4:2}
dd=${PDY:6:2}
#
#-----------------------------------------------------------------------
#
# Create a text file (itag) containing arguments to pass to the post-
# processing executable.
#
#-----------------------------------------------------------------------
#
NEST="conus"
MODEL=fv3

mkdir -p $DATA/bufrpost
cd $DATA/bufrpost

RUNLOC=${NEST}${MODEL}

export tmmark=tm00

cp ${FIX_BUFRSND}/${PREDEF_GRID_NAME}/rrfs_profdat regional_profdat

OUTTYP=netcdf
model=FV3S
INCR=01
FHRLIM=60

let NFILE=1

START_DATE=${PDY}${cyc}
STARTDATE=${yyyy}-${mm}-${dd}_${cyc}:00:00
endtime=$(date +%Y%m%d%H -d "${START_DATE} +60 hours")

YYYY=`echo $endtime | cut -c1-4`
MM=`echo $endtime | cut -c5-6`
DD=`echo $endtime | cut -c7-8`

FINALDATE=${YYYY}-${MM}-${DD}_${cyc}:00:00

if [ -e sndpostdone00.tm00 ]; then
  lasthour=`ls -1rt sndpostdone??.tm00 | tail -1 | cut -c 12-13`
  typeset -Z2 lasthour

  let "fhr=lasthour+1"
  typeset -Z2 fhr
else
  fhr=00
fi

echo starting with fhr $fhr

DATAFCST="${DATAROOT}/${TAG}_${RUN_FCST_TN}${USCORE_ENSMEM_NAME}.${CDATE}"

while [ $fhr -le $FHRLIM ]
do
  date=$(date +%Y%m%d%H -d "${START_DATE} +${fhr} hours")
  let fhrold="$fhr - 1"
  if [ "${model}" = "FV3S" ]; then
    OUTFILDYN=${DATAFCST}/dynf0${fhr}.nc
    OUTFILPHYS=${DATAFCST}/phyf0${fhr}.nc

    icnt=1
    # wait for model restart file
    while [ $icnt -lt 1000 ]
    do
      if [ -s ${DATAFCST}/log.atm.f0${fhr} ]; then
        break
      else
        icnt=$((icnt + 1))
        sleep 9
      fi
      if [ $icnt -ge 200 ]; then
        msg="FATAL ERROR: ABORTING after 30 minutes of waiting for FV3S ${RUNLOC} FCST F${fhr} to end."
        exit
      fi
    done
  else
    msg="FATAL ERROR: ABORTING due to bad model selection for this script"
    exit
  fi

  NSTAT=1850
  datestr=`date`
  echo top of loop after found needed log file for $fhr at $datestr

cat > itag <<EOF
$OUTFILDYN
$OUTFILPHYS
$model
$OUTTYP
$STARTDATE
$NFILE
$INCR
$fhr
$NSTAT
$OUTFILDYN
$OUTFILPHYS
EOF

  export pgm="regional_bufr.x"
  . prep_step

  export FORT19="$DATA/bufrpost/regional_profdat"
  export FORT79="$DATA/bufrpost/profilm.c1.${tmmark}"
  export FORT11="itag"

  ${APRUNC} ${EXECrrfs}/$pgm >> pgmout 2>errfile
  export err=$?; err_chk

  echo DONE $fhr at `date`

  mv $DATA/bufrpost/profilm.c1.${tmmark} $DATA/profilm.c1.${tmmark}.f${fhr}
  echo done > $DATA/sndpostdone${fhr}.${tmmark}

  cat $DATA/profilm.c1.${tmmark}  $DATA/profilm.c1.${tmmark}.f${fhr} > $DATA/profilm_int
  mv $DATA/profilm_int $DATA/profilm.c1.${tmmark}

  fhr=`expr $fhr + $INCR`

  if [ $fhr -lt 10 ]; then
    fhr=0$fhr
  fi
done

cd $DATA

########################################################
# SNDP code
########################################################

export pgm="rrfs_sndp.x"
. prep_step

cp ${FIX_BUFRSND}/regional_sndp.parm.mono $DATA/regional_sndp.parm.mono
cp ${FIX_BUFRSND}/regional_bufr.tbl $DATA/regional_bufr.tbl

export FORT11="$DATA/regional_sndp.parm.mono"
export FORT32="$DATA/regional_bufr.tbl"
export FORT66="$DATA/profilm.c1.${tmmark}"
export FORT78="$DATA/class1.bufr"
echo here RUNLOC  $RUNLOC
echo here MODEL $MODEL
echo here model $model

nlev=65
FCST_LEN_HRS=$FHRLIM
echo "$nlev $NSTAT $FCST_LEN_HRS" > itag
${APRUNS} $EXECrrfs/$pgm  < itag >> $pgmout 2>errfile
export err=$?; err_chk

SENDCOM=YES

if [ "${SENDCOM}" = "YES" ]; then
  cp $DATA/class1.bufr $COMOUT/rrfs.t${cyc}z.${RUNLOC}.class1.bufr
  cp $DATA/profilm.c1.${tmmark} ${COMOUT}/rrfs.t${cyc}z.${RUNLOC}.profilm.c1
fi

rm stnmlist_input

cat <<EOF > stnmlist_input
1
$DATA/class1.bufr
${COMOUT}/bufr.${NEST}${MODEL}${cyc}/${NEST}${MODEL}bufr
EOF

mkdir -p ${COMOUT}/bufr.${NEST}${MODEL}${cyc}

export pgm="rrfs_stnmlist.x"
. prep_step

export FORT20=$DATA/class1.bufr
export DIRD=${COMOUT}/bufr.${NEST}${MODEL}${cyc}/${NEST}${MODEL}bufr

echo "before stnmlist.x"
${APRUNS} ${EXECrrfs}/$pgm < stnmlist_input >> $pgmout 2>errfile
export err=$?; err_chk
echo "after stnmlist.x"

echo ${COMOUT}/bufr.${NEST}${MODEL}${cyc} > ${COMOUT}/bufr.${NEST}${MODEL}${cyc}/bufrloc

cd ${COMOUT}/bufr.${NEST}${MODEL}${cyc}

# Tar and gzip the individual bufr files and send them to /com
tar -cf - . | /usr/bin/gzip > ../rrfs.t${cyc}z.${RUNLOC}.bufrsnd.tar.gz

GEMPAKrrfs=/lfs/h2/emc/lam/noscrub/emc.lam/FIX_RRFS/gempak
cp $GEMPAKrrfs/fix/snrrfs.prm snrrfs.prm
err1=$?
cp $GEMPAKrrfs/fix/sfrrfs.prm_aux sfrrfs.prm_aux
err2=$?
cp $GEMPAKrrfs/fix/sfrrfs.prm sfrrfs.prm
err3=$?

mkdir -p $COMOUT/gempak

if [ $err1 -ne 0 -o $err2 -ne 0 -o $err3 -ne 0 ]; then
  msg="FATAL ERROR: Missing GEMPAK BUFR tables"
  exit
fi

#  Set input file name.
export INFILE=$COMOUT/rrfs.t${cyc}z.${NEST}${MODEL}.class1.bufr
outfilbase=rrfs_${MODEL}_${PDY}${cyc}

namsnd << EOF > /dev/null
SNBUFR   = $INFILE
SNOUTF   = ${outfilbase}.snd
SFOUTF   = ${outfilbase}.sfc+
SNPRMF   = snrrfs.prm
SFPRMF   = sfrrfs.prm
TIMSTN   = 61/1600
r

exit
EOF

print_info_msg "
========================================================================
BUFR-sounding processing completed successfully.

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

