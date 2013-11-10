R_IB = R_IB
R_Spec = R_Spec
Bar_mesh_coarse = Bar_mesh_coarse
Spec_mesh_coarse = Spec_mesh_coarse
path0 = 'path'
Spec_LD = Spec_LD

Bar_Z_IntervalSize = ceil(1e6*2*R_Spec*Spec_LD)*1e-6/(5+4*(Bar_mesh_coarse-1));
Num_R_Interval_Bar = floor(R_IB/(ceil(1e6*2*R_Spec*Spec_LD)*1e-6/(5+4*(Bar_mesh_coarse-1))));
Num_R_Interval_Spec = floor(R_Spec/(ceil(1e6*2*R_Spec*Spec_LD)*1e-6/(5+4*(Spec_mesh_coarse-1))));
%%
cd(path0)

%Cannot "read in" sample batch number; must be edited into variable name or
%updated in this script.

%%
%Get folder listing within current directory
j=1;
basepath = {pwd};
listing = dir;
datadir = cell(1, sum(cell2mat({listing.isdir}))-2);
for i=3:1:length(listing)
    if listing(i).isdir == 1
%         datadir{j} = strcat(basepath, '\',{listing(i).name});
        datadir{j} = strcat(basepath, '/',{listing(i).name}); %unix systems use forward slashes.
        j=j+1;
    end
end
clear i j listing
%%
time_vectorJOBNUM = importdata('tsteps.csv',',')
%%
ts_length = length(time_vectorJOBNUM) %
sampleJOBNUM = struct('spec_xsec', ...
    struct('header',{'sxx, syy, szz, sxy, syz, szx, vx, vy, vz, ax, ay, az, w, lzz, u, lxx, lxx_dot, lzz_dot, lxy, lyy, lyz, lzx, R_xx, R_yy, R_zz, R_xy, R_yz, R_zx, R_yx, R_zy, R_xz, X, Y, Z,  p, V, ux(c), uz(c), az(c), X_c, Y_c, Z_c'}, ...
       'front_face', zeros([Num_R_Interval_Spec+1, 42, ts_length]), 'mid_specimen', zeros([Num_R_Interval_Spec+1, 42, ts_length]), ...
       'back_face', zeros([Num_R_Interval_Spec+1, 42, ts_length]), 'quarter', zeros([Num_R_Interval_Spec+1, 42, ts_length]), ...
       'three_quarter', zeros([Num_R_Interval_Spec+1, 42, ts_length])), ...
    'bar_spec_intrfc', ...
    struct('header', {'w, vz, az, lzz, az_centr, X, Y, Z, X_centr, Y_centr, Z_centr'}, ...
       'ib', zeros([Num_R_Interval_Bar+1, 12, ts_length]), 'tb', zeros([Num_R_Interval_Bar+1, 12, ts_length]) ), ...
    'bar_gauge_loc', ...
    struct('header', {'sxx, syy, szz, sxy, syz, szx, vx, vy, vz, ax, ay, az, X, Y, Z, p'}, ...
        'ib', zeros([Num_R_Interval_Bar+1, 16, ts_length]), 'tb', zeros([Num_R_Interval_Bar+1, 16, ts_length]) ) );
%%
tic
for i=1:1:length(datadir)
    datapath = char(datadir{i});
    cd(datapath)
%     subdir = strfind(datapath, '\');
    subdir = strfind(datapath, '/');
    switch datapath(subdir(end)+1:length(datapath))
        case 'spec_xsec'
            file_query = {'S_front_c.*.csv','S_back_c.*.csv','S_front.*.csv', 'S_quarter.*.csv','S_mid.*.csv', 'S_three_quarter.*.csv','S_back.*.csv'};
        case 'bar_spec_intrfc'
            file_query = {'S_IB.*.csv','S_TB.*.csv', 'S_IB_c.*.csv', 'S_TB_c.*.csv'};
        case 'bar_gauge_loc'
            file_query = {'IB_sg.*.csv', 'TB_sg.*.csv'};
        otherwise
            file_query = {''};
    end
    
    for j=1:1:length(file_query)
    	filelist = dir(file_query{j});
        filenames = {filelist.name}';
    
        k = 1;
        while k < length(filenames)+1
            t_loc = findstr(filenames{k}, '.');
            t=str2num(filenames{k}(t_loc(1)+1:t_loc(2)-1)); %parse timestep number from filename
            import = importdata(filenames{k}, ',', 1); %file parsed into data, textdata, colheaders
            switch file_query{j}
                case 'S_front_c.*.csv'
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,40:42,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,39,t+1)=import.data(1:Num_R_Interval_Spec+1,6); %az
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,37:38,t+1)=import.data(1:Num_R_Interval_Spec+1,1:2:3);%ux, uz
                case 'S_front.*.csv'
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,1:3,t+1)=import.data(1:Num_R_Interval_Spec+1,26:28); %sxx,syy,szz
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,4:6,t+1)=import.data(1:Num_R_Interval_Spec+1,29:31); %sxy,syz,szx
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,7:9,t+1)=import.data(1:Num_R_Interval_Spec+1,7:9);%vx,vy,vz
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,10:12,t+1)=import.data(1:Num_R_Interval_Spec+1,4:6); %ax,ay,az
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,13,t+1)=import.data(1:Num_R_Interval_Spec+1,3);%w
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,14,t+1)=import.data(1:Num_R_Interval_Spec+1,13);%lzz
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,15,t+1)=import.data(1:Num_R_Interval_Spec+1,1);%u
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,16,t+1)=import.data(1:Num_R_Interval_Spec+1,11);%lxx
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,17:18,t+1)=import.data(1:Num_R_Interval_Spec+1,32:33);%lxx_dot, lzz_dot
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,19,t+1)=import.data(1:Num_R_Interval_Spec+1,14);%lxy
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,20,t+1)=import.data(1:Num_R_Interval_Spec+1,12);%lyy
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,21:22,t+1)=import.data(1:Num_R_Interval_Spec+1,15:16);%lyz, lzx
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,23:31,t+1)=import.data(1:Num_R_Interval_Spec+1,17:25);%R_xx, R_yy, R_zz, R_xy, R_yz, R_zx, R_yx, R_zy, R_xz
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,32:34,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,35,t+1)=import.data(1:Num_R_Interval_Spec+1,10); % p                 
                    sampleJOBNUM.spec_xsec.front_face(1:Num_R_Interval_Spec+1,36,t+1)=import.data(1:Num_R_Interval_Spec+1,34); % V                 
                case 'S_quarter.*.csv'
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,1:3,t+1)=import.data(1:Num_R_Interval_Spec+1,26:28); %sxx,syy,szz
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,4:6,t+1)=import.data(1:Num_R_Interval_Spec+1,29:31); %sxy,syz,szx
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,7:9,t+1)=import.data(1:Num_R_Interval_Spec+1,7:9);%vx,vy,vz
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,10:12,t+1)=import.data(1:Num_R_Interval_Spec+1,4:6); %ax,ay,az
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,13,t+1)=import.data(1:Num_R_Interval_Spec+1,3);%w
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,14,t+1)=import.data(1:Num_R_Interval_Spec+1,13);%lzz
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,15,t+1)=import.data(1:Num_R_Interval_Spec+1,1);%u
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,16,t+1)=import.data(1:Num_R_Interval_Spec+1,11);%lxx
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,17:18,t+1)=import.data(1:Num_R_Interval_Spec+1,32:33);%lxx_dot, lzz_dot
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,19,t+1)=import.data(1:Num_R_Interval_Spec+1,14);%lxy
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,20,t+1)=import.data(1:Num_R_Interval_Spec+1,12);%lyy
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,21:22,t+1)=import.data(1:Num_R_Interval_Spec+1,15:16);%lyz, lzx
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,23:31,t+1)=import.data(1:Num_R_Interval_Spec+1,17:25);%R_xx, R_yy, R_zz, R_xy, R_yz, R_zx, R_yx, R_zy, R_xz
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,32:34,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,35,t+1)=import.data(1:Num_R_Interval_Spec+1,10); % p                 
                    sampleJOBNUM.spec_xsec.quarter(1:Num_R_Interval_Spec+1,36,t+1)=import.data(1:Num_R_Interval_Spec+1,34); % V  
                case 'S_mid.*.csv'
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,1:3,t+1)=import.data(1:Num_R_Interval_Spec+1,26:28); %sxx,syy,szz
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,4:6,t+1)=import.data(1:Num_R_Interval_Spec+1,29:31); %sxy,syz,szx
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,7:9,t+1)=import.data(1:Num_R_Interval_Spec+1,7:9);%vx,vy,vz
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,10:12,t+1)=import.data(1:Num_R_Interval_Spec+1,4:6); %ax,ay,az
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,13,t+1)=import.data(1:Num_R_Interval_Spec+1,3);%w
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,14,t+1)=import.data(1:Num_R_Interval_Spec+1,13);%lzz
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,15,t+1)=import.data(1:Num_R_Interval_Spec+1,1);%u
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,16,t+1)=import.data(1:Num_R_Interval_Spec+1,11);%lxx
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,17:18,t+1)=import.data(1:Num_R_Interval_Spec+1,32:33);%lxx_dot, lzz_dot
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,19,t+1)=import.data(1:Num_R_Interval_Spec+1,14);%lxy
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,20,t+1)=import.data(1:Num_R_Interval_Spec+1,12);%lyy
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,21:22,t+1)=import.data(1:Num_R_Interval_Spec+1,15:16);%lyz, lzx
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,23:31,t+1)=import.data(1:Num_R_Interval_Spec+1,17:25);%R_xx, R_yy, R_zz, R_xy, R_yz, R_zx, R_yx, R_zy, R_xz
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,32:34,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,35,t+1)=import.data(1:Num_R_Interval_Spec+1,10); % p                 
                    sampleJOBNUM.spec_xsec.mid_specimen(1:Num_R_Interval_Spec+1,36,t+1)=import.data(1:Num_R_Interval_Spec+1,34); % V  
                case 'S_three_quarter.*.csv'
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,1:3,t+1)=import.data(1:Num_R_Interval_Spec+1,26:28); %sxx,syy,szz
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,4:6,t+1)=import.data(1:Num_R_Interval_Spec+1,29:31); %sxy,syz,szx
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,7:9,t+1)=import.data(1:Num_R_Interval_Spec+1,7:9);%vx,vy,vz
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,10:12,t+1)=import.data(1:Num_R_Interval_Spec+1,4:6); %ax,ay,az
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,13,t+1)=import.data(1:Num_R_Interval_Spec+1,3);%w
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,14,t+1)=import.data(1:Num_R_Interval_Spec+1,13);%lzz
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,15,t+1)=import.data(1:Num_R_Interval_Spec+1,1);%u
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,16,t+1)=import.data(1:Num_R_Interval_Spec+1,11);%lxx
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,17:18,t+1)=import.data(1:Num_R_Interval_Spec+1,32:33);%lxx_dot, lzz_dot
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,19,t+1)=import.data(1:Num_R_Interval_Spec+1,14);%lxy
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,20,t+1)=import.data(1:Num_R_Interval_Spec+1,12);%lyy
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,21:22,t+1)=import.data(1:Num_R_Interval_Spec+1,15:16);%lyz, lzx
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,23:31,t+1)=import.data(1:Num_R_Interval_Spec+1,17:25);%R_xx, R_yy, R_zz, R_xy, R_yz, R_zx, R_yx, R_zy, R_xz
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,32:34,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,35,t+1)=import.data(1:Num_R_Interval_Spec+1,10); % p                 
                    sampleJOBNUM.spec_xsec.three_quarter(1:Num_R_Interval_Spec+1,36,t+1)=import.data(1:Num_R_Interval_Spec+1,34); % V  
                case 'S_back_c.*.csv'
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,40:42,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,39,t+1)=import.data(1:Num_R_Interval_Spec+1,6); %az
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,37:38,t+1)=import.data(1:Num_R_Interval_Spec+1,1:2:3);%ux, uz
                case 'S_back.*.csv'
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,1:3,t+1)=import.data(1:Num_R_Interval_Spec+1,26:28); %sxx,syy,szz
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,4:6,t+1)=import.data(1:Num_R_Interval_Spec+1,29:31); %sxy,syz,szx
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,7:9,t+1)=import.data(1:Num_R_Interval_Spec+1,7:9);%vx,vy,vz
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,10:12,t+1)=import.data(1:Num_R_Interval_Spec+1,4:6); %ax,ay,az
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,13,t+1)=import.data(1:Num_R_Interval_Spec+1,3);%w
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,14,t+1)=import.data(1:Num_R_Interval_Spec+1,13);%lzz
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,15,t+1)=import.data(1:Num_R_Interval_Spec+1,1);%u
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,16,t+1)=import.data(1:Num_R_Interval_Spec+1,11);%lxx
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,17:18,t+1)=import.data(1:Num_R_Interval_Spec+1,32:33);%lxx_dot, lzz_dot
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,19,t+1)=import.data(1:Num_R_Interval_Spec+1,14);%lxy
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,20,t+1)=import.data(1:Num_R_Interval_Spec+1,12);%lyy
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,21:22,t+1)=import.data(1:Num_R_Interval_Spec+1,15:16);%lyz, lzx
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,23:31,t+1)=import.data(1:Num_R_Interval_Spec+1,17:25);%R_xx, R_yy, R_zz, R_xy, R_yz, R_zx, R_yx, R_zy, R_xz
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,32:34,t+1)=import.data(1:Num_R_Interval_Spec+1,38:40); % X, Y, Z                    
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,35,t+1)=import.data(1:Num_R_Interval_Spec+1,10); % p                 
                    sampleJOBNUM.spec_xsec.back_face(1:Num_R_Interval_Spec+1,36,t+1)=import.data(1:Num_R_Interval_Spec+1,34); % V  
                case 'S_IB.*.csv'
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,1,t+1)=import.data(1:Num_R_Interval_Bar+1,3); %w
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,2,t+1)=import.data(1:Num_R_Interval_Bar+1,9);%vz
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,3,t+1)=import.data(1:Num_R_Interval_Bar+1,6);%az
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,4,t+1)=import.data(1:Num_R_Interval_Bar+1,11);%lzz
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,6:8,t+1)=import.data(1:Num_R_Interval_Bar+1,18:20);%X, Y, Z
                case 'S_IB_c.*.csv'
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,5,t+1)=import.data(1:Num_R_Interval_Bar+1,3); %a_z_centr
                    sampleJOBNUM.bar_spec_intrfc.ib(1:Num_R_Interval_Bar+1,9:11,t+1)=import.data(1:Num_R_Interval_Bar+1,7:9);%X_centr, Y_centr, Z_centr                  
                case 'S_TB.*.csv' 
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,1,t+1)=import.data(1:Num_R_Interval_Bar+1,3); %w
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,2,t+1)=import.data(1:Num_R_Interval_Bar+1,9);%vz
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,3,t+1)=import.data(1:Num_R_Interval_Bar+1,6);%az
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,4,t+1)=import.data(1:Num_R_Interval_Bar+1,11);%lzz
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,6:8,t+1)=import.data(1:Num_R_Interval_Bar+1,18:20);%X, Y, Z
                case 'S_TB_c.*.csv'
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,5,t+1)=import.data(1:Num_R_Interval_Bar+1,3); %a_z_centr
                    sampleJOBNUM.bar_spec_intrfc.tb(1:Num_R_Interval_Bar+1,9:11,t+1)=import.data(1:Num_R_Interval_Bar+1,7:9);%X_centr, Y_centr, Z_centr                  
                case 'IB_sg.*.csv'
                    sampleJOBNUM.bar_gauge_loc.ib(1:Num_R_Interval_Bar+1,1:3,t+1)=import.data(1:Num_R_Interval_Bar+1,12:14);%sxx,syy,szz
                    sampleJOBNUM.bar_gauge_loc.ib(1:Num_R_Interval_Bar+1,7:9,t+1)=import.data(1:Num_R_Interval_Bar+1,7:9);%vx,vy,vz                   
                    sampleJOBNUM.bar_gauge_loc.ib(1:Num_R_Interval_Bar+1,10:12,t+1)=import.data(1:Num_R_Interval_Bar+1,4:6);%ax,ay,az
                    sampleJOBNUM.bar_gauge_loc.ib(1:Num_R_Interval_Bar+1,13:15,t+1)=import.data(1:Num_R_Interval_Bar+1,18:20);%X,Y,Z
                    sampleJOBNUM.bar_gauge_loc.ib(1:Num_R_Interval_Bar+1,16,t+1)=import.data(1:Num_R_Interval_Bar+1,15);% V
                case 'TB_sg.*.csv'
                    sampleJOBNUM.bar_gauge_loc.tb(1:Num_R_Interval_Bar+1,1:3,t+1)=import.data(1:Num_R_Interval_Bar+1,12:14);%sxx,syy,szz
                    sampleJOBNUM.bar_gauge_loc.tb(1:Num_R_Interval_Bar+1,7:9,t+1)=import.data(1:Num_R_Interval_Bar+1,7:9);%vx,vy,vz                   
                    sampleJOBNUM.bar_gauge_loc.tb(1:Num_R_Interval_Bar+1,10:12,t+1)=import.data(1:Num_R_Interval_Bar+1,4:6);%ax,ay,az
                    sampleJOBNUM.bar_gauge_loc.tb(1:Num_R_Interval_Bar+1,13:15,t+1)=import.data(1:Num_R_Interval_Bar+1,18:20);%X,Y,Z
                    sampleJOBNUM.bar_gauge_loc.tb(1:Num_R_Interval_Bar+1,16,t+1)=import.data(1:Num_R_Interval_Bar+1,15);% V
           end
            k=k+1;
        end
        
    end
    
end
toc
clear filelist filenames file_query
save(strcat(basepath{1},'/','sampleJOBNUM.mat'))
