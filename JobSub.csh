#!/bin/csh

# Name has max of 15 characters, with first letter alphabetic
set InputDeck = G30k2500OPS1004
set InputDir = /u/home/jfitzpat/quarter_geometry/ShearModulus
set MeshFile = qtr1004xfineR550_1
set MeshDir = /u/home/jfitzpat/quarter_geometry/mesh

# decimal point for floating-point
# use a forward slash before multiplication operations
set R_IB = 9.50e-3
set L_IB = 1004
set L_TB = 20\*R_IB
set gauge_loc = 2.52e-3

set R_Spec = 5.48e-3
set Specimen_L_D_Ratio = 0.114

set Spec_mesh_coarse = 3 
set Bar_mesh_coarse = 2
set ExodusIIFile = shpb
#######################################################################################

set PreCopy = `qsub -h -q transfer@harold -l select=1:ncpus=1:mpiprocs=1 /u/home/jfitzpat/scripts/PreCopy.pbs`
#set PreCopy = `qsub -q transf`r@harold -l select=1:ncpus=1:mpiprocs=1 -W depend=afterany:577631.service9 /u/home/jfitzpat/scripts/PreCopy.pbs`
echo PreCopy is ${PreCopy}

mkdir -p /p/cwfs/jfitzpat/${PreCopy}/
mkdir -p /u/work/jfitzpat/${PreCopy}/
#cp ${MeshDir}/${MeshFile}.py ${InputDir}/${InputDeck}.i /p/cwfs/jfitzpat/${PreCopy} 
cp ${InputDir}/${InputDeck}.i ${MeshDir}/${MeshFile}.* /p/cwfs/jfitzpat/${PreCopy} &
#cp ${InputDir}/${InputDeck}.i /p/cwfs/jfitzpat/${PreCopy}

# Comment out if mesh job not needed
#set HPC_MeshPath = /usr/people/jfitzpat/quarter_geometry/mesh/95bar55spec
set HPC_MeshPath = /usr/var/tmp/jfitzpat/${PreCopy}
#sed -e "16 s;MESH_NAME;${MeshFile};ig" -e "13 s;JOBNUM;${PreCopy};ig" /u/home/jfitzpat/scripts/CubitRun.pbs > /p/cwfs/jfitzpat/${PreCopy}/CubitRun.pbs
#set MESH_JOB = `qsub -q standard@harold -l select=1:ncpus=8:mpiprocs=1 -l walltime=10:00:00 -W depend=afterok:${PreCopy} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/CubitRun.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/CubitRun.e /p/cwfs/jfitzpat/${PreCopy}/CubitRun.pbs`
#set MESH_JOB = `qsub -q standard@harold -l select=1:ncpus=8:mpiprocs=1 -l walltime=10:00:00 -W depend=afterany:${PreCopy}:xxxxxx.service9 /p/cwfs/jfitzpat/${PreCopy}/CubitRun.pbs`
#set MESH_JOB = 604648.service9
#echo MESH_JOB is ${MESH_JOB}

# Comment out depending on whether or not mesh job is needed 
sed -e "18,21 s;MESH_PATH;${HPC_MeshPath};2" -e "18,21 s;MESH_NAME;${MeshFile};2" -e "18,21 s;JOBNUM;${PreCopy};ig" -e "18,21 s;INPUT;${InputDeck};2" /u/home/jfitzpat/scripts/HPC_Job.pbs > /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs
#set HPC_JOB = `qsub -q standard@harold -l select=12:ncpus=8:mpiprocs=8 -l walltime=96:00:00 -W depend=afterany:${PreCopy} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.e /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
set HPC_JOB = `qsub -q debug@harold -l select=8:ncpus=8:mpiprocs=8 -l walltime=01:00:00 -W depend=afterany:${PreCopy} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.e /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
#set HPC_JOB = `qsub -q debug@harold -l select=4:ncpus=8:mpiprocs=8 -l walltime=01:00:00 -W depend=afterany:${PreCopy} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.e /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
#set HPC_JOB = `qsub -q standard@harold -l select=2:ncpus=8:mpiprocs=8 -l walltime=80:00:00 -W depend=afterany:${MESH_JOB} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/HPC_Job.e /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
#set HPC_JOB = `qsub -q standard@harold -l select=8:ncpus=8:mpiprocs=8 -l walltime=80:00:00 -W depend=afterok:${PreCopy} /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
#set HPC_JOB = `qsub -q standard@harold -l select=8:ncpus=8:mpiprocs=8 -l walltime=80:00:00 -W depend=afterany:577517.service9 /p/cwfs/jfitzpat/${PreCopy}/HPC_Job.pbs` 
echo HPC_JOB is ${HPC_JOB}

## transfer input and mesh files to temporary directories on utility server and Harold
sed -e "s;JOBNUM;${PreCopy};ig" -e "s;EXODUSIIFILE;${ExodusIIFile};ig" /u/home/jfitzpat/scripts/PostCopy.pbs > /p/cwfs/jfitzpat/${PreCopy}/PostCopy.pbs
sed -e "s;JOBNUM;${PreCopy};ig" -e "s;ExodusIIFile;${ExodusIIFile};ig" /u/home/jfitzpat/scripts/TransCopy.pbs > /p/cwfs/jfitzpat/${PreCopy}/TransCopy.pbs

set ParaPy_Dir1 = /u/home/jfitzpat/scripts/MFParaPy/
set ParaPy_Dir2 = /p/cwfs/jfitzpat/${PreCopy}
set ParaPy_Dir3 = /u/work/jfitzpat/${PreCopy}
##set ParaPy_Dir3 = /usr/var/tmp/jfitzpat/${PreCopy}
sed -e "1,7 s;path;${ParaPy_Dir3};2" -e "s;JOBNUM;${PreCopy};ig" -e "7,$ s;.service9;;ig" -e "1,6 s;Spec_LD;${Specimen_L_D_Ratio};2" -e "1,6 s;R_IB;${R_IB};2" -e "1,6 s;R_Spec;${R_Spec};2" -e "1,6 s;Bar_mesh_coarse;${Bar_mesh_coarse};2" -e "1,6 s;Spec_mesh_coarse;${Spec_mesh_coarse};2" ${ParaPy_Dir1}/SimDataParse.m > ${ParaPy_Dir3}/SimDataParse.m

sed -e "2,4 s;ParaPy_CD;${ParaPy_Dir2};2" -e "2,4 s;ParaPy_WD;${ParaPy_Dir3};2" -e "69,71 s;ParaPy_WD;${ParaPy_Dir3};ig" ${ParaPy_Dir1}/MFParaPyGen > ${ParaPy_Dir2}/MFParaPyGen

cd ${ParaPy_Dir1}
set FILES = *.py
set i = 1
while ($i <= ${#FILES})
  sed -e "s;JOBNUM;${PreCopy};ig" -e "4,15 s;gauge_loc;${gauge_loc};2" -e "4,15 s;Specimen_L_D_Ratio;${Specimen_L_D_Ratio};2" -e "4,15 s;R_IB;${R_IB};2" -e "4,15 s;R_Spec;${R_Spec};2" -e "4,15 s;Bar_mesh_coarse;${Bar_mesh_coarse};2" -e "4,15 s;Spec_mesh_coarse;${Spec_mesh_coarse};2" ${ParaPy_Dir1}/$FILES[$i] > ${ParaPy_Dir2}/$FILES[$i]
  @ i++
end

# Perform ParaView data parsing, wait 
#sed -e "3 s;ParaPy_WD3;${ParaPy_Dir3};2" -e "28 s;ParaPy_WD3;${ParaPy_Dir3};ig" ${ParaPy_Dir1}/MFParaPyGen > ${ParaPy_Dir2}/MFParaPyGen
#set PARAVIEW = `qsub -q standard@harold -l select=2:ncpus=8:mpiprocs=8 -l walltime=18:00:00 -A ARLAP01001600 -W depend=afterok:${HPC_JOB} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/ParaView.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/ParaView.e /p/cwfs/jfitzpat/${PreCopy}/MFParaPyGen`
#echo PARAVIEW is ${PARAVIEW}

## copy files from Harold to CWFS
##set POST_HPC = `qsub -q transfer@harold -l select=1:ncpus=1:mpiprocs=1 -l walltime=24:00:00 -W depend=afterany:${PARAVIEW} /p/cwfs/jfitzpat/${PreCopy}/PostCopy.pbs`
##set POST_HPC = `qsub -q transfer@harold -l select=1:ncpus=1:mpiprocs=1 -l walltime=24:00:00 -W depend=afterany:${HPC_JOB} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/Post_HPC.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/Post_HPC.e /p/cwfs/jfitzpat/${PreCopy}/PostCopy.pbs`
set POST_HPC = `qsub -q transfer@harold -l select=1:ncpus=1:mpiprocs=1 -l walltime=24:00:00 -W depend=afterok:${HPC_JOB} -o harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/Post_HPC.o -e harold-l3.arl.hpc.mil:/usr/var/tmp/jfitzpat/${PreCopy}/Post_HPC.e /p/cwfs/jfitzpat/${PreCopy}/PostCopy.pbs`
echo POST_HPC is ${POST_HPC}


# copy files from CWFS to utility server $WORKDIR
#set POST_TRANS = `qsub -l select=1:ncpus=1 -l walltime=12:00:00 -W depend=afterok:${POST_HPC} /p/cwfs/jfitzpat/${PreCopy}/TransCopy.pbs`
#echo POST_TRANS is ${POST_TRANS}

# Perform ParaView data parsing, wait 
#sed -e "3 s;ParaPy_WD3;${ParaPy_Dir3};2" -e "28 s;ParaPy_WD3;${ParaPy_Dir3};ig" ${ParaPy_Dir1}/MFParaPyGen > ${ParaPy_Dir2}/MFParaPyGen
#set PARAVIEW = `qsub -l select=1:ncpus=16 -l walltime=18:00:00 -A ARLAP01001600 -W depend=afterok:${POST_TRANS} -o /p/cwfs/jfitzpat/${PreCopy}/ParaView.o -e /p/cwfs/jfitzpat/${PreCopy}/ParaView.e /p/cwfs/jfitzpat/${PreCopy}/MFParaPyGen`
#echo PARAVIEW is ${PARAVIEW}

wait

#qrls ${PreCopy} @harold
cd /u/home/jfitzpat/scripts/
