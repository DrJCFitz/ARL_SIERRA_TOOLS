ARL_SIERRA_TOOLS
================

A collection of bash, Python, MATLAB, and PBS scripts used to semi-automate the run submission, data mining, and analysis tasks of DoE Hydrocode simulations

"JobSub.csh"  -  Unix csh script that sets up project environment and copies local files (mesh, input deck, etc.) between remote hosts, submits chain of PBS dependencies on jobs [cubitrun.pbs, PreCopy.pbs, HPC_Job.pbs, PostCopy.pbs]
 *  "cubitrun.pbs"  -  Sets up and runs Sandia National Labs' mesh preprocessor based on a source Python file executing CUBIT commands. Example script given in "1068qtrfineR550.py"
 *  "PreCopy.pbs"  - File copy between pre-processing server and compute nodes on work server.
 *  "HPC_Job.pbs"  -  Executes runtime of PRESTO within Sierra SolidMechanics suite (path and build may be out-of-date as of posting)
 *  "PostCopy.pbs"  -  File copy between compute nodes on work server and pre-processing server.
 

"ParaPy00.py"  - Zero-th of n scripts, where n is number of processors utilized on compute node. This script serializes instances of ParaView (an open-source visualization program that does not support parallel computing); variables are set within the "JobSub.csh" script.
"NewSimDataAnalysisROD.m" and "NewSimDataAnalysisROD_TR.m" -- MATLAB scripts with and without LaTeX markup, respectively.  This script covers permutations of the theoretical and mechanical analysis, generating plots of interest. 
