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

This is the ex-script for the task that runs the bufr-sounding 
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set environment
#
#-----------------------------------------------------------------------
#
ulimit -s unlimited
ulimit -a

case $MACHINE in

  "WCOSS2")
    ncores=$(( NNODES_RUN_BUFRSND*PPN_RUN_BUFRSND ))
    APRUNC="mpiexec -n ${ncores} -ppn ${PPN_RUN_BUFRSND}"
    APRUNS="time"
    ;;

  "HERA")
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  "ORION")
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  "HERCULES")
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  "JET")
    APRUNC="srun --export=ALL"
    APRUNS="time"
    ;;

  *)
    err_exit "\
Run command has not been specified for this machine:
  MACHINE = \"$MACHINE\"
  APRUN = \"$APRUN\""
    ;;

esac
#
#-----------------------------------------------------------------------
#
# Create a text file (itag) containing arguments to pass to the post-
# processing executable.
#
#-----------------------------------------------------------------------
#
cd $DATA/bufrpost

export tmmark="tm00"

cp ${FIX_BUFRSND}/${PREDEF_GRID_NAME}/rrfs_profdat regional_profdat

OUTTYP=netcdf
model=FV3S
INCR=01
FHRLIM=60

let NFILE=1

START_DATE=$(echo "${CDATE}" | sed 's/\([[:digit:]]\{2\}\)$/ \1/')
YYYY=${CDATE:0:4}
MM=${CDATE:4:2}
DD=${CDATE:6:2}
STARTDATE=${YYYY}-${MM}-${DD}_${cyc}:00:00
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
if [ "${CYCLE_TYPE}" = "spinup" ]; then
  if [ "${CYCLE_SUBTYPE}" = "ensinit" ]; then
    DATAFCST="${DATAROOT}/${TAG}_${RUN_FCST_TN}_ensinit${USCORE_ENSMEM_NAME}.${CDATE}"
  else
    DATAFCST="${DATAROOT}/${TAG}_${RUN_FCST_TN}_spinup${USCORE_ENSMEM_NAME}.${CDATE}"
  fi
else
  DATAFCST="${DATAROOT}/${TAG}_${RUN_FCST_TN}_prod${USCORE_ENSMEM_NAME}.${CDATE}"
fi

while [ $fhr -le $FHRLIM ]
do

  date=$(date +%Y%m%d%H -d "${START_DATE} +${fhr} hours")

  let fhrold="$fhr - 1"

  if [ $model = "FV3S" ]; then
    OUTFILDYN="${DATAFCST}/dynf0${fhr}.nc"
    OUTFILPHYS="${DATAFCST}/phyf0${fhr}.nc"

    icnt=1

    # wait for model restart file
    while [ $icnt -lt 1000 ]
    do
      if [ -s "${DATAFCST}/log.atm.f0${fhr}" ]; then
        break
      else
        icnt=$((icnt + 1))
        sleep 9
      fi
      if [ $icnt -ge 200 ]; then
        err_exit "ABORTING after 30 minutes of waiting for RRFS FCST F${fhr} to end."
      fi
    done

  else
    err_exit "ABORTING due to bad model selection for this script."
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

  export pgm="rrfs_bufr.exe"
  . prep_step

  export FORT19="$DATA/bufrpost/regional_profdat"
  export FORT79="$DATA/bufrpost/profilm.c1.${tmmark}"
  export FORT11="itag"

  ${APRUNC} ${EXECrrfs}/$pgm >>$pgmout 2>errfile
  export err=$?; err_chk
  mv errfile errfile_rrfs_bufr

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

export pgm="rrfs_sndp.exe"
. prep_step

cp ${FIX_BUFRSND}/regional_sndp.parm.mono $DATA/regional_sndp.parm.mono
cp ${FIX_BUFRSND}/regional_bufr.tbl $DATA/regional_bufr.tbl

export FORT11="$DATA/regional_sndp.parm.mono"
export FORT32="$DATA/regional_bufr.tbl"
export FORT66="$DATA/profilm.c1.${tmmark}"
export FORT78="$DATA/class1.bufr"

echo here model $model

nlev=65

FCST_LEN_HRS=$FHRLIM
echo "$nlev $NSTAT $FCST_LEN_HRS" > itag

${APRUNS} ${EXECrrfs}/$pgm < itag >>$pgmout 2>errfile
export err=$?; err_chk
mv errfile errfile_rrfs_sndp

if [ "${SENDCOM}" = "YES" ]; then
  cp $DATA/class1.bufr $COMOUT/rrfs.t${cyc}z.class1.bufr
  cp $DATA/profilm.c1.${tmmark} ${COMOUT}/rrfs.t${cyc}z.profilm.c1
fi

rm stnmlist_input

cat <<EOF > stnmlist_input
1
$DATA/class1.bufr
${COMOUT}/bufr.${cyc}/bufr
EOF

export pgm="rrfs_stnmlist.exe"
. prep_step

export FORT20=$DATA/class1.bufr
export DIRD=${COMOUT}/bufr.${cyc}/bufr

echo "before stnmlist.exe"
${APRUNS} ${EXECrrfs}/$pgm < stnmlist_input >>$pgmout 2>errfile
export err=$?; err_chk
mv errfile errfile_rrfs_stnmlist
echo "after stnmlist.exe"

echo ${COMOUT}/bufr.${cyc} > ${COMOUT}/bufr.${cyc}/bufrloc

cd ${COMOUT}/bufr.${cyc}

# Tar and gzip the individual bufr files and send them to /com
tar -cf - . | /usr/bin/gzip > ../rrfs.t${cyc}z.bufrsnd.tar.gz

GEMPAKrrfs=/lfs/h2/emc/lam/noscrub/emc.lam/FIX_RRFS/gempak
cp $GEMPAKrrfs/fix/snrrfs.prm snrrfs.prm
err1=$?
cp $GEMPAKrrfs/fix/sfrrfs.prm_aux sfrrfs.prm_aux
err2=$?
cp $GEMPAKrrfs/fix/sfrrfs.prm sfrrfs.prm
err3=$?

if [ $err1 -ne 0 -o $err2 -ne 0 -o $err3 -ne 0 ]; then
  err_exit "Missing GEMPAK BUFR tables"
fi

#  Set input file name.
export INFILE=$COMOUT/rrfs.${cycle}.class1.bufr

outfilbase=rrfs_${CDATE}

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
BUFR-sounding -processing completed successfully.

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

