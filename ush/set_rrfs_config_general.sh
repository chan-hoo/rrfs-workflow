
if [[ $MACHINE == "jet" ]] ; then
  ACCOUNT=nrtrr
  if [[ -n $RESERVATION ]] ; then
    ACCOUNT=rtrr
    SERVICE_ACCOUNT=rtrr
    HPSS_ACCOUNT=nrtrr
    PARTITION_DEFAULT=kjet
    PARTITION_FCST=kjet
    PARTITION_GRAPHICS=kjet
    PARTITION_ANALYSIS=kjet
    PARTITION_PRDGEN=kjet
    PARTITION_POST=kjet
    PARTITION_HPSS=service
    QUEUE_DEFAULT="rth"
    QUEUE_FCST="rth"
    QUEUE_ANALYSIS="rth"
    QUEUE_PRDGEN="rt"
    QUEUE_GRAPHICS="rt"
    QUEUE_HPSS="batch"
    QUEUE_POST="rt"
    RESERVATION_POST="rrfsdet"
    NNODES_MAKE_ICS="3"
    PPN_MAKE_ICS="20"
    NNODES_MAKE_LBCS="3"
    PPN_MAKE_LBCS="20"
    NNODES_RUN_POST="1"
    PPN_RUN_POST="40"
  fi

elif [[ $MACHINE == "hera" ]] ; then
  ACCOUNT="zrtrr"
  PARTITION_DEFAULT=""
  PARTITION_FCST=""
  QUEUE_ANALYSIS="batch"
  QUEUE_PRDGEN="batch"
  QUEUE_GRAPHICS="batch"

elif [[ $MACHINE == "orion" ]] ; then
  ACCOUNT="fv3-cam"
  PARTITION_ANALYSIS=orion
  QUEUE_ANALYSIS="batch"
  QUEUE_PRDGEN="batch"
  QUEUE_GRAPHICS="batch"
  QUEUE_POST="batch"
  NCORES_PER_NODE=24

elif [[ $MACHINE == "wcoss2" ]] ; then
  ACCOUNT=RRFS-DEV
  HPSS_ACCOUNT="RRFS-DEV"

  if [[ "${envir}" == "para" ]]; then
    QUEUE_DEFAULT="pridev"
    QUEUE_ANALYSIS="pridev"
    QUEUE_FCST="pridev"
    QUEUE_HPSS="dev_transfer"
    QUEUE_POST="pridev"
    QUEUE_PRDGEN="pridev"
    QUEUE_GRAPHICS="pridev"
  elif [[ "${envir}" == "prod" ]]; then
    QUEUE_DEFAULT="prod"
    QUEUE_ANALYSIS="prod"
    QUEUE_FCST="prod"
    QUEUE_HPSS="prod_transfer"
    QUEUE_POST="prod"
    QUEUE_PRDGEN="prod"
    QUEUE_GRAPHICS="prod"
  else
    QUEUE_DEFAULT="dev"
    QUEUE_ANALYSIS="dev"
    QUEUE_FCST="dev"
    QUEUE_HPSS="dev_transfer"
    QUEUE_POST="dev"
    QUEUE_PRDGEN="dev"
    QUEUE_GRAPHICS="dev"
  fi
  if [[ $MACHINETYPE == "backup" ]] ; then
    QUEUE_DEFAULT="devhigh"
    QUEUE_FCST="devmax"
    QUEUE_ANALYSIS="devmax"
    QUEUE_POST="devhigh"
    QUEUE_PRDGEN="devhigh"
    QUEUE_GRAPHICS="devhigh"
  fi
fi

netcdf_diag=.true.
binary_diag=.false.
HYBENSMEM_NMIN=66
HALO_BLEND=20
PRINT_DIFF_PGR="TRUE"
USE_CUSTOM_POST_CONFIG_FILE="TRUE"
TESTBED_FIELDS_FN="testbed_fields_bgdawp.txt"
TESTBED_FIELDS_FN2="testbed_fields_bgrd3d.txt"
CUSTOM_POST_CONFIG_FP="$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." &>/dev/null&&pwd)/fix/upp/postxconfig-NT-fv3lam_rrfs.txt"
CUSTOM_POST_PARAMS_FP="$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." &>/dev/null&&pwd)/fix/upp/params_grib2_tbl_new"
NCARG_ROOT="/apps/ncl/6.5.0-CentOS6.10_64bit_nodap_gnu447"
NCL_HOME="/home/rtrr/RRFS/graphics"
COMINgfs=""

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

NCORES_RUN_ANAL=360
NCORES_RUN_OBSERVER=80
HYBENSMEM_NMIN=66
IO_LAYOUT_Y=1
PPN_RUN_REF2TTEN=1
PPN_RUN_NONVARCLDANL="6"
NNODES_RUN_NONVARCLDANL="20"
MAXTRIES_GET_EXTRN_ICS="2"
MAXTRIES_GET_EXTRN_LBCS="2"
MAXTRIES_MAKE_ICS="2"
MAXTRIES_MAKE_LBCS="2"
MAXTRIES_RUN_PREPSTART="2"
MAXTRIES_RUN_FCST="2"
MAXTRIES_ANAL_GSI="2"
MAXTRIES_POSTANAL="2"
MAXTRIES_ANAL_ENKF="2"
MAXTRIES_RUN_ANAL="2"
MAXTRIES_CLDANL_NONVAR="2"
MAXTRIES_SAVE_DA_OUTPUT="2"
MAXTRIES_SAVE_RESTART="2"
MAXTRIES_RUN_POST="2"
MAXTRIES_RUN_PRDGEN="2"

WTIME_RUN_FCST="00:45:00"
WTIME_RUN_FCST_LONG="03:45:00"
WTIME_MAKE_LBCS="02:00:00"
WTIME_RUN_ANAL="00:50:00"
WTIME_RUN_PREPSTART="00:20:00"

START_TIME_SPINUP="01:30:00"
START_TIME_PROD="01:40:00"
START_TIME_LATE_ANALYSIS="01:40:00"
START_TIME_CONVENTIONAL_SPINUP="00:40:00"
START_TIME_CONVENTIONAL="00:50:00"
START_TIME_NSSLMOSIAC="00:55:00"
START_TIME_LIGHTNINGNC="00:55:00"
START_TIME_PROCSMOKE="00:50:00"

if [[ ${PREDEF_GRID_NAME} == "RRFS_CONUS_3km" ]] ; then 
  DT_ATMOS=36
  ADDNL_OUTPUT_GRIDS=()
  TILE_LABELS="CONUS REGIONS"
  TILE_SETS="full NE,NC,NW,SE,SC,SW"
  CCPP_PHYS_SUITE="FV3_HRRR_gf"
  PPN_RUN_POSTANAL="5"

  if [[ $MACHINE == "jet" ]] ; then
    if [[ -n $RESERVATION ]] ; then
      NNODES_MAKE_ICS="3"
      PPN_MAKE_ICS="20"
      NNODES_MAKE_LBCS="3"
      PPN_MAKE_LBCS="20"
      TPP_RUN_FCST="2"
      NNODES_RUN_POST="2"
      PPN_RUN_POST="40"
      PPN_PROC_RADAR="20"
      LAYOUT_X=15
      LAYOUT_Y=40
      NCORES_RUN_ANAL=200
      PPN_RUN_NONVARCLDANL="10"
      NNODES_RUN_NONVARCLDANL="12"
      NNODES_RUN_RECENTER="5"
      PPN_RUN_RECENTER="40"

      NCORES_PER_NODE=40
      PPN_RUN_GSIDIAG=20
      START_TIME_PROCSMOKE="00:55:00"

      CLEAN_OLDFCST_HRS="18"
    fi

  elif [[ $MACHINE == "hera" ]] ; then
    LAYOUT_X="15"
    LAYOUT_Y="20"
    PPN_RUN_FCST="20"
    NNODES_RUN_FCST="16"
    PPN_MAKE_ICS="20"
    PPN_MAKE_LBCS="20"
    NNODES_MAKE_ICS="3"
    NNODES_MAKE_LBCS="3"
    TPP_RUN_FCST="2"
    PPN_RUN_POST="40"
    NNODES_RUN_POST="2"
    PPN_RUN_NONVARCLDANL="10"
    NNODES_RUN_NONVARCLDANL="10"
    PPN_RUN_GSIDIAG=40
    PPN_RUN_ENKF="2"
    NNODES_RUN_RECENTER="5"
    PPN_RUN_RECENTER="40"

    WTIME_MAKE_LBCS="00:30:00"
    WTIME_RUN_PREPSTART="00:10:00"
    WTIME_RUN_FCST="00:45:00"
    WTIME_RUN_FCST_LONG="02:30:00"
    WTIME_RUN_ANAL="00:30:00"

    START_TIME_SPINUP="01:10:00"
    START_TIME_PROD="02:10:00"
    START_TIME_LATE_ANALYSIS="01:40:00"

  elif [[ $MACHINE == "wcoss2" ]] ; then
    LAYOUT_X="31"
    LAYOUT_Y="32"
    PPN_MAKE_ICS="32"
    TPP_MAKE_ICS="4"
    PPN_MAKE_LBCS="64"
    TPP_MAKE_LBCS="2"
    NNODES_MAKE_ICS="2"
    NNODES_MAKE_LBCS="1"
    PPN_RUN_ANAL="32"
    TPP_RUN_ANAL="4"
    NNODES_RUN_ANAL="10"
    PPN_RUN_FCST="64"
    TPP_RUN_FCST="2"
    NNODES_RUN_FCST="16"
    PPN_RUN_POST="128"
    NNODES_RUN_POST="1"
    TPP_RUN_POST="1"
    PPN_PROC_RADAR="128"
    NNODES_PROC_RADAR="1"
    PPN_RUN_ENKF="32"
    TPP_RUN_ENKF="4"
    NNODES_RUN_ENKF="24"
    MEMO_RUN_PRDGEN="80G"
    MEMO_RUN_PROCESSBUFR="80G"
    PPN_RUN_NONVARCLDANL="64"
    NNODES_RUN_NONVARCLDANL="10"
    PPN_RUN_GSIDIAG=128
    NNODES_RUN_RECENTER="10"
    PPN_RUN_RECENTER="128"

    MAXTRIES_GET_EXTRN_ICS="1"
    MAXTRIES_GET_EXTRN_LBCS="1"
    MAXTRIES_MAKE_ICS="1"
    MAXTRIES_MAKE_LBCS="1"
    MAXTRIES_RUN_PREPSTART="1"
    MAXTRIES_CLDANL_NONVAR="1"
    MAXTRIES_RECENTER="1"
    MAXTRIES_SAVE_RESTART="1"
    MAXTRIES_PROCESS_BUFR="1"
    MAXTRIES_PROCESS_RADARREF="1"
    MAXTRIES_RUN_FCST="1"
    MAXTRIES_ANAL_GSI="1"
    MAXTRIES_ANAL_ENKF="1"
    MAXTRIES_RUN_POST="2"
    MAXTRIES_RUN_PRDGEN="1"
    MAXTRIES_ANAL_GSI="1"

    WTIME_RUN_FCST="01:15:00"
    WTIME_RUN_FCST_LONG="03:15:00"
    WTIME_RUN_FCST_SPINUP="00:25:00"
    WTIME_MAKE_ICS="00:20:00"
    WTIME_MAKE_LBCS="02:00:00"
    WTIME_RUN_ANAL="00:50:00"
    WTIME_RUN_PREPSTART="00:20:00"

    START_TIME_SPINUP="01:10:00"
    START_TIME_PROD="02:20:00"
    START_TIME_LATE_ANALYSIS="01:40:00"

    FV3GFS_FILE_FMT_ICS="netcdf"
    FV3GFS_FILE_FMT_LBCS="netcdf"

    CLEAN_OLDPROD_HRS="120"
    CLEAN_OLDLOG_HRS="120"
    CLEAN_OLDRUN_HRS="18"
    CLEAN_OLDFCST_HRS="18"
    CLEAN_OLDSTMPPOST_HRS="6"
    CLEAN_NWGES_HRS="28"

  elif [[ $MACHINE == "orion" ]] ; then
    LAYOUT_X="30"
    LAYOUT_Y="40"
    PPN_RUN_FCST="40"
    WTIME_RUN_PRDGEN="00:20:00"
  fi

elif [[ ${PREDEF_GRID_NAME} == "RRFS_CONUS_13km" ]] ; then 
  DT_ATMOS=120
  ADDNL_OUTPUT_GRIDS=()
  TILE_LABELS="CONUS REGIONS"
  TILE_SETS="full NE,NC,NW,SE,SC,SW"
  CCPP_PHYS_SUITE="FV3_HRRR_gf"
  PPN_RUN_POSTANAL="5"

  if [[ $MACHINE == "wcoss2" ]] ; then
    LAYOUT_X="7"
    LAYOUT_Y="8"
    PPN_MAKE_ICS="64"
    TPP_MAKE_ICS="2"
    PPN_MAKE_LBCS="64"
    TPP_MAKE_LBCS="2"
    NNODES_MAKE_ICS="1"
    NNODES_MAKE_LBCS="1"
    PPN_RUN_ANAL="64"
    TPP_RUN_ANAL="2"
    NNODES_RUN_ANAL="1"
    PPN_RUN_FCST="64"
    TPP_RUN_FCST="2"
    NNODES_RUN_FCST="1"
    PPN_RUN_POST="64"
    NNODES_RUN_POST="1"
    PPN_PROC_RADAR="64"
    NNODES_PROC_RADAR="1"
    PPN_RUN_ENKF="32"
    TPP_RUN_ENKF="4"
    NNODES_RUN_ENKF="2"
    PPN_RUN_NONVARCLDANL="128"
    NNODES_RUN_NONVARCLDANL="1"
    PPN_RUN_GSIDIAG=128

    WTIME_GET_EXTRN_ICS="00:05:00"
    WTIME_GET_EXTRN_LBCS="00:05:00"
    WTIME_MAKE_ICS="00:10:00"
    WTIME_MAKE_LBCS="00:30:00"
    WTIME_RUN_PREPSTART="00:05:00"
    WTIME_RUN_FCST="00:35:00"
    WTIME_RUN_FCST_LONG="01:15:00"
    WTIME_RUN_FCST_SPINUP="00:15:00"
    WTIME_RUN_POST="00:05:00"
    WTIME_RUN_PRDGEN="00:10:00"
    WTIME_RUN_ANAL="00:20:00"
    WTIME_RUN_POSTANAL="00:10:00"
    WTIME_RUN_ENKF="00:10:00"
    WTIME_RUN_RECENTER="00:10:00"
    WTIME_PROC_RADAR="00:05:00"
    WTIME_PROC_LIGHTNING="00:05:00"
    WTIME_PROC_BUFR="00:05:00"
    WTIME_RUN_NONVARCLDANL="00:10:00"
    WTIME_SAVE_RESTART="00:05:00"

    MAXTRIES_MAKE_ICS="2"
    MAXTRIES_MAKE_LBCS="2"
    MAXTRIES_RUN_PREPSTART="2"
    MAXTRIES_RUN_FCST="2"
    MAXTRIES_ANAL_GSI="2"
    MAXTRIES_ANAL_ENKF="2"
    MAXTRIES_RUN_POST="2"
    MAXTRIES_RUN_PRDGEN="2"
    MAXTRIES_ANAL_GSI="2"

    FV3GFS_FILE_FMT_ICS="netcdf"
    FV3GFS_FILE_FMT_LBCS="netcdf"

  elif [[ $MACHINE == "orion" ]] ; then
    LAYOUT_X="30"
    LAYOUT_Y="40"
    PPN_RUN_FCST="40"
    WTIME_RUN_PRDGEN="00:20:00"
 
  elif [[ $MACHINE == "hera" ]] ; then
    NNODES_MAKE_ICS="1"
    NNODES_MAKE_LBCS="1"
    NNODES_RUN_POST="1"
    NCORES_RUN_ANAL=60
    NATIVE_RUN_ANAL="--cpus-per-task 4 --exclusive"

    LAYOUT_X=12
    LAYOUT_Y=6

    PPN_MAKE_ICS="20"
    PPN_MAKE_LBCS="20"
    NNODES_MAKE_ICS="1"
    NNODES_MAKE_LBCS="1"
    PPN_RUN_ANAL="20"
    NNODES_RUN_ANAL="3"
    PPN_RUN_FCST="20"
    NNODES_RUN_FCST="3"
    TPP_RUN_FCST="2"
    PPN_RUN_POST="20"
    NNODES_RUN_POST="1"
    PPN_PROC_RADAR="40"
    NNODES_PROC_RADAR="1"
    NCORES_RUN_OBSERVER="40"
    PPN_RUN_NONVARCLDANL="20"
    NNODES_RUN_NONVARCLDANL="5"
    PPN_RUN_GSIDIAG=40
  fi

elif [[ ${PREDEF_GRID_NAME} == "RRFS_NA_3km" ]] ; then 
  DT_ATMOS=36
  CCPP_PHYS_SUITE="FV3_HRRR_gf"
  ADDNL_OUTPUT_GRIDS=( "hrrr" "hrrrak" )
  TILE_LABELS="NA hrrr_regions1 hrrr_regions2 hrrr_tiles1 hrrr_tiles2 hrrr_tiles3 \
    hrrr_tiles4 hrrrak_tiles"
  TILE_SETS="full SE,SC,SW NE,NC,NW ATL,CA-NV,CentralCA CHI-DET,DCArea,EastCO \
    GreatLakes,NYC-BOS,SEA-POR SouthCA,SouthFL,VortexSE AKRange,Anchorage,Juneau"
  PPN_RUN_POSTANAL="5"

  if [[ -n $RESERVATION ]] ; then
    NNODES_MAKE_ICS="10"
    NNODES_MAKE_LBCS="5"
    PPN_MAKE_ICS="8"
    PPN_MAKE_LBCS="10"
    WTIME_MAKE_LBCS="02:45:00"
    WTIME_RUN_PREPSTART="00:20:00"
    PPN_RUN_PREPSTART="5"
    WRTCMP_write_tasks_per_group="50"
    NCORES_PER_NODE="40"
    MEMO_RUN_REF2TTEN="60G"
    TPP_RUN_FCST="4"
    WTIME_RUN_FCST="04:00:00"
    LAYOUT_X=50
    LAYOUT_Y=20
    IO_LAYOUT_Y=10
    PPN_RUN_NONVARCLDANL="10"
    NNODES_RUN_NONVARCLDANL="20"
    NATIVE_RUN_FCST="--cpus-per-task 4 --exclusive"
    NATIVE_RUN_ANAL="--cpus-per-task 4 --exclusive"

    PARTITION_POST="kjet"
    PPN_RUN_POST="20"
    NNODES_RUN_POST="10"
    WTIME_RUN_POST="00:35:00"
  fi

  if [[ $MACHINE == "wcoss2" ]] ; then
    WRTCMP_write_groups="1"
    WRTCMP_write_tasks_per_group="128"
    LAYOUT_X="50"
    LAYOUT_Y="64"
    PPN_MAKE_ICS="32"
    TPP_MAKE_ICS="4"
    PPN_MAKE_LBCS="64"
    TPP_MAKE_LBCS="2"
    NNODES_MAKE_ICS="2"
    NNODES_MAKE_LBCS="1"
    PPN_RUN_ANAL="8"
    NNODES_RUN_ANAL="60"
    TPP_RUN_ANAL="16"
    PPN_RUN_FCST="64"
    NNODES_RUN_FCST="51"
    TPP_RUN_FCST="2"
    PPN_RUN_POST="32"
    NNODES_RUN_POST="4"
    TPP_RUN_POST="4"
    PPN_PROC_RADAR="64"
    NNODES_PROC_RADAR="1"
    PPN_RUN_ENKF="8"
    NNODES_RUN_ENKF="10"
    TPP_RUN_ENKF="16"
    PPN_RUN_NONVARCLDANL="128"
    NNODES_RUN_NONVARCLDANL="1"
    PPN_RUN_PRDGEN="128"
    PPN_RUN_POSTANAL="8"
    PPN_RUN_GSIDIAG=128
    NNODES_RUN_BUFRSND="2"
    PPN_RUN_BUFRSND="64"
    NNODES_RUN_RECENTER="10"
    PPN_RUN_RECENTER="128"

    MAXTRIES_MAKE_ICS="1"
    MAXTRIES_MAKE_LBCS="1"
    MAXTRIES_RUN_PREPSTART="1"
    MAXTRIES_RUN_FCST="1"
    MAXTRIES_ANAL_GSI="1"
    MAXTRIES_ANAL_ENKF="1"
    MAXTRIES_RUN_POST="2"
    MAXTRIES_RUN_PRDGEN="1"
    MAXTRIES_ANAL_GSI="1"

    MEMO_RUN_NONVARCLDANL="256G"
    MEMO_PROC_SMOKE="256G"
    MEMO_RUN_PREPSTART="120G"
    MEMO_PREP_CYC="40G"
    MEMO_SAVE_RESTART="120G"
    MEMO_SAVE_INPUT="120G"                                                                                                     
    MEMO_RUN_PRDGEN="256G"

    START_TIME_SPINUP="01:05:00"
    START_TIME_PROD="02:20:00"
    START_TIME_LATE_ANALYSIS="01:20:00"
    START_TIME_CONVENTIONAL="00:45:00"
    START_TIME_NSSLMOSIAC="00:45:00"

    FV3GFS_FILE_FMT_ICS="netcdf"
    FV3GFS_FILE_FMT_LBCS="netcdf"

    WTIME_RUN_FCST="02:30:00"
    WTIME_RUN_FCST_LONG="05:30:00"
    WTIME_MAKE_LBCS="02:30:00"
    WTIME_RUN_BUFRSND="04:45:00"

    CLEAN_OLDPROD_HRS="120"
    CLEAN_OLDLOG_HRS="120"
    CLEAN_OLDRUN_HRS="18"
    CLEAN_OLDFCST_HRS="18"
    CLEAN_OLDSTMPPOST_HRS="12"
    CLEAN_NWGES_HRS="18"

  elif [[ $MACHINE == "hera" ]] ; then
    CCPP_PHYS_SUITE="FV3_HRRR"
    WRTCMP_write_groups="1"
    WRTCMP_write_tasks_per_group="50"
    LAYOUT_X="50"
    LAYOUT_Y="20"
    PPN_RUN_FCST="10"
    NNODES_RUN_FCST="105"
    TPP_RUN_FCST="4"
    PPN_RUN_NONVARCLDANL="10"
    NNODES_RUN_NONVARCLDANL="20"
    NATIVE_RUN_ANAL="--cpus-per-task 4 --exclusive"
    PPN_RUN_GSIDIAG=40
  fi

elif [[ ${PREDEF_GRID_NAME} == "GSD_RAP13km" ]] ; then 
  DT_ATMOS=120
  CCPP_PHYS_SUITE="FV3_RAP"
  ADDNL_OUTPUT_GRIDS=( "130" "242" )
  TILE_LABELS="NA"
  TILE_SETS="full"
  NNODES_RUN_POST="1"
  grid_ratio_fv3=1.0
  PPN_RUN_POSTANAL="5"
  LAYOUT_X="16"
  LAYOUT_Y="16"
  PPN_RUN_FCST="20"
  NNODES_RUN_FCST="11"
fi

