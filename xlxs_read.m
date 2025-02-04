clc;clear;close all

data_folder = 'G:\공유 드라이브\GSP_Data\driving_sample';

% Split the path using the directory separator
splitPath = split(data_folder, filesep);

% Find the index of "Data" (to be replaced)
index = find(strcmp('driving_sample',splitPath), 1);

% Replace the first "Data" with "Processed_Data"
splitPath{index} = 'driving_sample';

% Create the new save_path
save_path = strjoin(splitPath, filesep);

% Create the directory if it doesn't exist
if ~exist(save_path, 'dir')
   mkdir(save_path)
end

I_1C = 55.6;
n_hd = 2; 


slash = filesep;
file = dir([data_folder slash '*.xlsx']); % select only txt files (raw data)

cd(file.folder)
NE_HPPC = readtable('NE_MCT25oC_HPPC25oC_OCV_KENTECH_송부.xlsx','Sheet','HPPC_25oC','NumHeaderLines',n_hd,'readVariableNames',0);
data1.I = NE_HPPC.Var7;
data1.V = NE_HPPC.Var6;
data1.t1 = NE_HPPC.Var4; %step time
data1.t2 = NE_HPPC.Var5; %total time
data1.cap = NE_HPPC.Var8;
data1.T = NE_HPPC.Var11;

 % datetime
 if isduration(data1.t2(1))
    data1.t = seconds(data1.t2);
 else
    data1.t = data1.t2;
 end

 % absolute current
 data1.I_abs = abs(data1.I);

 % type
 data1.type = char(zeros([length(data1.t),1]));
 data1.type(data1.I>0) = 'C';
 data1.type(data1.I==0) = 'R';
 data1.type(data1.I<0) = 'D';


 % step
 data1_length = length(data1.t);
 data1.step = zeros(data1_length,1);
 m  =1;
 data1.step(1) = m;
 for j = 2:data1_length
    if data1.type(j) ~= data1.type(j-1)
       m = m+1;
    end
    data1.step(j) = m;
end

 %  check for error, if any step has more than one types
 vec_step = unique(data1.step);
 num_step = length(vec_step);
 for i_step = 1:num_step
        type_in_step = unique(data1.type(data1.step == vec_step(i_step)));
          
          if size(type_in_step,1) ~=1 || size(type_in_step,2) ~=1
              disp('ERROR: step assignent is not unique for a step')
              return
          end
     end












% NE_OCV(:,1:3) = [];

% save_fullpath = [save_path slash file.name(1:end-4) '.mat'];
% save(save_fullpath,'NE_OCV')


