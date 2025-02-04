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
sample_plot = [1];

slash = filesep;
file = dir([data_folder slash '*.xlsx']); % select only txt files (raw data)

cd(file.folder)
NE_HPPC = readtable('NE_MCT25oC_HPPC25oC_OCV_KENTECH_송부.xlsx','Sheet','HPPC_25oC','NumHeaderLines',n_hd,'readVariableNames',0);
NE_HPPC.SOC = NE_OCV.Var1;
NE_OCV.V = NE_OCV.Var2;
NE_OCV.BSA = NE_OCV.Var3;
% NE_OCV(:,1:3) = [];

% save_fullpath = [save_path slash file.name(1:end-4) '.mat'];
% save(save_fullpath,'NE_OCV')


