MACHINE="hera"
#RESERVATION="rrfsdet"

################################################################
#EXPT_BASEDIR="YourOwnSpace"
EXPT_SUBDIR="rrfs_test_da"

envir_default="test"
NET_default="rrfs"
model_ver_default="v0.0.0"
RUN_default="rrfs"
TAG="c0v00"

PTMP="/scratch2/NCEPDEV/stmp3/${USER}/rrfs_test_da"

EXTRN_MDL_DATE_JULIAN="TRUE"

#USE_CRON_TO_RELAUNCH="TRUE"
#CRON_RELAUNCH_INTVL_MNTS="03"
################################################################

PREDEF_GRID_NAME=RRFS_CONUS_3km

. set_rrfs_config_general.sh

################################################################
ACCOUNT="fv3-cam"
################################################################

. set_rrfs_config_SDL_VDL_MixEn.sh

#DO_ENSEMBLE="TRUE"
#DO_ENSFCST="TRUE"
DO_DACYCLE="TRUE"
DO_SURFACE_CYCLE="TRUE"
DO_SPINUP="TRUE"
DO_SAVE_INPUT="TRUE"
DO_POST_SPINUP="FALSE"
DO_POST_PROD="TRUE"
DO_RETRO="TRUE"
DO_NONVAR_CLDANAL="TRUE"
DO_ENVAR_RADAR_REF="FALSE"
DO_SMOKE_DUST="TRUE"
DO_REFL2TTEN="FALSE"
RADARREFL_TIMELEVEL=(0)
FH_DFI_RADAR="0.0,0.25,0.5"
DO_SOIL_ADJUST="TRUE"
DO_RADDA="TRUE"
DO_BUFRSND="FALSE"
USE_FVCOM="TRUE"
PREP_FVCOM="TRUE"
DO_PARALLEL_PRDGEN="FALSE"
DO_GSIDIAG_OFFLINE="TRUE"
DO_UPDATE_BC="TRUE"

EXTRN_MDL_ICS_OFFSET_HRS="3"
LBC_SPEC_INTVL_HRS="1"
EXTRN_MDL_LBCS_OFFSET_HRS="6"
BOUNDARY_LEN_HRS="24"
BOUNDARY_PROC_GROUP_NUM="12"

DATE_FIRST_CYCL="20230611"
DATE_LAST_CYCL="20230611"
CYCL_HRS=( "00" "12" )
CYCL_HRS_SPINSTART=("03" "15")
CYCL_HRS_PRODSTART=("09" "21")
CYCLEMONTH="06"
CYCLEDAY="11"

STARTYEAR=${DATE_FIRST_CYCL:0:4}
STARTMONTH=${DATE_FIRST_CYCL:4:2}
STARTDAY=${DATE_FIRST_CYCL:6:2}
STARTHOUR="00"
ENDYEAR=${DATE_LAST_CYCL:0:4}
ENDMONTH=${DATE_LAST_CYCL:4:2}
ENDDAY=${DATE_LAST_CYCL:6:2}
ENDHOUR="23"

PREEXISTING_DIR_METHOD="upgrade"
INITIAL_CYCLEDEF="${DATE_FIRST_CYCL}0300 ${DATE_LAST_CYCL}2300 12:00:00"
BOUNDARY_CYCLEDEF="${DATE_FIRST_CYCL}0000 ${DATE_LAST_CYCL}2300 06:00:00"
PROD_CYCLEDEF="00 01-11,13-23 ${CYCLEDAY} ${CYCLEMONTH} ${STARTYEAR} *"
PRODLONG_CYCLEDEF="00 00,12 ${CYCLEDAY} ${CYCLEMONTH} ${STARTYEAR} *"
ARCHIVE_CYCLEDEF="${DATE_FIRST_CYCL}1400 ${DATE_LAST_CYCL}2300 24:00:00"
if [[ $DO_SPINUP == "TRUE" ]] ; then
  SPINUP_CYCLEDEF="00 03-08,15-20 ${CYCLEDAY} ${CYCLEMONTH} ${STARTYEAR} *"
fi
FCST_LEN_HRS="9"
FCST_LEN_HRS_SPINUP="1"
for i in {0..23}; do FCST_LEN_HRS_CYCLES[$i]=9; done
for i in {0..23..3}; do FCST_LEN_HRS_CYCLES[$i]=24; done
DA_CYCLE_INTERV="1"
RESTART_INTERVAL="1"
RESTART_INTERVAL_LONG="1"
## set up post
POSTPROC_LEN_HRS="9"
POSTPROC_LONG_LEN_HRS="24"
# 15 min output upto 18 hours
OUTPUT_FH="0.0 0.25 0.50 0.75 1.0 1.25 1.50 1.75 2.0 2.25 2.50 2.75 3.0 3.25 3.50 3.75 4.0 4.25 4.50 4.75 5.0 5.25 5.50 5.75 6.0 6.25 6.50 6.75 7.0 7.25 7.50 7.75 8.0 8.25 8.50 8.75 9.0 9.25 9.50 9.75 10.0 10.25 10.50 10.75 11.0 11.25 11.50 11.75 12.0 13.0 14.0 15.0 16.0 17.0 18.0 19.0 20.0 21.0 22.0 23.0 24.0"

USE_RRFSE_ENS="FALSE"
CYCL_HRS_HYB_FV3LAM_ENS=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23")

SST_update_hour=01
GVF_update_hour=04
SNOWICE_update_hour=01
SOIL_SURGERY_time=2023061004
netcdf_diag=.true.
binary_diag=.false.
WRTCMP_output_file="netcdf_parallel"

regional_ensemble_option=1   # 5 for RRFS ensemble

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

ARCHIVEDIR="/1year/BMC/wrfruc/rrfs_b"
NCL_REGION="conus"

. set_rrfs_config.sh

if [[ ${regional_ensemble_option} == "5" ]]; then
  NUM_ENS_MEMBERS=30     # FV3LAM ensemble size for GSI hybrid analysis
  CYCL_HRS_PRODSTART_ENS=( "07" "19" )
  DO_ENVAR_RADAR_REF="TRUE"
fi
