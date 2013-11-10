#!/bin/csh

# This script meant to be executed by sourcing - i.e. `source JobSub.csh'
# ON UTILITY SERVER - see Utility Server Center-Wide Job Management tutorial

# Name has max of 15 characters; first letter must be alphabetic
# ${InputDir} refers to path of ${InputDeck}.i
set InputDeck = G2k2500Sm1068
set InputDir = /u/home/jfitzpat/quarter_geometry/ShearModulus

# Mesh script filename (*.py) and directory 
set MeshFile = qtr1068fineR550
set MeshDir = /u/home/jfitzpat/quarter_geometry/mesh
# Directory where mesh is generated (on HPC resource)
set HPC_MeshPath = /usr/people/jfitzpat/quarter_geometry/mesh/95bar55spec

# use decimal for floating-point computations
# use a forward slash before multiplication operations
set R_IB = 9.50e-3
set L_IB = 1068
set L_TB = 20\*R_IB
set gauge_loc = 2.52e-3

set R_Spec = 5.4800e-3
set Specimen_L_D_Ratio = 0.114

set mesh_coarse = 2 
#1 (coarse,0.22mm), 2 (fine,0.11), 4 (extra-fine,0.055) element lengths
set ExodusIIFile = shpb
#######################################################################################

# set up job files to be copied -- use transfer queue to copy files to HPC ${WORKDIR}
set PreCopy = `qsub -q transfer@harold -l select=1:ncpus=1:mpiprocs=1 /u/home/jfitzpat/scripts/PreCopy.pbs`
echo PreCopy is ${PreCopy}

mkdir -p /p/cwfs/jfitzpat/${PreCopy}/
mkdir -p /u/work/jfitzpat/${PreCopy}/
# Use appropriate form to specify script for ${MESH_JOB} or existing Genesis (*.g) file
#cp ${MeshDir}/${MeshFile}.py ${InputDir}/${InputDeck}.i /p/cwfs/jfitzpat/${PreCopy}
cp ${InputDir}/${InputDeck}.i /p/cwfs/jfitzpat/${PreCopy}

# Comment out if mesh job not needed; substitute and submit ${MESH_JOB}
#sed -e "16 s;MESH_NAME;${MeshFile};ig" -e "13 s;JOBNUM;${PreCopy};ig" /u/home/jfitzpat/scripts/CubitRun.pbs > /p/cwfs/jfitzpat/${PreCopy}/CubitRun.pbs
#set MESH_JOB = `qsub -q standard@harold -l select=1:ncpus=8:mpiprocs=2 -l walltime=10:00:00 -W depend=afterok:${PreCopy} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/CubitRun.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/CubitRun.e /p/cwfs/jfitzpat/${PreCopy}/CubitRun.pbs`
#echo MESH_JOB is ${MESH_JOB}

# Use appropriate form depending on whether mesh job is needed; substitute variables and submit
# directories on Harold (HPC resource) are specified for output file; otherwise user will get email for `.eo' copy error
sed -e "18,21 s;MESH_PATH;${HPC_MeshPath};2" -e "18,21 s;MESH_NAME;${MeshFile};2" -e "18,21 s;JOBNUM;${PreCopy};ig" -e "18,21 s;INPUT;${InputDeck};2" /u/home/jfitzpat/scripts/HPC_Job.pbs > /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs
set HPC_JOB = `qsub -q standard@harold -l select=4:ncpus=8:mpiprocs=8 -l walltime=80:00:00 -W depend=afterany:${PreCopy} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.e /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
set HPC_JOB = `qsub -q standard@harold -l select=4:ncpus=8:mpiprocs=8 -l walltime=80:00:00 -W depend=afterany:${MESH_JOB} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.e /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
echo HPC_JOB is ${HPC_JOB}

# PostCopy transfers files from HPC resource back to Utility Server - variables substituted into script
sed -e "s;JOBNUM;${PreCopy};ig" -e "s;EXODUSIIFILE;${ExodusIIFile};ig" /u/home/jfitzpat/scripts/PostCopy.pbs > /p/cwfs/jfitzpat/${PreCopy}/PostCopy.pbs
# TransCopy transfers files between CWFS and $WORKDIR on Utility Server - variables substituted into script
sed -e "s;JOBNUM;${PreCopy};ig" -e "s;ExodusIIFile;${ExodusIIFile};ig" /u/home/jfitzpat/scripts/TransCopy.pbs > /p/cwfs/jfitzpat/${PreCopy}/TransCopy.pbs

# Postprocessing on HPC resource or Utility Server?  Choose appropriate ${ParaPy_Dir3}
set ParaPy_Dir1 = /u/home/jfitzpat/scripts/MFParaPy
set ParaPy_Dir2 = /p/cwfs/jfitzpat/${PreCopy}
#set ParaPy_Dir3 = /u/work/jfitzpat/${PreCopy}
set ParaPy_Dir3 = /usr/var/tmp/jfitzpat/${PreCopy}

# sim variables and settings loaded into ParaView scripts, MATLAB script for batch processing
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy00.py > ${ParaPy_Dir2}/ParaPy00.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy01.py > ${ParaPy_Dir2}/ParaPy01.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy02.py > ${ParaPy_Dir2}/ParaPy02.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy03.py > ${ParaPy_Dir2}/ParaPy03.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy04.py > ${ParaPy_Dir2}/ParaPy04.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy10.py > ${ParaPy_Dir2}/ParaPy10.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy11.py > ${ParaPy_Dir2}/ParaPy11.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy10c.py > ${ParaPy_Dir2}/ParaPy10c.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy11c.py > ${ParaPy_Dir2}/ParaPy11c.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy20.py > ${ParaPy_Dir2}/ParaPy20.py
sed -e "s;JOBNUM;${ParaPy_Dir3};ig" -e "4,12 s;gauge_loc;${gauge_loc};2" -e "4,12 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,12 s;R_IB;${R_IB};2" -e "4,12 s;R_Spec;${R_Spec};2" -e "4,12 s;mesh_coarse;${mesh_coarse};2" ${ParaPy_Dir1}/ParaPy21.py > ${ParaPy_Dir2}/ParaPy21.py
sed -e "4 s;path;${ParaPy_Dir3};2" -e "5,$ s/JOBNUM/${PreCopy}/g" -e "5,$ s/.service9//" -e "1,4 s;R_IB;${R_IB};2" -e "1,4 s;R_Spec;${R_Spec};2" -e "1,4 s;mesh_coarse;${mesh_coarse};2" -e "1,5 s;Spec_LD;${Specimen_L_D_Ratio};2" ${ParaPy_Dir1}/SimDataParse.m > ${ParaPy_Dir2}/SimDataParse.m

# copy files from Harold to CWFS
set POST_HPC = `qsub -q transfer@harold -l select=1:ncpus=1:mpiprocs=1 -l walltime=24:00:00 -W depend=afterany:${HPC_JOB} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/Post_HPC.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/Post_HPC.e /p/cwfs/jfitzpat/${PreCopy}/PostCopy.pbs`
echo POST_HPC is ${POST_HPC}

# Note: Utility Server does not support job dependency across HPC resources
# Dependencies for ${TransCopy} and ${ParaView} are completed manually