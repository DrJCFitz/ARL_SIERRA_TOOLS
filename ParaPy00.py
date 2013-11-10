import os
import math
import csv
import fnmatch
from paraview.simple import *

gauge_loc = gauge_loc
Specimen_L_D_Ratio = Specimen_L_D_Ratio
R_IB = R_IB
R_Spec = R_Spec
path0 = 'JOBNUM/'
mesh_coarse = mesh_coarse #1 (coarse), 2 (fine), 4 (extra-fine)

###########################################################################
# Load python modules and define variables (substituted from sed function)
# in controlling script
###########################################################################

# Calculate quantities for the number of intervals
L_Specimen = math.ceil(1.0e6*Specimen_L_D_Ratio*2.0*R_Spec)*1.0e-6
Num_R_Interval_Bar = int(math.floor(R_IB/(L_Specimen/(5.0+4*(mesh_coarse-1)))))
Num_R_Interval_Spec = int(math.ceil(R_Spec/(L_Specimen/(5.0+4*(mesh_coarse-1)))))
Gauge_Loc1 = math.floor(gauge_loc/(L_Specimen/(5.0+4*(mesh_coarse-1))))*(L_Specimen/(5.0+4*(mesh_coarse-1)))

# split the output variables into three categories
datasets = ['spec_xsec','bar_gauge_loc','bar_spec_intrfc'] 

# populate lits of files to load
filelist=[]
for fileName in os.listdir(path0):
  if fnmatch.fnmatch(fileName,'shpb.e.*'):
    filelist.append(os.path.join(path0,fileName))
#

# load the set of files
shpb_e = ExodusIIReader( FileName=filelist )

# specify variables to output and other file settings
shpb_e.ElementVariables = ['left_stretch_xx', 'left_stretch_xy', 'left_stretch_yy', 'left_stretch_yz', 'left_stretch_zx', 'left_stretch_zz', 'rotation_xx', 'rotation_xy', 'rotation_xz', 'rotation_yx', 'rotation_yy', 'rotation_yz', 'rotation_zx', 'rotation_zy', 'rotation_zz', 'stress_xx', 'stress_yy', 'stress_zz', 'stress_xy', 'stress_yz', 'stress_zx', 'stretch_tensor_xx', 'stretch_tensor_zz', 'hydrostatic_stress', 'volume']
shpb_e.XMLFileName = ''
shpb_e.FilePattern = '%s%02i'
shpb_e.GlobalVariables = []
shpb_e.FileRange = [0, len(filelist)-1]
shpb_e.PointVariables = ['accel_', 'disp_', 'vel_']
shpb_e.ElementBlocks=['block_1']
shpb_e.ApplyDisplacements = 0

# output timestep values from simulation
tsteps = shpb_e.TimestepValues

# define writer method to save ans quit file
ts_writer = csv.writer(file(path0+'tsteps.csv','wq!'), delimiter=' ')

# write it to a comma-separated file
ts_writer.writerows([tsteps])

# create ParaView `PlotOverLine' pipeline on shpb_e object
Spec = PlotOverLine(shpb_e)

# the start and end points of line go from inner to outer radius 
# along axis -- in this case, the `IB' face of the specimen
Spec.Source.Point1 = [0.0, 0.0, -L_Specimen/2]
Spec.Source.Point2 = [R_Spec, 0.0, -L_Specimen/2]

# the resolution is set to be the number of radial intervals
Spec.Source.Resolution = Num_R_Interval_Spec

# create an output method for csv files
Spec_write = CreateWriter(path0+datasets[0]+'/S_front.csv',Spec)

# write all the time steps (1=true) corresponding to point values
Spec_write.WriteAllTimeSteps = 1
Spec_write.FieldAssociation = 'Points'

# execute the method (writing `lineout' data to csv files over all timesteps)
Spec_write.UpdatePipeline()
