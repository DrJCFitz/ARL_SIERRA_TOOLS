ARL_SIERRA_TOOLS
================

<p>A collection of bash, Python, MATLAB, and PBS scripts used to semi-automate the run submission, data mining, and analysis tasks of DoE Hydrocode simulations</p>

<p><b>"JobSub.csh"</b>  -  Unix csh script that sets up project environment and copies local files (mesh, input deck, etc.) between remote hosts, submits chain of PBS dependencies on jobs [cubitrun.pbs, PreCopy.pbs, HPC_Job.pbs, PostCopy.pbs]
<ul><li><i>"cubitrun.pbs"</i>  -  Sets up and runs Sandia National Labs' mesh preprocessor based on a source Python file executing CUBIT commands. Example script given in "1068qtrfineR550.py"</li>
<li><i>"PreCopy.pbs"</i>  - File copy between pre-processing server and compute nodes on work server.</li>
<li><i>"HPC_Job.pbs"</i>  -  Executes runtime of PRESTO within Sierra SolidMechanics suite (path and build may be out-of-date as of posting)</li>
<li><i>"PostCopy.pbs"</i>  -  File copy between compute nodes on work server and pre-processing server.</li>
</ul></p>
<p><b>"MFParaPyGen"</b> - csh script to submit serial ParaView batch processing jobs
<ul><li><i>"ParaPy00.py"</i>  - Zero-th of n scripts, where n is number of processors utilized on compute node. This script serializes instances of ParaView (an open-source visualization program that does not support parallel computing); variables are set within the "JobSub.csh" script.</li>
<li><i>"SimDataParse.m"</i> - Reads .txt file output of ParaView into MATLAB structures representing specific parts of analysis focus.</li>
</ul></p>
<p><b>"NewSimDataAnalysisROD.m"</b> and <b>"NewSimDataAnalysisROD_TR.m"</b> -- MATLAB scripts with and without LaTeX markup, respectively.  This script covers permutations of the theoretical and mechanical analysis, generating plots of interest. </p>
