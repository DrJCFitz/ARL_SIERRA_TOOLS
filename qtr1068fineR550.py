#!python
#!python
import cubit
cubit.cmd('reset')
cubit.cmd('#Mesh_Coarse : {Mesh_Coarse = 2}')
cubit.cmd('#Specimen_End_Strain : {Specimen_End_Strain = 2/3}')
cubit.cmd('#Specimen_L_D_Ratio : {Specimen_L_D_Ratio = 0.114}')
cubit.cmd('#R_Specimen : {R_Specimen = 5.48e-3}')
cubit.cmd('#L_Specimen : {L_Specimen = ceil(1e6*Specimen_L_D_Ratio*2*R_Specimen)/1e6}')
cubit.cmd('#Bar_Z_IntervalSize: {Bar_Z_IntervalSize = L_Specimen/(5*Mesh_Coarse)}')
cubit.cmd('#Num_R_Interval_Spec: {Num_R_Interval_Spec = floor( R_Specimen / Bar_Z_IntervalSize )}')
cubit.cmd('#R1_Specimen : {R1_Specimen = ceil(Num_R_Interval_Spec/2)*(R_Specimen/Num_R_Interval_Spec)}')

cubit.cmd('#R_IB : {R_IB = 9.50e-3}')
cubit.cmd('#L_IB : {L_IB = ceil(1068e-3/Bar_Z_IntervalSize)*Bar_Z_IntervalSize}')
#cubit.cmd('#L_TB : {L_TB = ceil(1800e-3/Bar_Z_IntervalSize)*Bar_Z_IntervalSize}')
cubit.cmd('#L_TB : {L_TB = ceil(20*R_IB/Bar_Z_IntervalSize)*Bar_Z_IntervalSize}')
cubit.cmd('#Num_R_Interval_Bar: {Num_R_Interval_Bar = floor( R_IB / Bar_Z_IntervalSize )}')
cubit.cmd('#R1_IB: {R1_IB = ceil(Num_R_Interval_Bar/2)*(R_IB/Num_R_Interval_Bar)}')
cubit.cmd('#Gauge_Loc : {Gauge_Loc = floor(2.52e-3/Bar_Z_IntervalSize)*Bar_Z_IntervalSize}')

cubit.cmd('create radialmesh \
numZ 1 zblock 1 {L_Specimen} interval {5*Mesh_Coarse} \
numR 2 trisection \
rblock 1 {R1_Specimen} interval {ceil(Num_R_Interval_Spec/2)} \
rblock 2 {R_Specimen} interval  {Num_R_Interval_Spec - ceil(Num_R_Interval_Spec/2)} \
numA 1 span 90 ablock 1 interval {ceil(Num_R_Interval_Spec/2)}')
cubit.cmd('volume 1 rename \'specimen\'')
cubit.cmd('specimen move 0 0 {-L_Specimen/2}')
cubit.cmd('#S:{S=IntNum(4)}')

cubit.cmd('create radialmesh \
numZ 2 zblock 1 {L_IB-4*Gauge_Loc} interval 2500 last size {Bar_Z_IntervalSize} \
zblock 2 {L_IB} first size {Bar_Z_IntervalSize} \
numR 2 trisection \
rblock 1 {R1_IB} interval {ceil(Num_R_Interval_Bar/2)} \
rblock 2 {R_IB} interval {Num_R_Interval_Bar - ceil(Num_R_Interval_Bar/2)} \
numA 1 span 90 ablock 1 interval {ceil(Num_R_Interval_Bar/2)}')
cubit.cmd('volume 2 3 rename \'IB\'')
cubit.cmd('volume IB IB@A move 0 0 {-(L_IB+L_Specimen/2)}')
cubit.cmd('#IB1:{IB1=IntNum(25)}')
cubit.cmd('#IB2:{IB2=IntNum(16)}')

cubit.cmd('create radialmesh \
numZ 2 zblock 1 {4*Gauge_Loc} first size {Bar_Z_IntervalSize} \
zblock 2 {L_TB} first size {Bar_Z_IntervalSize} last size {2*Bar_Z_IntervalSize} \
numR 2 trisection \
rblock 1 {R1_IB} interval {ceil(Num_R_Interval_Bar/2)} \
rblock 2 {R_IB} interval {Num_R_Interval_Bar - ceil(Num_R_Interval_Bar/2)} \
numA 1 span 90 ablock 1 interval {ceil(Num_R_Interval_Bar/2)}')
cubit.cmd('volume 4 5 rename \'TB\'')
cubit.cmd('TB TB@A move 0 0 {L_Specimen/2}')
cubit.cmd('#TB1:{TB1=IntNum(31)}')

cubit.cmd('reset block')
cubit.cmd('block 1 specimen')
cubit.cmd('block 2 IB IB@A')
cubit.cmd('block 3 TB TB@A')
cubit.cmd('block 1 2 3 element type HEX8')
cubit.cmd('reset nodeset')
cubit.cmd('nodeset 1 TopSurfTriSection0@A')
cubit.cmd('nodeset 2 BottomSurfTriSection0@A')
cubit.cmd('reset sideset')
cubit.cmd('sideset 1 BottomSurfTriSection0@B #TB end - nonreflecting boundary')
cubit.cmd('# remember to add Front- and Back- SurfTrisection1/2/3 depending on number of IB, TB blocks')
cubit.cmd('sideset 2 BackSurfTriSection0 BackSurfTriSection0@A BackSurfTriSection0@B BackSurfTriSection1 BackSurfTriSection1@A #X-disp constraint')
cubit.cmd('sideset 3 FrontSurfTriSection0@A FrontSurfTriSection1 FrontSurfTriSection0 FrontSurfTriSection0@B FrontSurfTriSection1@A #Y-disp constraint')
cubit.cmd('sideset 4 BottomSurfTriSection0@A #S-IB:IB')
cubit.cmd('sideset 5 TopSurfTriSection0 #S-IB:S')
cubit.cmd('sideset 6 BottomSurfTriSection0 #S-TB:S')
cubit.cmd('sideset 7 TopSurfTriSection0@B #S-TB:TB')
cubit.cmd('echo on')
cubit.cmd('comment {S} {IB1} {IB2} {TB1}') 
cubit.cmd('export genesis "/usr/people/jfitzpat/quarter_geometry/mesh/95bar55spec/qtr1800fineR550_2.g" dimension 3 block all nodeset all sideset all overwrite')

